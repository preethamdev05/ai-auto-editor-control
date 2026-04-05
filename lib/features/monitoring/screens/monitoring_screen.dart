import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../data/repositories/monitoring_repository.dart';
import '../../../domain/models/job.dart';
import '../../../domain/enums/job_status.dart';
import '../../../domain/models/monitoring_report.dart';

class MonitoringScreen extends ConsumerStatefulWidget {
  const MonitoringScreen({super.key});

  @override
  ConsumerState<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends ConsumerState<MonitoringScreen> {
  List<Job> _jobs = [];
  Job? _selectedJob;
  bool _loading = true;
  bool _analyzing = false;
  String? _logSummary;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final repo = ref.read(apiRepositoryProvider);
      final jobs = await repo.listJobs();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _loading = false;
      });
      if (jobs.isNotEmpty) {
        _selectJob(jobs.first);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _selectJob(Job job) {
    setState(() => _selectedJob = job);
    _runAllAnalyses(job);
  }

  Future<void> _runAllAnalyses(Job job) async {
    final notifier = ref.read(monitoringProvider.notifier);
    await notifier.runPreflight(job);
    if (job.status == OverallJobStatus.processing || job.status == OverallJobStatus.queued) {
      await notifier.updateRuntime(job, []);
    }
    if (job.status == OverallJobStatus.complete) {
      await notifier.runPostflight(job);
    }
  }

  Future<void> _recheck() async {
    if (_selectedJob == null) return;
    setState(() => _analyzing = true);
    await _runAllAnalyses(_selectedJob!);
    if (mounted) setState(() => _analyzing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildJobSelector()),
                if (_selectedJob == null)
                  const SliverToBoxAdapter(child: _buildEmpty())
                else ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
                      child: Text(
                        'Supervisor Analysis',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildMonitoringPanel()),
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(24, 8, 24, 8),
                      child: Text(
                        'Phase Results',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _buildPhaseResults()),
                  SliverToBoxAdapter(child: _buildRecheckButton()),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monitoring',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4),
          Text(
            'Lightweight quality supervision and anomaly detection',
            style: TextStyle(fontSize: 14, color: Color(0xFF9595B0)),
          ),
        ],
      ),
    );
  }

  Widget _buildJobSelector() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF282840),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF353555)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedJob?.jobId,
            isExpanded: true,
            hint: const Text('Select a job to analyze'),
            dropdownColor: const Color(0xFF282840),
            items: _jobs.map((j) {
              return DropdownMenuItem(
                value: j.jobId,
                child: Text(
                  j.filename,
                  style: const TextStyle(fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (v) {
              final job = _jobs.firstWhere((j) => j.jobId == v, orElse: () => _jobs.first);
              _selectJob(job);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMonitoringPanel() {
    final state = ref.watch(monitoringProvider);

    // Find the most complete report to show
    final report = _getBestReport(state);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: report == null
              ? const _EmptyAnalysis()
              : Column(
                  children: [
                    Row(
                      children: [
                        Icon(_statusIcon(report.status), color: _statusColor(report.status), size: 36),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.status.label,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _statusColor(report.status),
                                ),
                              ),
                              Text(
                                'Quality: ${(report.qualityScore * 100).toInt()}%',
                                style: const TextStyle(fontSize: 13, color: Color(0xFF9595B0)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    if (report.issues.isNotEmpty) ...[
                      const Text('Issues', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFFE17055))),
                      const SizedBox(height: 4),
                      ...report.issues.map((i) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('⚠ ', style: TextStyle(fontSize: 12)),
                            Expanded(child: Text(i, style: const TextStyle(fontSize: 12, color: Color(0xFF9595B0)))),
                          ],
                        ),
                      )),
                    ],
                    if (report.recommendations.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Text('Recommendations', style: TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF00B894))),
                      const SizedBox(height: 4),
                      ...report.recommendations.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡 ', style: TextStyle(fontSize: 12)),
                            Expanded(child: Text(r, style: const TextStyle(fontSize: 12, color: Color(0xFF9595B0)))),
                          ],
                        ),
                      )),
                    ],
                    if (report.summary.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(report.summary, style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFFB0B0CC))),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  MonitoringReport? _getBestReport(MonitoringPhaseReport state) {
    if (state.isCombined) {
      if (state.postflight?.report != null) return state.postflight!.report;
      if (state.runtime?.report != null) return state.runtime!.report;
      return state.preflight?.report;
    }
    return state.report;
  }

  Widget _buildPhaseResults() {
    final state = ref.watch(monitoringProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _phaseCard('🔍 Preflight', state.preflight?.report, MonitoringPhase.preflight.label),
          _phaseCard('⚡ Runtime', state.runtime?.report, MonitoringPhase.runtime.label),
          _phaseCard('✅ Post-flight', state.postflight?.report, MonitoringPhase.postflight.label),
        ],
      ),
    );
  }

  Widget _phaseCard(String title, MonitoringReport? report, String subtitle) {
    final status = report?.status ?? MonitoringStatus.warn;
    final score = report?.qualityScore ?? 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: ListTile(
          leading: Icon(_statusIcon(status), color: _statusColor(status)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('${subtitle} — ${(score * 100).toInt()}%', style: const TextStyle(fontSize: 11)),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor(status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(status.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor(status))),
          ),
        ),
      ),
    );
  }

  Widget _buildRecheckButton() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _analyzing ? null : _recheck,
          icon: _analyzing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.refresh),
          label: Text(_analyzing ? 'Analyzing...' : 'Recheck'),
        ),
      ),
    );
  }

  IconData _statusIcon(MonitoringStatus s) {
    switch (s) {
      case MonitoringStatus.pass:
        return Icons.check_circle;
      case MonitoringStatus.warn:
        return Icons.warning;
      case MonitoringStatus.fail:
        return Icons.error;
    }
  }

  Color _statusColor(MonitoringStatus s) {
    switch (s) {
      case MonitoringStatus.pass:
        return AppTheme.success;
      case MonitoringStatus.warn:
        return AppTheme.warning;
      case MonitoringStatus.fail:
        return AppTheme.error;
    }
  }
}

class _EmptyAnalysis extends StatelessWidget {
  const _EmptyAnalysis();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.analytics_outlined, size: 48, color: Color(0xFF353555)),
          SizedBox(height: 12),
          Text('No analysis data yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text('Select a job to run monitoring analysis.', style: TextStyle(fontSize: 13, color: Color(0xFF9595B0)), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _buildEmpty extends StatelessWidget {
  const _buildEmpty();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.monitor_heart_outlined, size: 64, color: Color(0xFF353555)),
          SizedBox(height: 16),
          Text('No jobs to monitor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Text('Upload a video and start processing to see monitoring data.', style: TextStyle(fontSize: 14, color: Color(0xFF9595B0))),
        ],
      ),
    );
  }
}
