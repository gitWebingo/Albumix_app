import 'package:hive/hive.dart';

enum MediaType { image, video }

class Photo {
  final String id;
  final String path;
  List<String> tags;
  String? category;
  final DateTime dateAdded;
  bool isFavorite;
  MediaType mediaType;
  String? thumbnailPath; // For videos
  bool isDeleted;
  DateTime? deletedAt;
  List<String> people;

  Photo({
    required this.id,
    required this.path,
    this.tags = const [],
    this.category,
    required this.dateAdded,
    this.isFavorite = false,
    this.mediaType = MediaType.image,
    this.thumbnailPath,
    this.isDeleted = false,
    this.deletedAt,
    this.people = const [],
  });

  Photo copyWith({
    String? id,
    String? path,
    List<String>? tags,
    String? category,
    DateTime? dateAdded,
    bool? isFavorite,
    MediaType? mediaType,
    String? thumbnailPath,
    bool? isDeleted,
    DateTime? deletedAt,
    List<String>? people,
  }) {
    return Photo(
      id: id ?? this.id,
      path: path ?? this.path,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavorite: isFavorite ?? this.isFavorite,
      mediaType: mediaType ?? this.mediaType,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      people: people ?? this.people,
    );
  }
}

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final int typeId = 0;

  @override
  Photo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Photo(
      id: fields[0] as String,
      path: fields[1] as String,
      tags: (fields[2] as List).cast<String>(),
      category: fields[3] as String?,
      dateAdded: fields[4] as DateTime,
      isFavorite: fields.containsKey(5) ? fields[5] as bool : false,
      mediaType: fields.containsKey(6)
          ? MediaType.values[fields[6] as int]
          : MediaType.image,
      thumbnailPath: fields.containsKey(7) ? fields[7] as String? : null,
      isDeleted: fields.containsKey(8) ? fields[8] as bool : false,
      deletedAt: fields.containsKey(9) ? fields[9] as DateTime? : null,
      people: fields.containsKey(10) ? (fields[10] as List).cast<String>() : [],
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.tags)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.dateAdded)
      ..writeByte(5)
      ..write(obj.isFavorite)
      ..writeByte(6)
      ..write(obj.mediaType.index)
      ..writeByte(7)
      ..write(obj.thumbnailPath)
      ..writeByte(8)
      ..write(obj.isDeleted)
      ..writeByte(9)
      ..write(obj.deletedAt)
      ..writeByte(10)
      ..write(obj.people);
  }
}
