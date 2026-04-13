import 'package:firebase_ai/firebase_ai.dart';

import '../models/chat_message.dart';

abstract class AiChatService {
  Stream<String> streamCoachReply({
    required String persona,
    required String modelName,
    required String vertexLocation,
    required List<ChatMessage> history,
    required String prompt,
  });
}

class FirebaseAiChatService implements AiChatService {
  FirebaseAiChatService({
    required String? firebaseSetupError,
  }) : _firebaseSetupError = firebaseSetupError;

  final String? _firebaseSetupError;

  @override
  Stream<String> streamCoachReply({
    required String persona,
    required String modelName,
    required String vertexLocation,
    required List<ChatMessage> history,
    required String prompt,
  }) async* {
    if (_firebaseSetupError != null) {
      throw Exception(
        'Firebase is not configured correctly. $_firebaseSetupError',
      );
    }

    final model = FirebaseAI.vertexAI(location: vertexLocation).generativeModel(
      model: modelName,
      systemInstruction: Content.system(persona),
    );

    final chat = model.startChat(
      history: history.map(_toContent).toList(),
    );

    final response = chat.sendMessageStream(
      Content.text(prompt),
    );

    await for (final chunk in response) {
      final text = chunk.text;
      if (text != null && text.trim().isNotEmpty) {
        yield text;
      }
    }
  }

  Content _toContent(ChatMessage message) {
    return Content(
      message.author == MessageAuthor.user ? 'user' : 'model',
      [TextPart(message.text)],
    );
  }
}

class MockAiChatService implements AiChatService {
  MockAiChatService({
    required this.modeLabel,
  });

  final String modeLabel;

  @override
  Stream<String> streamCoachReply({
    required String persona,
    required String modelName,
    required String vertexLocation,
    required List<ChatMessage> history,
    required String prompt,
  }) async* {
    final lowerPrompt = prompt.toLowerCase();
    final reply = _buildReply(
      persona: persona,
      prompt: prompt,
      lowerPrompt: lowerPrompt,
      historyLength: history.length,
    );

    final words = reply.split(' ');
    final buffer = StringBuffer();
    for (final word in words) {
      if (buffer.isNotEmpty) {
        buffer.write(' ');
      }
      buffer.write(word);
      yield '${word} ';
    }
  }

  String _buildReply({
    required String persona,
    required String prompt,
    required String lowerPrompt,
    required int historyLength,
  }) {
    if (lowerPrompt.contains('meal') ||
        lowerPrompt.contains('nutrition') ||
        lowerPrompt.contains('diet')) {
      return 'Demo mode: Focus on one protein source, one fiber source, and one easy snack option today. Start with a simple plate structure and repeat what is realistic for your schedule.';
    }

    if (lowerPrompt.contains('workout') ||
        lowerPrompt.contains('fitness') ||
        lowerPrompt.contains('exercise')) {
      return 'Demo mode: Try a 20 minute session with 5 minutes mobility, 10 minutes strength basics, and 5 minutes cooldown. Keep the effort moderate and prioritize consistent form.';
    }

    if (lowerPrompt.contains('pilates') ||
        lowerPrompt.contains('posture') ||
        lowerPrompt.contains('core')) {
      return 'Demo mode: Start with breath, rib control, and slow core activation. A short sequence of imprint, toe taps, and bridge holds is a solid low impact routine.';
    }

    if (lowerPrompt.contains('yoga') ||
        lowerPrompt.contains('stretch') ||
        lowerPrompt.contains('mobility')) {
      return 'Demo mode: Use a gentle flow with cat cow, low lunge, downward dog, and a seated fold. Keep the breath slow and stay below any painful range.';
    }

    return 'Demo mode: I am using the configured coach persona fallback because Firebase is not connected yet. Based on your message, start with one small habit today, keep it realistic, and review how it felt after you complete it. Message count in this conversation: $historyLength.';
  }
}
