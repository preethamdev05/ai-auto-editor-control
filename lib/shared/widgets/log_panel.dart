import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class AaeLogPanel extends StatelessWidget {
  final List<String> logs;
  final ScrollController? scrollController;

  const AaeLogPanel({super.key, required this.logs, this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF13131F),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A40)),
      ),
      padding: const EdgeInsets.all(12),
      constraints: const BoxConstraints(minHeight: 180),
      child: logs.isEmpty ? _emptyState() : _logList(),
    );
  }

  Widget _emptyState() {
    return const Center(
      child: Text(
        'Waiting for logs…',
        style: TextStyle(color: Color(0xFF6C6C85), fontSize: 13),
      ),
    );
  }

  Widget _logList() {
    return ListView.builder(
      controller: scrollController,
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (_, i) {
        final log = logs[i];
        final isError = log.toLowerCase().contains('error') || log.toLowerCase().contains('fail');
        final isComplete = log.toLowerCase().contains('complete') || log.contains('✅');

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            log,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 12,
              color: isError
                  ? AppTheme.error
                  : isComplete
                      ? AppTheme.success
                      : const Color(0xFFB0B0CC),
            ),
          ),
        );
      },
    );
  }
}
