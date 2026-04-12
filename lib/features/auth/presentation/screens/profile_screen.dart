import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:yusr_app/features/auth/presentation/extensions/auth_feedback_extension.dart';
import 'package:yusr_app/features/auth/presentation/functions/create_auth_controller.dart';
import 'package:yusr_app/features/auth/presentation/widgets/auth_glass_card.dart';
import 'package:yusr_app/features/auth/presentation/widgets/profile_edit_button.dart';
import 'package:yusr_app/features/auth/presentation/widgets/profile_guest_actions.dart';
import 'package:yusr_app/features/auth/presentation/widgets/profile_sign_out_button.dart';
import 'package:yusr_app/features/auth/presentation/widgets/profile_user_avatar.dart';
import 'package:yusr_app/features/auth/presentation/widgets/profile_user_name_text.dart';

part 'profile_screen_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
