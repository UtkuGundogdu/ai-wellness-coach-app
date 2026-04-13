import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/di/app_scope.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/coaches/presentation/coaches_screen.dart';
import '../../features/history/presentation/chat_history_cubit.dart';
import '../../features/history/presentation/chat_history_screen.dart';
import '../../features/navigation/navigation_cubit.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScopeProvider.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (_) => ChatHistoryCubit(scope.chatRepository)..loadHistory(),
        ),
      ],
      child: const _ShellView(),
    );
  }
}

class _ShellView extends StatelessWidget {
  const _ShellView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, selectedIndex) {
        return Scaffold(
          body: SafeArea(
            child: IndexedStack(
              index: selectedIndex,
              children: [
                CoachesScreen(
                  onCoachSelected: (coachId, sessionId) async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChatScreen(
                          coachId: coachId,
                          sessionId: sessionId,
                        ),
                      ),
                    );
                    if (context.mounted) {
                      context.read<ChatHistoryCubit>().loadHistory();
                    }
                  },
                ),
                ChatHistoryScreen(
                  onSessionSelected: (coachId, sessionId) async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ChatScreen(
                          coachId: coachId,
                          sessionId: sessionId,
                        ),
                      ),
                    );
                    if (context.mounted) {
                      context.read<ChatHistoryCubit>().loadHistory();
                    }
                  },
                ),
              ],
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: context.read<NavigationCubit>().changeTab,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.spa_outlined),
                selectedIcon: Icon(Icons.spa),
                label: 'Coaches',
              ),
              NavigationDestination(
                icon: Icon(Icons.forum_outlined),
                selectedIcon: Icon(Icons.forum),
                label: 'Chat History',
              ),
            ],
          ),
        );
      },
    );
  }
}
