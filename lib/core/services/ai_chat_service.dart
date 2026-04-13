import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';

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
    required FirebaseException? firebaseInitializationError,
  }) : _firebaseInitializationError = firebaseInitializationError;

  final FirebaseException? _firebaseInitializationError;

  @override
  Stream<String> streamCoachReply({
    required String persona,
    required String modelName,
    required String vertexLocation,
    required List<ChatMessage> history,
    required String prompt,
  }) async* {
    if (_firebaseInitializationError != null) {
      throw Exception(
        'Firebase is not configured. Add your platform Firebase config files and try again.',
      );
    }

    final model = FirebaseAI.vertexAI(location: vertexLocation).generativeModel(
      model: modelName,
      systemInstruction: Content.system(persona),
    );

    final chat = model.startChat(
      history: history.map(_toContent).toList(),
    );

    final response = chat.sendMessageStream([
      Content.text(prompt),
    ]);

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
