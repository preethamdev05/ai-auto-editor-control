import '../../core/constants.dart';
import '../../domain/enums/job_status.dart';
import '../../domain/enums/pipeline_layer.dart';

class Job {
  final String jobId;
  final String filename;
  final OverallJobStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int currentLayer;
  final String? error;
  final String? outputPath;
  final String? songPath;
  final Map<String, dynamic>? configJson;
  final Map<int, JobStageStatus> stageStatuses;

  const Job({
    required this.jobId,
    required this.filename,
    this.status = OverallJobStatus.queued,
    this.createdAt,
    this.updatedAt,
    this.currentLayer = 0,
    this.error,
    this.outputPath,
    this.songPath,
    this.configJson,
    this.stageStatuses = const {},
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    int layer = 0;
    final layerRaw = json['layer'] ?? json['current_layer'];
    if (layerRaw != null) {
      layer = layerRaw is int ? layerRaw : int.tryParse('$layerRaw') ?? 0;
    }

    final stages = <int, JobStageStatus>{};
    final statusRaw = json['status'] ?? '';
    final rawStatus = statusRaw is String ? statusRaw : '';
    final overallStatus = OverallJobStatus.fromString(rawStatus);

    for (int i = 1; i <= 8; i++) {
      if (i < layer) {
        stages[i] = overallStatus == OverallJobStatus.error ? JobStageStatus.failed : JobStageStatus.done;
      } else if (i == layer) {
        stages[i] = overallStatus == OverallJobStatus.error ? JobStageStatus.failed : JobStageStatus.active;
      } else {
        stages[i] = JobStageStatus.pending;
      }
    }

    if (overallStatus == OverallJobStatus.complete) {
      for (int i = 1; i <= 8; i++) {
        stages[i] = JobStageStatus.done;
      }
    }

    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v * 1000);
      return DateTime.tryParse(v.toString());
    }

    return Job(
      jobId: json['job_id'] ?? json['id'] ?? '',
      filename: json['filename'] ?? json['file'] ?? 'Unknown',
      status: overallStatus,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
      currentLayer: layer,
      error: json['error'],
      outputPath: json['output_path'],
      songPath: json['song_path'],
      configJson:
          json['config_json'] is String
              ? {}
              : (json['config_json'] ?? json['config'] as Map<String, dynamic>?),
      stageStatuses: stages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_id': jobId,
      'filename': filename,
      'status': status.name,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'current_layer': currentLayer,
      'error': error,
      'output_path': outputPath,
      'song_path': songPath,
    };
  }

  Job copyWith({
    String? jobId,
    String? filename,
    OverallJobStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? currentLayer,
    String? error,
    String? outputPath,
    String? songPath,
    Map<String, dynamic>? configJson,
    Map<int, JobStageStatus>? stageStatuses,
  }) {
    return Job(
      jobId: jobId ?? this.jobId,
      filename: filename ?? this.filename,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentLayer: currentLayer ?? this.currentLayer,
      error: error ?? this.error,
      outputPath: outputPath ?? this.outputPath,
      songPath: songPath ?? this.songPath,
      configJson: configJson ?? this.configJson,
      stageStatuses: stageStatuses ?? this.stageStatuses,
    );
  }

  StageInfo getStageInfo(int layerNum) {
    final name = AppConstants.layerNames[layerNum] ?? 'Unknown';
    final status = stageStatuses[layerNum] ?? JobStageStatus.pending;
    return StageInfo(name: name, number: layerNum, status: status);
  }
}

class StageInfo {
  final String name;
  final int number;
  final JobStageStatus status;

  const StageInfo({required this.name, required this.number, required this.status});
}
