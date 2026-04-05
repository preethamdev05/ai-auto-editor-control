class MonitoringReport {
  final MonitoringStatus status;
  final double qualityScore;
  final List<String> issues;
  final List<String> recommendations;
  final String summary;

  const MonitoringReport({
    required this.status,
    required this.qualityScore,
    required this.issues,
    required this.recommendations,
    required this.summary,
  });

  factory MonitoringReport.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] ?? 'warn';
    return MonitoringReport(
      status: MonitoringStatus.values.firstWhere(
        (v) => v.name == statusStr.toLowerCase(),
        orElse: () => MonitoringStatus.warn,
      ),
      qualityScore: (json['quality_score'] ?? 0.5).toDouble(),
      issues: (json['issues'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      recommendations: (json['recommendations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      summary: json['summary'] ?? '',
    );
  }

  factory MonitoringReport.empty() {
    return const MonitoringReport(
      status: MonitoringStatus.warn,
      qualityScore: 0.0,
      issues: [],
      recommendations: [],
      summary: 'No monitoring data yet. Process a job to generate reports.',
    );
  }
}

enum MonitoringStatus {
  pass,
  warn,
  fail;

  String get label {
    switch (this) {
      case MonitoringStatus.pass:
        return 'Pass';
      case MonitoringStatus.warn:
        return 'Warning';
      case MonitoringStatus.fail:
        return 'Fail';
    }
  }
}

/// Represents the monitoring phase (preflight, runtime, postflight)
enum MonitoringPhase {
  preflight('Preflight Validation'),
  runtime('Runtime Anomaly Detection'),
  postflight('Post-flight Quality Review');

  final String label;
  const MonitoringPhase(this.label);
}
