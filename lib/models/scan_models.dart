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

  /// API uses label `Healthy` for healthy class.
  bool get isHealthy {
    final n = diseaseClass.trim().toLowerCase();
    return n == 'healthy' || n == 'cassava___healthy';
  }
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
