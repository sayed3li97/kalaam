import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';
import 'package:go_router/go_router.dart';
import 'package:kalaam/core/config/app_config.dart';
import 'package:kalaam/core/constants/scenarios.dart';
import 'package:kalaam/features/session/view/widgets/genui_inspector.dart';
import 'package:kalaam/shared/services/ai_session_service.dart';
import 'package:kalaam/theme.dart';

class SessionScreen extends ConsumerStatefulWidget {
  final String languageCode;
  final String scenarioId;

  /// Free-text learning goal (when the learner typed what they want to learn).
  final String? goal;

  const SessionScreen({
    super.key,
    required this.languageCode,
    required this.scenarioId,
    this.goal,
  });

  @override
  ConsumerState<SessionScreen> createState() => _SessionScreenState();
}

class _SessionScreenState extends ConsumerState<SessionScreen> {
  late final String _sessionKey;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  // One key per surface, so an Inspector tap can scroll the matching lesson
  // card into view.
  final Map<String, GlobalKey> _surfaceKeys = {};
  bool _showInspector = false;

  GlobalKey _keyFor(String surfaceId) =>
      _surfaceKeys.putIfAbsent(surfaceId, () => GlobalKey());

  void _locateSurface(String surfaceId, List<String> surfaces) {
    final ctx = _surfaceKeys[surfaceId]?.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: 300.ms,
        curve: Curves.easeOut,
        alignment: 0.1,
      );
      return;
    }
    // The card is scrolled off-screen, so ListView.builder recycled it and its
    // key has no context. Jump roughly to its position by index to force it to
    // build, then fine-tune with ensureVisible once it's mounted.
    if (!_scrollController.hasClients) return;
    final index = surfaces.indexOf(surfaceId);
    if (index < 0) return;
    final max = _scrollController.position.maxScrollExtent;
    final fraction = surfaces.length <= 1 ? 0.0 : index / (surfaces.length - 1);
    _scrollController.animateTo(
      (fraction * max).clamp(0.0, max),
      duration: 300.ms,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final mounted = _surfaceKeys[surfaceId]?.currentContext;
      if (mounted != null) {
        Scrollable.ensureVisible(
          mounted,
          duration: 200.ms,
          curve: Curves.easeOut,
          alignment: 0.1,
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sessionKey =
        "${widget.scenarioId}_${DateTime.now().millisecondsSinceEpoch}";

    // Fail fast: in live mode, only kick off the lesson if Firebase actually
    // initialised. Otherwise the build shows an actionable screen instead of
    // firing a request that can only fail with an opaque AI error.
    final ready = AppConfig.demoMode || ref.read(firebaseReadyProvider);
    if (ready) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(aiSessionServiceProvider(_sessionKey)).start(_openingPrompt());
      });
    }
  }

  String _openingPrompt() {
    final goal = widget.goal?.trim();
    if (goal != null && goal.isNotEmpty) {
      return 'The learner wants to learn this in Arabic: "$goal". '
          'Design and begin a tailored Arabic lesson for it now.';
    }
    final scenario = KalaamScenarios.byId(widget.scenarioId);
    final title = scenario?.title ?? widget.scenarioId;
    final desc = scenario?.description ?? '';
    return 'Begin an Arabic lesson for the scenario "$title" ($desc). '
        'Open with a SceneCard.';
  }

  String _title() {
    final goal = widget.goal?.trim();
    if (goal != null && goal.isNotEmpty) {
      return goal.length > 28 ? '${goal.substring(0, 28)}…' : goal;
    }
    return KalaamScenarios.byId(widget.scenarioId)?.title ?? 'Lesson';
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Live mode needs Firebase. If it didn't initialise, don't pretend to run a
    // session — surface a clear, actionable message instead.
    if (!AppConfig.demoMode && !ref.watch(firebaseReadyProvider)) {
      return _FirebaseUnavailable(title: _title());
    }

    final service = ref.watch(aiSessionServiceProvider(_sessionKey));

    return ValueListenableBuilder<ConversationState>(
      valueListenable: service.conversation.state,
      builder: (context, state, child) {
        final isWaiting = state.isWaiting;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: 300.ms,
              curve: Curves.easeOut,
            );
          }
        });

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.go('/'),
            ),
            title: Text(
              _title(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: KalaamColors.surface,
            elevation: 0,
            actions: [

              _GenUILoopBadge(active: isWaiting),
            ],
          ),
          body: Column(
            children: [
              // Duolingo-style Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: state.surfaces.isEmpty ? 0.1 : (state.surfaces.length / 5.0).clamp(0.1, 1.0),
                    minHeight: 16,
                    backgroundColor: KalaamColors.surfaceTrim,
                    valueColor: const AlwaysStoppedAnimation<Color>(KalaamColors.primary),
                  ),
                ),
              ),
              Expanded(
                child: state.surfaces.isEmpty && isWaiting
                    ? const _ComposingFirst()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsetsDirectional.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        itemCount: state.surfaces.length,
                        itemBuilder: (context, index) {
                          final surfaceId = state.surfaces[index];
                          final isOld = index < state.surfaces.length - 1;
                          
                          return Padding(
                            key: _keyFor(surfaceId),
                            padding: const EdgeInsetsDirectional.only(
                              bottom: 24,
                            ),
                            child: ValueListenableBuilder<String?>(
                              valueListenable: service.highlightedSurface,
                              // RepaintBoundary isolates each lesson card so the
                              // pulsing badge / flash animation doesn't repaint
                              // the whole stacked list.
                              child: RepaintBoundary(
                                child: IgnorePointer(
                                  ignoring: isOld,
                                  child: Opacity(
                                    opacity: isOld ? 0.4 : 1.0,
                                    child: Surface(
                                      surfaceContext: service.surfaceController
                                          .contextFor(surfaceId),
                                    ),
                                  ),
                                ),
                              ),
                              builder: (context, highlighted, child) {
                                final on = highlighted == surfaceId;
                                return AnimatedContainer(
                                  duration: 250.ms,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: on
                                          ? KalaamColors.primary
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: on
                                        ? [
                                            BoxShadow(
                                              color: KalaamColors.primary
                                                  .withValues(alpha: 0.4),
                                              blurRadius: 16,
                                            ),
                                          ]
                                        : const [],
                                  ),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),

              // Live GenUI Inspector (toggle)
              if (_showInspector)
                GenUiInspectorPanel(
                  log: service.a2uiLog,
                  onClose: () => setState(() => _showInspector = false),
                  onTapSurface: (id) {
                    service.flashSurface(id);
                    _locateSurface(id, state.surfaces);
                  },
                ),

              // Error banner
              ValueListenableBuilder<SessionError?>(
                valueListenable: service.lastError,
                builder: (context, error, _) {
                  if (error == null) return const SizedBox.shrink();
                  return _ErrorBanner(
                    error: error,
                    onRetry: service.retry,
                    onDismiss: () => service.lastError.value = null,
                  );
                },
              ),

              if (state.surfaces.isNotEmpty && isWaiting)
                const _ComposingNext(),

              _InputBar(
                controller: _inputController,
                enabled: !isWaiting,
                onSend: () => _sendMessage(service),
              ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(AiSessionService service) {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    service.sendText(text);
  }
}

class _ComposingFirst extends StatelessWidget {
  const _ComposingFirst();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: KalaamColors.primary),
          const Gap(16),
          Text(
            'Creating your personalized lesson...',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ComposingNext extends StatelessWidget {
  const _ComposingNext();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(KalaamColors.primary),
            ),
          ),
          const Gap(10),
          Text(
            'composing…',
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(fontSize: 10),
          ),
        ],
      ).animate().fadeIn(),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: KalaamColors.surfaceVar,
        border: Border(
          top: BorderSide(color: KalaamColors.surfaceTrim, width: 1.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: enabled ? (_) => onSend() : null,
                  decoration: const InputDecoration(
                    hintText: 'Type your message in English or Arabic...',
                    hintStyle: TextStyle(fontSize: 14),
                  ),
                ),
              ),
              const Gap(12),
              IconButton(
                icon: const Icon(
                  Icons.send_rounded,
                  color: KalaamColors.primary,
                ),
                onPressed: enabled ? onSend : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final SessionError error;
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.error,
    required this.onRetry,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      padding: const EdgeInsetsDirectional.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3D1F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF8B3A3A)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF6B6B),
            size: 20,
          ),
          const Gap(10),
          Expanded(
            child: Text(
              error.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFFFFADAD),
                fontSize: 12,
              ),
            ),
          ),
          const Gap(8),
          TextButton(
            onPressed: onRetry,
            style: TextButton.styleFrom(
              foregroundColor: KalaamColors.primary,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Retry',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          const Gap(4),
          InkWell(
            onTap: onDismiss,
            child: const Icon(
              Icons.close_rounded,
              color: Color(0xFF888888),
              size: 16,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.3, end: 0);
  }
}

/// Shown when live mode is active but Firebase failed to initialise — gives the
/// learner an honest, actionable next step instead of an opaque AI failure.
class _FirebaseUnavailable extends StatelessWidget {
  final String title;

  const _FirebaseUnavailable({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: KalaamColors.surface,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                color: KalaamColors.onSurfaceDim,
                size: 48,
              ),
              const Gap(20),
              Text(
                'Live AI is unavailable',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: KalaamColors.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Gap(12),
              Text(
                'We couldn’t connect to your AI tutor right now. Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Gap(28),
              ElevatedButton(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: KalaamColors.primary,
                  foregroundColor: KalaamColors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                ),
                child: const Text('Back to Scenarios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenUILoopBadge extends StatelessWidget {
  final bool active;

  const _GenUILoopBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Semantics(
        label: 'Kalaam is idle',
        child: Container(
          width: 12,
          height: 12,
          margin: const EdgeInsetsDirectional.only(end: 20),
          decoration: const BoxDecoration(
            color: KalaamColors.onSurfaceDim,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return Semantics(
      label: 'Kalaam is composing the next step',
      child:
          Container(
                width: 12,
                height: 12,
                margin: const EdgeInsetsDirectional.only(end: 20),
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.3, 1.3),
                duration: 800.ms,
              )
              .boxShadow(
                begin: const BoxShadow(
                  color: Colors.transparent,
                  blurRadius: 0,
                ),
                end: BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.6),
                  blurRadius: 8,
                ),
              ),
    );
  }
}
