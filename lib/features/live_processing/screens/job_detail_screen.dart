import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../../../core/router.dart';
import '../../../domain/models/job.dart';
import '../../../domain/enums/job_status.dart';
import '../../../domain/enums/pipeline_layer.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../data/repositories/websocket_repository.dart';
import '../../../data/repositories/monitoring_repository.dart';
import '../../../shared/widgets/log_panel.dart';
import '../../../core/theme.dart';

class JobDetailScreen extends ConsumerStatefulWidget {
  final dynamic initialData; // Could be Job or String (jobId)
  const JobDetailScreen({super.key, this.initialData});

  @override
  ConsumerState<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends ConsumerState<JobDetailScreen> {
  Job? _job;
  String? _jobId;
  bool _loading = true;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    if (widget.initialData is Job) {
      setState(() {
        _job = widget.initialData as Job;
        _jobId = _job!.jobId;
        _loading = false;
      });
    } else if (widget.initialData is String) {
      _jobId = widget.initialData as String;
      await _fetchJob();
    } else {
      setState(() {
        _error = 'No job data provided';
        _loading = false;
      });
    }
  }

  Future<void> _fetchJob() async {
    if (_jobId == null) return;
    try {
      final repo = ref.read(apiRepositoryProvider);
      final job = await repo.getJobStatus(_jobId!);
      if (!mounted) return;
      setState(() {
        _job = job;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load job: $e';
        _loading = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_job?.status.isFinal == true) {
        _pollTimer?.cancel();
        return;
      }
      await _fetchJob();
    });
  }

  Future<void> _startJob() async {
    if (_jobId == null) return;
    try {
      final repo = ref.read(apiRepositoryProvider);
      final job = await repo.startJob(_jobId!);
      setState(() => _job = job);
      _startPolling();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _retryJob() async {
    await _startJob();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_job?.filename ?? 'Job Detail'),
        actions: [
          if (_job?.status == OverallJobStatus.error)
            TextButton.icon(
              onPressed: _retryJob,
              icon: const Icon(Icons.replay, size: 18),
              label: const Text('Retry'),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFE17055))))
              : _job == null
                  ? const Center(child: Text('Job not found'))
                  : _buildContent(),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await _fetchJob();
        _startPolling();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status header
          _buildStatusHeader(),
          const SizedBox(height: 20),

          // Layer stages
          const Text('Pipeline Stages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...List.generate(8, (i) => _buildStage(i + 1)),
          const SizedBox(height: 20),

          // Logs
          const Text('Live Logs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 200,
            child: Consumer(
              builder: (context, ref, child) {
                final state = ref.watch(webSocketProvider);
                if (state.logMessages.isEmpty && _job?.status == OverallJobStatus.queued) {
                  return const Center(
                    child: Text(
                      'Logs will appear here when processing starts',
                      style: TextStyle(color: Color(0xFF9595B0), fontSize: 13),
                    ),
                  );
                }
                return AaeLogPanel(logs: state.logMessages);
              },
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons
          _buildActions(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStatusHeader() {
    final job = _job!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  _statusIcon(),
                  color: _statusColor(),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.status.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(),
                        ),
                      ),
                      Text(
                        'Job ID: ${job.jobId}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF9595B0)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (job.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                  ),
                  child: Text(job.error!, style: TextStyle(color: AppTheme.error, fontSize: 13)),
                ),
              ),
            if (job.status == OverallJobStatus.complete)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ref.read(apiRepositoryProvider).getDownloadUrl(job.jobId).then(
                        (url) {
                          Navigator.pushNamed(
                            context,
                            Routes.output,
                            arguments: {
                              'url': url,
                              'filename': job.filename,
                              'jobId': job.jobId,
                            },
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.play_circle),
                    label: const Text('View Output'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStage(int layerNum) {
    final job = _job!;
    final status = job.getStageInfo(layerNum);
    final color = _stageColor(status.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Center(
              child: Text(
                layerNum.toString(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              status.name,
              style: TextStyle(
                fontSize: 14,
                color: status.status == JobStageStatus.pending
                    ? const Color(0xFF6C6C85)
                    : const Color(0xFFEAEAFF),
              ),
            ),
          ),
          Text(
            status.status.label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final job = _job!;
    if (job.status == OverallJobStatus.queued) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _startJob,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Processing'),
        ),
      );
    }
    if (job.status == OverallJobStatus.processing) {
      return const Center(
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 8),
            Text('Processing...', style: TextStyle(color: Color(0xFF9595B0), fontSize: 14)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  IconData _statusIcon() {
    switch (_job!.status) {
      case OverallJobStatus.complete:
        return Icons.check_circle;
      case OverallJobStatus.processing:
        return Icons.play_circle;
      case OverallJobStatus.error:
        return Icons.error;
      default:
        return Icons.schedule;
    }
  }

  Color _statusColor() {
    switch (_job!.status) {
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
}
