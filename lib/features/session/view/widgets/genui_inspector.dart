import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import 'package:kalaam/shared/services/ai_session_service.dart';
import 'package:kalaam/theme.dart';

/// A live panel that streams the raw A2UI messages Gemini emits, so an audience
/// can literally watch the model compose the interface in real time.
class GenUiInspectorPanel extends StatefulWidget {
  const GenUiInspectorPanel({
    super.key,
    required this.log,
    this.onClose,
    this.onTapSurface,
  });

  final ValueNotifier<List<A2uiLogEntry>> log;
  final VoidCallback? onClose;

  /// Called with a message's surfaceId when the learner taps it, so the lesson
  /// list can scroll to and flash the surface that message produced.
  final void Function(String surfaceId)? onTapSurface;

  @override
  State<GenUiInspectorPanel> createState() => _GenUiInspectorPanelState();
}

class _GenUiInspectorPanelState extends State<GenUiInspectorPanel> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Color _kindColor(String kind) => switch (kind) {
    'createSurface' => KalaamColors.secondary,
    'updateComponents' => KalaamColors.primary,
    'updateDataModel' => const Color(0xFFB07BD6),
    _ => KalaamColors.error,
  };

  /// Short, glanceable tag for each A2UI op.
  String _kindTag(String kind) => switch (kind) {
    'createSurface' => 'CREATE',
    'updateComponents' => 'UPDATE',
    'updateDataModel' => 'DATA',
    'deleteSurface' => 'DELETE',
    _ => kind.toUpperCase(),
  };

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0C10),
        border: Border(
          top: BorderSide(color: KalaamColors.surfaceTrim, width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 10, 8, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.code_rounded,
                  color: KalaamColors.primary,
                  size: 16,
                ),
                const Gap(8),
                Text(
                  'GenUI · live A2UI stream',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: KalaamColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                ValueListenableBuilder<List<A2uiLogEntry>>(
                  valueListenable: widget.log,
                  builder: (context, entries, _) => Text(
                    '${entries.length} msgs',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
                if (widget.onClose != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.close_rounded, size: 16),
                    color: KalaamColors.onSurfaceDim,
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: KalaamColors.surfaceTrim),
          // Stream
          SizedBox(
            height: 240,
            child: ValueListenableBuilder<List<A2uiLogEntry>>(
              valueListenable: widget.log,
              builder: (context, entries, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scroll.hasClients) {
                    _scroll.jumpTo(_scroll.position.maxScrollExtent);
                  }
                });
                if (entries.isEmpty) {
                  return Center(
                    child: Text(
                      'Waiting for Gemini to compose…',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsetsDirectional.all(12),
                  itemCount: entries.length,
                  itemBuilder: (context, i) => _Entry(
                    entry: entries[i],
                    color: _kindColor(entries[i].kind),
                    tag: _kindTag(entries[i].kind),
                    onTap: widget.onTapSurface == null
                        ? null
                        : () => widget.onTapSurface!(entries[i].surfaceId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.entry,
    required this.color,
    required this.tag,
    this.onTap,
  });
  final A2uiLogEntry entry;
  final Color color;
  final String tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsetsDirectional.all(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 6,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: color.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontFamily: 'IBMPlexMono',
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const Gap(6),
                  Text(
                    entry.surfaceId,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexMono',
                      fontSize: 9,
                      color: KalaamColors.onSurfaceDim,
                    ),
                  ),
                  if (onTap != null) ...[
                    const Gap(6),
                    Icon(
                      Icons.my_location_rounded,
                      size: 11,
                      color: color.withValues(alpha: 0.7),
                    ),
                  ],
                ],
              ),
              const Gap(4),
              Text(
                entry.json,
                style: const TextStyle(
                  fontFamily: 'IBMPlexMono',
                  fontSize: 10,
                  height: 1.35,
                  color: Color(0xFFB9C2CF),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 250.ms).slideY(begin: 0.15, end: 0);
  }
}
