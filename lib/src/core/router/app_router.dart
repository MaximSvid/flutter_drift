import 'package:flutter/material.dart';
import 'package:flutter_database_drift/src/views/home/home_screen.dart';
import 'package:flutter_database_drift/src/views/list/task_list_detail_screen.dart';
import 'package:flutter_database_drift/src/views/list/task_list_screen.dart';
import 'package:flutter_database_drift/src/views/navigation/scaffold_with_nav_bar.dart';
import 'package:flutter_database_drift/src/views/settings/settings_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: <RouteBase>[
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: <GoRoute>[
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/list',
            builder: (context, state) => const TaskListScreen(),
            routes: <GoRoute>[
              GoRoute(
                path: ':id',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) =>
                    TaskListDetailScreen(taskId: state.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
