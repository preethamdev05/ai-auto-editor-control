class Preset {
  final String name;
  final String label;
  final String description;
  final Map<String, dynamic> overrides;

  const Preset({
    required this.name,
    required this.label,
    required this.description,
    required this.overrides,
  });

  factory Preset.fromDefinition(Map<String, dynamic> def) {
    return Preset(
      name: def['name'] ?? '',
      label: def['label'] ?? def['name'] ?? '',
      description: def['description'] ?? '',
      overrides: def['overrides'] as Map<String, dynamic>? ?? {},
    );
  }
}
