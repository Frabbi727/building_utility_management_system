import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.isLoading = true,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;
    final highlightColor = isDark ? Colors.grey.shade700 : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _controller.value - 0.3,
                _controller.value,
                _controller.value + 0.3,
              ].map((s) => s.clamp(0.0, 1.0)).toList(),
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final ShapeBorder? shape;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return Container(
      width: width,
      height: height,
      decoration: ShapeDecoration(
        color: color,
        shape: shape ??
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 8.r),
            ),
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(
              width: double.infinity,
              height: 160.h,
              borderRadius: 20.r,
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ShimmerBox(height: 80.h, borderRadius: 16.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ShimmerBox(height: 80.h, borderRadius: 16.r),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ShimmerBox(height: 80.h, borderRadius: 16.r),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ShimmerBox(
              width: double.infinity,
              height: 120.h,
              borderRadius: 16.r,
            ),
            SizedBox(height: 16.h),
            ShimmerBox(
              width: 150.w,
              height: 20.h,
              borderRadius: 6.r,
            ),
            SizedBox(height: 10.h),
            ...List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: ShimmerBox(
                  width: double.infinity,
                  height: 64.h,
                  borderRadius: 12.r,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CardListSkeleton extends StatelessWidget {
  final int itemCount;
  final double cardHeight;

  const CardListSkeleton({
    super.key,
    this.itemCount = 4,
    this.cardHeight = 110,
  });

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: itemCount,
        itemBuilder: (_, _) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ShimmerBox(
            width: double.infinity,
            height: cardHeight.h,
            borderRadius: 14.r,
          ),
        ),
      ),
    );
  }
}
