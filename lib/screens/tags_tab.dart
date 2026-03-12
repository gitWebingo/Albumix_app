import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';

import 'photo_detail_screen.dart';

class TagsTab extends StatelessWidget {
  const TagsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        final tags = provider.photos.expand((p) => p.tags).toSet().toList();
        if (tags.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.label_outline_rounded,
                    size: 64, color: Colors.white24),
                const SizedBox(height: 16),
                Text(
                  'No tags yet',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add tags to your photos to see them here',
                  style: TextStyle(color: Colors.white38),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: tags.length,
          itemBuilder: (context, index) {
            final tag = tags[index];
            final photosWithTag =
                provider.photos.where((p) => p.tags.contains(tag)).toList();
            final count = photosWithTag.length;
            final firstPhoto =
                photosWithTag.isEmpty ? null : photosWithTag.first;

            return _buildTagCard(context, tag, count, firstPhoto?.path);
          },
        );
      },
    );
  }

  Widget _buildTagCard(
      BuildContext context, String tag, int count, String? imagePath) {
    // Reusing the CategoryPhotosScreen for now, passing tag as category name context if needed
    // But CategoryPhotosScreen filters by category. We need a TagPhotosScreen.
    // Or we can update CategoryPhotosScreen to handle tags.
    // For simplicity, let's create a TagPhotosScreen or adapt.
    // Since CategoryPhotosScreen likely filters by `p.category == category`,
    // we should create a similar screen for tags.

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TagPhotosScreen(tagName: tag),
            ),
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null)
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: Colors.grey[800]),
              )
            else
              Container(
                  color: Colors.grey[850],
                  child:
                      const Icon(Icons.label, size: 40, color: Colors.white24)),
            Container(color: Colors.black45),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.label,
                          size: 16, color: Color(0xFFBB86FC)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tag,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '$count photos',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagPhotosScreen extends StatelessWidget {
  final String tagName;

  const TagPhotosScreen({super.key, required this.tagName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#$tagName'),
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, provider, child) {
          final photos =
              provider.photos.where((p) => p.tags.contains(tagName)).toList();

          if (photos.isEmpty) {
            return const Center(child: Text("No photos with this tag"));
          }

          // Reusing PhotoTile logic, likely need to import PhotoTile or create grid
          // Since PhotoTile is in widgets/photo_tile.dart, we need to import it.
          // But I don't want to add another import if I can avoid it or just copy a simple grid.
          // Actually, passing `photos` to a simple GridView is easier.

          return GridView.builder(
            padding: const EdgeInsets.all(4),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoDetailScreen(
                        photos: photos,
                        initialIndex: index,
                      ),
                    ),
                  );
                },
                child: Image.file(
                  File(photo.path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: Colors.grey),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
