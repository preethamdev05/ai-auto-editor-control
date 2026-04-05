import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../domain/models/preset.dart';

class PresetCard extends StatelessWidget {
  final Preset preset;
  final bool isSelected;
  final VoidCallback onTap;

  const PresetCard({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary.withOpacity(0.15) : const Color(0xFF282840),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary : const Color(0xFF2A2A40),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.2)
                    : const Color(0xFF353555),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _iconForPreset(preset.name),
                color: isSelected ? AppTheme.primary : const Color(0xFF9595B0),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    preset.label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppTheme.primary : const Color(0xFFEAEAFF),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    preset.description,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF9595B0)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary, size: 20),
          ],
        ),
      ),
    );
  }

  IconData _iconForPreset(String name) {
    switch (name.toLowerCase()) {
      case 'interview':
        return Icons.mic_external_on;
      case 'action':
        return Icons.speed;
      case 'music':
        return Icons.music_note;
      case 'vlog':
        return Icons.videocam;
      case 'anime edit':
        return Icons.animation;
      case 'gaming montage':
        return Icons.sports_esports;
      case 'cinematic':
        return Icons.movie;
      case 'reel short':
        return Icons.auto_awesome;
      default:
        return Icons.tune;
    }
  }
}
