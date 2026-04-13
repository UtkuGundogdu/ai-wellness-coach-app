import 'package:equatable/equatable.dart';

import 'chat_message.dart';

class ChatSession extends Equatable {
  const ChatSession({
    required this.id,
    required this.coachId,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  final String id;
  final String coachId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  String get lastMessagePreview {
    if (messages.isEmpty) {
      return 'Start the conversation';
    }
    return messages.last.text;
  }

  ChatSession copyWith({
    String? id,
    String? coachId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'coachId': coachId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((message) => message.toJson()).toList(),
    };
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String,
      coachId: json['coachId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List<dynamic>)
          .map((item) => ChatMessage.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, coachId, createdAt, updatedAt, messages];
}
