import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/models/coach.dart';
import 'chat_history_cubit.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({
    super.key,
    required this.onSessionSelected,
  });

  final Future<void> Function(String coachId, String sessionId) onSessionSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chat History',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Resume any conversation exactly where you left it.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Expanded(
            child: BlocBuilder<ChatHistoryCubit, ChatHistoryState>(
              builder: (context, state) {
                if (state.status == ChatHistoryStatus.loading &&
                    state.sessions.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == ChatHistoryStatus.failure &&
                    state.sessions.isEmpty) {
                  return Center(
                    child: Text(state.errorMessage ?? 'History could not load.'),
                  );
                }

                if (state.sessions.isEmpty) {
                  return const _EmptyHistory();
                }

                final scope = AppScopeProvider.of(context);
                return FutureBuilder<List<Coach>>(
                  future: scope.coachRepository.getCoaches(),
                  builder: (context, snapshot) {
                    final coaches = snapshot.data ?? const <Coach>[];
                    return ListView.separated(
                      itemCount: state.sessions.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final session = state.sessions[index];
                        final coach = coaches.firstWhere(
                          (item) => item.id == session.coachId,
                          orElse: () => const Coach(
                            id: 'unknown',
                            name: 'Coach',
                            specialty: 'Coach',
                            description: '',
                            icon: Icons.support_agent,
                            color: Colors.white,
                            remoteConfigKey: '',
                          ),
                        );

                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(18),
                            leading: CircleAvatar(
                              backgroundColor: coach.color,
                              child: Icon(coach.icon),
                            ),
                            title: Text('${coach.specialty} • ${coach.name}'),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                session.lastMessagePreview,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing: Text(
                              DateFormat('MMM d, HH:mm').format(session.updatedAt),
                            ),
                            onTap: () => onSessionSelected(
                              session.coachId,
                              session.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline_rounded,
            size: 44,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            'No saved conversations yet.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          const Text(
            'Start a coach chat and it will appear here automatically.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
