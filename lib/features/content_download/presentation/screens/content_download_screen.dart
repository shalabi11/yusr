import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_cubit.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_state.dart';
import 'package:yusr_app/features/content_download/presentation/widgets/content_download_view.dart';

class ContentDownloadScreen extends StatelessWidget {
  const ContentDownloadScreen({
    this.initialOption,
    this.autoProceedOnComplete = false,
    this.successRoute,
    super.key,
  });

  final ContentDownloadOption? initialOption;
  final bool autoProceedOnComplete;
  final String? successRoute;

  @override
  Widget build(BuildContext context) {
    return BlocListener<ContentDownloadCubit, ContentDownloadState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == ContentDownloadStatus.completed,
      listener: (context, state) {
        if (!autoProceedOnComplete) {
          return;
        }

        _handleCompletion(context, successRoute);
      },
      child: ContentDownloadView(initialOption: initialOption),
    );
  }
}

void _handleCompletion(BuildContext context, String? successRoute) {
  final targetRoute = successRoute;

  if (targetRoute != null && targetRoute.isNotEmpty) {
    Navigator.pushNamedAndRemoveUntil(context, targetRoute, (route) {
      return route.settings.name == '/home' || route.isFirst;
    });
    return;
  }

  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
}
