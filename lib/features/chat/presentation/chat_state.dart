part of 'chat_cubit.dart';

enum ChatStatus {
  initial,
  loading,
  ready,
  failure,
}

class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.coachId,
    this.coachName,
    this.coachSpecialty,
    this.session,
    this.isSending = false,
    this.streamingReply = '',
    this.errorMessage,
  });

  final ChatStatus status;
  final String? coachId;
  final String? coachName;
  final String? coachSpecialty;
  final ChatSession? session;
  final bool isSending;
  final String streamingReply;
  final String? errorMessage;

  ChatState copyWith({
    ChatStatus? status,
    String? coachId,
    String? coachName,
    String? coachSpecialty,
    ChatSession? session,
    bool? isSending,
    String? streamingReply,
    String? errorMessage,
  }) {
    return ChatState(
      status: status ?? this.status,
      coachId: coachId ?? this.coachId,
      coachName: coachName ?? this.coachName,
      coachSpecialty: coachSpecialty ?? this.coachSpecialty,
      session: session ?? this.session,
      isSending: isSending ?? this.isSending,
      streamingReply: streamingReply ?? this.streamingReply,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        coachId,
        coachName,
        coachSpecialty,
        session,
        isSending,
        streamingReply,
        errorMessage,
      ];
}
