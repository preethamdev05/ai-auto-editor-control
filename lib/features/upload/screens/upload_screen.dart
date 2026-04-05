import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../../../core/router.dart';
import '../../../data/repositories/api_repository.dart';
import '../../../domain/models/config.dart';
import '../../../domain/models/preset.dart';
import '../../../core/constants.dart';
import '../../../shared/widgets/preset_card.dart';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  PlatformFile? _videoFile;
  PlatformFile? _songFile;
  String? _currentJobId;
  bool _uploading = false;
  double? _uploadProgress;
  String? _errorMessage;
  Map<String, dynamic> _selectedPreset = {};
  AppConfig? _serverConfig;
  bool _configLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
      final repo = ref.read(apiRepositoryProvider);
      _serverConfig = await repo.getConfig();
      setState(() => _configLoaded = true);
    } catch (_) {
      setState(() => _configLoaded = true); // still show UI
    }
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _videoFile = result.files.first;
        _errorMessage = null;
      });
    }
  }

  Future<void> _pickSong() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _songFile = result.files.first;
      });
    }
  }

  Future<void> _uploadAndCreateJob() async {
    if (_videoFile == null) {
      setState(() => _errorMessage = 'Please select a video file first');
      return;
    }

    setState(() {
      _uploading = true;
      _errorMessage = null;
      _uploadProgress = 0;
    });

    try {
      final repo = ref.read(apiRepositoryProvider);
      final jobId = await repo.uploadVideo(_videoFile!);

      _currentJobId = jobId;

      if (_songFile != null) {
        await repo.uploadSong(jobId, _songFile!);
      }

      if (_selectedPreset.isNotEmpty && _serverConfig != null) {
        final config = AppConfig.fromJson(_serverConfig!.toJson());
        config.applyPreset(_selectedPreset);
        await repo.updateConfig(config);
      }

      if (!mounted) return;
      setState(() {
        _uploading = false;
        _uploadProgress = 1.0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload complete! Job ID: $jobId'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppTheme.success,
          action: SnackBarAction(
            label: 'Start',
            textColor: Colors.white,
            onPressed: () => _startJob(jobId),
          ),
        ),
      );

      Navigator.pushNamed(context, Routes.jobDetail, arguments: _currentJobId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _uploading = false;
        _errorMessage = 'Upload failed: $e';
      });
    }
  }

  Future<void> _startJob(String jobId) async {
    try {
      final repo = ref.read(apiRepositoryProvider);
      await repo.startJob(jobId);
      if (!mounted) return;
      Navigator.pushNamed(context, Routes.jobDetail, arguments: jobId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start: $e'), behavior: SnackBarBehavior.floating),
      );
    }
  }

  void _selectPreset(String name) {
    final preset = AppConstants.availablePresets.firstWhere(
      (p) => p['name'] == name,
      orElse: () => {},
    );
    if (preset.isNotEmpty) {
      setState(() {
        _selectedPreset = preset['overrides'] as Map<String, dynamic>;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadConfig,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Upload Video',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select a video to create a new job',
                      style: TextStyle(fontSize: 14, color: Color(0xFF9595B0)),
                    ),
                    const SizedBox(height: 24),

                    // Video upload area
                    _buildUploadArea(
                      icon: Icons.video_file_outlined,
                      title: _videoFile?.name ?? 'Select Video',
                      subtitle: _videoFile != null
                          ? '${(_videoFile!.size / 1024 / 1024).toStringAsFixed(1)} MB'
                          : 'Tap to pick a video file',
                      onTap: _pickVideo,
                      accent: AppTheme.primary,
                    ),

                    const SizedBox(height: 16),

                    // Song upload area
                    _buildUploadArea(
                      icon: Icons.music_note_outlined,
                      title: _songFile?.name ?? 'Background Song (Optional)',
                      subtitle: _songFile != null
                          ? '${(_songFile!.size / 1024 / 1024).toStringAsFixed(1)} MB'
                          : 'Tap to add background music',
                      onTap: _pickSong,
                      accent: AppTheme.info,
                    ),

                    const SizedBox(height: 24),

                    // Preset selection
                    const Text('Preset', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 56,
                      child: _buildPresetChips(),
                    ),

                    const SizedBox(height: 24),

                    // Start button
                    if (_uploading)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: _uploadProgress,
                            color: AppTheme.primary,
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          const SizedBox(height: 8),
                          const Text('Uploading...', style: TextStyle(fontSize: 13, color: Color(0xFF9595B0))),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _videoFile != null ? _uploadAndCreateJob : null,
                          icon: const Icon(Icons.upload, size: 20),
                          label: const Text('Upload & Create Job'),
                        ),
                      ),

                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFFE17055), fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color accent,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF282840),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withOpacity(0.3), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: accent, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF9595B0))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF9595B0)),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChips() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: AppConstants.availablePresets.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, index) {
        final preset = AppConstants.availablePresets[index];
        final name = preset['name'] as String;
        final selected = _selectedPreset.isNotEmpty && _selectedPreset == preset['overrides'];
        return FilterChip(
          label: Text(name, style: TextStyle(fontSize: 12)),
          selected: selected,
          onSelected: (_) => _selectPreset(name),
          selectedColor: AppTheme.primary.withOpacity(0.25),
        );
      },
    );
  }
}
