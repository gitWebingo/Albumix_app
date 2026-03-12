import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/photo_tile.dart';
import '../models/photo.dart';

class CategoryPhotosScreen extends StatelessWidget {
  final String category;

  const CategoryPhotosScreen({super.key, required this.category});

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
                category,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Consumer<GalleryProvider>(
              builder: (context, provider, child) {
                final photos = provider.photos
                    .where((p) => p.category == category)
                    .toList();

                if (photos.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        "No photos in this album",
                        style: TextStyle(color: Colors.white.withOpacity(0.2)),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          PhotoTile(photos: photos, index: index),
                      childCount: photos.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context
              .read<GalleryProvider>()
              .pickAndImportPhotos(category: category);
        },
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text("Add Photos"),
      ),
    );
  }
}
