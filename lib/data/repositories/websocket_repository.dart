import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../remote/websocket_service.dart';
import '../repositories/api_repository.dart';
import '../../core/constants.dart';

/// Live job state from WebSocket
class JobLiveState {
  final int currentLayer;
  final String? currentLayerName;
  final String lastLogMessage;
  final List<String> logMessages;
  final bool isWsConnected;
  final bool isComplete;
  final String? errorMessage;
  final int progressPercent;

  const JobLiveState({
    this.currentLayer = 0,
    this.currentLayerName,
    this.lastLogMessage = '',
    this.logMessages = const [],
    this.isWsConnected = false,
    this.isComplete = false,
    this.errorMessage,
    this.progressPercent = 0,
  });

  JobLiveState copyWith({
    int? currentLayer,
    String? currentLayerName,
    String? lastLogMessage,
    String? appendLog,
    bool? isWsConnected,
    bool? isComplete,
    String? errorMessage,
    int? progressPercent,
  }) {
    final newLogs = appendLog != null
        ? [...logMessages, appendLog].take(200).toList()
        : logMessages;
    return JobLiveState(
      currentLayer: currentLayer ?? this.currentLayer,
      currentLayerName: currentLayerName ?? this.currentLayerName,
      lastLogMessage: lastLogMessage ?? this.lastLogMessage,
      logMessages: newLogs,
      isWsConnected: isWsConnected ?? this.isWsConnected,
      isComplete: isComplete ?? this.isComplete,
      errorMessage: errorMessage ?? this.errorMessage,
      progressPercent: progressPercent ?? this.progressPercent,
    );
  }
}

class WebSocketRepository extends StateNotifier<JobLiveState> {
  WebSocketService? _ws;
  String? _jobId;

  WebSocketRepository() : super(const JobLiveState());

  void connect(String jobId, String baseUrl) {
    _disconnect();
    _jobId = jobId;

    final wsBaseUrl = baseUrl.replaceAll('http://', 'ws://').replaceAll('https://', 'wss://');
    _ws = WebSocketService(baseUrl: wsBaseUrl);
    _ws!.connect(jobId);

    _ws!.connectionState.listen((connected) {
      state = state.copyWith(isWsConnected: connected);
    });

    _ws!.messages.listen((msg) {
      _handleMessage(msg);
    });
  }

  void _handleMessage(dynamic msg) {
    final type = msg is Map ? (msg['type'] as String?) : (msg as dynamic).type;
    final data = msg is Map ? msg : (msg as dynamic).data;

    switch (type) {
      case 'progress':
        final layer = data['layer'] as int? ?? 0;
        final name = data['name'] as String?;
        final percent = ((layer) / 8 * 100).round();
        state = state.copyWith(
          currentLayer: layer,
          currentLayerName: name,
          progressPercent: percent,
        );

      case 'log':
        final logMsg = data['message'] as String? ?? '';
        state = state.copyWith(
          lastLogMessage: logMsg,
          appendLog: _formatLog(logMsg),
        );

      case 'complete':
        state = state.copyWith(
          isComplete: true,
          appendLog: '✅ Pipeline completed successfully',
          progressPercent: 100,
        );

      case 'error':
        final errMsg = data['message'] as String? ?? 'Unknown error';
        state = state.copyWith(
          errorMessage: errMsg,
          appendLog: '❌ $errMsg',
        );

      case 'status':
        final jobData = data['data'];
        if (jobData is Map) {
          final layer = jobData['layer'] as int? ?? 0;
          final rawStatus = jobData['status'] as String? ?? '';
          final isComplete = rawStatus == 'complete' || rawStatus == 'completed';
          state = state.copyWith(
            currentLayer: layer,
            currentLayerName: AppConstants.layerNames[layer],
            isComplete: isComplete,
            progressPercent: isComplete ? 100 : (layer / 8 * 100).round(),
          );
        }
    }
  }

  void _disconnect() {
    _ws?.dispose();
    _ws = null;
  }

  static String _formatLog(String msg) {
    final now = DateTime.now();
    final time = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return '[$time] $msg';
  }

  void dispose() {
    _disconnect();
  }
}

// ─── Provider ───
final webSocketProvider = StateNotifierProvider<WebSocketRepository, JobLiveState>(
  (ref) => WebSocketRepository(),
);
