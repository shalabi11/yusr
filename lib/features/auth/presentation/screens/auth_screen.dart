import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/auth/presentation/cubit/auth_form_cubit.dart';
import 'package:yusr_app/features/auth/presentation/cubit/auth_form_state.dart';
import 'package:yusr_app/features/auth/presentation/extensions/auth_feedback_extension.dart';
import 'package:yusr_app/features/auth/presentation/functions/create_auth_form_cubit.dart';
import 'package:yusr_app/features/auth/presentation/functions/navigate_after_auth_success.dart';
import 'package:yusr_app/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:yusr_app/features/auth/presentation/widgets/auth_header_icon.dart';
import 'package:yusr_app/features/auth/presentation/widgets/auth_mode_switch_button.dart';
import 'package:yusr_app/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:yusr_app/features/auth/presentation/widgets/custom_auth_text_field.dart';

part 'auth_screen_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    this.startInSignUpMode = false,
    this.successRoute = '/home',
    this.clearStackOnSuccess = false,
    this.markAccountOnboardingSeenOnSuccess = false,
  });

  final bool startInSignUpMode;
  final String successRoute;
  final bool clearStackOnSuccess;
  final bool markAccountOnboardingSeenOnSuccess;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}
