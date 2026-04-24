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

class HomeServicesCarousel extends StatelessWidget {
  const HomeServicesCarousel({required this.services, super.key});

  final List<ServiceItem> services;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.hasBoundedWidth ? constraints.maxWidth : 360.0;
        final cardWidth = availableWidth >= 340
            ? ((availableWidth - 12) / 2).clamp(140.0, 180.0).toDouble()
            : availableWidth;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: services
              .map(
                (item) => SizedBox(
                  width: cardWidth,
                  child: ServiceCard(
                    title: item.title,
                    icon: item.icon,
                    route: item.route,
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }
}