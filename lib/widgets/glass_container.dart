
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color color;
  final double blur;
  final Gradient? borderGradient;
  final double borderWidth;
  final BoxShape shape;
  final List<BoxShadow>? shadows;
  final AlignmentGeometry? alignment;
  final BoxConstraints? constraints;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.margin,
    this.color = const Color(0x1FFFFFFF), // Default fairly transparent white
    this.blur = 10.0,
    this.borderGradient,
    this.borderWidth = 1.0,
    this.shape = BoxShape.rectangle,
    this.shadows,
    this.alignment,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? BorderRadius.circular(20)),
        border: Border.all(
          color: Colors.white.withOpacity(0.2), // Fallback or base border
          width: borderWidth,
        ),
      ),
      foregroundDecoration: borderGradient != null
          ? BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(20),
              border: Border.all(color: Colors.transparent, width: borderWidth),
              gradient: borderGradient,
            )
          : null,
      child: child,
    );

    // Optimization: Skip BackdropFilter if blur is 0
    if (blur > 0) {
      content = ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: content,
        ),
      );
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      alignment: alignment,
      constraints: constraints,
      decoration: BoxDecoration(
        boxShadow: shadows ?? [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: content,
    );
  }
}
