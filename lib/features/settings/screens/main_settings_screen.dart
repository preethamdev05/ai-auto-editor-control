import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/local/storage_service.dart';
import '../../../core/router.dart';

class MainSettingsScreen extends StatelessWidget {
  const MainSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.only(top: 8),
        children: [
          _SectionHeader('Backend'),
          ListTile(
            leading: const Icon(Icons.computer),
            title: const Text('Connection'),
            subtitle: const Text('Paired PC address'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.connection),
          ),
          _Divider(),
          _SectionHeader('App'),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configuration'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.config),
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Job History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.history),
          ),
          _Divider(),
          _SectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('Clear All Data'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showClearDialog(context),
          ),
          _Divider(),
          _SectionHeader('Info'),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Help & About'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.pushNamed(context, Routes.help),
          ),
          const ListTile(
            title: Center(child: Text('AI Auto Editor Control', style: TextStyle(color: Color(0xFF6C6C85), fontSize: 12))),
            subtitle: Center(child: Text('v0.1.0', style: TextStyle(color: Color(0xFF6C6C85), fontSize: 11))),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text('This will remove all saved settings, job history, and connection data. Continue?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final service = StorageService();
              await service.clearAll();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared'), behavior: SnackBarBehavior.floating),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Color(0xFFE17055))),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF6C6C85), letterSpacing: 1)),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(indent: 24, endIndent: 24, height: 8);
  }
}
