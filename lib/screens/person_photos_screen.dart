import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/photo_tile.dart';

class PersonPhotosScreen extends StatelessWidget {
  final String personName;

  const PersonPhotosScreen({super.key, required this.personName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(personName),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<GalleryProvider>(
        builder: (context, provider, child) {
          final photos = provider.getPhotosForPerson(personName);

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return PhotoTile(
                  photos: photos,
                  index: index,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
