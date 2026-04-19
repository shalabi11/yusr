import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:yusr_app/core/services/supabase/supabase_bootstrap.dart';
import 'package:yusr_app/core/theme/app_colors.dart';
import 'package:yusr_app/core/widgets/app_radial_background.dart';
import 'package:yusr_app/features/ai_assistant/presentation/cubit/chat_cubit.dart';
import 'package:yusr_app/features/ai_assistant/presentation/screens/chat_screen.dart';
import 'package:yusr_app/injection_container.dart';

part 'ai_assistant_entry_views.dart';
part 'ai_assistant_entry_gate.dart';

class AIAssistantEntryScreen extends StatelessWidget {
  const AIAssistantEntryScreen({super.key});

  bool _isAnonymous(User? user) {
    if (user == null) return true;
    final provider = user.appMetadata['provider']?.toString().toLowerCase();
    if (provider == 'anonymous') {
      return true;
    }

    final identities = user.identities;
    return identities?.any(
          (identity) =>
              identity.provider.toString().toLowerCase() == 'anonymous',
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseBootstrap.isEnabled) {
      return buildSupabaseDisabled();
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (_isAnonymous(user)) {
      return buildAnonymousGate(context);
    }

    return buildAssistantChat();
  }
}
