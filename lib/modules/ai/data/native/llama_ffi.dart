// lib/modules/ai/data/native/llama_ffi.dart
//
// Bindings de Dart FFI a la librería nativa libguardian_llama.so
// Este archivo define las firmas de las funciones C para que Dart pueda llamarlas.

import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ── Tipos nativos ─────────────────────────────────────────────────

// void guardian_llama_backend_init()
typedef _BackendInitC    = Void Function();
typedef BackendInitDart  = void Function();

// void guardian_llama_backend_free()
typedef _BackendFreeC    = Void Function();
typedef BackendFreeDart  = void Function();

// void* guardian_load_model(const char* path, int32_t n_ctx, int32_t n_threads)
typedef _LoadModelC = Pointer<Void> Function(
    Pointer<Utf8>, Int32, Int32);
typedef LoadModelDart = Pointer<Void> Function(
    Pointer<Utf8>, int, int);

// char* guardian_generate(void* session, const char* prompt, int32_t max_tokens, float temp)
typedef _GenerateC = Pointer<Utf8> Function(
    Pointer<Void>, Pointer<Utf8>, Int32, Float);
typedef GenerateDart = Pointer<Utf8> Function(
    Pointer<Void>, Pointer<Utf8>, int, double);

// void guardian_free_string(char* str)
typedef _FreeStringC    = Void Function(Pointer<Utf8>);
typedef FreeStringDart  = void Function(Pointer<Utf8>);

// void guardian_free_session(void* session)
typedef _FreeSessionC   = Void Function(Pointer<Void>);
typedef FreeSessionDart = void Function(Pointer<Void>);

// ── Cargador de librería ──────────────────────────────────────────

class LlamaFFI {
  late final DynamicLibrary _lib;

  late final BackendInitDart  backendInit;
  late final BackendFreeDart  backendFree;
  late final LoadModelDart    loadModel;
  late final GenerateDart     generate;
  late final FreeStringDart   freeString;
  late final FreeSessionDart  freeSession;

  static LlamaFFI? _instance;
  static bool _initialized = false;

  LlamaFFI._() {
    _lib = _loadLibrary();

    backendInit = _lib
        .lookup<NativeFunction<_BackendInitC>>('guardian_llama_backend_init')
        .asFunction<BackendInitDart>();

    backendFree = _lib
        .lookup<NativeFunction<_BackendFreeC>>('guardian_llama_backend_free')
        .asFunction<BackendFreeDart>();

    loadModel = _lib
        .lookup<NativeFunction<_LoadModelC>>('guardian_load_model')
        .asFunction<LoadModelDart>();

    generate = _lib
        .lookup<NativeFunction<_GenerateC>>('guardian_generate')
        .asFunction<GenerateDart>();

    freeString = _lib
        .lookup<NativeFunction<_FreeStringC>>('guardian_free_string')
        .asFunction<FreeStringDart>();

    freeSession = _lib
        .lookup<NativeFunction<_FreeSessionC>>('guardian_free_session')
        .asFunction<FreeSessionDart>();
  }

  static LlamaFFI get instance {
    _instance ??= LlamaFFI._();
    return _instance!;
  }

  static bool get isSupported => Platform.isAndroid || Platform.isLinux || Platform.isMacOS;

  DynamicLibrary _loadLibrary() {
    if (Platform.isAndroid) {
      return DynamicLibrary.open('libguardian_llama.so');
    } else if (Platform.isLinux) {
      return DynamicLibrary.open('libguardian_llama.so');
    } else if (Platform.isMacOS) {
      return DynamicLibrary.open('libguardian_llama.dylib');
    } else {
      throw UnsupportedError(
          'Inferencia nativa no soportada en esta plataforma: ${Platform.operatingSystem}');
    }
  }

  void initBackend() {
    if (!_initialized) {
      backendInit();
      _initialized = true;
    }
  }

  void freeBackend() {
    if (_initialized) {
      backendFree();
      _initialized = false;
    }
  }
}
