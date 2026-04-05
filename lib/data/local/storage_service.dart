import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../../domain/models/job.dart';
import '../../domain/models/config.dart';

class StorageService {
  final Future<SharedPreferences> _prefs;

  StorageService([Future<SharedPreferences>? prefs]) : _prefs = prefs ?? SharedPreferences.getInstance();

  // Backend host
  Future<String> loadBackendHost() async {
    final s = await _prefs;
    return s.getString(AppConstants.keyBackendHost) ?? AppConstants.defaultHost;
  }

  Future<void> saveBackendHost(String host) async {
    final s = await _prefs;
    await s.setString(AppConstants.keyBackendHost, host);
  }

  // Pairing token
  Future<String?> loadPairingToken() async {
    final s = await _prefs;
    return s.getString(AppConstants.keyPairingToken);
  }

  Future<void> savePairingToken(String token) async {
    final s = await _prefs;
    await s.setString(AppConstants.keyPairingToken, token);
  }

  // Recent jobs (cached list)
  Future<List<Job>> loadRecentJobs() async {
    final s = await _prefs;
    final raw = s.getString(AppConstants.keyRecentJobs);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      return list.map((j) => Job.fromJson(j)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecentJobs(List<Job> jobs) async {
    final s = await _prefs;
    final list = jobs.take(20).map((j) => j.toJson()).toList();
    await s.setString(AppConstants.keyRecentJobs, jsonEncode(list));
  }

  // Recent presets
  Future<List<String>> loadRecentPresets() async {
    final s = await _prefs;
    final raw = s.getString(AppConstants.keyRecentPresets);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecentPreset(String name) async {
    final s = await _prefs;
    final recent = await loadRecentPresets();
    recent.remove(name);
    recent.insert(0, name);
    if (recent.length > 8) recent.removeLast();
    await s.setString(AppConstants.keyRecentPresets, jsonEncode(recent));
  }

  // Config draft
  Future<Map<String, dynamic>?> loadConfigDraft() async {
    final s = await _prefs;
    final raw = s.getString(AppConstants.keyConfigDraft);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveConfigDraft(Map<String, dynamic> config) async {
    final s = await _prefs;
    await s.setString(AppConstants.keyConfigDraft, jsonEncode(config));
  }

  // Connection status
  Future<String> loadConnectionStatus() async {
    final s = await _prefs;
    return s.getString(AppConstants.keyConnectionStatus) ?? 'disconnected';
  }

  Future<void> saveConnectionStatus(String status) async {
    final s = await _prefs;
    await s.setString(AppConstants.keyConnectionStatus, status);
  }

  // Download history
  Future<List<String>> loadDownloadHistory() async {
    final s = await _prefs;
    final raw = s.getString(AppConstants.keyDownloadHistory);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List).map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addToDownloadHistory(String jobId) async {
    final s = await _prefs;
    final history = await loadDownloadHistory();
    history.remove(jobId);
    history.insert(0, jobId);
    if (history.length > 50) history.removeLast();
    await s.setString(AppConstants.keyDownloadHistory, jsonEncode(history));
  }

  // Last selected song path (display name)
  Future<String?> loadLastSongName() async {
    final s = await _prefs;
    return s.getString(AppConstants.keyLastSelectedSong);
  }

  Future<void> saveLastSongName(String name) async {
    final s = await _prefs;
    await s.setString(AppConstants.keyLastSelectedSong, name);
  }

  // Clear all
  Future<void> clearAll() async {
    final s = await _prefs;
    await s.clear();
  }
}
