/// Dataset folder names and display labels from the Cassava Guard API `/classes`.
const Map<String, String> _cassavaFolderToLabel = {
  'cassava___healthy': 'Healthy',
  'cassava___bacterial_blight': 'Cassava bacterial blight',
  'cassava___brown_streak_disease': 'Cassava brown streak disease',
  'cassava___green_mottle': 'Cassava green mottle',
  'cassava___mosaic_disease': 'Cassava mosaic disease',
  'cassava _mosaic_disease': 'Cassava mosaic disease',
};

String _normalizeClassKey(String raw) {
  return raw.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
}

bool _isUnknownDiseaseClass(String diseaseClass) {
  final trimmed = diseaseClass.trim();
  if (trimmed.isEmpty) return true;
  final key = _normalizeClassKey(trimmed);
  return key == 'unknown' || key == 'n_a' || key == 'na' || key == 'none';
}

bool cassavaClassIsHealthy(String diseaseClass) {
  if (_isUnknownDiseaseClass(diseaseClass)) return false;
  final key = _normalizeClassKey(diseaseClass);
  if (key == 'healthy') return true;
  if (key.endsWith('___healthy') || key.endsWith('_healthy')) return true;
  return _cassavaFolderToLabel[key] == 'Healthy';
}

/// When [disease_class] is missing or "Unknown", the API often puts the outcome in [analysis].
bool cassavaAnalysisIndicatesHealthy(String analysis) {
  final trimmed = analysis.trim();
  if (trimmed.isEmpty) return false;
  if (cassavaClassIsHealthy(trimmed)) return true;

  final lower = trimmed.toLowerCase();
  if (RegExp(r'\b(not\s+healthy|unhealthy|non-healthy|diseased|infected)\b')
      .hasMatch(lower)) {
    return false;
  }
  if (RegExp(r'\bhealthy\b').hasMatch(lower)) return true;
  if (lower.contains('no disease') || lower.contains('no sign of disease')) {
    return true;
  }
  return false;
}

/// Healthy vs issue for dashboard/history tallies and save.
bool cassavaScanIsHealthy({
  required String diseaseClass,
  required String analysis,
}) {
  if (cassavaClassIsHealthy(diseaseClass)) return true;
  if (_isUnknownDiseaseClass(diseaseClass) &&
      cassavaAnalysisIndicatesHealthy(analysis)) {
    return true;
  }
  return false;
}

/// Human-readable label for history and scan UI.
String cassavaClassDisplayLabel(String diseaseClass) {
  final trimmed = diseaseClass.trim();
  if (trimmed.isEmpty) return 'Unknown';
  if (cassavaClassIsHealthy(trimmed)) return 'Healthy';

  final key = _normalizeClassKey(trimmed);
  final mapped = _cassavaFolderToLabel[key];
  if (mapped != null) return mapped;

  if (!trimmed.contains('___') && !trimmed.contains('__')) {
    return trimmed;
  }

  var name = trimmed;
  if (name.toLowerCase().startsWith('cassava___')) {
    name = name.substring('cassava___'.length);
  } else if (name.toLowerCase().startsWith('cassava_')) {
    name = name.substring('cassava_'.length);
  }
  return name
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .map(
        (w) =>
            '${w[0].toUpperCase()}${w.length > 1 ? w.substring(1).toLowerCase() : ''}',
      )
      .join(' ');
}

/// Label shown in UI/history; falls back to [analysis] when class is unknown.
String cassavaScanDisplayLabel({
  required String diseaseClass,
  required String analysis,
}) {
  if (cassavaScanIsHealthy(diseaseClass: diseaseClass, analysis: analysis)) {
    return 'Healthy';
  }
  if (!_isUnknownDiseaseClass(diseaseClass)) {
    return cassavaClassDisplayLabel(diseaseClass);
  }
  final analysisTrim = analysis.trim();
  if (analysisTrim.isNotEmpty) {
    final fromAnalysis = cassavaClassDisplayLabel(analysisTrim);
    if (fromAnalysis != 'Unknown') return fromAnalysis;
    if (analysisTrim.length <= 56) return analysisTrim;
    return '${analysisTrim.substring(0, 53)}...';
  }
  return cassavaClassDisplayLabel(diseaseClass);
}

/// Result returned from [CassavaApiService.analyzeLeaf].
class CassavaAnalysisResult {
  const CassavaAnalysisResult({
    required this.diseaseClass,
    required this.analysis,
    required this.suggestions,
  });

  final String diseaseClass;
  final String analysis;
  final String suggestions;

  bool get isHealthy =>
      cassavaScanIsHealthy(diseaseClass: diseaseClass, analysis: analysis);

  String get displayDiseaseLabel => cassavaScanDisplayLabel(
        diseaseClass: diseaseClass,
        analysis: analysis,
      );
}

class HistoryRow {
  const HistoryRow({
    required this.dateLabel,
    required this.diseaseLabel,
    required this.healthy,
    this.confidencePct,
    required this.pending,
  });

  final String dateLabel;
  final String diseaseLabel;
  final bool healthy;
  /// Null when the scan came from the API (no numeric confidence).
  final int? confidencePct;
  final bool pending;
}
