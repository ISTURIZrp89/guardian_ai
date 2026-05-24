// lib/modules/ai/data/services/llama_service.dart
//
// Motor de inferencia local con llama.cpp usando un Isolate persistente.
// El modelo se carga UNA VEZ en el background isolate y permanece en memoria.
// La UI nunca se bloquea: los prompts viajan por SendPort/ReceivePort.

import 'dart:async';
import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import '../native/llama_ffi.dart';

// ══════════════════════════════════════════════════════════════
//  Protocolo de mensajes entre el hilo principal y el Isolate
// ══════════════════════════════════════════════════════════════

/// Envuelve cualquier solicitud al isolate con su puerto de respuesta.
class _Request {
  final dynamic    payload;
  final SendPort   replyTo;
  _Request(this.payload, this.replyTo);
}

/// Solicitudes específicas (payloads)
class _LoadPayload {
  final String modelPath;
  final int    nCtx;
  final int    nThreads;
  _LoadPayload(this.modelPath, this.nCtx, this.nThreads);
}

class _GeneratePayload {
  final String prompt;
  final int    maxTokens;
  final double temperature;
  _GeneratePayload(this.prompt, this.maxTokens, this.temperature);
}

class _UnloadPayload  {}
class _DisposePayload {}

/// Respuesta del isolate al hilo principal.
class _LlamaResult {
  final bool    success;
  final String  text;
  final String? error;
  const _LlamaResult({required this.success, this.text = '', this.error});
}

// ══════════════════════════════════════════════════════════════
//  Punto de entrada del Isolate de llama.cpp
// ══════════════════════════════════════════════════════════════

void _isolateEntryPoint(SendPort handshakePort) {
  final ffi = LlamaFFI.instance;
  ffi.initBackend();

  // Anunciamos al hilo principal nuestro ReceivePort
  final receivePort = ReceivePort();
  handshakePort.send(receivePort.sendPort);

  // Estado local del isolate: el puntero al modelo cargado
  Pointer<Void>? session;

  receivePort.listen((message) {
    if (message is! _Request) return;
    final req = message;

    if (req.payload is _LoadPayload) {
      final p = req.payload as _LoadPayload;
      // Liberar modelo previo
      if (session != null) {
        ffi.freeSession(session!);
        session = null;
      }
      final pathPtr = p.modelPath.toNativeUtf8();
      try {
        final ptr = ffi.loadModel(pathPtr, p.nCtx, p.nThreads);
        if (ptr.address != 0) {
          session = ptr;
          req.replyTo.send(const _LlamaResult(success: true));
        } else {
          req.replyTo.send(const _LlamaResult(
              success: false, error: 'No se pudo cargar el modelo'));
        }
      } finally {
        calloc.free(pathPtr);
      }

    } else if (req.payload is _GeneratePayload) {
      final p = req.payload as _GeneratePayload;
      if (session == null) {
        req.replyTo.send(const _LlamaResult(
            success: false, error: 'Ningún modelo cargado'));
        return;
      }
      final promptPtr = p.prompt.toNativeUtf8();
      try {
        final resultPtr = ffi.generate(
            session!, promptPtr, p.maxTokens, p.temperature);
        if (resultPtr.address == 0) {
          req.replyTo.send(const _LlamaResult(
              success: false, error: 'Error al generar respuesta'));
        } else {
          final text = resultPtr.toDartString();
          ffi.freeString(resultPtr);
          req.replyTo.send(_LlamaResult(success: true, text: text));
        }
      } finally {
        calloc.free(promptPtr);
      }

    } else if (req.payload is _UnloadPayload) {
      if (session != null) { ffi.freeSession(session!); session = null; }
      req.replyTo.send(const _LlamaResult(success: true));

    } else if (req.payload is _DisposePayload) {
      if (session != null) { ffi.freeSession(session!); session = null; }
      ffi.freeBackend();
      req.replyTo.send(const _LlamaResult(success: true));
      receivePort.close();
    }
  });
}

// ══════════════════════════════════════════════════════════════
//  Servicio público — API limpia para el resto de la app
// ══════════════════════════════════════════════════════════════

class LlamaService {
  Isolate?   _isolate;
  SendPort?  _toIsolate;
  bool       _isModelLoaded   = false;
  String?    _loadedModelPath;

  static final LlamaService _instance = LlamaService._();
  static LlamaService get instance => _instance;
  LlamaService._();

  bool    get isModelLoaded   => _isModelLoaded;
  String? get loadedModelPath => _loadedModelPath;

  // ── Ciclo de vida del isolate ─────────────────────────────────

  Future<void> _ensureIsolateRunning() async {
    if (_isolate != null) return;
    if (!LlamaFFI.isSupported) return;

    final handshake = ReceivePort();
    _isolate     = await Isolate.spawn(_isolateEntryPoint, handshake.sendPort);
    _toIsolate   = await handshake.first as SendPort;
    handshake.close();
  }

  /// Envía un payload al isolate y espera la respuesta sin bloquear la UI.
  Future<_LlamaResult> _call(dynamic payload) async {
    final reply = ReceivePort();
    _toIsolate!.send(_Request(payload, reply.sendPort));
    final result = await reply.first as _LlamaResult;
    reply.close();
    return result;
  }

  // ── API pública ───────────────────────────────────────────────

  /// Carga un modelo GGUF en el background isolate.
  ///
  /// [modelPath]  Ruta completa al archivo .gguf descargado por Dio.
  /// [nCtx]       Ventana de contexto en tokens (2048 recomendado para móviles).
  /// [nThreads]   Hilos de CPU (4 es un buen equilibrio en dispositivos móviles).
  Future<bool> loadModel({
    required String modelPath,
    int nCtx     = 2048,
    int nThreads = 4,
  }) async {
    if (!LlamaFFI.isSupported) return false;
    await _ensureIsolateRunning();

    final result = await _call(_LoadPayload(modelPath, nCtx, nThreads));
    _isModelLoaded   = result.success;
    _loadedModelPath = result.success ? modelPath : null;
    return result.success;
  }

  /// Genera una respuesta médica real con el modelo cargado.
  ///
  /// [temperature] recomendada: 0.2-0.4 para contexto clínico (respuestas precisas).
  Future<String> generate({
    required String prompt,
    int    maxTokens  = 512,
    double temperature = 0.3,
  }) async {
    if (!_isModelLoaded) {
      throw StateError('No hay modelo cargado. Llama loadModel() primero.');
    }
    if (!LlamaFFI.isSupported) {
      throw UnsupportedError('Inferencia nativa no disponible en esta plataforma.');
    }

    final result = await _call(_GeneratePayload(prompt, maxTokens, temperature));
    if (!result.success) throw Exception(result.error ?? 'Error de inferencia');
    return result.text;
  }

  /// Libera el modelo de RAM (~3-9 GB) sin cerrar el isolate.
  Future<void> unloadModel() async {
    if (_toIsolate == null) return;
    await _call(_UnloadPayload());
    _isModelLoaded   = false;
    _loadedModelPath = null;
  }

  /// Libera TODOS los recursos al cerrar la app (llamar desde AppLifecycleState.detached).
  Future<void> dispose() async {
    if (_toIsolate != null) {
      await _call(_DisposePayload());
      await Future.delayed(const Duration(milliseconds: 100));
    }
    _isolate?.kill(priority: Isolate.immediate);
    _isolate         = null;
    _toIsolate       = null;
    _isModelLoaded   = false;
    _loadedModelPath = null;
  }
}
