import 'package:flutter/material.dart';

import '../core/di/app_scope.dart';
import 'theme.dart';
import 'widgets/app_shell.dart';

class WellnessCoachApp extends StatelessWidget {
  const WellnessCoachApp({
    super.key,
    required this.scope,
  });

  final AppScope scope;

  @override
  Widget build(BuildContext context) {
    return AppScopeProvider(
      scope: scope,
      child: MaterialApp(
        title: 'Wellness AI Coaches',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AppShell(),
      ),
    );
  }
}
