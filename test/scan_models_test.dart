import 'package:cassava_guard/models/scan_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cassavaClassIsHealthy', () {
    test('recognizes API display label', () {
      expect(cassavaClassIsHealthy('Healthy'), isTrue);
    });

    test('recognizes dataset folder name', () {
      expect(cassavaClassIsHealthy('Cassava___healthy'), isTrue);
    });

    test('rejects disease labels', () {
      expect(cassavaClassIsHealthy('Cassava mosaic disease'), isFalse);
      expect(cassavaClassIsHealthy('Cassava___brown_streak_disease'), isFalse);
    });

    test('rejects unknown class token', () {
      expect(cassavaClassIsHealthy('Unknown'), isFalse);
      expect(cassavaClassIsHealthy(''), isFalse);
    });
  });

  group('cassavaScanIsHealthy', () {
    test('uses analysis when disease class is unknown', () {
      expect(
        cassavaScanIsHealthy(
          diseaseClass: 'Unknown',
          analysis: 'The leaf appears healthy with no visible disease.',
        ),
        isTrue,
      );
    });

    test('flags disease when class unknown but analysis mentions disease', () {
      expect(
        cassavaScanIsHealthy(
          diseaseClass: '',
          analysis: 'Signs consistent with cassava mosaic disease.',
        ),
        isFalse,
      );
    });

    test('prefers explicit healthy class', () {
      expect(
        cassavaScanIsHealthy(
          diseaseClass: 'cassava___healthy',
          analysis: '',
        ),
        isTrue,
      );
    });
  });

  group('cassavaClassDisplayLabel', () {
    test('formats healthy', () {
      expect(cassavaClassDisplayLabel('Cassava___healthy'), 'Healthy');
    });

    test('formats disease from folder name', () {
      expect(
        cassavaClassDisplayLabel('Cassava___bacterial_blight'),
        'Cassava bacterial blight',
      );
    });

    test('keeps API display label for diseases', () {
      expect(
        cassavaClassDisplayLabel('Cassava brown streak disease'),
        'Cassava brown streak disease',
      );
    });
  });

  group('cassavaScanDisplayLabel', () {
    test('shows Healthy when analysis says healthy but class unknown', () {
      expect(
        cassavaScanDisplayLabel(
          diseaseClass: 'Unknown',
          analysis: 'Healthy',
        ),
        'Healthy',
      );
    });

    test('uses analysis text when class unknown', () {
      expect(
        cassavaScanDisplayLabel(
          diseaseClass: 'Unknown',
          analysis: 'Cassava bacterial blight',
        ),
        'Cassava bacterial blight',
      );
    });
  });
}
