import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/job.dart';
import '../../../domain/enums/job_status.dart';
import '../../../core/theme.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({super.key, required this.job, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(_statusIcon(), color: _statusColor(), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      job.filename,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFEAEAFF),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _statusBadge(),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _getProgress(),
                      backgroundColor: const Color(0xFF353555),
                      color: _statusColor(),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(_getProgress() * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9595B0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _layerInfo(),
                style: const TextStyle(fontSize: 12, color: Color(0xFF9595B0)),
              ),
              if (job.createdAt != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DateFormat('MMM d, HH:mm').format(job.createdAt!),
                    style: const TextStyle(fontSize: 11, color: Color(0xFF6C6C85)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  double _getProgress() {
    if (job.status == OverallJobStatus.complete) return 1.0;
    if (job.status == OverallJobStatus.error) return 0.0;
    if (job.currentLayer == 0) return 0.0;
    return job.currentLayer / 8;
  }

  IconData _statusIcon() {
    switch (job.status) {
      case OverallJobStatus.complete:
        return Icons.check_circle;
      case OverallJobStatus.processing:
        return Icons.autorenew;
      case OverallJobStatus.error:
        return Icons.error;
      default:
        return Icons.schedule;
    }
  }

  Color _statusColor() {
    switch (job.status) {
      case OverallJobStatus.complete:
        return AppTheme.success;
      case OverallJobStatus.processing:
        return AppTheme.info;
      case OverallJobStatus.error:
        return AppTheme.error;
      default:
        return AppTheme.warning;
    }
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor().withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        job.status.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _statusColor(),
        ),
      ),
    );
  }

  String _layerInfo() {
    if (job.status == OverallJobStatus.complete) return 'All 8 layers completed ✓';
    if (job.status == OverallJobStatus.error) {
      return 'Failed at layer ${job.currentLayer}: ${job.error ?? 'Unknown'}';
    }
    if (job.currentLayer > 0) {
      return 'Layer ${job.currentLayer}/8 — Processing';
    }
    return 'Queued';
  }
}
