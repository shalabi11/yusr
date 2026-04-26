import 'package:flutter/material.dart';
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

/// Simplified Services Grid Widget
/// Replaces the complex infinite carousel with a clean, performant grid layout.
///
/// **Why this is better:**
/// - Eliminates unnecessary complexity (200k virtual items, timer-based scrolling)
/// - Reduces memory footprint significantly
/// - Improves performance on low-end devices
/// - Easier to maintain and test
/// - Better UX for fixed set of services
class HomeServicesGrid extends StatelessWidget {
  const HomeServicesGrid({required this.services, super.key});

  final List<ServiceItem> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    // Use GridView for fixed services (typically 4 items)
    // This is simpler, more performant, and more maintainable than infinite carousel
    return GridView.builder(
      shrinkWrap: true,

      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final item = services[index];
        return ServiceCard(
          title: item.title,
          icon: item.icon,
          route: item.route,
        );
      },
    );
  }
}

/// Alternative: Horizontal scrollable row for compact display
/// Use this if you prefer a horizontal layout instead of grid
class HomeServicesCarouselSimplified extends StatelessWidget {
  const HomeServicesCarouselSimplified({required this.services, super.key});

  final List<ServiceItem> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(services.length, (index) {
          final item = services[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == services.length - 1 ? 16 : 8,
            ),
            child: SizedBox(
              width: 160,
              child: ServiceCard(
                title: item.title,
                icon: item.icon,
                route: item.route,
              ),
            ),
          );
        }),
      ),
    );
  }
}
