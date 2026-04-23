import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:yusr_app/core/services/storage_service.dart';
import 'package:yusr_app/features/content_download/domain/entities/download_content_type.dart';

/// A utility class to consolidate the logic of loading and parsing content files
/// from either the local assets or the downloaded content directory.
class ContentFileLoader {
  const ContentFileLoader._();

  /// Loads and parses a content file.
  ///
  /// Priority:
  /// 1. Downloaded files (matching [fileCandidates] in the [type] directory).
  /// 2. Any other JSON file in the [type] directory (if [fileCandidates] fail).
  /// 3. Local asset at [assetPath] (if provided).
  static Future<T?> loadAndParse<T>({
    required List<String> fileCandidates,
    required DownloadContentType type,
    required T Function(String raw) parser,
    String? assetPath,
  }) async {
    // 1. Try downloaded files
    final basePath = StorageService.downloadedContentBasePath;
    if (basePath != null && basePath.isNotEmpty) {
      final dir = Directory('$basePath${Platform.pathSeparator}${type.value}');
      if (await dir.exists()) {
        // First try the specific candidates
        for (final fileName in fileCandidates) {
          final file = File('${dir.path}${Platform.pathSeparator}$fileName');
          if (await file.exists()) {
            try {
              final raw = await file.readAsString();
              return await compute(parser, raw);
            } catch (_) {
              // Continue to next candidate
            }
          }
        }

        // Fallback to any JSON file in the directory
        try {
          await for (final entity in dir.list()) {
            if (entity is File &&
                entity.path.toLowerCase().endsWith('.json')) {
              try {
                final raw = await entity.readAsString();
                return await compute(parser, raw);
              } catch (_) {
                // Continue to next file
              }
            }
          }
        } catch (_) {
          // Directory listing failed
        }
      }
    }

    // 2. Try asset path if provided
    if (assetPath != null) {
      try {
        final raw = await rootBundle.loadString(assetPath);
        return await compute(parser, raw);
      } catch (_) {
        // Asset loading failed
      }
    }

    return null;
  }
}
