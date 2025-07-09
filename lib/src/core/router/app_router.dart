import 'package:flutter/material.dart';
import 'package:flutter_database_drift/src/views/home_screen.dart';
import 'package:flutter_database_drift/src/views/settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_database_drift/src/views/task_list_screen.dart';
import 'package:flutter_database_drift/src/views/task_list_detail_screen.dart';
import 'package:flutter_database_drift/src/views/scaffold_with_nav_bar.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/list',
    routes: <RouteBase>[
      GoRoute(
        path: '/task/:id',
        builder: (BuildContext context, GoRouterState state) {
          final String id = state.pathParameters['id']!;
          return TaskListDetailScreen(taskId: id);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/home',
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/list',
                builder: (BuildContext context, GoRouterState state) =>
                    const TaskListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: '/settings',
                builder: (BuildContext context, GoRouterState state) =>
                    const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
