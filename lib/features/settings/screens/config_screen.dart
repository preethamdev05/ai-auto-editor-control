import 'package:flutter/material.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuration')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConfigSection(title: 'Whisper', rows: [
              _ConfigRow(label: 'Model', value: 'tiny'),
              _ConfigRow(label: 'Device', value: 'cpu'),
            ]),
          ],
        ),
      ),
    );
  }
}

class _ConfigSection extends StatelessWidget {
  final String title;
  final List<Widget> rows;
  const _ConfigSection({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Card(child: Column(children: rows)),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ConfigRow extends StatelessWidget {
  final String label;
  final String value;
  const _ConfigRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: Text(value, style: const TextStyle(color: Color(0xFF9595B0), fontSize: 13)),
    );
  }
}
