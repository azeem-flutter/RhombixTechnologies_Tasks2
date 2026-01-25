class ArtworkModel {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final String category;
  final String artistId;
  final String artistName;
  final String? artistImage;
  final int likes;
  final List<String> likedBy; // User IDs who liked this
  final DateTime createdAt;
  final int views;

  ArtworkModel({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.description,
    required this.category,
    required this.artistId,
    required this.artistName,
    this.artistImage,
    this.likes = 0,
    this.likedBy = const [],
    required this.createdAt,
    this.views = 0,
  });

  // Convert ArtworkModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'imageUrl': imageUrl,
      'description': description,
      'category': category,
      'artistId': artistId,
      'artistName': artistName,
      'artistImage': artistImage,
      'likes': likes,
      'likedBy': likedBy,
      'createdAt': createdAt.toIso8601String(),
      'views': views,
    };
  }

  // Create ArtworkModel from Firestore document
  factory ArtworkModel.fromMap(Map<String, dynamic> map) {
    return ArtworkModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      artistId: map['artistId'] ?? '',
      artistName: map['artistName'] ?? '',
      artistImage: map['artistImage'],
      likes: map['likes'] ?? 0,
      likedBy: List<String>.from(map['likedBy'] ?? []),
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      views: map['views'] ?? 0,
    );
  }

  // Copy with method for updates
  ArtworkModel copyWith({
    String? id,
    String? title,
    String? imageUrl,
    String? description,
    String? category,
    String? artistId,
    String? artistName,
    String? artistImage,
    int? likes,
    List<String>? likedBy,
    DateTime? createdAt,
    int? views,
  }) {
    return ArtworkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      category: category ?? this.category,
      artistId: artistId ?? this.artistId,
      artistName: artistName ?? this.artistName,
      artistImage: artistImage ?? this.artistImage,
      likes: likes ?? this.likes,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
    );
  }
}
