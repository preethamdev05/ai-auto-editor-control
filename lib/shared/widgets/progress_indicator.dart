import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../domain/enums/pipeline_layer.dart';
import '../../domain/enums/job_status.dart';

class AaeProgressIndicator extends StatelessWidget {
  final int currentLayer;
  final int totalLayers;
  final bool isComplete;
  final Map<int, JobStageStatus> stageStatuses;

  const AaeProgressIndicator({
    super.key,
    required this.currentLayer,
    this.totalLayers = 8,
    this.isComplete = false,
    this.stageStatuses = const {},
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(totalLayers, (i) {
        final layerNum = i + 1;
        final layer = PipelineLayer.fromNumber(layerNum);
        final status = stageStatuses[layerNum] ?? _inferStatus(layerNum, currentLayer, isComplete);

        return Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(
            children: [
              _LayerDot(status: status),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  layer.name,
                  style: TextStyle(
                    color: status == JobStageStatus.pending
                        ? const Color(0xFF6C6C85)
                        : const Color(0xFFEAEAFF),
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _stageBgColor(status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _stageTextColor(status),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  JobStageStatus _inferStatus(int layerNum, int current, bool complete) {
    if (complete) return JobStageStatus.done;
    if (layerNum < current) return JobStageStatus.done;
    if (layerNum == current) return JobStageStatus.active;
    return JobStageStatus.pending;
  }
}

class _LayerDot extends StatelessWidget {
  final JobStageStatus status;
  const _LayerDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _stageColor(status);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(status == JobStageStatus.active ? 0.3 : 0.15),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Icon(
          status == JobStageStatus.done ? Icons.check : status == JobStageStatus.active ? Icons.play_arrow : Icons.circle,
          color: color,
          size: status == JobStageStatus.pending ? 6 : 12,
        ),
      ),
    );
  }
}

Color _stageColor(JobStageStatus status) {
  switch (status) {
    case JobStageStatus.done:
      return AppTheme.success;
    case JobStageStatus.active:
      return AppTheme.info;
    case JobStageStatus.failed:
      return AppTheme.error;
    default:
      return const Color(0xFF6C6C85);
  }
}

Color _stageBgColor(JobStageStatus status) {
  switch (status) {
    case JobStageStatus.done:
      return AppTheme.success.withOpacity(0.15);
    case JobStageStatus.active:
      return AppTheme.info.withOpacity(0.15);
    case JobStageStatus.failed:
      return AppTheme.error.withOpacity(0.15);
    default:
      return const Color(0xFF353555);
  }
}

Color _stageTextColor(JobStageStatus status) {
  switch (status) {
    case JobStageStatus.done:
      return AppTheme.success;
    case JobStageStatus.active:
      return AppTheme.info;
    case JobStageStatus.failed:
      return AppTheme.error;
    default:
      return const Color(0xFF9595B0);
  }
}
