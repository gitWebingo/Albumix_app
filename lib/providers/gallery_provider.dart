import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:photo_manager/photo_manager.dart';
import '../datasources/local_storage.dart';
import '../models/photo.dart';

enum SortOption { dateNewest, dateOldest }

class GalleryProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  LocalStorageService get storageService => _storageService;

  List<Photo> _importedPhotos = [];
  List<AssetEntity> _deviceAssets = [];
  List<String> _categories = [];
  List<String> _tags = [];

  SortOption _currentSort = SortOption.dateNewest;
  SortOption get currentSort => _currentSort;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetchingMore = false;
  bool get isFetchingMore => _isFetchingMore;

  int _currentPage = 0;
  bool _hasMore = true;
  static const int _pageSize = 60;

  List<Photo> get allImportedPhotos => _importedPhotos;

  // Combined list for display
  List<dynamic> get photos {
    final List<dynamic> combined = [];
    combined.addAll(_importedPhotos.where((p) => !p.isDeleted));
    combined.addAll(_deviceAssets);

    combined.sort((a, b) {
      final dateA =
          a is Photo ? a.dateAdded : (a as AssetEntity).createDateTime;
      final dateB =
          b is Photo ? b.dateAdded : (b as AssetEntity).createDateTime;
      return _currentSort == SortOption.dateNewest
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });

    return combined;
  }

  List<Photo> get trashedPhotos =>
      _importedPhotos.where((p) => p.isDeleted).toList();
  List<Photo> get favoritePhotos =>
      _importedPhotos.where((p) => p.isFavorite && !p.isDeleted).toList();
  List<String> get categories => _categories;
  List<String> get tags => _tags;

  // Month-wise grouping logic updated for combined types
  Map<String, List<dynamic>> get photosByMonth {
    final Map<String, List<dynamic>> grouped = {};
    final activePhotos = photos;

    for (var item in activePhotos) {
      final date =
          item is Photo ? item.dateAdded : (item as AssetEntity).createDateTime;
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
    await fetchFirstPage();
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
    _tags = _storageService.getTags();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFirstPage() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (!ps.isAuth) {
      _hasMore = false;
      return;
    }

    _currentPage = 0;
    _deviceAssets = await PhotoManager.getAssetListPaged(
      page: _currentPage,
      pageCount: _pageSize,
    );

    _hasMore = _deviceAssets.length == _pageSize;
    notifyListeners();
  }

  Future<void> fetchMoreAssets() async {
    if (!_hasMore || _isFetchingMore) return;

    _isFetchingMore = true;
    notifyListeners();

    _currentPage++;
    final List<AssetEntity> newAssets = await PhotoManager.getAssetListPaged(
      page: _currentPage,
      pageCount: _pageSize,
    );

    if (newAssets.isEmpty) {
      _hasMore = false;
    } else {
      _deviceAssets.addAll(newAssets);
      _hasMore = newAssets.length == _pageSize;
    }

    _isFetchingMore = false;
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }

  Future<void> pickAndImportPhotos() async {
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

  Future<void> addTagToPhoto(String photoId, String tag) async {
    final index = _importedPhotos.indexWhere((p) => p.id == photoId);
    if (index != -1) {
      final photo = _importedPhotos[index];
      if (!photo.tags.contains(tag)) {
        final newTags = List<String>.from(photo.tags)..add(tag);
        final updatedPhoto = photo.copyWith(tags: newTags);
        await _storageService.updatePhoto(updatedPhoto);
        _importedPhotos[index] = updatedPhoto;

        if (!_tags.contains(tag)) {
          _tags.add(tag);
          await _storageService.saveTags(_tags);
        }

        notifyListeners();
      }
    }
  }

  Future<void> removeTagFromPhoto(String photoId, String tag) async {
    final index = _importedPhotos.indexWhere((p) => p.id == photoId);
    if (index != -1) {
      final photo = _importedPhotos[index];
      if (photo.tags.contains(tag)) {
        final newTags = List<String>.from(photo.tags)..remove(tag);
        final updatedPhoto = photo.copyWith(tags: newTags);
        await _storageService.updatePhoto(updatedPhoto);
        _importedPhotos[index] = updatedPhoto;
        notifyListeners();
      }
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
    _deviceAssets = [];
    notifyListeners();
  }

  // People Feature Logic
  List<String> get uniquePeople {
    final Set<String> peopleSet = {};
    for (var photo in _importedPhotos) {
      peopleSet.addAll(photo.people);
    }
    return peopleSet.toList()..sort();
  }

  List<Photo> getPhotosForPerson(String personName) {
    return _importedPhotos
        .where((p) => p.people.contains(personName) && !p.isDeleted)
        .toList();
  }

  Future<void> addPersonToPhoto(String photoId, String personName) async {
    final index = _importedPhotos.indexWhere((p) => p.id == photoId);
    if (index != -1) {
      final photo = _importedPhotos[index];
      if (!photo.people.contains(personName)) {
        final newPeople = List<String>.from(photo.people)..add(personName);
        final updatedPhoto = photo.copyWith(people: newPeople);
        await _storageService.updatePhoto(updatedPhoto);
        _importedPhotos[index] = updatedPhoto;
        notifyListeners();
      }
    }
  }

  Future<void> removePersonFromPhoto(String photoId, String personName) async {
    final index = _importedPhotos.indexWhere((p) => p.id == photoId);
    if (index != -1) {
      final photo = _importedPhotos[index];
      if (photo.people.contains(personName)) {
        final newPeople = List<String>.from(photo.people)..remove(personName);
        final updatedPhoto = photo.copyWith(people: newPeople);
        await _storageService.updatePhoto(updatedPhoto);
        _importedPhotos[index] = updatedPhoto;
        notifyListeners();
      }
    }
  }
}
