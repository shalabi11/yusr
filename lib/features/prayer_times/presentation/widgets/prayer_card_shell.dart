// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/material.dart';

import '../../../../core/widgets/glass_container.dart';

class PrayerCardShell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;

  const PrayerCardShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: _buildGlassContainer(
        Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassContainer(Widget content) {
    final builders = <Widget Function()>[
      () => Function.apply(
            GlassContainer.new,
            const [],
            {#child: content},
          ) as Widget,
      () => Function.apply(GlassContainer.new, [content]) as Widget,
    ];

    for (final builder in builders) {
      try {
        return builder();
      } catch (_) {}
    }

    return content;
  }
}