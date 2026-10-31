import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_tokens.dart';

/// Kotak skeleton berdenyut. Menghormati pengaturan "hapus animasi".
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = AppRadius.inputAll,
  });

  /// Skeleton seukuran kartu.
  const Skeleton.card({super.key, this.height = 96})
    : width = double.infinity,
      borderRadius = AppRadius.cardAll;

  final double width;
  final double height;
  final BorderRadius borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: FadeTransition(
        opacity: Tween<double>(begin: 0.45, end: 1).animate(_controller),
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: widget.borderRadius,
          ),
        ),
      ),
    );
  }
}

/// Daftar skeleton kartu dengan teks "Memuat…" untuk pembaca layar.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 3, this.itemHeight = 88});

  final int itemCount;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat…',
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < itemCount; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.cardGap),
            Skeleton.card(height: itemHeight),
          ],
        ],
      ),
    );
  }
}
