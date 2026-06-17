import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:genui/genui.dart';

import 'package:kalaam/theme.dart';

/// Bridges a user interaction back to the AI (or the offline demo script).
///
/// IMPORTANT: calling `ctx.dataContext.update()` only mutates the LOCAL data
/// model — the model is never informed. To advance the lesson and let the AI
/// adapt (the entire point of the GenUI loop), an interactive widget MUST
/// dispatch a [UserActionEvent]. The [SurfaceController] converts it into a
/// request on its `onSubmit` stream, which [Conversation] forwards to the
/// transport and on to Gemini. The surfaceId is injected automatically by the
/// hosting [Surface].
void sendKalaamAction(
  CatalogItemContext ctx,
  String action, [
  Map<String, Object?> payload = const {},
]) {
  ctx.dispatchEvent(
    UserActionEvent(
      name: action,
      sourceComponentId: ctx.id,
      context: <String, Object?>{'action': action, ...payload},
    ),
  );
}

/// A one-shot "advance the lesson" button for display-only widgets
/// (SceneCard, VocabCarousel, VocabCard, CulturalNote, WordFamilyWheel).
///
/// It locks itself after the first tap so a stacked, already-answered surface
/// can never dispatch the action twice.
class KalaamContinueButton extends StatefulWidget {
  const KalaamContinueButton({
    super.key,
    required this.ctx,
    this.label = 'Continue',
    this.action = 'continue',
    this.payload = const {},
    this.icon = Icons.arrow_forward_rounded,
  });

  /// The catalog context used to dispatch the action.
  final CatalogItemContext ctx;

  /// The button label.
  final String label;

  /// The action name reported to the AI.
  final String action;

  /// Extra context delivered to the AI alongside the action.
  final Map<String, Object?> payload;

  /// Trailing icon.
  final IconData icon;

  @override
  State<KalaamContinueButton> createState() => _KalaamContinueButtonState();
}

class _KalaamContinueButtonState extends State<KalaamContinueButton> {
  bool _sent = false;

  void _onPressed() {
    if (_sent) return;
    setState(() => _sent = true);
    sendKalaamAction(widget.ctx, widget.action, widget.payload);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _sent
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: KalaamColors.onSurfaceDim,
                ),
                const Gap(8),
                Text(
                  'Sent to Kalaam',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            )
          : OutlinedButton.icon(
              onPressed: _onPressed,
              icon: Icon(widget.icon, size: 18),
              label: Text(widget.label),
              style: OutlinedButton.styleFrom(
                foregroundColor: KalaamColors.primary,
                side: BorderSide(
                  color: KalaamColors.primary.withValues(alpha: 0.5),
                ),
                padding: const EdgeInsetsDirectional.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
    );
  }
}
