import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DashboardSkeleton extends StatefulWidget {
  const DashboardSkeleton({super.key});

  @override
  State<DashboardSkeleton> createState() => _DashboardSkeletonState();
}

class _DashboardSkeletonState extends State<DashboardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.28, end: 0.82).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _bone(AppPalette colors, double width, double height, double radius) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, _) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: Color.lerp(colors.surfaceSoft, colors.border, _anim.value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SliverList(
      delegate: SliverChildListDelegate([
        // ── ResumenCard skeleton ──────────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _bone(colors, 38, 38, AppRadius.md),
                  const SizedBox(width: 12),
                  _bone(colors, 110, 14, AppRadius.pill),
                  const Spacer(),
                  _bone(colors, 68, 22, AppRadius.pill),
                ],
              ),
              const SizedBox(height: 16),
              _bone(colors, 175, 32, AppRadius.sm),
              const SizedBox(height: 18),
              _bone(colors, double.infinity, 7, AppRadius.pill),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _bone(colors, double.infinity, 52, AppRadius.md)),
                  const SizedBox(width: 12),
                  Expanded(child: _bone(colors, double.infinity, 52, AppRadius.md)),
                ],
              ),
            ],
          ),
        ),

        // ── CategoriaChart skeleton ───────────────────────────────
        Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: colors.border),
          ),
          child: Row(
            children: [
              _bone(colors, 100, 100, 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  children: List.generate(
                    4,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _bone(colors, double.infinity, 13, AppRadius.pill),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Tile skeletons ────────────────────────────────────────
        ...List.generate(
          4,
          (_) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                _bone(colors, 4, 46, 2),
                const SizedBox(width: 12),
                _bone(colors, 46, 46, AppRadius.md),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bone(colors, 130, 13, AppRadius.pill),
                      const SizedBox(height: 8),
                      _bone(colors, 80, 10, AppRadius.pill),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _bone(colors, 38, 10, AppRadius.pill),
                    const SizedBox(height: 6),
                    _bone(colors, 72, 14, AppRadius.pill),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 96),
      ]),
    );
  }
}
