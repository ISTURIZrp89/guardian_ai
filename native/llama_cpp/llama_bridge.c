/**
 * llama_bridge.c
 *
 * C Wrapper para llama.cpp — expone una API simple con ABI de C puro
 * para que dart:ffi pueda llamarla directamente sin problemas de name mangling.
 *
 * Este archivo actúa como el "puente" entre el mundo de Dart y el C++ de llama.cpp.
 * Dart FFI solo puede hablar con C (no C++ directo), por eso este wrapper es necesario.
 */

#include "llama.h"
#include "common.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* ─── Estructuras internas ───────────────────────────────────── */

typedef struct {
    llama_model*   model;
    llama_context* ctx;
    int32_t        n_ctx;
} GuardianSession;

/* ─── API pública (ABI de C puro) ────────────────────────────── */

/** Inicializa llama.cpp una sola vez al arrancar */
void guardian_llama_backend_init(void) {
    llama_backend_init();
}

/** Libera recursos del backend al cerrar */
void guardian_llama_backend_free(void) {
    llama_backend_free();
}

/**
 * Carga un modelo GGUF desde disco.
 * Devuelve un puntero opaco (GuardianSession*) o NULL si falla.
 */
void* guardian_load_model(const char* model_path, int32_t n_ctx, int32_t n_threads) {
    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = 0; // CPU-only para máxima compatibilidad

    llama_model* model = llama_model_load_from_file(model_path, model_params);
    if (model == NULL) {
        fprintf(stderr, "[Guardian] Error: no se pudo cargar el modelo: %s\n", model_path);
        return NULL;
    }

    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx     = n_ctx;
    ctx_params.n_threads = n_threads;
    ctx_params.n_threads_batch = n_threads;

    llama_context* ctx = llama_new_context_with_model(model, ctx_params);
    if (ctx == NULL) {
        llama_model_free(model);
        fprintf(stderr, "[Guardian] Error: no se pudo crear el contexto.\n");
        return NULL;
    }

    GuardianSession* session = (GuardianSession*)malloc(sizeof(GuardianSession));
    session->model = model;
    session->ctx   = ctx;
    session->n_ctx = n_ctx;

    return (void*)session;
}

/**
 * Genera una respuesta completa a un prompt.
 *
 * @param session_ptr  Puntero devuelto por guardian_load_model
 * @param prompt       Texto del prompt médico
 * @param max_tokens   Máximo de tokens a generar
 * @param temperature  Temperatura (0.0 = determinista, 1.0 = creativo)
 * @return             Texto generado (heap-allocated, liberar con guardian_free_string)
 */
char* guardian_generate(
    void*       session_ptr,
    const char* prompt,
    int32_t     max_tokens,
    float       temperature
) {
    if (session_ptr == NULL || prompt == NULL) return NULL;

    GuardianSession* session = (GuardianSession*)session_ptr;
    llama_model*     model   = session->model;
    llama_context*   ctx     = session->ctx;

    // Tokenizar el prompt
    const int prompt_len  = (int)strlen(prompt);
    const int n_max_tokens = prompt_len / 2 + max_tokens + 64;
    llama_token* tokens = (llama_token*)malloc(n_max_tokens * sizeof(llama_token));

    int n_tokens = llama_tokenize(
        model, prompt, prompt_len, tokens, n_max_tokens,
        /*add_special=*/true, /*parse_special=*/true
    );

    if (n_tokens < 0) {
        free(tokens);
        return NULL;
    }

    // Resetear el contexto KV
    llama_kv_cache_clear(ctx);

    // Crear el lote de tokens de entrada
    llama_batch batch = llama_batch_get_one(tokens, n_tokens);
    if (llama_decode(ctx, batch) != 0) {
        free(tokens);
        return NULL;
    }

    // Buffer de salida
    size_t out_size = (size_t)(max_tokens * 8);
    char*  output   = (char*)calloc(out_size, 1);
    size_t out_pos  = 0;

    // Parámetros de muestreo
    llama_sampler* sampler = llama_sampler_chain_init(llama_sampler_chain_default_params());
    llama_sampler_chain_add(sampler, llama_sampler_init_temp(temperature));
    llama_sampler_chain_add(sampler, llama_sampler_init_dist(0));

    // Generar tokens
    for (int i = 0; i < max_tokens; i++) {
        llama_token new_token = llama_sampler_sample(sampler, ctx, -1);

        // Token de fin de secuencia
        if (llama_token_is_eog(model, new_token)) break;

        // Decodificar token a texto
        char piece[32] = {0};
        int  piece_len = llama_token_to_piece(model, new_token, piece, sizeof(piece), 0, true);
        if (piece_len < 0) break;

        // Agregar al buffer de salida
        if (out_pos + piece_len + 1 < out_size) {
            memcpy(output + out_pos, piece, piece_len);
            out_pos += piece_len;
        }

        // Procesar el nuevo token para el siguiente ciclo
        llama_batch next = llama_batch_get_one(&new_token, 1);
        if (llama_decode(ctx, next) != 0) break;
    }

    llama_sampler_free(sampler);
    free(tokens);
    return output;
}

/** Libera el string devuelto por guardian_generate */
void guardian_free_string(char* str) {
    if (str != NULL) free(str);
}

/** Libera la sesión completa del modelo */
void guardian_free_session(void* session_ptr) {
    if (session_ptr == NULL) return;
    GuardianSession* session = (GuardianSession*)session_ptr;
    llama_free(session->ctx);
    llama_model_free(session->model);
    free(session);
}
