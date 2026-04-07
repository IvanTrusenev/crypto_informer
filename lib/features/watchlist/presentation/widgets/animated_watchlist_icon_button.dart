import 'package:flutter/material.dart';

/// Кнопка «избранное»: сжатие при нажатии, лёгкий отскок при отпускании.
class AnimatedWatchlistIconButton extends StatefulWidget {
  const AnimatedWatchlistIconButton({
    required this.isInWatchlist,
    required this.onPressed,
    required this.tooltip,
    this.visualDensity,
    this.style,
    super.key,
  });

  final bool isInWatchlist;
  final VoidCallback onPressed;
  final String tooltip;
  final VisualDensity? visualDensity;
  final ButtonStyle? style;

  @override
  State<AnimatedWatchlistIconButton> createState() =>
      _AnimatedWatchlistIconButtonState();
}

class _AnimatedWatchlistIconButtonState
    extends State<AnimatedWatchlistIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1, end: 0.76).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeInOut,
        reverseCurve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Listener(
      onPointerDown: (_) => _pressController.forward(),
      onPointerUp: (_) => _pressController.reverse(),
      onPointerCancel: (_) => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _pressController,
        builder: (context, child) => Transform.scale(
          scale: _scale.value,
          child: child,
        ),
        child: IconButton(
          tooltip: widget.tooltip,
          visualDensity: widget.visualDensity,
          style: widget.style,
          icon: Icon(
            widget.isInWatchlist ? Icons.star : Icons.star_border,
            color: widget.isInWatchlist ? scheme.primary : null,
          ),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
