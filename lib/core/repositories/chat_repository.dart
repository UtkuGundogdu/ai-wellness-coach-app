import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/ai_chat_service.dart';

class ChatRepository {
  ChatRepository({
    required SharedPreferences sharedPreferences,
    required AiChatService aiChatService,
  })  : _sharedPreferences = sharedPreferences,
        _aiChatService = aiChatService;

  static const _storageKey = 'chat_sessions_v1';

  final SharedPreferences _sharedPreferences;
  final AiChatService _aiChatService;

  Future<List<ChatSession>> getAllSessions() async {
    final raw = _sharedPreferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw) as List<dynamic>;

    return decoded
        .map((item) => ChatSession.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList()
      ..sort((left, right) => right.updatedAt.compareTo(left.updatedAt));
  }

  Future<ChatSession?> getSession(String sessionId) async {
    final sessions = await getAllSessions();
    for (final session in sessions) {
      if (session.id == sessionId) {
        return session;
      }
    }
    return null;
  }

  Future<ChatSession> createSession({
    required String coachId,
  }) async {
    final now = DateTime.now();
    final session = ChatSession(
      id: now.microsecondsSinceEpoch.toString(),
      coachId: coachId,
      createdAt: now,
      updatedAt: now,
      messages: const [],
    );

    final sessions = await getAllSessions();
    await _saveSessions([session, ...sessions]);
    return session;
  }

  Future<ChatSession> ensureSession({
    required String coachId,
    String? sessionId,
  }) async {
    if (sessionId != null) {
      final existing = await getSession(sessionId);
      if (existing != null) {
        return existing;
      }
    }

    return createSession(coachId: coachId);
  }

  Stream<String> streamCoachReply({
    required String persona,
    required String modelName,
    required String vertexLocation,
    required List<ChatMessage> history,
    required String prompt,
  }) {
    return _aiChatService.streamCoachReply(
      persona: persona,
      modelName: modelName,
      vertexLocation: vertexLocation,
      history: history,
      prompt: prompt,
    );
  }

  Future<ChatSession> appendExchange({
    required ChatSession session,
    required String userMessage,
    required String coachMessage,
  }) async {
    final now = DateTime.now();
    final updated = session.copyWith(
      updatedAt: now,
      messages: [
        ...session.messages,
        ChatMessage(
          id: '${now.microsecondsSinceEpoch}-user',
          author: MessageAuthor.user,
          text: userMessage,
          createdAt: now,
        ),
        ChatMessage(
          id: '${now.microsecondsSinceEpoch}-coach',
          author: MessageAuthor.coach,
          text: coachMessage,
          createdAt: now.add(const Duration(milliseconds: 1)),
        ),
      ],
    );

    final sessions = await getAllSessions();
    final nextSessions = [
      updated,
      ...sessions.where((item) => item.id != updated.id),
    ];
    await _saveSessions(nextSessions);
    return updated;
  }

  Future<void> _saveSessions(List<ChatSession> sessions) async {
    final payload = jsonEncode(
      sessions.map((session) => session.toJson()).toList(),
    );
    await _sharedPreferences.setString(_storageKey, payload);
  }
}
