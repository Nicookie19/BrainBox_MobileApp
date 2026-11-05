import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/presentation/widgets/course_card.dart';
import 'package:brainbox/presentation/widgets/filter_chips.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/learning_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String _selectedCategory = 'All';
  DifficultyLevel? _selectedDifficulty;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _availableOnly = false;
  String _sort = 'Recommended';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const _LoadingSkeleton();
        }

        final filteredCourses = _filterCourses(provider);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, provider),
                    const SizedBox(height: 24),
                    _buildSearchBar(context),
                    const SizedBox(height: 16),
                    _buildDifficultyFilter(context),
                    const SizedBox(height: 16),
                    _buildCategoryFilter(context, provider),
                    const SizedBox(height: 20),
                    _buildCatalogControls(context, filteredCourses.length),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              sliver: SliverLayoutBuilder(
                builder: (context, constraints) {
                  if (filteredCourses.isEmpty) {
                    return SliverToBoxAdapter(child: _buildEmptyState());
                  }
                  final columns = constraints.crossAxisExtent >= 760 ? 2 : 1;
                  return SliverList.separated(
                    itemCount: (filteredCourses.length / columns).ceil(),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, row) => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var column = 0; column < columns; column++) ...[
                          if (column > 0) const SizedBox(width: 16),
                          Expanded(
                            child:
                                row * columns + column < filteredCourses.length
                                ? CourseCard(
                                    course:
                                        filteredCourses[row * columns + column],
                                    onTap: () => context.push(
                                      '/course/${filteredCourses[row * columns + column].id}',
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find your next\ninteresting problem.',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${provider.courses.length} courses. One next step for your curiosity.',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        hintText: 'Search courses, topics, skills...',
        hintStyle: TextStyle(color: AppColors.textMuted),
        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textMuted),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                tooltip: 'Clear search',
                icon: Icon(Icons.clear_rounded, color: AppColors.textMuted),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildDifficultyFilter(BuildContext context) {
    return FilterChips<DifficultyLevel?>(
      label: 'Difficulty',
      options: [null, ...DifficultyLevel.values],
      selected: _selectedDifficulty,
      getLabel: (d) => d == null ? 'Every level' : d.label,
      onChanged: (value) => setState(() => _selectedDifficulty = value),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildCategoryFilter(BuildContext context, AppProvider provider) {
    return FilterChips<String>(
      label: 'Category',
      options: [
        'All',
        ...provider.courses.map((c) => c.category.title).toSet().toList()
          ..sort(),
      ],
      selected: _selectedCategory,
      getLabel: (c) => c,
      onChanged: (value) => setState(() => _selectedCategory = value),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedCategory = 'All';
      _selectedDifficulty = null;
      _availableOnly = false;
      _sort = 'Recommended';
    });
  }

  Widget _buildCatalogControls(BuildContext context, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilterChip(
              label: const Text('Ready to learn'),
              avatar: const Icon(Icons.play_circle_outline, size: 18),
              selected: _availableOnly,
              onSelected: (value) => setState(() => _availableOnly = value),
            ),
            PopupMenuButton<String>(
              tooltip: 'Sort courses',
              initialValue: _sort,
              onSelected: (value) => setState(() => _sort = value),
              itemBuilder: (_) =>
                  [
                        'Recommended',
                        'Highest rated',
                        'Shortest first',
                        'Title A–Z',
                      ]
                      .map(
                        (value) =>
                            PopupMenuItem(value: value, child: Text(value)),
                      )
                      .toList(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(_sort),
                    const Icon(Icons.expand_more, size: 18),
                  ],
                ),
              ),
            ),
            if (_searchQuery.isNotEmpty ||
                _selectedCategory != 'All' ||
                _selectedDifficulty != null ||
                _availableOnly)
              TextButton(
                onPressed: _resetFilters,
                child: const Text('Reset filters'),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          '$count learning path${count == 1 ? '' : 's'} found',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }

  List<Course> _filterCourses(AppProvider provider) {
    final query = _searchQuery.trim().toLowerCase();
    final result = provider.courses.where((course) {
      final matchesSearch =
          query.isEmpty ||
          [
            course.title,
            course.shortDescription,
            course.category.title,
            ...course.tags,
          ].any((value) => value.toLowerCase().contains(query));
      return matchesSearch &&
          (_selectedCategory == 'All' ||
              course.category.title == _selectedCategory) &&
          (_selectedDifficulty == null ||
              course.difficulty == _selectedDifficulty) &&
          (!_availableOnly || provider.hasLessons(course.id));
    }).toList();
    result.sort((a, b) {
      final comparison = switch (_sort) {
        'Highest rated' => b.rating.compareTo(a.rating),
        'Shortest first' => a.estimatedHours.compareTo(b.estimatedHours),
        'Title A–Z' => a.title.compareTo(b.title),
        _ => (b.isFeatured ? 1 : 0).compareTo(a.isFeatured ? 1 : 0),
      };
      return comparison == 0 ? a.title.compareTo(b.title) : comparison;
    });
    return result;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'No courses match your filters',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'Try another topic or start again with all courses.',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _resetFilters,
            child: const Text('Show all courses'),
          ),
        ],
      ),
    );
  }
}

class _LoadingSkeleton extends StatelessWidget {
  const _LoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(width: 200, height: 32),
                const SizedBox(height: 8),
                _skeletonBox(width: 300, height: 20),
                const SizedBox(height: 24),
                _skeletonBox(width: double.infinity, height: 56),
                const SizedBox(height: 16),
                _skeletonBox(width: double.infinity, height: 48),
                const SizedBox(height: 16),
                _skeletonBox(width: double.infinity, height: 48),
                const SizedBox(height: 20),
                _skeletonBox(width: 150, height: 24),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          sliver: SliverList.separated(
            itemCount: 5,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) =>
                _skeletonBox(width: double.infinity, height: 140),
          ),
        ),
      ],
    );
  }

  Widget _skeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.bgTertiary,
        borderRadius: BorderRadius.circular(12),
      ),
    ).animate().shimmer(duration: 1500.ms);
  }
}
