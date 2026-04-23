import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yusr_app/features/content_download/domain/entities/content_download_option.dart';
import 'package:yusr_app/features/content_download/domain/repositories/content_download_repository.dart';
import 'package:yusr_app/features/content_download/domain/services/download_orchestrator.dart';
import 'content_download_state.dart';

class ContentDownloadCubit extends Cubit<ContentDownloadState> {
  final DownloadOrchestrator _orchestrator;
  final ContentDownloadRepository _repository;
  late final StreamSubscription<ContentDownloadState> _orchestratorSubscription;

  ContentDownloadCubit(this._orchestrator, this._repository) : super(_orchestrator.state) {
    _orchestratorSubscription = _orchestrator.stream.listen((nextState) {
      if (!isClosed) {
        emit(nextState);
      }
    });
  }

  Future<void> syncInitialState() async {
    if (state.isPreparing || state.isDownloading || state.isPaused) return;

    if (_repository.isQuranContentDownloaded && _repository.isAdhkarContentDownloaded) {
      emit(state.copyWith(
        status: ContentDownloadStatus.completed,
        wasAlreadyDownloaded: true,
      ));
      return;
    }

    emit(state.copyWith(
      status: ContentDownloadStatus.initial,
      wasAlreadyDownloaded: false,
    ));
  }

  Future<void> startDownload(ContentDownloadOption option) async {
    await _orchestrator.start(option);
    if (!isClosed) emit(_orchestrator.state);
  }

  Future<void> pauseDownload() async {
    await _orchestrator.pause();
    if (!isClosed) emit(_orchestrator.state);
  }

  Future<void> resumeDownload() async {
    await _orchestrator.resume();
    if (!isClosed) emit(_orchestrator.state);
  }

  @override
  Future<void> close() async {
    await _orchestratorSubscription.cancel();
    await _orchestrator.dispose();
    return super.close();
  }
}
