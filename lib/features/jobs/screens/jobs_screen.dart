import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../domain/models/job.dart';
import '../../../domain/enums/job_status.dart';
import '../../../shared/widgets/job_card.dart';
import '../../../core/router.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> with SingleTickerProviderStateMixin {
  List<Job> _jobs = [];
  bool _loading = true;
  String? _error;
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _currentTab = _tabController.index);
    });
    _refresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
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

  List<Job> get _filteredJobs {
    switch (_currentTab) {
      case 0: // All
        return _jobs;
      case 1: // Active
        return _jobs.where((j) => j.status == OverallJobStatus.processing || j.status == OverallJobStatus.queued).toList();
      case 2: // Completed
        return _jobs.where((j) => j.status == OverallJobStatus.complete || j.status == OverallJobStatus.error).toList();
      default:
        return _jobs;
    }
  }

  Future<void> _retryJob(Job job) async {
    try {
      final repo = ref.read(apiRepositoryProvider);
      await repo.startJob(job.jobId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Job restarted!'), behavior: SnackBarBehavior.floating, backgroundColor: Color(0xFF00B894)),
      );
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Retry failed: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
            indicatorColor: Colors.deepPurpleAccent,
            labelColor: Colors.deepPurpleAccent,
            unselectedLabelColor: const Color(0xFF9595B0),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _buildError()
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: _filteredJobs.isEmpty
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.assignment_turned_in_outlined, size: 64, color: Color(0xFF353555)),
                                  SizedBox(height: 16),
                                  Text('No jobs found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                                  SizedBox(height: 8),
                                  Text('Pull to refresh', style: TextStyle(color: Color(0xFF9595B0), fontSize: 14)),
                                ],
                              ),
                            )
                          : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _filteredJobs.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (_, i) => _buildJobItem(_filteredJobs[i]),
                          ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobItem(Job job) {
    return Dismissible(
      key: Key(job.jobId),
      direction: job.status == OverallJobStatus.error ? DismissDirection.endToStart : DismissDirection.none,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.replay, color: Color(0xFFE17055)),
      ),
      confirmDismiss: (_) async {
        if (job.status == OverallJobStatus.error) {
          await _retryJob(job);
          return false;
        }
        return false;
      },
      child: JobCard(
        job: job,
        onTap: () {
          Navigator.pushNamed(context, Routes.jobDetail, arguments: job);
        },
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFE17055)),
          const SizedBox(height: 12),
          Text('Failed to load: $_error', style: const TextStyle(color: Color(0xFF9595B0))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _refresh, child: const Text('Retry')),
        ],
      ),
    );
  }
}
