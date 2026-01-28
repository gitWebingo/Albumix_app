import 'package:hive_flutter/hive_flutter.dart';
import '../models/photo.dart';

class LocalStorageService {
  static const String photoBoxName = 'photos';
  static const String metaBoxName = 'meta'; // For categories list, tags list

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(PhotoAdapter());
    await Hive.openBox<Photo>(photoBoxName);
    await Hive.openBox(metaBoxName);
  }

  Box<Photo> get photoBox => Hive.box<Photo>(photoBoxName);
  Box get metaBox => Hive.box(metaBoxName);

  List<Photo> getAllPhotos() {
    return photoBox.values.toList();
  }

  Future<void> addPhoto(Photo photo) async {
    await photoBox.put(photo.id, photo);
  }

  Future<void> updatePhoto(Photo photo) async {
    await photoBox.put(photo.id, photo);
  }

  Future<void> deletePhoto(String id) async {
    await photoBox.delete(id);
  }

  // Categories and Tags Management
  List<String> getCategories() {
    return (metaBox.get('categories') as List<dynamic>?)?.cast<String>() ?? [];
  }

  Future<void> saveCategories(List<String> categories) async {
    await metaBox.put('categories', categories);
  }

  List<String> getTags() {
    return (metaBox.get('tags') as List<dynamic>?)?.cast<String>() ?? [];
  }

  Future<void> saveTags(List<String> tags) async {
    await metaBox.put('tags', tags);
  }

  Future<void> setOnboardingSeen() async {
    await metaBox.put('seenOnboarding', true);
  }

  bool get seenOnboarding {
    return metaBox.get('seenOnboarding', defaultValue: false) as bool;
  }

  Future<void> setLoggedIn(bool value) async {
    await metaBox.put('isLoggedIn', value);
  }

  bool get isLoggedIn {
    return metaBox.get('isLoggedIn', defaultValue: false) as bool;
  }

  Future<void> setGuest(bool value) async {
    await metaBox.put('isGuest', value);
  }

  bool get isGuest {
    return metaBox.get('isGuest', defaultValue: false) as bool;
  }

  Future<void> logout() async {
    await metaBox.put('isLoggedIn', false);
    await metaBox.put('isGuest', false);
    await metaBox.put('seenOnboarding', false); // Reset for testing flow
  }
}
