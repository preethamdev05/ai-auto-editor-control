import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/storage_service.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  List<String> _downloadHistory = [];
  List<String> _jobTitles = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final storage = StorageService();
    final history = await storage.loadDownloadHistory();

    // Try to get job names from API
    try {
      final repo = ref.read(apiRepositoryProvider);
      final jobs = await repo.listJobs();
      final titles = <String>[];
      for (final jobId in history) {
        final job = jobs.where((j) => j.jobId == jobId).firstOrNull;
        titles.add(job?.filename ?? 'Job $jobId');
      }
      if (!mounted) return;
      setState(() {
        _downloadHistory = history;
        _jobTitles = titles;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _downloadHistory = history;
        _jobTitles = history.map((id) => 'Job $id').toList();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Download History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _downloadHistory.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download_outlined, size: 64, color: Color(0xFF353555)),
                      SizedBox(height: 16),
                      Text('No downloads yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                      SizedBox(height: 8),
                      Text('Downloaded videos will appear here.', style: TextStyle(color: Color(0xFF9595B0), fontSize: 14)),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _downloadHistory.length,
                  itemBuilder: (_, i) {
                    return ListTile(
                      leading: const Icon(Icons.video_library),
                      title: Text(_jobTitles.length > i ? _jobTitles[i] : _downloadHistory[i]),
                      subtitle: Text(_downloadHistory[i], style: const TextStyle(fontSize: 11, color: Color(0xFF9595B0))),
                      trailing: OutlinedButton(
                        onPressed: () {
                          final repo = ref.read(apiRepositoryProvider);
                          repo.getDownloadUrl(_downloadHistory[i]).then(
                            (url) => Navigator.pushNamed(
                              context,
                              Routes.output,
                              arguments: {'url': url, 'filename': _jobTitles[i], 'jobId': _downloadHistory[i]},
                            ),
                          );
                        },
                        child: const Text('Open'),
                      ),
                    );
                  },
                ),
    );
  }
}
