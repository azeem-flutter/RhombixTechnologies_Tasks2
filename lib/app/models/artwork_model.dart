import 'package:cloud_firestore/cloud_firestore.dart';

class ArtworkModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String category;
  final String artistId;
  final String artistName;
  final String? artistImage;
  final Timestamp createdAt;

  ArtworkModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.artistId,
    required this.artistName,
    this.artistImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'artistId': artistId,
      'artistName': artistName,
      'artistImage': artistImage,
      'createdAt': createdAt,
      // likes and views are stored ONLY as subcollections, not as fields
    };
  }

  factory ArtworkModel.fromMap(String id, Map<String, dynamic> map) {
    return ArtworkModel(
      id: id,
      title: map['title'],
      imageUrl: map['imageUrl'],
      description: map['description'],
      category: map['category'],
      artistId: map['artistId'],
      artistName: map['artistName'],
      artistImage: map['artistImage'],
      createdAt: map['createdAt'],
    );
  }

  ArtworkModel copyWith({
    String? title,
    String? imageUrl,
    String? description,
    String? category,
    String? artistId,
    String? artistName,
    String? artistImage,
  }) {
    return ArtworkModel(
      id: id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      artistImage: artistImage ?? this.artistImage,
      createdAt: createdAt,
    );
  }
}
