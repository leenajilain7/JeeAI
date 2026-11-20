import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                builder: (context, state) => const FeaturePlaceholder(
                  title: 'Dashboard',
                  subtitle:
                      'Your messages and assistant activity will appear here.',
                  icon: Icons.dashboard_rounded,
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const FeaturePlaceholder(
                  title: 'Inbox',
                  subtitle: 'Your conversations will appear here.',
                  icon: Icons.chat_bubble_rounded,
                ),
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
