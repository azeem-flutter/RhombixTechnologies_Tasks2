class CommentModel {
  final String id;
  final String artworkId;
  final String userId;
  final String userName;
  final String? userImage;
  final String text;
  final DateTime timestamp;

  CommentModel({
    required this.id,
    required this.artworkId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.text,
    required this.timestamp,
  });

  // Convert CommentModel to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'artworkId': artworkId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // Create CommentModel from Firestore document
  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      artworkId: map['artworkId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      userImage: map['userImage'],
      text: map['text'] ?? '',
      timestamp: DateTime.parse(
        map['timestamp'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Copy with method
  CommentModel copyWith({
    String? id,
    String? artworkId,
    String? userId,
    String? userName,
    String? userImage,
    String? text,
    DateTime? timestamp,
  }) {
    return CommentModel(
      id: id ?? this.id,
      artworkId: artworkId ?? this.artworkId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userImage: userImage ?? this.userImage,
      text: text ?? this.text,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
