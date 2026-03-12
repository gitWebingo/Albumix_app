import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../datasources/local_storage.dart';
import '../models/photo.dart';

enum SortOption { dateNewest, dateOldest }

class GalleryProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  LocalStorageService get storageService => _storageService;

  List<Photo> _importedPhotos = [];
  List<String> _categories = [];

  SortOption _currentSort = SortOption.dateNewest;
  SortOption get currentSort => _currentSort;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isGridView = true;
  bool get isGridView => _isGridView;

  List<Photo> get allImportedPhotos => _importedPhotos;

  List<Photo> get photos {
    final List<Photo> visible =
        _importedPhotos.where((p) => !p.isDeleted).toList();
    visible.sort((a, b) {
      final dateA = a.dateAdded;
      final dateB = b.dateAdded;
      return _currentSort == SortOption.dateNewest
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });
    return visible;
  }

  List<Photo> get trashedPhotos =>
      _importedPhotos.where((p) => p.isDeleted).toList();
  List<Photo> get favoritePhotos =>
      _importedPhotos.where((p) => p.isFavorite && !p.isDeleted).toList();
  List<String> get categories => _categories;

  // Month-wise grouping logic updated for combined types
  Map<String, List<Photo>> get photosByMonth {
    final Map<String, List<Photo>> grouped = {};
    final activePhotos = photos;

    for (var item in activePhotos) {
      final date = item.dateAdded;
      final String monthYear = DateFormat('MMMM yyyy').format(date);
      if (!grouped.containsKey(monthYear)) {
        grouped[monthYear] = [];
      }
      grouped[monthYear]!.add(item);
    }
    return grouped;
  }

  GalleryProvider(this._storageService) {
    _init();
  }

  Future<void> _init() async {
    await _loadImportedData();
  }

  Future<void> _loadImportedData() async {
    _isLoading = true;
    notifyListeners();

    _importedPhotos = _storageService.getAllPhotos();
    _categories = _storageService.getCategories();
    if (_categories.isEmpty) {
      _categories = ['Family', 'Travel', 'Work', 'Friends'];
      await _storageService.saveCategories(_categories);
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  void toggleViewMode() {
    _isGridView = !_isGridView;
    notifyListeners();
  }

  Future<void> pickAndImportPhotos({String? category}) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> medias = await picker.pickMultipleMedia();

    if (medias.isNotEmpty) {
      _isLoading = true;
      notifyListeners();

      final io.Directory appDir = await getApplicationDocumentsDirectory();
      final String photosDir = path.join(appDir.path, 'albumix_photos');
      await io.Directory(photosDir).create(recursive: true);

      for (var media in medias) {
        final String fileName =
            '${const Uuid().v4()}${path.extension(media.path)}';
        final String savedPath = path.join(photosDir, fileName);

        await io.File(media.path).copy(savedPath);

        MediaType mediaType = MediaType.image;
        String? thumbnailPath;

        final ext = path.extension(savedPath).toLowerCase();
        if (['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(ext)) {
          mediaType = MediaType.video;
          try {
            thumbnailPath = await VideoThumbnail.thumbnailFile(
              video: savedPath,
              thumbnailPath: photosDir,
              imageFormat: ImageFormat.JPEG,
              maxHeight: 200,
              quality: 75,
            );
          } catch (e) {
            debugPrint("Error generating thumbnail: $e");
          }
        }

        final newPhoto = Photo(
          id: const Uuid().v4(),
          path: savedPath,
          dateAdded: DateTime.now(),
          mediaType: mediaType,
          thumbnailPath: thumbnailPath,
          category: category,
        );

        await _storageService.addPhoto(newPhoto);
        _importedPhotos.insert(0, newPhoto);
      }

      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deletePhoto(String id) async {
    final index = _importedPhotos.indexWhere((p) => p.id == id);
    if (index != -1) {
      final photo = _importedPhotos[index];
      final updatedPhoto = photo.copyWith(
        isDeleted: true,
        deletedAt: DateTime.now(),
      );
      await _storageService.updatePhoto(updatedPhoto);
      _importedPhotos[index] = updatedPhoto;
      notifyListeners();
    }
  }

  Future<void> restorePhoto(String id) async {
    final index = _importedPhotos.indexWhere((p) => p.id == id);
    if (index != -1) {
      final photo = _importedPhotos[index];
      final updatedPhoto = photo.copyWith(
        isDeleted: false,
        deletedAt: null,
      );
      await _storageService.updatePhoto(updatedPhoto);
      _importedPhotos[index] = updatedPhoto;
      notifyListeners();
    }
  }

  Future<void> permanentlyDeletePhoto(String id) async {
    final index = _importedPhotos.indexWhere((p) => p.id == id);
    if (index != -1) {
      final photo = _importedPhotos[index];
      await _storageService.deletePhoto(id);

      try {
        final file = io.File(photo.path);
        if (await file.exists()) {
          await file.delete();
        }
        if (photo.thumbnailPath != null) {
          final thumbFile = io.File(photo.thumbnailPath!);
          if (await thumbFile.exists()) {
            await thumbFile.delete();
          }
        }
      } catch (e) {
        debugPrint("Error deleting file: $e");
      }

      _importedPhotos.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> emptyTrash() async {
    final trashed = trashedPhotos;
    for (var photo in trashed) {
      await permanentlyDeletePhoto(photo.id);
    }
  }

  Future<void> updatePhotoCategory(String photoId, String? category) async {
    final index = _importedPhotos.indexWhere((p) => p.id == photoId);
    if (index != -1) {
      final photo = _importedPhotos[index];
      final updatedPhoto = photo.copyWith(category: category);
      await _storageService.updatePhoto(updatedPhoto);
      _importedPhotos[index] = updatedPhoto;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String photoId) async {
    final index = _importedPhotos.indexWhere((p) => p.id == photoId);
    if (index != -1) {
      final photo = _importedPhotos[index];
      final updatedPhoto = photo.copyWith(isFavorite: !photo.isFavorite);
      await _storageService.updatePhoto(updatedPhoto);
      _importedPhotos[index] = updatedPhoto;
      notifyListeners();
    }
  }

  Future<void> createCategory(String categoryName) async {
    if (!_categories.contains(categoryName)) {
      _categories.add(categoryName);
      await _storageService.saveCategories(_categories);
      notifyListeners();
    }
  }

  Future<void> sharePhoto(String path) async {
    await Share.shareXFiles([XFile(path)],
        text: 'Check out this photo from Albumix!');
  }

  Future<void> logout() async {
    await _storageService.logout();
    _importedPhotos = [];
    notifyListeners();
  }
}
