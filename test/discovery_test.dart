import 'package:brainbox/core/theme/app_theme.dart';
import 'package:brainbox/data/repositories/course_repository.dart';
import 'package:brainbox/data/services/storage_backend.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/presentation/screens/explore_screen.dart';
import 'package:brainbox/presentation/widgets/course_card.dart';
import 'package:brainbox/presentation/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  Future<AppProvider> mountExplore(WidgetTester tester) async {
    StorageService.resetForTesting();
    await StorageService.init(backend: MemoryStorageBackend());
    await CourseRepository.initializeSampleCourses();
    final provider = AppProvider();
    await tester.runAsync(provider.initialize);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: ExploreScreen()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return provider;
  }

  testWidgets('search trims whitespace and empty results can be reset', (
    tester,
  ) async {
    final provider = await mountExplore(tester);
    await tester.enterText(find.byType(TextField), '  PYTHON ESSENTIALS  ');
    await tester.pumpAndSettle();
    expect(find.text('1 learning path found'), findsOneWidget);
    expect(
      tester.widget<CourseCard>(find.byType(CourseCard).first).course.id,
      'python-essentials',
    );
    await tester.enterText(find.byType(TextField), 'no matching topic');
    await tester.pumpAndSettle();
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Show all courses'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show all courses'));
    await tester.pumpAndSettle();
    expect(
      find.text('${provider.courses.length} learning paths found'),
      findsOneWidget,
    );
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
  });

  testWidgets('catalog sorting changes the visible course order', (
    tester,
  ) async {
    final provider = await mountExplore(tester);
    await tester.tap(find.text('Recommended'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Title A–Z').last);
    await tester.pumpAndSettle();
    final titles = provider.courses.map((c) => c.title).toList()..sort();
    expect(
      tester.widget<CourseCard>(find.byType(CourseCard).first).course.title,
      titles.first,
    );
  });

  testWidgets('compact catalog stays within screen bounds', (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await mountExplore(tester);
    expect(tester.takeException(), isNull);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('desktop navigation changes destinations', (tester) async {
    tester.view.physicalSize = const Size(1440, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final router = GoRouter(
      routes: [
        ShellRoute(
          builder: (_, _, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const Text('Dashboard content'),
            ),
            GoRoute(
              path: '/explore',
              builder: (_, _) => const Text('Catalog content'),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(find.text('Explore'));
    await tester.pumpAndSettle();
    expect(find.text('Catalog content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
