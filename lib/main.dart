import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: JeeAiApp()));
}

class JeeAiApp extends StatelessWidget {
  const JeeAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'JeeAI',
      theme: AppTheme.dark,
      routerConfig: AppRouter.router,
    );
  }
}
