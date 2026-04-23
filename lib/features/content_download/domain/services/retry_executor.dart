import 'dart:async';

enum RetryDirective { success, retry, abort }

class RetryPolicy {
  const RetryPolicy({required this.maxAttempts, this.delayForAttempt});

  final int maxAttempts;
  final Duration Function(int attempt)? delayForAttempt;
}

class RetryExecutor {
  const RetryExecutor();

  Future<RetryDirective> execute({
    required RetryPolicy policy,
    required Future<RetryDirective> Function(int attempt) operation,
  }) async {
    if (policy.maxAttempts <= 0) {
      return RetryDirective.abort;
    }

    for (var attempt = 1; attempt <= policy.maxAttempts; attempt += 1) {
      final result = await operation(attempt);
      if (result == RetryDirective.success || result == RetryDirective.abort) {
        return result;
      }

      if (attempt >= policy.maxAttempts) {
        return RetryDirective.abort;
      }

      final delay = policy.delayForAttempt?.call(attempt);
      if (delay != null && delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
    }

    return RetryDirective.abort;
  }
}
