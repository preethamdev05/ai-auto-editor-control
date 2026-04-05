enum ConnectionStatus {
  connected,
  connecting,
  error,
  disconnected;

  String get label {
    switch (this) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting...';
      case ConnectionStatus.error:
        return 'Connection Error';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }
}
