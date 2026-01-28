import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../providers/gallery_provider.dart';
import '../models/photo.dart';

class PhotoDetailScreen extends StatefulWidget {
  final List<dynamic> photos;
  final int initialIndex;

  const PhotoDetailScreen({
    super.key,
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<PhotoDetailScreen> createState() => _PhotoDetailScreenState();
}

class _PhotoDetailScreenState extends State<PhotoDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GalleryProvider>(
      builder: (context, provider, child) {
        if (_currentIndex >= widget.photos.length) {
          _currentIndex = widget.photos.length - 1;
        }
        if (widget.photos.isEmpty) {
          return const Scaffold(
              body: Center(child: Text("No photos available")));
        }

        final currentItem = widget.photos[_currentIndex];
        final isImported = currentItem is Photo;

        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              if (isImported) ...[
                _buildAppBarAction(
                  icon: currentItem.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_outline_rounded,
                  color: currentItem.isFavorite
                      ? const Color(0xFF6366F1)
                      : Colors.white,
                  onPressed: () => provider.toggleFavorite(currentItem.id),
                ),
                _buildAppBarAction(
                  icon: Icons.share_rounded,
                  onPressed: () => provider.sharePhoto(currentItem.path),
                ),
                _buildAppBarAction(
                  icon: Icons.info_outline_rounded,
                  onPressed: () =>
                      _showInfoSheet(context, currentItem, provider),
                ),
                _buildAppBarAction(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  onPressed: () =>
                      _confirmDelete(context, provider, currentItem.id),
                ),
              ],
              const SizedBox(width: 8),
            ],
          ),
          body: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.photos.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return PhotoDetailItem(item: widget.photos[index]);
                },
              ),
              // Bottom Indicator Overlay
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(
                      "${_currentIndex + 1} / ${widget.photos.length}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBarAction(
      {required IconData icon,
      Color color = Colors.white,
      required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 4, bottom: 4),
      child: CircleAvatar(
        backgroundColor: Colors.black.withOpacity(0.3),
        child: IconButton(
          icon: Icon(icon, size: 20, color: color),
          onPressed: onPressed,
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, GalleryProvider provider, String photoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Move to Bin?"),
        content: const Text(
            "This photo will be moved to the Bin. You can restore it later."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              provider.deletePhoto(photoId);
              Navigator.pop(context); // Close dialog
              if (widget.photos.length <= 1) {
                Navigator.pop(context); // Go back to grid if no photos left
              }
            },
            child:
                const Text("Move to Bin", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // ... (rest of the methods like _showInfoSheet, etc. remain very similar, but update to currentPhoto)
  void _showInfoSheet(
      BuildContext context, Photo photo, GalleryProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Details",
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: Colors.white),
                      ),
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, color: Colors.white70))
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.calendar_today, "Date Added",
                      DateFormat.yMMMd().add_jm().format(photo.dateAdded)),
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),

                  // Category Section
                  Text("Category",
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white70)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: photo.category,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: [
                      const DropdownMenuItem(
                          value: null, child: Text("Uncategorized")),
                      ...provider.categories.map(
                          (c) => DropdownMenuItem(value: c, child: Text(c))),
                    ],
                    onChanged: (val) {
                      provider.updatePhotoCategory(photo.id, val);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Tags Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tags",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white70)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: Color(0xFFBB86FC)),
                        onPressed: () =>
                            _showAddTagDialog(context, provider, photo.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: photo.tags
                        .map((tag) => Chip(
                              label: Text(tag),
                              backgroundColor: const Color(0xFF333333),
                              labelStyle: const TextStyle(color: Colors.white),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () =>
                                  provider.removeTagFromPhoto(photo.id, tag),
                            ))
                        .toList(),
                  ),
                  if (photo.tags.isEmpty)
                    const Text("No tags",
                        style: TextStyle(
                            color: Colors.white38,
                            fontStyle: FontStyle.italic)),

                  const SizedBox(height: 24),

                  // People Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("People",
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.white70)),
                      IconButton(
                        icon: const Icon(Icons.person_add_alt_1_rounded,
                            color: Color(0xFF6366F1)),
                        onPressed: () =>
                            _showAddPersonDialog(context, provider, photo.id),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: photo.people
                        .map((person) => Chip(
                              avatar: const Icon(Icons.person,
                                  size: 16, color: Colors.white70),
                              label: Text(person),
                              backgroundColor:
                                  const Color(0xFF6366F1).withOpacity(0.2),
                              labelStyle: const TextStyle(color: Colors.white),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => provider.removePersonFromPhoto(
                                  photo.id, person),
                            ))
                        .toList(),
                  ),
                  if (photo.people.isEmpty)
                    const Text("No people tagged",
                        style: TextStyle(
                            color: Colors.white38,
                            fontStyle: FontStyle.italic)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.white54),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  void _showAddTagDialog(
      BuildContext context, GalleryProvider provider, String photoId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Tag"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Tag name"),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  children: provider.tags
                      .map((t) => ActionChip(
                            label: Text(t),
                            onPressed: () {
                              controller.text = t;
                            },
                          ))
                      .toList(),
                ),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.addTagToPhoto(photoId, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddPersonDialog(
      BuildContext context, GalleryProvider provider, String photoId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tag Person"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: "Person's name"),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  children: provider.uniquePeople
                      .map((p) => ActionChip(
                            label: Text(p),
                            onPressed: () {
                              controller.text = p;
                            },
                          ))
                      .toList(),
                ),
              ),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.addPersonToPhoto(photoId, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Tag"),
          ),
        ],
      ),
    );
  }
}

class PhotoDetailItem extends StatefulWidget {
  final dynamic item;
  const PhotoDetailItem({super.key, required this.item});

  @override
  State<PhotoDetailItem> createState() => _PhotoDetailItemState();
}

class _PhotoDetailItemState extends State<PhotoDetailItem> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  bool _isInitVideo = false;

  @override
  void initState() {
    super.initState();
    if (widget.item is Photo) {
      final photo = widget.item as Photo;
      if (photo.mediaType == MediaType.video) {
        _initializeVideo(File(photo.path));
      }
    } else if (widget.item is AssetEntity) {
      final asset = widget.item as AssetEntity;
      if (asset.type == AssetType.video) {
        _initializeVideoAsset(asset);
      }
    }
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo(File file) async {
    if (_isInitVideo) return;
    _isInitVideo = true;

    _videoPlayerController = VideoPlayerController.file(file);
    await _setupChewie();
  }

  Future<void> _initializeVideoAsset(AssetEntity asset) async {
    if (_isInitVideo) return;
    _isInitVideo = true;

    final file = await asset.file;
    if (file != null) {
      _videoPlayerController = VideoPlayerController.file(file);
      await _setupChewie();
    }
  }

  Future<void> _setupChewie() async {
    try {
      await _videoPlayerController!.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );
    } catch (e) {
      debugPrint("Error initializing video: $e");
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.item is Photo) {
      final photo = widget.item as Photo;
      return Center(
        child: photo.mediaType == MediaType.video
            ? (_chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator())
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.file(
                  File(photo.path),
                  fit: BoxFit.contain,
                ),
              ),
      );
    } else {
      final asset = widget.item as AssetEntity;
      return Center(
        child: asset.type == AssetType.video
            ? (_chewieController != null &&
                    _chewieController!.videoPlayerController.value.isInitialized
                ? Chewie(controller: _chewieController!)
                : const CircularProgressIndicator())
            : InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: AssetEntityImage(
                  asset,
                  isOriginal: true,
                  fit: BoxFit.contain,
                ),
              ),
      );
    }
  }
}
