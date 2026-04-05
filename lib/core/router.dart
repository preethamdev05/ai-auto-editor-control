import 'package:flutter/material.dart';
import '../main_nav_screen.dart';
import '../features/connection/screens/connection_screen.dart';
import '../features/live_processing/screens/job_detail_screen.dart';
import '../features/output/screens/output_screen.dart';
import '../features/monitoring/screens/monitoring_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/settings/screens/help_screen.dart';
import '../features/settings/screens/config_screen.dart';

class Routes {
  static const String splash = '/splash';
  static const String connection = '/connection';
  static const String dashboard = '/dashboard';
  static const String upload = '/upload';
  static const String jobs = '/jobs';
  static const String jobDetail = '/job-detail';
  static const String presets = '/presets';
  static const String config = '/config';
  static const String monitoring = '/monitoring';
  static const String history = '/history';
  static const String settings = '/settings';
  static const String output = '/output';
  static const String help = '/help';
  static const String songUpload = '/song-upload';
}

class AaeRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => _screenFor(settings.name, settings.arguments),
      settings: settings,
    );
  }

  static Widget _screenFor(String? routeName, Object? args) {
    switch (routeName) {
      case Routes.connection:
        return const ConnectionScreen();
      case Routes.jobDetail:
        return JobDetailScreen(initialData: args);
      case Routes.output:
        if (args is Map<String, dynamic>) {
          return OutputScreen(
            downloadUrl: args['url'] ?? '',
            fileName: args['filename'] ?? 'output.mp4',
            jobId: args['jobId'] ?? '',
          );
        }
        return const MainNavigationScreen();
      case Routes.monitoring:
        return const MonitoringScreen();
      case Routes.history:
        return const HistoryScreen();
      case Routes.help:
        return const HelpScreen();
      case Routes.config:
        return const ConfigScreen();
      case Routes.dashboard:
      case Routes.jobs:
      case Routes.settings:
      case Routes.upload:
      default:
        return const MainNavigationScreen();
    }
  }
}
