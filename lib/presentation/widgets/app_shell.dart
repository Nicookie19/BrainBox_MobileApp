import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/core/constants/app_colors.dart';
import 'package:brainbox/presentation/widgets/brand_mark.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  static const _routes = ['/', '/explore', '/learn', '/community', '/profile'];

  static const _items = [
    _NavItem('Home', 'assets/ui/nav_home.png', 'assets/ui/nav_home_active.png'),
    _NavItem(
      'Learn',
      'assets/ui/nav_learn.png',
      'assets/ui/nav_learn_active.png',
    ),
    _NavItem('Code', 'assets/ui/nav_code.png', 'assets/ui/nav_code.png'),
    _NavItem(
      'Community',
      'assets/ui/nav_community.png',
      'assets/ui/nav_community.png',
    ),
    _NavItem(
      'Profile',
      'assets/ui/nav_profile.png',
      'assets/ui/nav_profile.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPath = GoRouterState.of(context).uri.path;
    final selectedIndex = _routes.indexWhere((route) => currentPath == route);
    final activeIndex = selectedIndex == -1 ? 0 : selectedIndex;
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 64,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            decoration: const BoxDecoration(
              color: AppColors.bgSecondary,
              border: Border(
                bottom: BorderSide(color: AppColors.borderDefault),
              ),
            ),
            child: const BrandMark(size: 31),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 58,
          decoration: const BoxDecoration(
            color: AppColors.bgSecondary,
            border: Border(top: BorderSide(color: AppColors.borderDefault)),
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == activeIndex;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: item.label,
                  child: InkWell(
                    onTap: () => context.go(_routes[index]),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox.square(
                          dimension: 20,
                          child: Image.asset(
                            selected ? item.activeAsset : item.asset,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: selected
                                ? AppColors.textPrimary
                                : AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.asset, this.activeAsset);

  final String label;
  final String asset;
  final String activeAsset;
}
