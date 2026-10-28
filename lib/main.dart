import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/course_repository.dart';
import 'data/services/storage_service.dart';
import 'presentation/providers/app_provider.dart';
import 'presentation/screens/bookmarks_screen.dart';
import 'presentation/screens/community_screen.dart';
import 'presentation/screens/course_detail_screen.dart';
import 'presentation/screens/daily_challenge_screen.dart';
import 'presentation/screens/explore_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/learning_screen.dart';
import 'presentation/screens/lesson_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/widgets/app_shell.dart';

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
      builder: (context, child) =>
          _MobileAppFrame(child: child ?? const SizedBox.shrink()),
    ),
  );
}

/// Keeps the web and desktop previews faithful to the phone-first product.
/// On actual phones the app remains full screen; wider viewports receive a
/// centered handset canvas instead of a stretched tablet/desktop layout.
class _MobileAppFrame extends StatelessWidget {
  const _MobileAppFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth <= 600) return child;
      return ColoredBox(
        color: AppColors.bgPrimary,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390, maxHeight: 844),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.bgPrimary,
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: AppColors.borderDefault),
                boxShadow: AppShadows.cardElevated,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: child,
              ),
            ),
          ),
        ),
      );
    },
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
        initialLessonId: state.uri.queryParameters['lesson'],
      ),
    ),
    GoRoute(
      path: '/challenge',
      builder: (_, _) => const DailyChallengeScreen(),
    ),
    GoRoute(
      path: '/course/:courseId',
      builder: (context, state) =>
          CourseDetailScreen(courseId: state.pathParameters['courseId']!),
    ),
    GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
    GoRoute(path: '/bookmarks', builder: (_, _) => const BookmarksScreen()),
  ],
);
