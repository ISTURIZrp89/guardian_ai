/**
 * llama_bridge.cpp
 *
 * Wrapper C++ para llama.cpp (API actualizada para llama.cpp >= b5000).
 * Exporta funciones con ABI de C puro (extern "C") para dart:ffi.
 *
 * Cambios de API en llama.cpp moderno:
 *  - llama_new_context_with_model() → llama_init_from_model()
 *  - llama_tokenize(model, ...) → llama_tokenize(vocab, ...)
 *  - llama_token_is_eog(model, ...) → llama_vocab_is_eog(vocab, ...)
 *  - llama_token_to_piece(model, ...) → llama_token_to_piece(vocab, ...)
 *  - llama_kv_cache_clear() → llama_kv_self_clear()
 */

#include "llama.h"
#include <cstdlib>
#include <cstring>
#include <cstdio>

/* ─── Estructuras internas ───────────────────────────────────── */

struct GuardianSession {
    llama_model*        model;
    llama_context*      ctx;
    const llama_vocab*  vocab;
    int32_t             n_ctx;
};

/* ─── API pública (ABI de C puro para dart:ffi) ─────────────── */

extern "C" {

void guardian_llama_backend_init(void) {
    llama_backend_init();
}

void guardian_llama_backend_free(void) {
    llama_backend_free();
}

/**
 * Carga un modelo GGUF desde disco.
 * Devuelve puntero opaco (GuardianSession*) o NULL si falla.
 */
void* guardian_load_model(const char* model_path, int32_t n_ctx, int32_t n_threads) {
    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = 0; // CPU-only para máxima compatibilidad móvil

    llama_model* model = llama_model_load_from_file(model_path, model_params);
    if (model == nullptr) {
        fprintf(stderr, "[Guardian] Error cargando modelo: %s\n", model_path);
        return nullptr;
    }

    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx           = static_cast<uint32_t>(n_ctx);
    ctx_params.n_threads       = n_threads;
    ctx_params.n_threads_batch = n_threads;

    // API nueva: llama_init_from_model (reemplaza llama_new_context_with_model)
    llama_context* ctx = llama_init_from_model(model, ctx_params);
    if (ctx == nullptr) {
        llama_model_free(model);
        fprintf(stderr, "[Guardian] Error creando contexto de inferencia.\n");
        return nullptr;
    }

    // Obtener el vocabulario del modelo (necesario para tokenizar)
    const llama_vocab* vocab = llama_model_get_vocab(model);

    auto* session    = new GuardianSession();
    session->model   = model;
    session->ctx     = ctx;
    session->vocab   = vocab;
    session->n_ctx   = n_ctx;

    return static_cast<void*>(session);
}

/**
 * Genera texto a partir de un prompt médico.
 *
 * @param session_ptr  Puntero de guardian_load_model
 * @param prompt       Texto del prompt
 * @param max_tokens   Máximo de tokens a generar
 * @param temperature  0.1-0.4 para uso clínico (preciso), 0.7+ para creativo
 * @return             Texto generado (liberar con guardian_free_string)
 */
char* guardian_generate(
    void*       session_ptr,
    const char* prompt,
    int32_t     max_tokens,
    float       temperature
) {
    if (session_ptr == nullptr || prompt == nullptr) return nullptr;

    auto*               session = static_cast<GuardianSession*>(session_ptr);
    llama_context*      ctx     = session->ctx;
    const llama_vocab*  vocab   = session->vocab;
    llama_model*        model   = session->model;

    // ── Tokenizar ────────────────────────────────────────────────
    const int prompt_len   = static_cast<int>(strlen(prompt));
    const int n_max_tokens = prompt_len / 2 + max_tokens + 64;
    auto* tokens = static_cast<llama_token*>(malloc(n_max_tokens * sizeof(llama_token)));

    // API nueva: llama_tokenize recibe vocab en lugar de model
    int n_tokens = llama_tokenize(
        vocab, prompt, prompt_len, tokens, n_max_tokens,
        /*add_special=*/true, /*parse_special=*/true
    );

    if (n_tokens < 0) {
        free(tokens);
        return nullptr;
    }

    // ── Procesar prompt ──────────────────────────────────────────
    llama_batch batch = llama_batch_get_one(tokens, n_tokens);
    if (llama_decode(ctx, batch) != 0) {
        free(tokens);
        return nullptr;
    }

    // ── Buffer de salida ─────────────────────────────────────────
    const size_t out_size = static_cast<size_t>(max_tokens * 8);
    char*  output   = static_cast<char*>(calloc(out_size, 1));
    size_t out_pos  = 0;

    // ── Muestreador ──────────────────────────────────────────────
    llama_sampler* sampler = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(sampler, llama_sampler_init_temp(temperature));
    llama_sampler_chain_add(sampler, llama_sampler_init_dist(0));

    // ── Generar tokens ───────────────────────────────────────────
    for (int i = 0; i < max_tokens; i++) {
        llama_token new_token = llama_sampler_sample(sampler, ctx, -1);

        // API nueva: llama_vocab_is_eog (reemplaza llama_token_is_eog)
        if (llama_vocab_is_eog(vocab, new_token)) break;

        // API nueva: llama_token_to_piece recibe vocab en lugar de model
        char piece[64] = {0};
        int  piece_len = llama_token_to_piece(vocab, new_token, piece, sizeof(piece), 0, true);
        if (piece_len < 0) break;

        if (out_pos + static_cast<size_t>(piece_len) + 1 < out_size) {
            memcpy(output + out_pos, piece, static_cast<size_t>(piece_len));
            out_pos += static_cast<size_t>(piece_len);
        }

        llama_batch next = llama_batch_get_one(&new_token, 1);
        if (llama_decode(ctx, next) != 0) break;
    }

    llama_sampler_free(sampler);
    free(tokens);
    return output;
}

void guardian_free_string(char* str) {
    if (str != nullptr) free(str);
}

void guardian_free_session(void* session_ptr) {
    if (session_ptr == nullptr) return;
    auto* session = static_cast<GuardianSession*>(session_ptr);
    llama_free(session->ctx);
    llama_model_free(session->model);
    delete session;
}

} // extern "C"
