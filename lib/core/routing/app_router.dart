import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/inbox/presentation/screens/conversation_screen.dart';
import '../../features/inbox/presentation/screens/inbox_screen.dart';
import '../../shared/widgets/app_navigation_shell.dart';
import '../../shared/widgets/feature_placeholder.dart';

abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppNavigationShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const InboxScreen(),
                routes: [
                  GoRoute(
                    path: ':conversationId',
                    builder: (context, state) => ConversationScreen(
                      conversationId:
                          state.pathParameters['conversationId'] ?? '',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/assistant',
                builder: (context, state) => const FeaturePlaceholder(
                  title: 'AI Assistant',
                  subtitle: 'Your AI assistant will be ready here.',
                  icon: Icons.auto_awesome_rounded,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const FeaturePlaceholder(
                  title: 'Settings',
                  subtitle: 'Personalize your JeeAI experience here.',
                  icon: Icons.settings_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
