import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/chat_session.dart';
import '../../../core/repositories/chat_repository.dart';

part 'chat_history_state.dart';

class ChatHistoryCubit extends Cubit<ChatHistoryState> {
  ChatHistoryCubit(this._chatRepository) : super(const ChatHistoryState());

  final ChatRepository _chatRepository;

  Future<void> loadHistory() async {
    emit(state.copyWith(status: ChatHistoryStatus.loading));
    try {
      final sessions = await _chatRepository.getAllSessions();
      emit(
        state.copyWith(
          status: ChatHistoryStatus.success,
          sessions: sessions,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: ChatHistoryStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }
}
