import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/features/home/presentation/widgets/service_card.dart';

class ServiceItem {
  const ServiceItem({
    required this.title,
    required this.icon,
    required this.route,
  });

  final String title;
  final IconData icon;
  final String route;
}

class HomeServicesCarousel extends StatefulWidget {
  const HomeServicesCarousel({required this.services, super.key});

  final List<ServiceItem> services;

  @override
  State<HomeServicesCarousel> createState() => _HomeServicesCarouselState();
}

class _HomeServicesCarouselState extends State<HomeServicesCarousel> {
  static const int _virtualItemCount = 200000;
  static const int _recenterThreshold = 1500;
  static const Duration _autoScrollInterval = Duration(seconds: 5);

  late final PageController _controller;
  Timer? _autoScrollTimer;
  late final int _initialPage;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final servicesLength = widget.services.length;
    final middle = _virtualItemCount ~/ 2;
    _initialPage = servicesLength == 0 ? 0 : middle - (middle % servicesLength);
    _currentIndex = _normalizeIndex(_initialPage);
    _controller = PageController(
      viewportFraction: 0.82,
      initialPage: _initialPage,
    );
    _startAutoScroll();
  }

  int _normalizeIndex(int index) {
    final length = widget.services.length;
    if (length == 0) return 0;
    return ((index % length) + length) % length;
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(_autoScrollInterval, (_) {
      if (!mounted || !_controller.hasClients || widget.services.isEmpty) {
        return;
      }

      final currentPage = _controller.page?.round() ?? _initialPage;
      _controller.animateToPage(
        currentPage + 1,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _recenterIfNeeded(int page) {
    if (!mounted || !_controller.hasClients || widget.services.isEmpty) {
      return;
    }

    if (page > _recenterThreshold &&
        page < (_virtualItemCount - _recenterThreshold)) {
      return;
    }

    final servicesLength = widget.services.length;
    final middle = _virtualItemCount ~/ 2;
    final alignedMiddle = middle - (middle % servicesLength);
    final targetPage = alignedMiddle + _normalizeIndex(page);

    _controller.jumpToPage(targetPage);
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _controller,
            padEnds: true,
            itemCount: _virtualItemCount,
            onPageChanged: (index) {
              if (!mounted) return;
              setState(() => _currentIndex = _normalizeIndex(index));
              _recenterIfNeeded(index);
            },
            itemBuilder: (context, index) {
              final item = widget.services[_normalizeIndex(index)];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final position = _controller.hasClients
                      ? (_controller.page ?? _currentIndex.toDouble())
                      : _currentIndex.toDouble();
                  final distance = (position - index).abs();
                  final scale = 1 - (distance * 0.08).clamp(0.0, 0.16);
                  final opacity = 1 - (distance * 0.25).clamp(0.0, 0.35);

                  return Transform.scale(
                    scale: scale,
                    child: Opacity(opacity: opacity, child: child),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ServiceCard(
                    title: item.title,
                    icon: item.icon,
                    route: item.route,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.services.length, (index) {
            final isActive = index == _currentIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 22 : 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.accent
                    : AppColors.textWhite.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}
