import 'package:firebase_core/firebase_core.dart';
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
    required this.firebaseInitializationError,
  });

  final CoachRepository coachRepository;
  final ChatRepository chatRepository;
  final FirebaseException? firebaseInitializationError;

  static Future<AppScope> create({
    required FirebaseException? firebaseInitializationError,
  }) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    final remoteConfigService = RemoteCoachConfigService(
      firebaseInitializationError: firebaseInitializationError,
    );
    final aiChatService = FirebaseAiChatService(
      firebaseInitializationError: firebaseInitializationError,
    );

    return AppScope(
      coachRepository: CoachRepository(
        remoteConfigService: remoteConfigService,
      ),
      chatRepository: ChatRepository(
        sharedPreferences: sharedPreferences,
        aiChatService: aiChatService,
      ),
      firebaseInitializationError: firebaseInitializationError,
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
