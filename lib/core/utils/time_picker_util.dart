import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/glass_container.dart';
import 'package:yusr_app/core/localization/app_localizations.dart';
import 'package:yusr_app/core/localization/app_translations.dart';

class TimePickerUtil {
  static void showCupertinoTimePicker({
    required BuildContext context,
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onTimeChanged,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext builderContext) {
        return GlassContainer(
          borderRadius: 30,
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.only(top: 20),
          color: AppColors.primaryDark.withValues(alpha: 0.9),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.chooseTime.tr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      2020,
                      1,
                      1,
                      initialTime.hour,
                      initialTime.minute,
                    ),
                    onDateTimeChanged: (DateTime newTime) {
                      onTimeChanged(TimeOfDay.fromDateTime(newTime));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: const Size(200, 45),
                ),
                onPressed: () => Navigator.pop(builderContext),
                child: Text(
                  AppStrings.save.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
