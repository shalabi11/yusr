import 'package:flutter/material.dart';

void navigateAfterAuthSuccess({
  required BuildContext context,
  required String successRoute,
  required bool clearStackOnSuccess,
}) {
  if (clearStackOnSuccess) {
    Navigator.pushNamedAndRemoveUntil(context, successRoute, (route) => false);
    return;
  }

  Navigator.pushReplacementNamed(context, successRoute);
}
