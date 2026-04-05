import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../domain/enums/connection_status.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../jobs/screens/jobs_screen.dart';
import '../../upload/screens/upload_screen.dart';
import '../../monitoring/screens/monitoring_screen.dart';
import '../../settings/screens/main_settings_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const JobsScreen(),
    const UploadScreen(),
    const MonitoringScreen(),
    const MainSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(connectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Auto Editor'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusBg(connectionStatus),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: _statusDot(connectionStatus),
                ),
                const SizedBox(width: 6),
                Text(
                  connectionStatus.label,
                  style: TextStyle(
                    color: _statusDot(connectionStatus),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.playlist_play_outlined), activeIcon: Icon(Icons.playlist_play), label: 'Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.upload_file_outlined), activeIcon: Icon(Icons.upload_file), label: 'Upload'),
          BottomNavigationBarItem(icon: Icon(Icons.monitor_heart_outlined), activeIcon: Icon(Icons.monitor_heart), label: 'Monitor'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Color _statusBg(ConnectionStatus s) {
    switch (s) {
      case ConnectionStatus.connected:
        return AppTheme.success.withOpacity(0.15);
      case ConnectionStatus.error:
        return AppTheme.error.withOpacity(0.15);
      case ConnectionStatus.connecting:
        return AppTheme.warning.withOpacity(0.15);
      default:
        return Colors.grey.withOpacity(0.15);
    }
  }

  Color _statusDot(ConnectionStatus s) {
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
