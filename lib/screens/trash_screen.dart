import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../providers/gallery_provider.dart';
import '../models/photo.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              pinned: true,
              backgroundColor: const Color(0xFF0F172A),
              title: Text(
                'Bin',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
              ),
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_forever_rounded,
                        size: 20, color: Colors.redAccent),
                  ),
                  tooltip: 'Empty Bin',
                  onPressed: () => _confirmEmptyTrash(context),
                ),
                const SizedBox(width: 8),
              ],
            ),
            Consumer<GalleryProvider>(
              builder: (context, provider, child) {
                final trashed = provider.trashedPhotos;

                if (trashed.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.02),
                            ),
                            child: Icon(Icons.delete_outline_rounded,
                                size: 64, color: Colors.white.withOpacity(0.1)),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Your bin is empty',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Colors.white24,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverMasonryGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childCount: trashed.length,
                    itemBuilder: (context, index) {
                      final photo = trashed[index];
                      return _buildTrashedTile(context, photo, provider);
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrashedTile(
      BuildContext context, Photo photo, GalleryProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.file(
                  File(photo.thumbnailPath ?? photo.path),
                  fit: BoxFit.cover,
                ),
              ),
              Container(
                color: const Color(0xFF0F172A),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.restore_rounded,
                          color: Colors.greenAccent, size: 20),
                      onPressed: () => provider.restorePhoto(photo.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever_rounded,
                          color: Colors.redAccent, size: 20),
                      onPressed: () =>
                          _confirmPermanentDelete(context, photo.id, provider),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (photo.mediaType == MediaType.video)
            Positioned.fill(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 24),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmEmptyTrash(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Empty Bin?'),
        content: const Text(
            'All items in the bin will be permanently deleted. This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<GalleryProvider>().emptyTrash();
              Navigator.pop(context);
            },
            child: const Text('Empty Bin', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmPermanentDelete(
      BuildContext context, String id, GalleryProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Permanently?'),
        content: const Text('This item will be deleted forever surfaces.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              provider.permanentlyDeletePhoto(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
