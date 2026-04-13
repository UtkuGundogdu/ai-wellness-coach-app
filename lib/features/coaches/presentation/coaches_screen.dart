import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/app_scope.dart';
import '../../../core/models/coach.dart';
import '../../history/presentation/chat_history_cubit.dart';

class CoachesScreen extends StatelessWidget {
  const CoachesScreen({
    super.key,
    required this.onCoachSelected,
  });

  final Future<void> Function(String coachId, String? sessionId) onCoachSelected;

  @override
  Widget build(BuildContext context) {
    final scope = AppScopeProvider.of(context);

    return FutureBuilder<List<Coach>>(
      future: scope.coachRepository.getCoaches(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final coaches = snapshot.data!;

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Wellness Coaches',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Remote Config controls each coach persona before the Vertex AI chat session starts.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final coach = coaches[index];
                    return _CoachCard(
                      coach: coach,
                      onTap: () async {
                        final session = await scope.chatRepository.createSession(
                          coachId: coach.id,
                        );
                        if (context.mounted) {
                          await onCoachSelected(coach.id, session.id);
                          if (context.mounted) {
                            context.read<ChatHistoryCubit>().loadHistory();
                          }
                        }
                      },
                    );
                  },
                  childCount: coaches.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.92,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.coach,
    required this.onTap,
  });

  final Coach coach;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: coach.color,
                child: Icon(
                  coach.icon,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              Text(
                coach.specialty,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                coach.name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                coach.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
