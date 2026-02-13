import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Smart Image Widget
/// Automatically handles both local files and cloud URLs
/// Uses industry-standard cached_network_image for optimal performance
/// Supports local-first architecture with dual photo paths
class SmartImageWidget extends StatelessWidget {
  final String? localPath;
  final String? remotePath;
  final BoxFit? fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;

  const SmartImageWidget({
    super.key,
    this.localPath,
    this.remotePath,
    this.fit,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    // Priority 1: Check local file first (offline-first)
    if (localPath != null && localPath!.isNotEmpty) {
      return Image.file(
        File(localPath!),
        fit: fit ?? BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) => _tryRemoteOrError(),
        gaplessPlayback: true,
      );
    }

    // Priority 2: Try remote URL if local not available
    if (remotePath != null && remotePath!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: remotePath!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        placeholder: placeholder != null
            ? (context, url) => placeholder!
            : (context, url) => Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
        errorWidget: errorWidget != null
            ? (context, url, error) => errorWidget!
            : (context, url, error) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 100),
        // Memory cache optimization - resize images for thumbnails
        memCacheWidth: width != null ? (width! * 2).toInt() : null,
        memCacheHeight: height != null ? (height! * 2).toInt() : null,
      );
    }

    // No valid path available
    return _buildErrorWidget();
  }

  Widget _tryRemoteOrError() {
    // If local file failed and we have remote, try remote
    if (remotePath != null && remotePath!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: remotePath!,
        width: width,
        height: height,
        fit: fit ?? BoxFit.cover,
        errorWidget: (context, url, error) => _buildErrorWidget(),
        fadeInDuration: const Duration(milliseconds: 150),
        fadeOutDuration: const Duration(milliseconds: 100),
        memCacheWidth: width != null ? (width! * 2).toInt() : null,
        memCacheHeight: height != null ? (height! * 2).toInt() : null,
      );
    }
    return _buildErrorWidget();
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: const Icon(Icons.broken_image, color: Colors.grey, size: 32),
        );
  }
}
