import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../config/api_config.dart';
import '../models/scan_models.dart';

class CassavaApiException implements Exception {
  CassavaApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'CassavaApiException($statusCode): $message';
}

abstract final class CassavaApiService {
  /// POST multipart `file` to [ApiConfig.analyzeCassavaUri].
  static Future<CassavaAnalysisResult> analyzeLeaf(Uint8List imageBytes) async {
    final contentType = _imageMediaType(imageBytes);
    final ext = contentType.subtype == 'png' ? 'png' : 'jpg';
    final request = http.MultipartRequest('POST', ApiConfig.analyzeCassavaUri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'leaf.$ext',
          contentType: contentType,
        ),
      );

    late http.Response response;
    try {
      final streamed = await request.send();
      response = await http.Response.fromStream(streamed);
    } catch (e, st) {
      final msg = e.toString();
      if (_isConnectivityFailure(msg)) {
        debugPrint('CassavaApiService connectivity error: $msg');
        throw CassavaApiException(
          'Cannot reach the API (DNS/network). Use Wi‑Fi or mobile data, '
          'open Chrome and test ${ApiConfig.baseUrl}. '
          'On Android: Settings → Network → Private DNS → Automatic or Off.',
        );
      }
      Error.throwWithStackTrace(e, st);
    }

    final body = response.body;

    if (response.statusCode == 200) {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final payload = json['result'] is Map<String, dynamic>
          ? json['result'] as Map<String, dynamic>
          : json;

      String? readString(Map<String, dynamic> map, List<String> keys) {
        for (final key in keys) {
          final value = map[key];
          if (value is String && value.trim().isNotEmpty) {
            return value.trim();
          }
        }
        return null;
      }

      final disease = readString(payload, [
            'disease_class',
            'disease',
            'predicted_class',
            'class',
            'class_name',
            'label',
            'pest',
          ]) ??
          '';
      final analysis = readString(payload, [
            'analysis',
            'result',
            'diagnosis',
            'description',
          ]) ??
          '';
      final suggestions = readString(payload, [
            'suggestions',
            'recommendation',
            'recommendations',
            'advice',
          ]) ??
          '';

      return CassavaAnalysisResult(
        diseaseClass: disease,
        analysis: analysis,
        suggestions: suggestions,
      );
    }

    String detail = body;
    try {
      final err = jsonDecode(body);
      if (err is Map && err['detail'] != null) {
        detail = err['detail'].toString();
      }
    } catch (_) {}

    throw CassavaApiException(
      detail.isEmpty ? 'Request failed' : detail,
      statusCode: response.statusCode,
    );
  }

  static MediaType _imageMediaType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xFF &&
        bytes[1] == 0xD8 &&
        bytes[2] == 0xFF) {
      return MediaType('image', 'jpeg');
    }
    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return MediaType('image', 'png');
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46) {
      return MediaType('image', 'webp');
    }
    return MediaType('image', 'jpeg');
  }

  static bool _isConnectivityFailure(String msg) {
    const markers = [
      'Failed host lookup',
      'SocketException',
      'Connection refused',
      'Network is unreachable',
      'timed out',
      'Timed out',
      'ClientException',
      'HandshakeException',
      'CertificateException',
    ];
    return markers.any(msg.contains);
  }
}
