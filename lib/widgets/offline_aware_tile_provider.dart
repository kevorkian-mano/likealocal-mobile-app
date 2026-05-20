import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../core/services/offline_map_service.dart';

class OfflineAwareTileProvider extends TileProvider {
  OfflineAwareTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    if (OfflineMapService.cacheDirectoryPath != null) {
      final file = File(
        '${OfflineMapService.cacheDirectoryPath}/${coordinates.z}/${coordinates.x}/${coordinates.y}.png',
      );
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    // Fallback: Construct standard OpenStreetMap URL from template
    final url = getTileUrl(coordinates, options);
    return NetworkImage(url, headers: headers);
  }
}
