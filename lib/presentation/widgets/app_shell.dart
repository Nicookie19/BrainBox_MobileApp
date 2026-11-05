import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/core/constants/app_colors.dart';
import 'package:brainbox/presentation/widgets/brand_mark.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});
  final Widget child;
  static const _routes = ['/', '/explore', '/learn', '/community', '/profile'];
  static const _labels = ['Today', 'Explore', 'Learn', 'Community', 'Profile'];
  static const _icons = [
    Icons.home_outlined,
    Icons.explore_outlined,
    Icons.auto_stories_outlined,
    Icons.forum_outlined,
    Icons.person_outline_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final index = _routes.indexOf(GoRouterState.of(context).uri.path);
    final selected = index < 0 ? 0 : index;
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                const BrandMark(size: 32),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    'BrainBox',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Saved lessons',
                icon: const Icon(Icons.bookmarks_outlined),
                onPressed: () => context.push('/bookmarks'),
              ),
              IconButton(
                tooltip: 'Downloads',
                icon: const Icon(Icons.download_outlined),
                onPressed: () => context.push('/downloads'),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            top: false,
            child: Row(
              children: [
                if (wide) ...[
                  NavigationRail(
                    extended: constraints.maxWidth >= 1200,
                    backgroundColor: AppColors.bgPrimary,
                    selectedIndex: selected,
                    onDestinationSelected: (i) => context.go(_routes[i]),
                    labelType: constraints.maxWidth >= 1200
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.all,
                    destinations: List.generate(
                      _routes.length,
                      (i) => NavigationRailDestination(
                        icon: Icon(_icons[i]),
                        label: Text(_labels[i]),
                      ),
                    ),
                    trailing: Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: IconButton(
                        tooltip: 'Settings',
                        icon: const Icon(Icons.settings_outlined),
                        onPressed: () => context.push('/settings'),
                      ),
                    ),
                  ),
                  const VerticalDivider(width: 1),
                ],
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 960),
                      child: child,
                    ),
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: selected,
                  onDestinationSelected: (i) => context.go(_routes[i]),
                  destinations: List.generate(
                    _routes.length,
                    (i) => NavigationDestination(
                      icon: Icon(_icons[i]),
                      label: _labels[i],
                    ),
                  ),
                ),
        );
      },
    );
  }
}
