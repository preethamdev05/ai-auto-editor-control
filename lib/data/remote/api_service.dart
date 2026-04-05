import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../domain/models/job.dart';
import '../../domain/models/config.dart';
import '../../core/constants.dart';
import '../local/storage_service.dart';

class ApiService {
  String _baseUrl;
  final StorageService _storage;

  ApiService({String? baseUrl, StorageService? storage})
      : _baseUrl = baseUrl ?? AppConstants.defaultHost,
        _storage = storage ?? StorageService();

  String get baseUrl => _baseUrl;

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
    await _storage.saveBackendHost(_baseUrl);
  }

  Future<AppConfig> loadConfig() async {
    final uri = Uri.parse('$_baseUrl/api/config');
    final resp = await http.get(uri).timeout(const Duration(seconds: AppConstants.apiTimeoutSeconds));
    if (resp.statusCode != 200) {
      throw ApiException('Failed to load config: ${resp.statusCode}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return AppConfig.fromJson(json);
  }

  Future<void> updateConfig(AppConfig config) async {
    final uri = Uri.parse('$_baseUrl/api/config');
    final resp = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(config.toBackendJson()),
    ).timeout(const Duration(seconds: AppConstants.apiTimeoutSeconds));
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw ApiException('Failed to update config: ${resp.statusCode}');
    }
  }

  Future<String> uploadVideo(PlatformFile file) async {
    final uri = Uri.parse('$_baseUrl/api/upload');
    final request = http.MultipartRequest('POST', uri);
    final bytes = file.bytes;
    if (bytes == null) {
      throw ApiException('Cannot read file bytes');
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: file.name),
    );
    final streamed = await request.send().timeout(
      const Duration(seconds: AppConstants.apiTimeoutSeconds * 3),
    );
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw ApiException('Upload failed: ${resp.statusCode} - ${resp.body}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return json['job_id'] as String;
  }

  Future<String> uploadSong(String jobId, PlatformFile file) async {
    final uri = Uri.parse('$_baseUrl/api/upload-song/$jobId');
    final request = http.MultipartRequest('POST', uri);
    final bytes = file.bytes;
    if (bytes == null) {
      throw ApiException('Cannot read file bytes');
    }
    request.files.add(
      http.MultipartFile.fromBytes('file', bytes, filename: file.name),
    );
    final streamed = await request.send().timeout(
      const Duration(seconds: AppConstants.apiTimeoutSeconds * 3),
    );
    final resp = await http.Response.fromStream(streamed);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw ApiException('Song upload failed: ${resp.statusCode}');
    }
    return jobId;
  }

  Future<Job> startJob(String jobId) async {
    final uri = Uri.parse('$_baseUrl/api/start/$jobId');
    final resp = await http.post(uri).timeout(
      const Duration(seconds: AppConstants.apiTimeoutSeconds),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      throw ApiException('Failed to start job: ${resp.statusCode}');
    }
    return await getJobStatus(jobId);
  }

  Future<List<Job>> listJobs() async {
    final uri = Uri.parse('$_baseUrl/api/jobs');
    final resp = await http.get(uri).timeout(
      const Duration(seconds: AppConstants.apiTimeoutSeconds),
    );
    if (resp.statusCode != 200) {
      throw ApiException('Failed to list jobs: ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body);
    if (data is List) {
      return data.map((j) => Job.fromJson(j as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<Job> getJobStatus(String jobId) async {
    final uri = Uri.parse('$_baseUrl/api/status/$jobId');
    final resp = await http.get(uri).timeout(
      const Duration(seconds: AppConstants.apiTimeoutSeconds),
    );
    if (resp.statusCode != 200) {
      throw ApiException('Job not found: ${resp.statusCode}');
    }
    final json = jsonDecode(resp.body) as Map<String, dynamic>;
    return Job.fromJson(json);
  }

  Future<String> getDownloadUrl(String jobId) async {
    return '$_baseUrl/api/download/$jobId';
  }

  Future<Map<String, dynamic>?> checkHealth() async {
    final uri = Uri.parse('$_baseUrl/health');
    final resp = await http.get(uri).timeout(
      const Duration(seconds: AppConstants.healthCheckTimeoutSeconds),
    );
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      return null;
    }
    return jsonDecode(resp.body) as Map<String, dynamic>?;
  }

  Future<List<Map<String, dynamic>>> getPresets() async {
    final uri = Uri.parse('$_baseUrl/api/presets');
    try {
      final resp = await http.get(uri).timeout(
        const Duration(seconds: AppConstants.apiTimeoutSeconds),
      );
      if (resp.statusCode != 200) return [];
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final presets = json['presets'];
      if (presets is List) {
        return presets.map((e) => e as Map<String, dynamic>).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
