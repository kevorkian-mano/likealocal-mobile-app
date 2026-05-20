import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SafeImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  const SafeImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    final String path = (imageUrl ?? '').trim();

    Widget fallback() {
      return placeholder ??
          Container(
            width: width,
            height: height,
            color: const Color(0xFFE8F2E9),
            child: const Center(
              child: Icon(
                Icons.image_not_supported_outlined,
                color: Color(0xFF1B3022),
                size: 24,
              ),
            ),
          );
    }

    if (path.isEmpty) {
      return fallback();
    }

    // 1. Base64 Stored Image
    if (path.startsWith('data:image') ||
        (!path.startsWith('http') && path.length > 500)) {
      try {
        final cleanBase64 = path.contains(',') ? path.split(',').last : path;
        final bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => fallback(),
        );
      } catch (e) {
        return fallback();
      }
    }

    // 2. Network Image
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? Container(
          width: width,
          height: height,
          color: const Color(0xFFE8F2E9),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1B3022)),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => fallback(),
      );
    }

    // 3. Fallback
    return fallback();
  }
}
