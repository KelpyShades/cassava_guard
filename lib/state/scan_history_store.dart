import 'package:flutter/foundation.dart';

import '../models/scan_models.dart';

/// In-memory history for scans saved from the app.
final ValueNotifier<List<HistoryRow>> scanHistory =
    ValueNotifier<List<HistoryRow>>(<HistoryRow>[]);

void prependScanToHistory({
  required String diseaseLabel,
  required bool healthy,
  int? confidencePct,
}) {
  final row = HistoryRow(
    dateLabel: _todayLabel(),
    diseaseLabel: diseaseLabel,
    healthy: healthy,
    confidencePct: confidencePct,
    pending: false,
  );
  scanHistory.value = <HistoryRow>[row, ...scanHistory.value];
}

String _todayLabel() {
  final now = DateTime.now();
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[now.month - 1]} ${now.day}, ${now.year}';
}
