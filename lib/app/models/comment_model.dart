import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String artworkId;
  final String userId;
  final String userName;
  final String? userImage;
  final String text;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.artworkId,
    required this.userId,
    required this.userName,
    this.userImage,
    required this.text,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'artworkId': artworkId,
      'userId': userId,
      'userName': userName,
      'userImage': userImage,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory CommentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return CommentModel(
      id: doc.id,
      artworkId: data['artworkId'],
      userId: data['userId'],
      userName: data['userName'],
      userImage: data['userImage'],
      text: data['text'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
