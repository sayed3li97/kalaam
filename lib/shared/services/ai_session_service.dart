import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genui/genui.dart' hide TextPart, Part;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kalaam/core/config/app_config.dart';
import 'package:kalaam/features/session/catalog/catalog.dart';
import 'package:kalaam/features/session/demo/kalaam_demo.dart';
import 'package:kalaam/features/session/prompt/kalaam_prompt.dart';

part 'ai_session_service.g.dart';

/// Holds an error message and a timestamp for the UI to display.
class SessionError {
  SessionError(this.message, this.timestamp);
  final String message;
  final DateTime timestamp;
}

/// One A2UI message the model emitted, captured for the Live GenUI Inspector.
class A2uiLogEntry {
  A2uiLogEntry({
    required this.kind,
    required this.surfaceId,
    required this.json,
  });
  final String
  kind; // createSurface | updateComponents | updateDataModel | deleteSurface
  final String surfaceId;
  final String json; // pretty-printed
}

/// Owns one live GenUI conversation: the [SurfaceController] (engine), the
/// [A2uiTransportAdapter] (transport) and the [Conversation] (facade).
///
/// The transport's `onSend` streams the conversation to Gemini via `firebase_ai`
/// and feeds the response back through [A2uiTransportAdapter.addChunk]. The
/// model runs in `createAndUpdate(dataModel: true)` mode, so it can both create
/// new surfaces AND update existing ones / the data model in place.
class AiSessionService {
  AiSessionService(String sessionKey) {
    final prompt = buildKalaamSystemPrompt();

    surfaceController = SurfaceController(catalogs: [kalaamCatalog]);

    // Demo Mode replays canned transcripts and never touches Firebase, so the
    // live model is only constructed when actually needed.
    if (!AppConfig.demoMode) {
      _model = FirebaseAI.googleAI().generativeModel(
        model: AppConfig.geminiModel,
        systemInstruction: Content.system(prompt.systemPromptJoined()),
      );
    }

    _transport = A2uiTransportAdapter(onSend: _handleSend);

    // Tap the parsed A2UI stream for the Live GenUI Inspector — this is exactly
    // the sequence of UI commands the model composed.
    _logSub = _transport.incomingMessages.listen(_logMessage);

    conversation = Conversation(
      controller: surfaceController,
      transport: _transport,
    );
    log('AiSessionService created: $sessionKey', name: 'AiSessionService');
  }

  late final GenerativeModel _model;
  late final SurfaceController surfaceController;
  late final A2uiTransportAdapter _transport;
  late final Conversation conversation;
  StreamSubscription<A2uiMessage>? _logSub;

  final List<Content> _chatHistory = [];

  /// Latest error for the session screen to display.
  final ValueNotifier<SessionError?> lastError = ValueNotifier(null);

  /// Live feed of A2UI messages the model has emitted (for the Inspector).
  final ValueNotifier<List<A2uiLogEntry>> a2uiLog = ValueNotifier([]);

  /// The surfaceId the session screen should briefly highlight, set when the
  /// learner taps a message in the Inspector. Cleared after the flash.
  final ValueNotifier<String?> highlightedSurface = ValueNotifier(null);

  /// Newest-last; the Inspector caps its visible history at this many entries
  /// so a long session can't grow the log unbounded.
  static const int _maxLogEntries = 120;

  Timer? _flashTimer;

  /// Flash [surfaceId] in the lesson list (from an Inspector tap).
  void flashSurface(String surfaceId) {
    highlightedSurface.value = surfaceId;
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 1400), () {
      highlightedSurface.value = null;
    });
  }

  // --- public conversation API ---------------------------------------------
  // The view drives the lesson through these, rather than reaching into the
  // Conversation directly, so all request orchestration lives in one place.

  /// Kick off the lesson with its opening instruction.
  void start(String openingPrompt) =>
      conversation.sendRequest(ChatMessage.user(openingPrompt));

  /// Send the learner's free-text message (a question or steer).
  void sendText(String text) =>
      conversation.sendRequest(ChatMessage.user(text));

  /// Clear the current error and ask the model to continue.
  void retry() {
    lastError.value = null;
    conversation.sendRequest(ChatMessage.user('Continue the lesson.'));
  }

  static const int _maxRetries = 2;

  /// Guards against runaway error loops: if the controller keeps reporting
  /// validation/runtime errors back to the model, stop resubmitting after a
  /// couple of attempts instead of looping forever.
  int _consecutiveErrorReports = 0;

  /// Index of the next scripted turn in Demo Mode.
  int _demoTurn = 0;

  void _logMessage(A2uiMessage message) {
    final (kind, surfaceId, payload) = switch (message) {
      CreateSurface() => ('createSurface', message.surfaceId, message.toJson()),
      UpdateComponents() => (
        'updateComponents',
        message.surfaceId,
        message.toJson(),
      ),
      UpdateDataModel() => (
        'updateDataModel',
        message.surfaceId,
        message.toJson(),
      ),
      DeleteSurface() => ('deleteSurface', message.surfaceId, message.toJson()),
    };
    final entry = A2uiLogEntry(
      kind: kind,
      surfaceId: surfaceId,
      json: const JsonEncoder.withIndent('  ').convert(payload),
    );
    final next = [...a2uiLog.value, entry];
    a2uiLog.value = next.length > _maxLogEntries
        ? next.sublist(next.length - _maxLogEntries)
        : next;
  }

  /// The core send handler — called by the transport for every outgoing
  /// message (typed text or widget interaction). MUST NOT rethrow: a rethrow
  /// would loop through SurfaceController.reportError → onSubmit → onSend.
  Future<void> _handleSend(ChatMessage message) async {
    final decoded = _decode(message);
    if (decoded.isEmpty) return;

    // Break runaway error loops: the controller reports validation/runtime
    // failures back to the model as {"error":{"code":...}}. Let the model try
    // to self-correct once or twice, then stop instead of looping.
    final isErrorReport =
        decoded.contains('"error"') && decoded.contains('"code"');
    if (isErrorReport) {
      if (++_consecutiveErrorReports > 2) {
        log(
          'Suppressing error loop after $_consecutiveErrorReports reports',
          name: 'AiSessionService',
        );
        lastError.value = SessionError(
          'Kalaam hit a snag composing that step. Tap retry or steer it.',
          DateTime.now(),
        );
        return;
      }
    } else {
      _consecutiveErrorReports = 0;
    }

    // Demo Mode: replay the next scripted turn through the real pipeline.
    if (AppConfig.demoMode) {
      if (!isErrorReport) await _handleDemo(message);
      return;
    }

    _chatHistory.add(Content('user', [TextPart(decoded)]));

    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      try {
        final stream = _model.generateContentStream(_chatHistory);
        final responseBuffer = StringBuffer();
        await for (final chunk in stream) {
          final text = chunk.text ?? '';
          responseBuffer.write(text);
          _transport.addChunk(text);
        }
        final responseText = responseBuffer.toString();
        if (responseText.isNotEmpty) {
          _chatHistory.add(Content.model([TextPart(responseText)]));
        }
        _trimHistory();
        lastError.value = null;
        return;
      } catch (e, st) {
        log(
          'onSend error (attempt ${attempt + 1}/${_maxRetries + 1}): $e',
          name: 'AiSessionService',
          error: e,
          stackTrace: st,
        );
        if (attempt == _maxRetries) {
          if (_chatHistory.isNotEmpty) _chatHistory.removeLast();
          lastError.value = SessionError(_friendlyError(e), DateTime.now());
          return;
        }
        await Future<void>.delayed(Duration(seconds: 2 << attempt));
      }
    }
  }

  /// Keeps only the most recent turns so a long lesson can't grow the request
  /// (and token cost) without bound. The system prompt lives in
  /// `systemInstruction`, not here, so trimming never drops Kalaam's identity.
  static const int _maxHistory = 24; // ~12 exchanges
  void _trimHistory() {
    if (_chatHistory.length > _maxHistory) {
      _chatHistory.removeRange(0, _chatHistory.length - _maxHistory);
    }
  }

  /// Merges the message's text with any [UiInteractionPart] payloads (button
  /// taps / answers), which [ChatMessage.text] excludes. Without this every
  /// interaction would be dropped and the lesson could never advance.
  String _decode(ChatMessage message) {
    final buffer = StringBuffer(message.text);
    for (final part in message.parts.uiInteractionParts) {
      if (buffer.isNotEmpty) buffer.write('\n');
      buffer.write(part.interaction);
    }
    return buffer.toString();
  }

  /// Replays the next scripted turn in Demo Mode, reacting to the learner's
  /// last action, through the same transport the live model uses.
  Future<void> _handleDemo(ChatMessage message) async {
    final text = KalaamDemo.responseFor(_demoTurn, _extractAction(message));
    _demoTurn++;
    if (text == null) return;
    // Simulate composing latency so the loop badge pulses, like live mode.
    await Future<void>.delayed(const Duration(milliseconds: 700));
    _transport.addChunk(text);
  }

  /// Decodes the `action` object from an interaction message, if present.
  Map<String, Object?>? _extractAction(ChatMessage message) {
    for (final part in message.parts.uiInteractionParts) {
      try {
        final decoded = jsonDecode(part.interaction);
        if (decoded is Map && decoded['action'] is Map) {
          return (decoded['action'] as Map).cast<String, Object?>();
        }
      } catch (_) {
        // Not JSON — ignore for demo branching.
      }
    }
    return null;
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('Quota') || msg.contains('RESOURCE_EXHAUSTED')) {
      return 'API rate limit reached. Please wait a moment and retry.';
    }
    if (msg.contains('PERMISSION_DENIED') || msg.contains('403')) {
      return 'Permission denied — check Firebase AI Logic is enabled.';
    }
    if (msg.contains('not found') || msg.contains('NOT_FOUND')) {
      return 'Firebase AI Logic isn\'t fully set up for this project yet.';
    }
    return 'AI service error. Please retry.';
  }

  void dispose() {
    _flashTimer?.cancel();
    _logSub?.cancel();
    conversation.dispose();
    _transport.dispose();
    surfaceController.dispose();
    lastError.dispose();
    a2uiLog.dispose();
    highlightedSurface.dispose();
  }
}

@riverpod
AiSessionService aiSessionService(Ref ref, String sessionKey) {
  final service = AiSessionService(sessionKey);
  ref.onDispose(() {
    log('Session disposed: $sessionKey', name: 'AiSessionService');
    service.dispose();
  });
  return service;
}
