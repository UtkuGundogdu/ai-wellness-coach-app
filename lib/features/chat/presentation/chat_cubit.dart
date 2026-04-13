import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/chat_session.dart';
import '../../../core/repositories/chat_repository.dart';
import '../../../core/repositories/coach_repository.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({
    required ChatRepository chatRepository,
    required CoachRepository coachRepository,
  })  : _chatRepository = chatRepository,
        _coachRepository = coachRepository,
        super(const ChatState());

  final ChatRepository _chatRepository;
  final CoachRepository _coachRepository;

  Future<void> initialize({
    required String coachId,
    String? sessionId,
  }) async {
    emit(state.copyWith(status: ChatStatus.loading));

    try {
      final coach = await _coachRepository.getCoachById(coachId);
      final session = await _chatRepository.ensureSession(
        coachId: coachId,
        sessionId: sessionId,
      );

      emit(
        state.copyWith(
          status: ChatStatus.ready,
          coachId: coachId,
          coachName: coach.name,
          coachSpecialty: coach.specialty,
          session: session,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ChatStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  Future<void> sendMessage(String prompt) async {
    final trimmed = prompt.trim();
    if (trimmed.isEmpty || state.session == null || state.isSending) {
      return;
    }

    emit(
      state.copyWith(
        isSending: true,
        streamingReply: '',
        errorMessage: null,
      ),
    );

    try {
      final persona = await _coachRepository.getPersona(state.coachId!);
      final modelName = await _coachRepository.getModelName();
      final vertexLocation = await _coachRepository.getVertexLocation();

      final buffer = StringBuffer();
      await for (final chunk in _chatRepository.streamCoachReply(
        persona: persona,
        modelName: modelName,
        vertexLocation: vertexLocation,
        history: state.session!.messages,
        prompt: trimmed,
      )) {
        buffer.write(chunk);
        emit(
          state.copyWith(
            isSending: true,
            streamingReply: buffer.toString(),
            errorMessage: null,
          ),
        );
      }

      final reply = buffer.toString().trim();
      if (reply.isEmpty) {
        throw Exception('The AI coach returned an empty response.');
      }

      final updatedSession = await _chatRepository.appendExchange(
        session: state.session!,
        userMessage: trimmed,
        coachMessage: reply,
      );

      emit(
        state.copyWith(
          status: ChatStatus.ready,
          session: updatedSession,
          isSending: false,
          streamingReply: '',
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isSending: false,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
