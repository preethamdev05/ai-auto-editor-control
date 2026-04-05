enum ConnectionStatus {
  disconnected('Disconnected', 'Tap to connect'),
  connecting('Connecting...', 'Checking backend health'),
  connected('Connected', 'Backend ready'),
  error('Connection Error', 'Unable to reach backend');

  final String label;
  final String subtitle;

  const ConnectionStatus(this.label, this.subtitle);
}
