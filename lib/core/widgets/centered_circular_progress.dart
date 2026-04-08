import 'package:flutter/material.dart';

/// Индикатор загрузки по центру доступной области
/// (экран, sliver, фиксированная высота).
class CenteredCircularProgress extends StatelessWidget {
  const CenteredCircularProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}
