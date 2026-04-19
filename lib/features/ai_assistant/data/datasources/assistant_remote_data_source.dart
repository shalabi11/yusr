import 'dart:convert';

import 'package:dio/dio.dart';

class AssistantRemoteDataSource {
  AssistantRemoteDataSource({required Dio dio, required String webhookUrl})
    : _dio = dio,
      _webhookUrl = webhookUrl;

  final Dio _dio;
  final String _webhookUrl;

  Future<Map<String, dynamic>> sendPayload(Map<String, dynamic> payload) async {
    final response = await _dio.post(_webhookUrl, data: payload);

    if (response.statusCode != 200) {
      throw Exception(
        'Assistant webhook failed with status ${response.statusCode}.',
      );
    }

    final parsed = _extractResponseObject(response.data);
    if (parsed != null) {
      return parsed;
    }

    throw Exception('Assistant webhook response is not a valid JSON object.');
  }

  Map<String, dynamic>? _extractResponseObject(dynamic value) {
    if (value is Map<String, dynamic>) {
      return _normalizeResponseMap(value);
    }

    if (value is Map) {
      return _normalizeResponseMap(
        value.map((key, val) => MapEntry(key.toString(), val)),
      );
    }

    if (value is List && value.isNotEmpty) {
      return _extractResponseObject(value.first);
    }

    if (value is String) {
      final decoded =
          _tryDecodeJson(value) ?? _tryDecodeJson(_stripCodeFence(value));
      if (decoded != null) {
        return _extractResponseObject(decoded);
      }
    }

    return null;
  }

  Map<String, dynamic> _normalizeResponseMap(Map<String, dynamic> map) {
    final text = map['text'];
    if (text is String &&
        map['type'] == null &&
        map['reply_text'] == null &&
        map['reply'] == null &&
        map['message'] == null) {
      final nested = _extractResponseObject(text);
      if (nested != null) {
        return nested;
      }

      return <String, dynamic>{'type': 'answer', 'reply_text': text};
    }

    if (map['reply_text'] == null && map['message'] is String) {
      return <String, dynamic>{...map, 'reply_text': map['message']};
    }

    return map;
  }

  dynamic _tryDecodeJson(String raw) {
    final text = raw.trim();
    if (text.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(text);
    } catch (_) {
      return null;
    }
  }

  String _stripCodeFence(String raw) {
    final text = raw.trim();
    if (!text.startsWith('```')) {
      return text;
    }

    final withoutStart = text.replaceFirst(
      RegExp(r'^```[a-zA-Z0-9_\-]*\s*'),
      '',
    );
    return withoutStart.replaceFirst(RegExp(r'\s*```$'), '').trim();
  }
}
