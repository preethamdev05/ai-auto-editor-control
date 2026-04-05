import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(
            child: Column(
              children: [
                Icon(Icons.video_settings, size: 64, color: Color(0xFF6C5CE7)),
                SizedBox(height: 16),
                Text('AI Auto Editor Control', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                SizedBox(height: 4),
                Text('v0.1.0', style: TextStyle(color: Color(0xFF9595B0))),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('Getting Started', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _steps(),
          const SizedBox(height: 24),
          const Text('How It Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _howItWorks(),
          const SizedBox(height: 24),
          const Text('Troubleshooting', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _troubleshooting(),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Built by Preetham N\nBackend: AI Auto Editor Engine',
              style: TextStyle(color: Color(0xFF6C6C85), fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _steps() {
    final steps = [
      'Connect to your local AI Auto Editor backend (same network)',
      'Upload a video and optionally a background song',
      'Choose a preset (interview, action, cinematic, etc.)',
      'Start processing and watch progress live',
      'Download the completed video',
    ];
    return Column(
      children: steps.asMap().entries.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF6C5CE7).withOpacity(0.2),
                child: Text('${e.key + 1}', style: const TextStyle(color: Color(0xFF6C5CE7), fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(e.value, style: const TextStyle(fontSize: 14))),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _howItWorks() {
    const points = [
      'Your video is uploaded to the local backend which runs a pipeline of 8 automated editing stages',
      'Each stage (ingest, signal extraction, semantic analysis, etc.) processes the video incrementally',
      'The backend streams live progress through WebSocket connections',
      'The app monitors the quality and detects anomalies during processing',
    ];
    return Column(
      children: points.map((p) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  ', style: TextStyle(color: Color(0xFF9595B0))),
            Expanded(child: Text(p, style: const TextStyle(fontSize: 14))),
          ],
        ),
      )).toList(),
    );
  }

  Widget _troubleshooting() {
    return const Column(
      children: [
        _TroubleshootItem(q: 'Can\'t connect to backend?', a: 'Make sure the backend is running on your PC and the device is on the same network. Enter the LAN IP (e.g., 192.168.1.x:8000).'),
        _TroubleshootItem(q: 'Upload fails?', a: 'Check file size limits and ensure the backend is reachable. Try pinging the server first.'),
        _TroubleshootItem(q: 'Processing stuck?', a: 'Check the live log panel for errors. You can retry failed jobs from the Jobs tab.'),
      ],
    );
  }
}

class _TroubleshootItem extends StatelessWidget {
  final String q;
  final String a;
  const _TroubleshootItem({required this.q, required this.a});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 4),
          Text(a, style: const TextStyle(fontSize: 13, color: Color(0xFF9595B0))),
        ],
      ),
    );
  }
}
