import 'package:ai_wellness_coach_app/core/models/chat_session.dart';
import 'package:ai_wellness_coach_app/features/history/presentation/chat_history_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chat history initial state is empty', () {
    const state = ChatHistoryState();

    expect(state.sessions, isEmpty);
    expect(state.status, ChatHistoryStatus.initial);
  });

  test('chat session preview falls back when empty', () {
    final session = ChatSession(
      id: '1',
      coachId: 'coach',
      createdAt: DateTime(2026, 4, 13),
      updatedAt: DateTime(2026, 4, 13),
      messages: const [],
    );

    expect(session.lastMessagePreview, 'Start the conversation');
  });
}
