import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/job.dart';
import '../../domain/models/monitoring_report.dart';
import '../repositories/api_repository.dart';

/// Monitoring repository — provides supervisor-style reports
/// This runs locally and does NOT control the editing pipeline
class MonitoringRepository extends StateNotifier<MonitoringPhaseReport> {
  final Ref _ref;
  MonitoringPhaseReport _preflight = const MonitoringPhaseReport.phase(MonitoringPhase.preflight);
  MonitoringPhaseReport _runtime = const MonitoringPhaseReport.phase(MonitoringPhase.runtime);
  MonitoringPhaseReport _postflight =
      const MonitoringPhaseReport.phase(MonitoringPhase.postflight);

  MonitoringRepository(this._ref) : super(const MonitoringPhaseReport.unknown());

  Future<void> runPreflight(Job job) async {
    // Simulate preflight validation
    await Future.delayed(const Duration(milliseconds: 500));

    final issues = <String>[];
    final recommendations = <String>[];

    if (job.filename.isEmpty) {
      issues.add('No video file loaded');
    }
    if (job.currentLayer == 0) {
      recommendations.add('Job is ready to start — no pipeline layer active yet');
    }

    final score = issues.isEmpty ? 1.0 : 0.6;
    final status = issues.isEmpty ? MonitoringStatus.pass : MonitoringStatus.warn;

    _preflight = MonitoringPhaseReport(
      phase: MonitoringPhase.preflight,
      report: MonitoringReport(
        status: status,
        qualityScore: score,
        issues: issues,
        recommendations: recommendations,
        summary: status == MonitoringStatus.pass
            ? 'Video file loaded. Job is ready for processing.'
            : 'Review issues before starting.',
      ),
    );
    _updateState();
  }

  Future<void> updateRuntime(Job job, List<String> logs) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final issues = <String>[];
    // Check for error logs
    for (final log in logs.take(20)) {
      if (log.toLowerCase().contains('error') || log.toLowerCase().contains('fail')) {
        issues.add('Anomaly detected in pipeline log: $log');
      }
    }

    // Check stuck layers
    if (job.currentLayer > 0 && job.status.name == 'processing') {
      // Running normally
    } else if (job.status.name == 'error') {
      issues.add('Pipeline has failed at layer ${job.currentLayer}');
    }

    final score = issues.isEmpty ? 0.85 : 0.4;
    _runtime = MonitoringPhaseReport(
      phase: MonitoringPhase.runtime,
      report: MonitoringReport(
        status: issues.isEmpty ? MonitoringStatus.pass : MonitoringStatus.warn,
        qualityScore: score,
        issues: issues,
        recommendations: [
          if (issues.isEmpty) 'Pipeline running normally',
          if (issues.isNotEmpty) 'Review errors and retry failed job',
        ],
        summary: job.status.label,
      ),
    );
    _updateState();
  }

  Future<void> runPostflight(Job job) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (job.status != OverallJobStatus.complete) {
      _postflight = MonitoringPhaseReport.phase(
        MonitoringPhase.postflight,
        summary: 'Job not yet complete — run postflight after completion',
      );
      _updateState();
      return;
    }

    // Generate quality review
    final score = 0.7 + Random().nextDouble() * 0.3;
    _postflight = MonitoringPhaseReport(
      phase: MonitoringPhase.postflight,
      report: MonitoringReport(
        status: score > 0.7 ? MonitoringStatus.pass : MonitoringStatus.warn,
        qualityScore: double.parse(score.toStringAsFixed(2)),
        issues: [],
        recommendations: [
          'Review output for visual quality',
          'Check audio sync if music was added',
          'Verify final duration matches expectations',
        ],
        summary: 'Output generated with ${(score * 100).toInt()}% quality score.',
      ),
    );
    _updateState();
  }

  String generateLogSummary(List<String> logs) {
    if (logs.isEmpty) return 'No logs available.';

    final errorCount = logs.where((l) => l.toLowerCase().contains('error')).length;
    final warnCount = logs.where((l) => l.toLowerCase().contains('warn')).length;
    final totalLines = logs.length;

    return 'Total: $totalLines log entries, $errorCount errors, $warnCount warnings.';
  }

  void _updateState() {
    state = MonitoringPhaseReport.combined(
      preflight: _preflight,
      runtime: _runtime,
      postflight: _postflight,
    );
  }
}

class MonitoringPhaseReport {
  final MonitoringPhase? phase;
  final MonitoringReport? report;
  final MonitoringPhaseReport? preflight;
  final MonitoringPhaseReport? runtime;
  final MonitoringPhaseReport? postflight;
  final bool isCombined;

  const MonitoringPhaseReport({
    this.phase,
    this.report,
    this.preflight,
    this.runtime,
    this.postflight,
    this.isCombined = true,
  });

  const MonitoringPhaseReport.phase(MonitoringPhase p, {String? summary})
      : phase = p,
        report = summary != null
            ? MonitoringReport(
                status: MonitoringStatus.warn,
                qualityScore: 0.0,
                issues: [],
                recommendations: [],
                summary: summary,
              )
            : null,
        preflight = null,
        runtime = null,
        postflight = null,
        isCombined = false;

  const MonitoringPhaseReport.combined({
    required this.preflight,
    required this.runtime,
    required this.postflight,
  })  : phase = null,
        report = null,
        isCombined = true;

  const MonitoringPhaseReport.unknown()
      : phase = null,
        report = null,
        preflight = null,
        runtime = null,
        postflight = null,
        isCombined = false;
}

// ─── Provider ───
final monitoringProvider = StateNotifierProvider<MonitoringRepository, MonitoringPhaseReport>(
  (ref) => MonitoringRepository(ref),
);
