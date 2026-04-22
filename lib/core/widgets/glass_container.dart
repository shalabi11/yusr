import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double blur;
  final bool enableBlur;
  final Color color;
  final double? width;
  final double? height;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.blur = 10.0,
    this.enableBlur = true,
    this.color = const Color(0x1AFFFFFF), // 10% white
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final decoration = BoxDecoration(
      color: color,
      borderRadius: radius,
      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
    );

    final content = DecoratedBox(
      decoration: decoration,
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    final clippedContent = ClipRRect(
      borderRadius: radius,
      child: enableBlur && blur > 0
          ? BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: content,
            )
          : content,
    );

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: clippedContent,
    );
  }
}
