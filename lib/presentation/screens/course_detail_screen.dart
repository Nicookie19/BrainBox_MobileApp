import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/data/repositories/course_repository.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/learning_models.dart';
import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({required this.courseId, super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> with TickerProviderStateMixin {
  Course? _course;
  bool _enrolled = false;
  late AnimationController _animationController;
  List<Color> _colors = [];
  bool _courseNotFound = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadCourse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCourse() async {
    final course = await CourseRepository.getCourseById(widget.courseId);
    if (mounted) {
      setState(() {
        _course = course;
        _courseNotFound = course == null;
        _enrolled = StorageService.getBool('course_${widget.courseId}_enrolled', defaultValue: false);
        if (course != null) {
          _colors = _getCategoryColors(course.category);
        }
      });
      if (course != null) {
        _animationController.forward();
      }
    }
  }

  Future<void> _toggleEnrollment() async {
    setState(() => _enrolled = !_enrolled);
    await StorageService.setBool('course_${widget.courseId}_enrolled', _enrolled);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_enrolled ? 'Added to My Learning' : 'Removed from My Learning'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _enrolled ? AppColors.accentSuccess : AppColors.accentError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_courseNotFound) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 64, color: AppColors.accentError),
                const SizedBox(height: 16),
                Text(
                  'Course Not Found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'The course you\'re looking for doesn\'t exist or has been removed.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_course == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.bgPrimary,
            surfaceTintColor: Colors.transparent,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.bgCard.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.bookmark_outline_rounded, color: AppColors.textPrimary),
                ),
              ),
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bgCard.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -40,
                      top: -40,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 24,
                      right: 24,
                      bottom: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_course!.category.icon, color: Colors.white, size: 36),
                          const SizedBox(height: 12),
                          Text(
                            _course!.category.title.toUpperCase(),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _course!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildMetaChip(Icons.menu_book_rounded, '${_course!.lessonCount} lessons'),
                              const SizedBox(width: 12),
                              _buildMetaChip(Icons.schedule_rounded, '${_course!.estimatedHours}h'),
                              const SizedBox(width: 12),
                              _buildMetaChip(
                                Icons.bar_chart_rounded,
                                _course!.difficulty.label,
                                color: _course!.difficulty.color,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildEnrollButton(),
                  const SizedBox(height: 28),
                  _buildLearningOutcomes(),
                  const SizedBox(height: 24),
                  _buildCurriculum(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(IconData icon, String text, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this course',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _course!.longDescription,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _course!.tags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderDefault),
              ),
              child: Text(
                '#$tag',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildEnrollButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: _toggleEnrollment,
        icon: Icon(_enrolled ? Icons.check_circle_rounded : Icons.play_circle_rounded),
        label: Text(
          _enrolled ? 'Continue Learning' : 'Start Learning',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: _enrolled ? AppColors.accentSuccess : AppColors.accentPrimary,
          foregroundColor: AppColors.textOnAccent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildLearningOutcomes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you\'ll learn',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        ..._course!.learningOutcomes.asMap().entries.map((entry) {
          final index = entry.key;
          final outcome = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _colors[0].withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: _colors[0],
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    outcome,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (300 + index * 50).ms).slideX(begin: 0.2, end: 0);
        }),
      ],
    );
  }

  Widget _buildCurriculum() {
    final lessonCount = _course!.lessonCount.clamp(8, 12);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Course Curriculum',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              '$lessonCount lessons',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...List.generate(lessonCount, (index) {
          final isLocked = index > 0 && !_enrolled;
          return _CurriculumItem(
            number: index + 1,
            title: _getLessonTitle(index),
            duration: '8 min',
            isLocked: isLocked,
            isCompleted: index == 0 && _enrolled,
            onTap: isLocked ? null : () => context.go('/lesson/${widget.courseId}?lesson=$index'),
          ).animate().fadeIn(delay: (400 + index * 50).ms).slideY(begin: 0.1, end: 0);
        }),
      ],
    );
  }

  String _getLessonTitle(int index) {
    const titles = [
      'Introduction & Setup',
      'Core Concepts',
      'Hands-on Practice',
      'Advanced Techniques',
      'Real-world Project',
      'Best Practices',
      'Common Pitfalls',
      'Final Project',
      'Review & Next Steps',
      'Bonus: Tips & Tricks',
    ];
    return index < titles.length ? titles[index] : 'Lesson ${index + 1}';
  }

  List<Color> _getCategoryColors(LearningCategory category) {
    switch (category) {
      case LearningCategory.webDevelopment:
        return [AppColors.accentSecondary, AppColors.accentSecondaryLight];
      case LearningCategory.mobileDevelopment:
        return [AppColors.accentPrimary, AppColors.accentPrimaryLight];
      case LearningCategory.programmingLanguages:
        return [AppColors.accentSuccess, AppColors.accentSuccessLight];
      case LearningCategory.machineLearning:
        return [AppColors.accentWarning, AppColors.accentWarningLight];
      default:
        return [AppColors.accentPrimary, AppColors.accentPrimaryLight];
    }
  }
}

class _CurriculumItem extends StatelessWidget {
  const _CurriculumItem({
    required this.number,
    required this.title,
    required this.duration,
    this.isLocked = false,
    this.isCompleted = false,
    this.onTap,
  });

  final int number;
  final String title;
  final String duration;
  final bool isLocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLocked ? AppColors.bgTertiary : AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLocked ? AppColors.borderMuted : AppColors.borderDefault,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.accentSuccess
                      : (isLocked ? AppColors.bgTertiary : AppColors.accentPrimarySoft),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isCompleted
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                    : isLocked
                        ? Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 18)
                        : Text(
                            number.toString(),
                            style: TextStyle(
                              color: isLocked ? AppColors.textMuted : AppColors.accentPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isLocked ? AppColors.textMuted : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Lesson $number · $duration',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLocked)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textMuted,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}