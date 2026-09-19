import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'data/services/storage_service.dart';
import 'data/repositories/course_repository.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/explore_screen.dart';
import 'presentation/screens/learning_screen.dart';
import 'presentation/screens/community_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/lesson_screen.dart';
import 'presentation/screens/daily_challenge_screen.dart';
import 'presentation/screens/course_detail_screen.dart';
import 'presentation/widgets/app_shell.dart';
import 'presentation/providers/app_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  await CourseRepository.initializeSampleCourses();
  runApp(const BrainBoxApp());
}

class BrainBoxApp extends StatelessWidget {
  const BrainBoxApp({super.key});

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
        create: (_) => AppProvider()..initialize(),
        child: MaterialApp.router(
          title: 'BrainBox | Learn by doing',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: _router,
        ),
      );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
        GoRoute(path: '/explore', builder: (_, _) => const ExploreScreen()),
        GoRoute(path: '/learn', builder: (_, _) => const LearningScreen()),
        GoRoute(path: '/community', builder: (_, _) => const CommunityScreen()),
        GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
      ],
    ),
    GoRoute(
      path: '/lesson/:courseId',
      builder: (context, state) => LessonScreen(
        courseId: state.pathParameters['courseId']!,
      ),
    ),
    GoRoute(
      path: '/challenge',
      builder: (_, _) => const DailyChallengeScreen(),
    ),
    GoRoute(
      path: '/course/:courseId',
      builder: (context, state) => CourseDetailScreen(
        courseId: state.pathParameters['courseId']!,
      ),
    ),
  ],
);