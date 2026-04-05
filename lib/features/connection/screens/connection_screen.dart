import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../domain/enums/connection_status.dart';

class ConnectionScreen extends ConsumerStatefulWidget {
  const ConnectionScreen({super.key});

  @override
  ConsumerState<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends ConsumerState<ConnectionScreen> {
  final _controller = TextEditingController();
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _loadSavedHost();
  }

  Future<void> _loadSavedHost() async {
    final connection = ref.read(connectionProvider.notifier);
    _controller.text = connection.baseUrl;
  }

  Future<void> _connect() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _checking = true);

    try {
      await HapticFeedback.mediumImpact();
      final result = await ref.read(connectionProvider.notifier).checkHealth(
        host: _controller.text.trim(),
      );

      if (!mounted) return;
      setState(() => _checking = false);

      if (result) {
        ref.read(connectionProvider.notifier);
        if (mounted) {
          Navigator.pushReplacementNamed(context, Routes.dashboard);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Connected to backend'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Color(0xFF00B894),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Unable to reach backend. Check the URL and try again.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFFE17055),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _checking = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect to Backend')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Icon(
              Icons.computer,
              size: 80,
              color: Color(0xFF6C5CE7),
            ),
            const SizedBox(height: 24),
            const Text(
              'Local Backend Address',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFFEAEAFF)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the LAN IP address and port of your AI Auto Editor backend.',
              style: TextStyle(fontSize: 14, color: Color(0xFF9595B0)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                hintText: 'http://192.168.1.100:8000',
                prefixIcon: const Icon(Icons.link, color: Color(0xFF9595B0)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste, color: Color(0xFF9595B0)),
                  onPressed: () async {
                    final clip = await Clipboard.getData('text/plain');
                    if (clip != null && clip.text != null) {
                      _controller.text = clip.text!;
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checking ? null : _connect,
              child: _checking
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Connect & Check Health'),
            ),
            const SizedBox(height: 32),
            _buildQuickActions(),
            const Spacer(),
            _buildHealthStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Quick Connect:', style: TextStyle(color: Color(0xFF9595B0), fontSize: 13)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _quickChip('localhost:8000'),
            _quickChip('192.168.1.100:8000'),
            _quickChip('10.0.0.1:8000'),
          ],
        ),
      ],
    );
  }

  Widget _quickChip(String host) {
    return ActionChip(
      label: Text(host, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        _controller.text = 'http://$host';
      },
    );
  }

  Widget _buildHealthStatus() {
    final status = ref.watch(connectionProvider);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _statusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: _statusColor(status)),
          const SizedBox(width: 8),
          Text(status.label, style: TextStyle(color: _statusColor(status), fontSize: 13)),
        ],
      ),
    );
  }

  Color _statusColor(ConnectionStatus s) {
    switch (s) {
      case ConnectionStatus.connected:
        return AppTheme.success;
      case ConnectionStatus.connecting:
        return AppTheme.warning;
      case ConnectionStatus.error:
        return AppTheme.error;
      default:
        return AppTheme.warning;
    }
  }
}
