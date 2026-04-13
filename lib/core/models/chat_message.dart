import 'package:equatable/equatable.dart';

enum MessageAuthor {
  user,
  coach,
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final MessageAuthor author;
  final String text;
  final DateTime createdAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.name,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      author: MessageAuthor.values.byName(json['author'] as String),
      text: json['text'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, author, text, createdAt];
}
