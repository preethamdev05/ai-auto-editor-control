import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/models/job.dart';
import '../../domain/models/config.dart';
import '../../domain/enums/connection_status.dart';
import '../remote/api_service.dart';
import '../local/storage_service.dart';

class ConnectionRepository extends StateNotifier<ConnectionStatus> {
  final ApiService _api;
  final StorageService _storage;

  ConnectionRepository(this._api, this._storage) : super(ConnectionStatus.disconnected) {
    _init();
  }

  Future<void> _init() async {
    final host = await _storage.loadBackendHost();
    await _api.setBaseUrl(host);
  }

  Future<bool> checkHealth({String? host}) async {
    if (host != null) {
      await _api.setBaseUrl(host);
      await _storage.saveBackendHost(host);
    }

    state = ConnectionStatus.connecting;
    try {
      final result = await _api.checkHealth();
      if (result != null && result['status'] == 'ok') {
        state = ConnectionStatus.connected;
        await _storage.saveConnectionStatus('connected');
        return true;
      }
      state = ConnectionStatus.error;
      await _storage.saveConnectionStatus('error');
      return false;
    } catch (_) {
      state = ConnectionStatus.error;
      await _storage.saveConnectionStatus('error');
      return false;
    }
  }

  Future<void> disconnect() async {
    state = ConnectionStatus.disconnected;
    await _storage.saveConnectionStatus('disconnected');
  }

  String get baseUrl => _api.baseUrl;
}

class ApiRepository {
  final ApiService _api;
  final StorageService _storage;

  ApiRepository(this._api, this._storage);

  Future<AppConfig> getConfig() async {
    return await _api.loadConfig();
  }

  Future<void> updateConfig(AppConfig config) async {
    await _api.updateConfig(config);
  }

  Future<String> uploadVideo(PlatformFile file) async {
    final jobId = await _api.uploadVideo(file);
    // Cache the job
    final jobs = await _storage.loadRecentJobs();
    jobs.insert(0, Job(jobId: jobId, filename: file.name));
    await _storage.saveRecentJobs(jobs);
    return jobId;
  }

  Future<String> uploadSong(String jobId, PlatformFile file) async {
    return await _api.uploadSong(jobId, file);
  }

  Future<Job> startJob(String jobId) async {
    return await _api.startJob(jobId);
  }

  Future<List<Job>> listJobs() async {
    final jobs = await _api.listJobs();
    await _storage.saveRecentJobs(jobs);
    return jobs;
  }

  Future<Job> getJobStatus(String jobId) async {
    return await _api.getJobStatus(jobId);
  }

  Future<String> getDownloadUrl(String jobId) async {
    await _storage.addToDownloadHistory(jobId);
    return await _api.getDownloadUrl(jobId);
  }

  Future<List<Map<String, dynamic>>> getPresets() async {
    return await _api.getPresets();
  }
}

// ─── Riverpod Providers ───

final storageProvider = Provider<StorageService>((ref) => StorageService());

final apiServiceProvider = Provider<ApiService>((ref) {
  final storage = ref.watch(storageProvider);
  return ApiService(storage: storage);
});

final connectionProvider = StateNotifierProvider<ConnectionRepository, ConnectionStatus>((ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(storageProvider);
  return ConnectionRepository(api, storage);
});

final apiRepositoryProvider = Provider<ApiRepository>((ref) {
  final api = ref.watch(apiServiceProvider);
  final storage = ref.watch(storageProvider);
  return ApiRepository(api, storage);
});
