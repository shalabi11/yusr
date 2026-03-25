import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String route;

  const ServiceCard({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (route.isNotEmpty) {
          Navigator.pushNamed(context, route);
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: GlassContainer(
        borderRadius: 24,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppColors.accent),
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
