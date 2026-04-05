class AppConstants {
  AppConstants._();

  // App
  static const String appName = 'AI Auto Editor Control';
  static const String version = '0.1.0';

  // Persistence keys
  static const String keyBackendHost = 'backend_host';
  static const String keyPairingToken = 'pairing_token';
  static const String keyRecentJobs = 'recent_jobs';
  static const String keyRecentPresets = 'recent_presets';
  static const String keyConfigDraft = 'config_draft';
  static const String keyDownloadHistory = 'download_history';
  static const String keyConnectionStatus = 'connection_status';
  static const String keyLastSelectedSong = 'last_selected_song';

  // Defaults
  static const String defaultHost = 'http://localhost:8000';

  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int healthCheckTimeoutSeconds = 10;
  static const int wsReconnectDelayMs = 2000;
  static const int wsReconnectMaxRetries = 5;

  // Upload limits
  static const int maxUploadSizeMB = 2048; // 2GB

  // Pipeline layer names
  static const Map<int, String> layerNames = {
    1: 'Ingest',
    2: 'Signal Extraction',
    3: 'Semantic Analysis',
    4: 'Classification',
    5: 'Scoring & Segmentation',
    6: 'Edit Decision List',
    7: 'Rendering',
    8: 'Quality Control',
  };

  // Available presets
  static const List<Map<String, dynamic>> availablePresets = [
    {
      'name': 'interview',
      'label': 'Interview',
      'description': 'Optimize for clear speech, remove dead air',
      'overrides': {
        'audio': {'silence_threshold_db': -30, 'silence_min_duration_ms': 300},
        'scoring': {'keep_floor_score': 0.5, 'nms_window_seconds': 1.5},
        'scene': {'threshold': 30.0},
        'transitions': {'crossfade_frames': 10, 'fade_frames': 18},
      },
    },
    {
      'name': 'action',
      'label': 'Action',
      'description': 'Fast-paced cuts, dynamic transitions',
      'overrides': {
        'audio': {'silence_threshold_db': -40, 'silence_min_duration_ms': 200},
        'scoring': {'keep_floor_score': 0.2, 'nms_window_seconds': 3.0},
        'scene': {'threshold': 20.0},
        'transitions': {'crossfade_frames': 8, 'fade_frames': 12},
      },
    },
    {
      'name': 'music',
      'label': 'Music',
      'description': 'Beat-synchronized edits, rhythmic flow',
      'overrides': {
        'audio': {'silence_threshold_db': -35, 'silence_min_duration_ms': 350},
        'scoring': {'keep_floor_score': 0.3, 'nms_window_seconds': 2.0},
        'scene': {'threshold': 25.0},
        'music': {'sync_to_beats': true, 'volume': 0.4},
        'transitions': {'crossfade_frames': 15, 'fade_frames': 22},
      },
    },
    {
      'name': 'vlog',
      'label': 'Vlog',
      'description': 'Casual pacing, natural pauses kept',
      'overrides': {
        'audio': {'silence_threshold_db': -32, 'silence_min_duration_ms': 500},
        'scoring': {'keep_floor_score': 0.4, 'nms_window_seconds': 2.5},
        'scene': {'threshold': 28.0},
        'transitions': {'crossfade_frames': 20, 'fade_frames': 25},
      },
    },
    {
      'name': 'anime edit',
      'label': 'Anime Edit',
      'description': 'Scene-focused, high-energy montage',
      'overrides': {
        'audio': {'silence_threshold_db': -38, 'silence_min_duration_ms': 250},
        'scoring': {'keep_floor_score': 0.25, 'nms_window_seconds': 2.0},
        'scene': {'threshold': 18.0},
        'transitions': {'crossfade_frames': 12, 'fade_frames': 16},
      },
    },
    {
      'name': 'gaming montage',
      'label': 'Gaming Montage',
      'description': 'Highlight-focused, tight cuts',
      'overrides': {
        'audio': {'silence_threshold_db': -36, 'silence_min_duration_ms': 300},
        'scoring': {'keep_floor_score': 0.35, 'nms_window_seconds': 1.8},
        'scene': {'threshold': 22.0},
        'transitions': {'crossfade_frames': 10, 'fade_frames': 14},
      },
    },
    {
      'name': 'cinematic',
      'label': 'Cinematic',
      'description': 'Film-grade pacing, dramatic transitions',
      'overrides': {
        'audio': {'silence_threshold_db': -34, 'silence_min_duration_ms': 600},
        'scoring': {'keep_floor_score': 0.45, 'nms_window_seconds': 3.5},
        'scene': {'threshold': 32.0},
        'transitions': {'crossfade_frames': 22, 'fade_frames': 30},
      },
    },
    {
      'name': 'reel short',
      'label': 'Reel / Short',
      'description': 'Short-form, fast cuts, high retention',
      'overrides': {
        'audio': {'silence_threshold_db': -33, 'silence_min_duration_ms': 150},
        'scoring': {'keep_floor_score': 0.3, 'nms_window_seconds': 1.0},
        'scene': {'threshold': 15.0},
        'transitions': {'crossfade_frames': 8, 'fade_frames': 10},
      },
    },
  ];
}
