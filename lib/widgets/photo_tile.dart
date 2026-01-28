import 'dart:io';
import 'package:flutter/material.dart';
import 'package:animations/animations.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:transparent_image/transparent_image.dart';
import '../models/photo.dart';
import '../screens/photo_detail_screen.dart';

class PhotoTile extends StatelessWidget {
  final List<dynamic> photos;
  final int index;

  const PhotoTile({super.key, required this.photos, required this.index});

  dynamic get item => photos[index];

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: 0,
      openElevation: 0,
      closedColor: Colors.transparent,
      openColor: Colors.transparent,
      closedBuilder: (context, action) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Stack(
              fit: StackFit.passthrough,
              children: [
                _buildImage(),
                Positioned.fill(child: _buildOverlays()),
              ],
            ),
          ),
        );
      },
      openBuilder: (context, action) {
        return PhotoDetailScreen(photos: photos, initialIndex: index);
      },
    );
  }

  Widget _buildImage() {
    if (item is Photo) {
      final photo = item as Photo;
      return FadeInImage(
        placeholder: MemoryImage(kTransparentImage),
        image:
            (photo.mediaType == MediaType.video && photo.thumbnailPath != null)
                ? FileImage(File(photo.thumbnailPath!))
                : FileImage(File(photo.path)),
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 300),
        imageErrorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    } else {
      final asset = item as AssetEntity;
      return AssetEntityImage(
        asset,
        isOriginal: false,
        thumbnailSize: const ThumbnailSize.square(300),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildErrorPlaceholder();
        },
      );
    }
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(Icons.broken_image_rounded,
          color: Colors.white24, size: 32),
    );
  }

  Widget _buildOverlays() {
    final isVideo = item is Photo
        ? (item as Photo).mediaType == MediaType.video
        : (item as AssetEntity).type == AssetType.video;

    final category = item is Photo ? (item as Photo).category : null;
    final isFavorite = item is Photo ? (item as Photo).isFavorite : false;

    return Stack(
      children: [
        if (isVideo)
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(Icons.play_arrow_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.6),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (category != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1).withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                const Spacer(),
                if (isFavorite)
                  const Icon(Icons.favorite_rounded,
                      color: Color(0xFF6366F1), size: 14),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
