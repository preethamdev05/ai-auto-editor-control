import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OutputScreen extends StatefulWidget {
  final String downloadUrl;
  final String fileName;
  final String jobId;
  const OutputScreen({super.key, required this.downloadUrl, required this.fileName, required this.jobId});

  @override
  State<OutputScreen> createState() => _OutputScreenState();
}

class _OutputScreenState extends State<OutputScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _downloading = false;
  double _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _download() async {
    setState(() {
      _downloading = true;
      _progress = 0.1;
      _error = null;
    });
    try {
      final response = await http.get(Uri.parse(widget.downloadUrl));
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _progress = 1.0;
      });
      if (response.statusCode == 200) {
        // For mobile: the file content is in response.bodyBytes
        // On a real app, save to file system and open
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded ${widget.fileName} (${(response.bodyBytes.length / 1024).toStringAsFixed(0)} KB)'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF00B894),
          ),
        );
      } else {
        setState(() => _error = 'Server returned ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _downloading = false;
        _error = 'Download failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Output')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.check_circle_outline, size: 80, color: Color(0xFF00B894)),
            const SizedBox(height: 24),
            const Text('Processing Complete!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Your edited video is ready to download.',
              style: const TextStyle(color: Color(0xFF9595B0), fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: ListTile(
                leading: const Icon(Icons.video_library),
                title: Text(widget.fileName),
                subtitle: Text(widget.jobId),
              ),
            ),
            const SizedBox(height: 24),
            _downloading
                ? LinearProgressIndicator(value: _progress, minHeight: 6)
                : const SizedBox.shrink(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_error!, style: const TextStyle(color: Color(0xFFE17055))),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _downloading ? null : _download,
                icon: _downloading ? const Icon(Icons.downloading) : const Icon(Icons.download),
                label: Text(_downloading ? 'Downloading... ${(_progress * 100).toInt()}%' : 'Download Video'),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.share),
              label: const Text('Share'),
            ),
          ],
        ),
      ),
    );
  }
}
