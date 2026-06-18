import 'package:flutter/material.dart';
import 'package:kalaam/theme.dart';

class DuoButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color color;
  final Color shadowColor;
  final EdgeInsetsGeometry padding;

  const DuoButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.color = KalaamColors.primary,
    this.shadowColor = KalaamColors.primaryDim,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  });

  @override
  State<DuoButton> createState() => _DuoButtonState();
}

class _DuoButtonState extends State<DuoButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = true);
        }
      },
      onTapUp: (_) {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
          widget.onPressed!();
        }
      },
      onTapCancel: () {
        if (widget.onPressed != null) {
          setState(() => _isPressed = false);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(
          top: _isPressed ? 4 : 0,
          bottom: _isPressed ? 0 : 4,
        ),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: widget.shadowColor,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        padding: widget.padding,
        alignment: Alignment.center,
        child: widget.child,
      ),
    );
  }
}
