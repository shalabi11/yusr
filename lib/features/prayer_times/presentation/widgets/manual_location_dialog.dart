import 'package:flutter/material.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';
import 'package:yusr_app/features/prayer_times/presentation/cubit/prayer_times_cubit.dart';

Future<void> showManualLocationDialog({
  required BuildContext context,
  required PrayerTimesCubit cubit,
}) async {
  final controller = TextEditingController();

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(AppStrings.enterCity.tr),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: AppStrings.enterCity.tr),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await cubit.useCurrentLocation();
            },
            child: Text(AppStrings.useCurrentLocation.tr),
          ),
          TextButton(
            onPressed: () async {
              final city = controller.text.trim();
              if (city.isEmpty) return;
              Navigator.pop(dialogContext);
              final ok = await cubit.setManualLocation(city);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? AppStrings.locationSaved.tr
                        : AppStrings.locationNotFound.tr,
                  ),
                ),
              );
            },
            child: Text(AppStrings.applyLocation.tr),
          ),
        ],
      );
    },
  );
}
