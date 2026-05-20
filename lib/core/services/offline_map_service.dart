import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineMapService {
  static String? cacheDirectoryPath;

  /// Initialize caching directory path
  static Future<void> initialize() async {
    try {
      final dir = await getApplicationSupportDirectory();
      cacheDirectoryPath = '${dir.path}/tile_cache';
      final directory = Directory(cacheDirectoryPath!);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      debugPrint('[OfflineMapService] Initialized cache directory: $cacheDirectoryPath');
    } catch (e) {
      debugPrint('[OfflineMapService] Error during initialization: $e');
    }
  }

  /// Convert longitude to Tile X coordinate
  static int lonToTileX(double lon, int zoom) {
    return ((lon + 180.0) / 360.0 * pow(2.0, zoom)).floor();
  }

  /// Convert latitude to Tile Y coordinate
  static int latToTileY(double lat, int zoom) {
    double latRad = lat * pi / 180.0;
    return ((1.0 - log(tan(latRad) + 1.0 / cos(latRad)) / pi) / 2.0 * pow(2.0, zoom)).floor();
  }

  /// Check if a package has been successfully downloaded
  static Future<bool> isPackageDownloaded(String packageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('offline_map_$packageId') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Mark package download status
  static Future<void> setPackageDownloaded(String packageId, bool downloaded) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('offline_map_$packageId', downloaded);
    } catch (_) {}
  }

  /// Retrieve download progress percentage for a package (0.0 to 1.0)
  static Future<double> getPackageProgress(String packageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble('offline_map_progress_$packageId') ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  /// Store download progress percentage
  static Future<void> setPackageProgress(String packageId, double progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('offline_map_progress_$packageId', progress);
    } catch (_) {}
  }

  /// Get predefined Cairo neighborhood package bounding boxes
  static Map<String, double> getPackageBounds(String packageName) {
    if (packageName.contains('Zamalek')) {
      return {
        'minLat': 30.03,
        'maxLat': 30.07,
        'minLng': 31.20,
        'maxLng': 31.25,
      };
    } else {
      // Maadi & Heliopolis bounds
      return {
        'minLat': 29.95,
        'maxLat': 30.13,
        'minLng': 31.24,
        'maxLng': 31.35,
      };
    }
  }

  /// Download OpenStreetMap tiles for a bounding box coordinate range
  static Stream<double> downloadAreaTiles({
    required String packageId,
    required double minLat,
    required double maxLat,
    required double minLng,
    required double maxLng,
    int minZoom = 12,
    int maxZoom = 15,
  }) async* {
    if (cacheDirectoryPath == null) {
      await initialize();
    }

    final List<Map<String, int>> tilesToDownload = [];
    for (int zoom = minZoom; zoom <= maxZoom; zoom++) {
      int xMin = lonToTileX(minLng, zoom);
      int xMax = lonToTileX(maxLng, zoom);
      int yMax = latToTileY(minLat, zoom);
      int yMin = latToTileY(maxLat, zoom);

      // Assure min is less than max
      if (yMin > yMax) {
        int temp = yMin;
        yMin = yMax;
        yMax = temp;
      }
      if (xMin > xMax) {
        int temp = xMin;
        xMin = xMax;
        xMax = temp;
      }

      for (int x = xMin; x <= xMax; x++) {
        for (int y = yMin; y <= yMax; y++) {
          tilesToDownload.add({'z': zoom, 'x': x, 'y': y});
        }
      }
    }

    int totalTiles = tilesToDownload.length;
    if (totalTiles == 0) {
      yield 1.0;
      return;
    }

    debugPrint('[OfflineMapService] Starting download of $totalTiles tiles for package: $packageId');

    int downloadedCount = 0;
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 8);

    // Dynamic stream controller to yield progress values
    final controller = StreamController<double>();
    final completer = Completer<void>();

    int index = 0;
    const int maxConcurrent = 5; // Download up to 5 tiles simultaneously

    Future<void> downloadNext() async {
      if (index >= totalTiles) return;
      int currentIdx = index++;
      final tile = tilesToDownload[currentIdx];
      final z = tile['z']!;
      final x = tile['x']!;
      final y = tile['y']!;

      final localFile = File('$cacheDirectoryPath/$z/$x/$y.png');
      if (await localFile.exists()) {
        downloadedCount++;
        controller.add(downloadedCount / totalTiles);
        await setPackageProgress(packageId, downloadedCount / totalTiles);
        await downloadNext();
        return;
      }

      try {
        final url = Uri.parse('https://tile.openstreetmap.org/$z/$x/$y.png');
        final request = await client.getUrl(url);
        request.headers.set(HttpHeaders.userAgentHeader, 'com.likelocal.app');
        final response = await request.close();

        if (response.statusCode == 200) {
          await localFile.parent.create(recursive: true);
          final bytes = await consolidateHttpClientResponseBytes(response);
          await localFile.writeAsBytes(bytes);
        }
      } catch (e) {
        debugPrint('[OfflineMapService] Failed to download tile ($z, $x, $y): $e');
      }

      downloadedCount++;
      controller.add(downloadedCount / totalTiles);
      await setPackageProgress(packageId, downloadedCount / totalTiles);
      await downloadNext();
    }

    final List<Future<void>> workers = [];
    for (int i = 0; i < min(maxConcurrent, totalTiles); i++) {
      workers.add(downloadNext());
    }

    Future.wait(workers).then((_) {
      client.close();
      completer.complete();
    }).catchError((err) {
      client.close();
      completer.completeError(err);
    });

    yield* controller.stream;
    await completer.future;

    await setPackageDownloaded(packageId, true);
    await setPackageProgress(packageId, 1.0);
    yield 1.0;
  }
}
