import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import '../../core/constants.dart';

/// Types of WebSocket messages from the backend
class WsMessage {
  final String type;
  final Map<String, dynamic> data;

  WsMessage({required this.type, required this.data});

  factory WsMessage.fromJson(Map<String, dynamic> json) {
    // Flatten: extract known top-level keys as data
    final type = json['type'] ?? 'unknown';
    final copy = Map<String, dynamic>.from(json);
    copy.remove('type');
    return WsMessage(type: type, data: copy);
  }
}

class WebSocketService {
  final String _baseUrl;
  WebSocketChannel? _channel;
  String? _currentJobId;

  final _messagesController = StreamController<WsMessage>.broadcast();
  final _connectionStateController = StreamController<bool>.broadcast();

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _isDisposed = false;

  Stream<WsMessage> get messages => _messagesController.stream;
  Stream<bool> get connectionState => _connectionStateController.stream;
  bool get isConnected => _channel != null;

  WebSocketService({String? baseUrl})
      : _baseUrl = (baseUrl ?? 'http://localhost:8000')
            .replaceAll('http://', 'ws://')
            .replaceAll('https://', 'wss://');

  void connect(String jobId) {
    if (_currentJobId == jobId && _channel != null) return;
    _disconnect();

    _currentJobId = jobId;
    _reconnectAttempts = 0;
    _connectWs(jobId);
  }

  void _connectWs(String jobId) {
    if (_isDisposed) return;

    final wsUrl = '$_baseUrl/ws/$jobId';
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _connectionStateController.add(true);

      _channel!.stream.listen(
        (raw) {
          _reconnectAttempts = 0;
          if (raw is String) {
            try {
              final json = jsonDecode(raw) as Map<String, dynamic>;
              _messagesController.add(WsMessage.fromJson(json));
            } catch (_) {
              // ignore malformed messages
            }
          }
        },
        onError: (_) => _handleDisconnect(),
        onDone: () => _handleDisconnect(),
      );
    } catch (e) {
      _handleDisconnect();
    }
  }

  void _handleDisconnect() {
    _connectionStateController.add(false);
    _channel = null;

    if (_isDisposed || _currentJobId == null) return;

    if (_reconnectAttempts < AppConstants.wsReconnectMaxRetries) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(
        Duration(milliseconds: AppConstants.wsReconnectDelayMs * (_reconnectAttempts + 1)),
        () {
          _reconnectAttempts++;
          _connectWs(_currentJobId!);
        },
      );
    }
  }

  void _disconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _channel?.sink.close(ws_status.goingAway);
    _channel = null;
  }

  void sendText(String text) {
    _channel?.sink.add(text);
  }

  void dispose() {
    _isDisposed = true;
    _disconnect();
    _messagesController.close();
    _connectionStateController.close();
  }
}
