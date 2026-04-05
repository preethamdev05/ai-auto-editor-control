enum JobStageStatus {
  pending,
  active,
  done,
  failed;

  String get label {
    switch (this) {
      case JobStageStatus.pending:
        return 'Pending';
      case JobStageStatus.active:
        return 'Running';
      case JobStageStatus.done:
        return 'Done';
      case JobStageStatus.failed:
        return 'Failed';
    }
  }
}

enum OverallJobStatus {
  queued,
  processing,
  complete,
  error,
  unknown;

  String get label {
    switch (this) {
      case OverallJobStatus.queued:
        return 'Queued';
      case OverallJobStatus.processing:
        return 'Processing';
      case OverallJobStatus.complete:
        return 'Complete';
      case OverallJobStatus.error:
        return 'Error';
      case OverallJobStatus.unknown:
        return 'Unknown';
    }
  }

  bool get isActive => this == OverallJobStatus.processing;
  bool get isFinal => this == OverallJobStatus.complete || this == OverallJobStatus.error;

  static OverallJobStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'queued':
      case 'pending':
        return OverallJobStatus.queued;
      case 'processing':
        return OverallJobStatus.processing;
      case 'complete':
      case 'completed':
        return OverallJobStatus.complete;
      case 'error':
      case 'failed':
        return OverallJobStatus.error;
      default:
        return OverallJobStatus.unknown;
    }
  }
}
