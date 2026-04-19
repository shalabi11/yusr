import 'package:yusr_app/features/auth/presentation/models/auth_submit_status.dart';

class AuthSubmitResult {
  const AuthSubmitResult({required this.status, this.message});

  final AuthSubmitStatus status;
  final String? message;
}
