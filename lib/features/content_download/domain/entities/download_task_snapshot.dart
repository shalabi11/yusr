import 'package:equatable/equatable.dart';

enum DownloadTaskState {
  undefined,
  enqueued,
  running,
  paused,
  complete,
  failed,
  canceled,
}

class DownloadTaskSnapshot extends Equatable {
  const DownloadTaskSnapshot({required this.state, required this.progress});

  final DownloadTaskState state;
  final int progress;

  @override
  List<Object?> get props => [state, progress];
}
