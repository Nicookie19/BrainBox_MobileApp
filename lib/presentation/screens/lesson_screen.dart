import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/data/repositories/course_repository.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;

  const LessonScreen({required this.courseId, super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> with TickerProviderStateMixin {
  Course? _course;
  int _currentLessonIndex = 0;
  late AnimationController _progressController;
  bool _isCompleted = false;
  bool _courseNotFound = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadCourse();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadCourse() async {
    final course = await CourseRepository.getCourseById(widget.courseId);
    if (mounted) {
      setState(() {
        _course = course;
        _courseNotFound = course == null;
      });
      if (course != null) {
        _progressController.forward();
      }
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

    final lesson = _getCurrentLesson();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLessonHeader(lesson),
                    const SizedBox(height: 24),
                    _buildKeyIdea(),
                    const SizedBox(height: 24),
                    _buildConceptSection(),
                    const SizedBox(height: 24),
                    _buildCodeExample(),
                    const SizedBox(height: 24),
                    _buildInteractiveProblem(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.bgCard,
              foregroundColor: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _course!.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.bookmark_outline_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.bgCard,
              foregroundColor: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.download_outlined),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.bgCard,
              foregroundColor: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentLessonIndex + 1) / _course!.lessonCount;
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return LinearProgressIndicator(
          value: progress * _progressController.value,
          minHeight: 4,
          backgroundColor: AppColors.bgTertiary,
          color: AppColors.accentPrimary,
        );
      },
    );
  }

  Lesson _getCurrentLesson() {
    // Mock lesson data - in real app this would come from the course modules
    return Lesson(
      id: 'lesson_${_currentLessonIndex + 1}',
      moduleId: 'module_1',
      title: _getLessonTitle(_currentLessonIndex),
      content: _getLessonContent(_currentLessonIndex),
      codeSnippets: _getCodeSnippets(_currentLessonIndex),
      keyTakeaways: _getKeyTakeaways(_currentLessonIndex),
      estimatedMinutes: 10,
      order: _currentLessonIndex + 1,
    );
  }

  String _getLessonTitle(int index) {
    const titles = [
      'Introduction to Flexbox',
      'Flex Direction & Axes',
      'Justify Content',
      'Align Items',
      'Flex Wrap',
      'Gap Property',
      'Flex Grow & Shrink',
      'Flex Basis',
      'Align Self',
      'Flexbox Patterns',
    ];
    return index < titles.length ? titles[index] : 'Lesson ${index + 1}';
  }

  String _getLessonContent(int index) {
    const contents = [
      'Flexbox is a one-dimensional layout method for arranging items in rows or columns. Items flex to fill additional space or shrink to fit into smaller spaces.',
      'The main axis is defined by flex-direction. The cross axis runs perpendicular. Understanding both axes is key to mastering Flexbox.',
      'justify-content aligns items along the main axis. Options include flex-start, flex-end, center, space-between, space-around, and space-evenly.',
      'align-items aligns items along the cross axis. Options include flex-start, flex-end, center, stretch, and baseline.',
      'flex-wrap controls whether items wrap to new lines. nowrap (default) forces all items on one line. wrap allows multiple lines.',
      'The gap property creates space between flex items without using margins. It works with both row and column directions.',
      'flex-grow defines how much an item grows relative to others. flex-shrink defines how much it shrinks. Both default to 0 and 1 respectively.',
      'flex-basis sets the initial size before growing/shrinking. It can be a length, percentage, or auto (based on content).',
      'align-self allows individual items to override the container\'s align-items value. Useful for special positioning.',
      'Common patterns: Holy Grail layout, card grids, navigation bars, centered content, and sticky footers.',
    ];
    return index < contents.length ? contents[index] : 'Lesson content here.';
  }

  List<String> _getCodeSnippets(int index) {
    const snippets = [
      ['.container { display: flex; }'],
      ['.container { flex-direction: row; }', '.container { flex-direction: column; }'],
      ['.container { justify-content: space-between; }'],
      ['.container { align-items: center; }'],
      ['.container { flex-wrap: wrap; }'],
      ['.container { gap: 16px; }'],
      ['.item { flex-grow: 1; }', '.item { flex-shrink: 0; }'],
      ['.item { flex-basis: 200px; }'],
      ['.item { align-self: flex-end; }'],
      ['.card { flex: 1 1 300px; }'],
    ];
    return index < snippets.length ? snippets[index] : ['/* Code example */'];
  }

  List<String> _getKeyTakeaways(int index) {
    const takeaways = [
      ['Flexbox is one-dimensional (row or column)', 'Parent controls child layout'],
      ['Main axis = flex-direction', 'Cross axis = perpendicular'],
      ['justify-content = main axis alignment', '6 values available'],
      ['align-items = cross axis alignment', 'stretch is default'],
      ['flex-wrap: wrap enables multi-line', 'wrap-reverse reverses order'],
      ['gap replaces margin hacks', 'Works in both directions'],
      ['flex-grow distributes extra space', 'flex-shrink prevents overflow'],
      ['flex-basis sets initial size', 'auto uses content size'],
      ['align-self overrides container', 'Per-item control'],
      ['Combine properties for layouts', 'Flexbox is composable'],
    ];
    return index < takeaways.length ? takeaways[index] : ['Key takeaway here'];
  }

  Widget _buildLessonHeader(Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LESSON ${_currentLessonIndex + 1} OF ${_course!.lessonCount}',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.accentPrimary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          lesson.title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          lesson.content,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildKeyIdea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentPrimarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Idea',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getCurrentLesson().keyTakeaways.first,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.accentPrimaryDark,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildConceptSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Two Axes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Flexbox works with a main axis and a cross axis. By default, the main axis runs horizontally (left to right). You can change that direction with flex-direction.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        _buildAxisVisualization(),
      ],
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildAxisVisualization() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAxisLabel('Main Axis', AppColors.accentPrimary, Icons.arrow_forward_rounded),
              _buildAxisLabel('Cross Axis', AppColors.accentSecondary, Icons.arrow_upward_rounded),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _AxisPainter(),
              size: const Size(double.infinity, 120),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisLabel(String label, Color color, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildCodeExample() {
    final lesson = _getCurrentLesson();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try It Yourself',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1117),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildCodeTag('.container'),
                  const SizedBox(width: 8),
                  _buildCodeTag('{'),
                ],
              ),
              const SizedBox(height: 8),
              ...lesson.codeSnippets.map((snippet) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 6),
                child: Text(
                  snippet,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Color(0xFFC7F9CC),
                    height: 1.6,
                  ),
                ),
              )),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildCodeTag('}'),
                ],
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildCodeTag(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        color: Color(0xFFD2A8FF),
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInteractiveProblem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check Your Understanding',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'What happens when justify-content is set to space-between?',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              ..._buildAnswerOptions(),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
  }

  List<Widget> _buildAnswerOptions() {
    const options = [
      'Items are evenly distributed with equal space around them',
      'Items are spaced with equal gaps between them, first and last at edges',
      'Items are centered with equal space on both sides',
      'Items are packed at the start of the container',
    ];

    return options.asMap().entries.map((entry) {
      final index = entry.key;
      final option = entry.value;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: _AnswerOption(
          text: option,
          isCorrect: index == 1,
          onSelected: (correct) => _handleAnswer(correct),
        ),
      );
    }).toList();
  }

  void _handleAnswer(bool correct) {
    if (correct) {
      _showCorrectDialog();
    } else {
      _showIncorrectDialog();
    }
  }

  void _showCorrectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentSuccess,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Correct!'),
          ],
        ),
        content: const Text('Great job! Items are evenly distributed with the first item at the start and the last item at the end.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _completeLesson();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showIncorrectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accentError,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Not Quite'),
          ],
        ),
        content: const Text('space-between places the first item at the start and the last item at the end, with equal spacing between the remaining items.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeLesson() async {
    final provider = context.read<AppProvider>();
    await provider.completeLesson(widget.courseId);

    if (_currentLessonIndex < _course!.lessonCount - 1) {
      setState(() => _currentLessonIndex++);
    } else {
      setState(() => _isCompleted = true);
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(child: Text('Lesson Complete!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+25 XP earned',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You\'ve completed all lessons in ${_course!.title}!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    if (_isCompleted) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(
          top: BorderSide(color: AppColors.borderDefault),
        ),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton.icon(
          onPressed: _completeLesson,
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Mark as Complete'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentPrimary,
            foregroundColor: AppColors.textOnAccent,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _AxisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Main axis
    paint.color = AppColors.accentPrimary;
    canvas.drawLine(
      Offset(40, size.height / 2),
      Offset(size.width - 40, size.height / 2),
      paint,
    );

    // Cross axis
    paint.color = AppColors.accentSecondary;
    canvas.drawLine(
      Offset(size.width / 2, 20),
      Offset(size.width / 2, size.height - 20),
      paint,
    );

    // Items on main axis
    final itemPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      final x = 60 + (size.width - 120) / 4 * i;
      itemPaint.color = AppColors.accentPrimary.withValues(alpha: 0.3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, size.height / 2),
            width: 40,
            height: 30,
          ),
          const Radius.circular(6),
        ),
        itemPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AnswerOption extends StatefulWidget {
  final String text;
  final bool isCorrect;
  final ValueChanged<bool> onSelected;

  const _AnswerOption({
    required this.text,
    required this.isCorrect,
    required this.onSelected,
  });

  @override
  State<_AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<_AnswerOption> {
  bool _selected = false;
  bool _answered = false;

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppColors.borderDefault;
    Color bgColor = AppColors.bgTertiary;

    if (_answered) {
      if (widget.isCorrect) {
        borderColor = AppColors.accentSuccess;
        bgColor = AppColors.accentSuccessSoft;
      } else if (_selected) {
        borderColor = AppColors.accentError;
        bgColor = AppColors.accentErrorSoft;
      }
    } else if (_selected) {
      borderColor = AppColors.accentPrimary;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _answered ? null : () {
          setState(() {
            _selected = true;
            _answered = true;
          });
          widget.onSelected(widget.isCorrect);
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _answered
                        ? (widget.isCorrect ? AppColors.accentSuccess : AppColors.accentError)
                        : (_selected ? AppColors.accentPrimary : AppColors.borderDefault),
                    width: 2,
                  ),
                  color: _answered && widget.isCorrect
                      ? AppColors.accentSuccess
                      : (_answered && _selected && !widget.isCorrect
                          ? AppColors.accentError
                          : Colors.transparent),
                ),
                child: _answered && widget.isCorrect
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 14)
                    : (_answered && _selected && !widget.isCorrect
                        ? const Icon(Icons.close_rounded, color: Colors.white, size: 14)
                        : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _answered && widget.isCorrect
                        ? AppColors.accentSuccess
                        : (_answered && _selected && !widget.isCorrect
                            ? AppColors.accentError
                            : AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}