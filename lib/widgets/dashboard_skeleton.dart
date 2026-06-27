import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SliverList(
      delegate: SliverChildListDelegate([
        _SkeletonBlock(
          height: 140,
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          color: colors.surface,
        ),
        _SkeletonBlock(
          height: 120,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          color: colors.surface,
        ),
        ...List.generate(
          5,
          (index) => _SkeletonBlock(
            height: 72,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            color: colors.surface,
          ),
        ),
        const SizedBox(height: 96),
      ]),
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  final double height;
  final EdgeInsets margin;
  final Color color;

  const _SkeletonBlock({
    required this.height,
    required this.margin,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.35, end: 0.78),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          height: height,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            gradient: LinearGradient(
              colors: [
                color,
                colors.surfaceSoft.withValues(alpha: value),
                color,
              ],
              stops: const [0, 0.5, 1],
            ),
            border: Border.all(color: colors.border),
          ),
        );
      },
      onEnd: () {},
    );
  }
}
