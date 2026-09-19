import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/community_repository.dart';
import 'data/repositories/course_repository.dart';
import 'data/services/storage_service.dart';
import 'data/models/course_models.dart';
import 'data/models/user_models.dart';
import 'data/models/community_models.dart';
import 'data/models/learning_models.dart';
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

void _toast(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );

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
        GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
        GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
        GoRoute(path: '/learn', builder: (_, __) => const LearningScreen()),
        GoRoute(path: '/community', builder: (_, __) => const CommunityScreen()),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
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
      builder: (_, __) => const DailyChallengeScreen(),
    ),
    GoRoute(
      path: '/course/:courseId',
      builder: (context, state) => CourseDetailScreen(
        courseId: state.pathParameters['courseId']!,
      ),
    ),
  ],
);