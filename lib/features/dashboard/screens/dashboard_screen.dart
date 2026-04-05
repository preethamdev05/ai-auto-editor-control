import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../data/repositories/websocket_repository.dart';
import '../../../data/repositories/monitoring_repository.dart';
import '../../../domain/enums/connection_status.dart';
import '../../../domain/enums/job_status.dart';
import '../../../domain/models/job.dart';
import '../../../shared/widgets/job_card.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  List<Job> _jobs = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final status = ref.read(connectionProvider);
    if (status != ConnectionStatus.connected) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repo = ref.read(apiRepositoryProvider);
      final jobs = await repo.listJobs();
      if (!mounted) return;
      setState(() {
        _jobs = jobs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildQuickStats()),
            SliverToBoxAdapter(child: _buildSectionTitle('Recent Jobs')),
            if (_loading)
              const SliverToBoxAdapter(child: _LoadingJobs())
            else if (_error != null)
              SliverToBoxAdapter(child: _buildError())
            else if (_jobs.isEmpty)
              const SliverToBoxAdapter(child: _EmptyState())
            else
              SliverList.builder(
                itemCount: _jobs.length.clamp(0, 10),
                itemBuilder: (_, i) => _buildJobItem(_jobs[i]),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final status = ref.watch(connectionProvider);
    final now = DateFormat('EEEE, MMM d').format(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(now, style: const TextStyle(color: Color(0xFF9595B0), fontSize: 14)),
          const SizedBox(height: 4),
          const Text(
            'Dashboard',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFFEAEAFF)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.videocam_outlined,
                  label: 'Connection',
                  value: status.label,
                  color: _statusColor(status),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.assignment_outlined,
                  label: 'Total Jobs',
                  value: '${_jobs.length}',
                  color: AppTheme.primaryVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required IconData icon, required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF282840),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF9595B0))),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    final processing = _jobs.where((j) => j.status == OverallJobStatus.processing).length;
    final completed = _jobs.where((j) => j.status == OverallJobStatus.complete).length;
    final errors = _jobs.where((j) => j.status == OverallJobStatus.error).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickStat('Processing', '$processing', AppTheme.info),
              _quickStat('Completed', '$completed', AppTheme.success),
              _quickStat('Failed', '$errors', AppTheme.error),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9595B0))),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          TextButton(
            onPressed: () {
              // navigate to jobs tab in parent Nav
            },
            child: const Text('View All'),
          ),
        ],
      ),
    );
  }

  Widget _buildJobItem(Job job) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: JobCard(
        job: job,
        onTap: () {
          Navigator.pushNamed(
            context,
            Routes.jobDetail,
            arguments: job,
          );
        },
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFE17055)),
          const SizedBox(height: 12),
          Text('Failed to load jobs: $_error', style: const TextStyle(color: Color(0xFF9595B0))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
        ],
      ),
    );
  }

  Color _statusColor(ConnectionStatus s) {
    switch (s) {
      case ConnectionStatus.connected:
        return AppTheme.success;
      case ConnectionStatus.error:
        return AppTheme.error;
      case ConnectionStatus.connecting:
        return AppTheme.warning;
      default:
        return Colors.grey;
    }
  }
}

class _LoadingJobs extends StatelessWidget {
  const _LoadingJobs();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF353555)),
          const SizedBox(height: 16),
          const Text('No jobs yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          const Text(
            'Upload a video to get started',
            style: TextStyle(color: Color(0xFF9595B0), fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
