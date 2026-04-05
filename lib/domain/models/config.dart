class AppConfig {
  // input
  String inputPath;
  int inputResolution;
  int audioSampleRate;

  // output
  String outputPath;
  int outputResolution;
  int outputFps;

  // whisper
  String whisperModelSize;
  String whisperDevice;
  String whisperComputeType;

  // yolo
  String yoloWeights;
  double yoloConfidence;
  String yoloDevice;
  int yoloBatchInterval;

  // scene
  double sceneThreshold;

  // audio
  int silenceThresholdDb;
  int silenceMinDurationMs;
  int energyPercentileFloor;

  // scoring
  double nmsWindowSeconds;
  double keepFloorScore;

  // llm
  String llmProvider;
  String llmModel;
  String? llmApiBase;

  // transitions
  int crossfadeFrames;
  int fadeFrames;

  // music
  double musicVolume;
  bool syncToBeats;
  int minBeatAlignmentMs;
  double beatAlignmentWeight;
  String? musicSongPath;

  // qc
  int maxSyncDriftMs;
  int maxBlackFrames;
  double durationTolerancePct;

  AppConfig({
    this.inputPath = 'input/video.mp4',
    this.inputResolution = 720,
    this.audioSampleRate = 16000,
    this.outputPath = 'output/final/result.mp4',
    this.outputResolution = 1080,
    this.outputFps = 30,
    this.whisperModelSize = 'tiny',
    this.whisperDevice = 'cpu',
    this.whisperComputeType = 'int8',
    this.yoloWeights = 'yolov8n.pt',
    this.yoloConfidence = 0.5,
    this.yoloDevice = 'cpu',
    this.yoloBatchInterval = 15,
    this.sceneThreshold = 27.0,
    this.silenceThresholdDb = -35,
    this.silenceMinDurationMs = 400,
    this.energyPercentileFloor = 20,
    this.nmsWindowSeconds = 2.0,
    this.keepFloorScore = 0.35,
    this.llmProvider = 'openai',
    this.llmModel = 'gpt-4o-mini',
    this.llmApiBase,
    this.crossfadeFrames = 15,
    this.fadeFrames = 22,
    this.musicVolume = 0.3,
    this.syncToBeats = true,
    this.minBeatAlignmentMs = 50,
    this.beatAlignmentWeight = 0.15,
    this.musicSongPath,
    this.maxSyncDriftMs = 40,
    this.maxBlackFrames = 3,
    this.durationTolerancePct = 5.0,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final input = json['input'] ?? {};
    final output = json['output'] ?? {};
    final whisper = json['whisper'] ?? {};
    final yolo = json['yolo'] ?? {};
    final scene = json['scene'] ?? {};
    final audio = json['audio'] ?? {};
    final scoring = json['scoring'] ?? {};
    final llm = json['llm'] ?? {};
    final transitions = json['transitions'] ?? {};
    final music = json['music'] ?? {};
    final qc = json['qc'] ?? {};

    num? safeNum(Map m, String k) {
      final v = m[k];
      if (v == null) return null;
      if (v is num) return v;
      if (v is String) return num.tryParse(v);
      return null;
    }

    return AppConfig(
      inputPath: input['path'] ?? 'input/video.mp4',
      inputResolution: safeNum(input, 'working_resolution')?.toInt() ?? 720,
      audioSampleRate: safeNum(input, 'audio_sr')?.toInt() ?? 16000,
      outputPath: output['path'] ?? 'output/final/result.mp4',
      outputResolution: safeNum(output, 'resolution')?.toInt() ?? 1080,
      outputFps: safeNum(output, 'fps')?.toInt() ?? 30,
      whisperModelSize: whisper['model_size'] ?? 'tiny',
      whisperDevice: whisper['device'] ?? 'cpu',
      whisperComputeType: whisper['compute_type'] ?? 'int8',
      yoloWeights: yolo['weights'] ?? 'yolov8n.pt',
      yoloConfidence: (safeNum(yolo, 'confidence') ?? 0.5).toDouble(),
      yoloDevice: yolo['device'] ?? 'cpu',
      yoloBatchInterval: safeNum(yolo, 'batch_interval')?.toInt() ?? 15,
      sceneThreshold: (safeNum(scene, 'threshold') ?? 27.0).toDouble(),
      silenceThresholdDb: safeNum(audio, 'silence_threshold_db')?.toInt() ?? -35,
      silenceMinDurationMs: safeNum(audio, 'silence_min_duration_ms')?.toInt() ?? 400,
      energyPercentileFloor: safeNum(audio, 'energy_percentile_floor')?.toInt() ?? 20,
      nmsWindowSeconds: (safeNum(scoring, 'nms_window_seconds') ?? 2.0).toDouble(),
      keepFloorScore: (safeNum(scoring, 'keep_floor_score') ?? 0.35).toDouble(),
      llmProvider: llm['provider'] ?? 'openai',
      llmModel: llm['model'] ?? 'gpt-4o-mini',
      llmApiBase: llm['api_base'],
      crossfadeFrames: safeNum(transitions, 'crossfade_frames')?.toInt() ?? 15,
      fadeFrames: safeNum(transitions, 'fade_frames')?.toInt() ?? 22,
      musicVolume: (safeNum(music, 'volume') ?? 0.3).toDouble(),
      syncToBeats: music['sync_to_beats'] ?? true,
      minBeatAlignmentMs: safeNum(music, 'min_beat_alignment_ms')?.toInt() ?? 50,
      beatAlignmentWeight: (safeNum(music, 'beat_alignment_weight') ?? 0.15).toDouble(),
      musicSongPath: music['song_path'],
      maxSyncDriftMs: safeNum(qc, 'max_sync_drift_ms')?.toInt() ?? 40,
      maxBlackFrames: safeNum(qc, 'max_black_frames')?.toInt() ?? 3,
      durationTolerancePct: (safeNum(qc, 'duration_tolerance_pct') ?? 5.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'input': {
        'path': inputPath,
        'working_resolution': inputResolution,
        'audio_sr': audioSampleRate,
      },
      'output': {
        'path': outputPath,
        'resolution': outputResolution,
        'fps': outputFps,
      },
      'whisper': {
        'model_size': whisperModelSize,
        'device': whisperDevice,
        'compute_type': whisperComputeType,
      },
      'yolo': {
        'weights': yoloWeights,
        'confidence': yoloConfidence,
        'device': yoloDevice,
        'batch_interval': yoloBatchInterval,
      },
      'scene': {'threshold': sceneThreshold},
      'audio': {
        'silence_threshold_db': silenceThresholdDb,
        'silence_min_duration_ms': silenceMinDurationMs,
        'energy_percentile_floor': energyPercentileFloor,
      },
      'scoring': {
        'nms_window_seconds': nmsWindowSeconds,
        'keep_floor_score': keepFloorScore,
      },
      'llm': {
        'provider': llmProvider,
        'model': llmModel,
        'api_base': llmApiBase,
      },
      'transitions': {
        'crossfade_frames': crossfadeFrames,
        'fade_frames': fadeFrames,
      },
      'music': {
        'volume': musicVolume,
        'sync_to_beats': syncToBeats,
        'min_beat_alignment_ms': minBeatAlignmentMs,
        'beat_alignment_weight': beatAlignmentWeight,
        'song_path': musicSongPath,
      },
      'qc': {
        'max_sync_drift_ms': maxSyncDriftMs,
        'max_black_frames': maxBlackFrames,
        'duration_tolerance_pct': durationTolerancePct,
      },
    };
  }

  Map<String, dynamic> toBackendJson() {
    // Backend expects flat merged keys: whisper, yolo, scene, audio, scoring, transitions, music
    return {
      'whisper': {
        'model_size': whisperModelSize,
        'device': whisperDevice,
        'compute_type': whisperComputeType,
      },
      'yolo': {
        'weights': yoloWeights,
        'confidence': yoloConfidence,
        'device': yoloDevice,
        'batch_interval': yoloBatchInterval,
      },
      'scene': {'threshold': sceneThreshold},
      'audio': {
        'silence_threshold_db': silenceThresholdDb,
        'silence_min_duration_ms': silenceMinDurationMs,
        'energy_percentile_floor': energyPercentileFloor,
      },
      'scoring': {
        'nms_window_seconds': nmsWindowSeconds,
        'keep_floor_score': keepFloorScore,
      },
      'transitions': {
        'crossfade_frames': crossfadeFrames,
        'fade_frames': fadeFrames,
      },
      'music': {
        'volume': musicVolume,
        'sync_to_beats': syncToBeats,
        'min_beat_alignment_ms': minBeatAlignmentMs,
        'beat_alignment_weight': beatAlignmentWeight,
        'song_path': musicSongPath,
      },
    };
  }

  void applyPreset(Map<String, dynamic> overrides) {
    if (overrides['audio'] != null) {
      final a = overrides['audio'] as Map<String, dynamic>;
      if (a['silence_threshold_db'] != null) silenceThresholdDb = a['silence_threshold_db'];
      if (a['silence_min_duration_ms'] != null) silenceMinDurationMs = a['silence_min_duration_ms'];
    }
    if (overrides['scoring'] != null) {
      final s = overrides['scoring'] as Map<String, dynamic>;
      if (s['keep_floor_score'] != null) keepFloorScore = (s['keep_floor_score'] as num).toDouble();
      if (s['nms_window_seconds'] != null) nmsWindowSeconds = (s['nms_window_seconds'] as num).toDouble();
    }
    if (overrides['scene'] != null) {
      final sc = overrides['scene'] as Map<String, dynamic>;
      if (sc['threshold'] != null) sceneThreshold = (sc['threshold'] as num).toDouble();
    }
    if (overrides['transitions'] != null) {
      final t = overrides['transitions'] as Map<String, dynamic>;
      if (t['crossfade_frames'] != null) crossfadeFrames = t['crossfade_frames'];
      if (t['fade_frames'] != null) fadeFrames = t['fade_frames'];
    }
    if (overrides['music'] != null) {
      final m = overrides['music'] as Map<String, dynamic>;
      if (m['sync_to_beats'] != null) syncToBeats = m['sync_to_beats'];
      if (m['volume'] != null) musicVolume = (m['volume'] as num).toDouble();
    }
  }

  AppConfig copy() {
    final copy = AppConfig();
    copy.inputPath = inputPath;
    copy.inputResolution = inputResolution;
    copy.audioSampleRate = audioSampleRate;
    copy.outputPath = outputPath;
    copy.outputResolution = outputResolution;
    copy.outputFps = outputFps;
    copy.whisperModelSize = whisperModelSize;
    copy.whisperDevice = whisperDevice;
    copy.whisperComputeType = whisperComputeType;
    copy.yoloWeights = yoloWeights;
    copy.yoloConfidence = yoloConfidence;
    copy.yoloDevice = yoloDevice;
    copy.yoloBatchInterval = yoloBatchInterval;
    copy.sceneThreshold = sceneThreshold;
    copy.silenceThresholdDb = silenceThresholdDb;
    copy.silenceMinDurationMs = silenceMinDurationMs;
    copy.energyPercentileFloor = energyPercentileFloor;
    copy.nmsWindowSeconds = nmsWindowSeconds;
    copy.keepFloorScore = keepFloorScore;
    copy.llmProvider = llmProvider;
    copy.llmModel = llmModel;
    copy.llmApiBase = llmApiBase;
    copy.crossfadeFrames = crossfadeFrames;
    copy.fadeFrames = fadeFrames;
    copy.musicVolume = musicVolume;
    copy.syncToBeats = syncToBeats;
    copy.minBeatAlignmentMs = minBeatAlignmentMs;
    copy.beatAlignmentWeight = beatAlignmentWeight;
    copy.musicSongPath = musicSongPath;
    copy.maxSyncDriftMs = maxSyncDriftMs;
    copy.maxBlackFrames = maxBlackFrames;
    copy.durationTolerancePct = durationTolerancePct;
    return copy;
  }
}
