import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/chat_repository.dart';
import '../repositories/coach_repository.dart';
import '../services/ai_chat_service.dart';
import '../services/remote_config_service.dart';

class AppScope {
  AppScope({
    required this.coachRepository,
    required this.chatRepository,
    required this.firebaseSetupError,
  });

  final CoachRepository coachRepository;
  final ChatRepository chatRepository;
  final String? firebaseSetupError;

  static Future<AppScope> create({
    required String? firebaseSetupError,
  }) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    final remoteConfigService = RemoteCoachConfigService(
      firebaseSetupError: firebaseSetupError,
    );
    final aiChatService = firebaseSetupError == null
        ? FirebaseAiChatService(
            firebaseSetupError: firebaseSetupError,
          )
        : MockAiChatService(
            modeLabel: 'demo',
          );

    return AppScope(
      coachRepository: CoachRepository(
        remoteConfigService: remoteConfigService,
      ),
      chatRepository: ChatRepository(
        sharedPreferences: sharedPreferences,
        aiChatService: aiChatService,
      ),
      firebaseSetupError: firebaseSetupError,
    );
  }
}

class AppScopeProvider extends InheritedWidget {
  const AppScopeProvider({
    super.key,
    required this.scope,
    required super.child,
  });

  final AppScope scope;

  static AppScope of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<AppScopeProvider>();
    assert(provider != null, 'AppScopeProvider is missing from the widget tree.');
    return provider!.scope;
  }

  @override
  bool updateShouldNotify(AppScopeProvider oldWidget) => oldWidget.scope != scope;
}
