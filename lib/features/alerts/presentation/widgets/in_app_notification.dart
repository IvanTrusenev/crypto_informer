import 'dart:async';

import 'package:flutter/material.dart';

/// Slide-down overlay that mimics a native push notification.
class InAppNotification extends StatefulWidget {
  const InAppNotification({
    required this.title,
    required this.body,
    required this.onDismiss,
    super.key,
  });

  final String title;
  final String body;
  final VoidCallback onDismiss;

  /// Shows an animated push-style notification at the top of the screen.
  static void show(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => InAppNotification(
        title: title,
        body: body,
        onDismiss: entry.remove,
      ),
    );
    overlay.insert(entry);
  }

  @override
  State<InAppNotification> createState() => _InAppNotificationState();
}

class _InAppNotificationState extends State<InAppNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  Timer? _autoDismiss;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    unawaited(_controller.forward());
    _autoDismiss = Timer(const Duration(seconds: 5), _dismiss);
  }

  void _dismiss() {
    _autoDismiss?.cancel();
    unawaited(_controller.reverse().then((_) {
      if (mounted) widget.onDismiss();
    }));
  }

  @override
  void dispose() {
    _autoDismiss?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              color: colorScheme.inverseSurface,
              child: InkWell(
                onTap: _dismiss,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.notifications_active,
                        color: colorScheme.inversePrimary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: colorScheme.onInverseSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.body,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onInverseSurface
                                    .withValues(alpha: .85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.close,
                        size: 18,
                        color:
                            colorScheme.onInverseSurface.withValues(alpha: .6),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
