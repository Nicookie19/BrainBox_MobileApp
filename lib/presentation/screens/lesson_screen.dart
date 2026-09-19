import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/data/repositories/lesson_repository.dart' as lr;
import 'package:brainbox/data/repositories/lesson_progress_repository.dart';
import 'package:brainbox/data/repositories/course_repository.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class LessonScreen extends StatefulWidget {
  final String courseId;
  final String? initialLessonId;

  const LessonScreen({
    required this.courseId,
    this.initialLessonId,
    super.key,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> with TickerProviderStateMixin {
  Course? _course;
  lr.LessonModuleData? _lessonData;
  List<lr.Lesson> _allLessons = [];
  int _currentLessonIndex = 0;
  int _currentStepIndex = 0;
  late AnimationController _progressController;
  bool _isCompleted = false;
  bool _courseNotFound = false;
  bool _lessonNotFound = false;

  // Answer state for interactive steps
  int? _selectedAnswer;
  String? _fillInBlankAnswer;
  List<int>? _codeOrderAnswer;
  bool _stepAnswered = false;
  bool _stepCorrect = false;

  // Persistence: track answered steps for resume
  Map<int, int> _answeredSteps = {}; // stepIndex -> selectedAnswerIndex

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadData();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final course = await CourseRepository.getCourseById(widget.courseId);
    final lessonData = await lr.LessonRepository.getCourseLessons(widget.courseId);

    if (mounted) {
      setState(() {
        _course = course;
        _lessonData = lessonData;
        _courseNotFound = course == null;
        _lessonNotFound = lessonData == null || lessonData.modules.isEmpty;

        if (course != null && lessonData != null) {
          _allLessons = lessonData.modules
              .expand((m) => m.lessons)
              .toList();

          // Find initial lesson index
          if (widget.initialLessonId != null) {
            _currentLessonIndex = _allLessons.indexWhere(
              (l) => l.id == widget.initialLessonId,
            );
            if (_currentLessonIndex == -1) _currentLessonIndex = 0;
          }

          // Load progress
          _loadLessonProgress();
          _progressController.forward();
        }
      });
    }
  }

  void _loadLessonProgress() async {
    final lesson = _getCurrentLesson();
    if (lesson != null) {
      final progress = await LessonProgressRepository.loadProgress(
        widget.courseId,
        lesson.id,
      );
      if (progress != null) {
        setState(() {
          _currentStepIndex = progress.currentStepIndex;
          _answeredSteps = progress.answeredSteps;
          // Restore answer state for current step
          if (progress.answeredSteps.containsKey(_currentStepIndex)) {
            _selectedAnswer = progress.answeredSteps[_currentStepIndex];
            _stepAnswered = true;
          }
        });
      }
    }
  }

  lr.Lesson? _getCurrentLesson() {
    if (_allLessons.isEmpty || _currentLessonIndex >= _allLessons.length) {
      return null;
    }
    return _allLessons[_currentLessonIndex];
  }

  lr.LessonStep? _getCurrentStep() {
    final lesson = _getCurrentLesson();
    if (lesson == null || _currentStepIndex >= lesson.steps.length) {
      return null;
    }
    return lesson.steps[_currentStepIndex];
  }

  double get _lessonProgress {
    final lesson = _getCurrentLesson();
    if (lesson == null || lesson.steps.isEmpty) return 0.0;
    return (_currentStepIndex + 1) / lesson.steps.length;
  }

  double get _courseProgress {
    if (_allLessons.isEmpty) return 0.0;
    return (_currentLessonIndex + _lessonProgress) / _allLessons.length;
  }

  @override
  Widget build(BuildContext context) {
    if (_courseNotFound) {
      return _buildErrorScreen(
        'Course Not Found',
        'The course you\'re looking for doesn\'t exist or has been removed.',
      );
    }

    if (_lessonNotFound) {
      return _buildErrorScreen(
        'Lessons Not Available',
        'Lesson content for this course is not available yet.',
      );
    }

    if (_course == null || _lessonData == null) {
      return Scaffold(
        backgroundColor: AppColors.bgPrimary,
        body: const Center(child: CircularProgressIndicator(color: AppColors.accentPrimary)),
      );
    }

    final lesson = _getCurrentLesson();
    final step = _getCurrentStep();

    if (lesson == null || step == null) {
      return _buildCompletionScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            _buildProgressBars(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLessonHeader(lesson),
                    const SizedBox(height: 24),
                    _buildStepContent(step),
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

Widget _buildErrorScreen(String title, String message) {
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
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              Text(message, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(onPressed: () => context.pop(), icon: const Icon(Icons.arrow_back_rounded), label: const Text('Go Back'), style: FilledButton.styleFrom(backgroundColor: AppColors.accentPrimary)),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildAppBar(BuildContext context) {
    final lesson = _getCurrentLesson();
    final backButton = IconButton(
      onPressed: () => context.pop(),
      icon: const Icon(Icons.arrow_back_rounded),
      style: IconButton.styleFrom(
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.textPrimary,
      ),
    );
    final titleColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _course!.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Lesson ${_currentLessonIndex + 1} of ${_allLessons.length}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );

    final isBookmarked = lesson != null && context.read<AppProvider>().isBookmarked('${widget.courseId}:${lesson.id}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          backButton,
          const SizedBox(width: 12),
          Expanded(child: titleColumn),
          IconButton(
            onPressed: lesson != null ? () => context.read<AppProvider>().toggleBookmark('${widget.courseId}:${lesson.id}') : null,
            icon: Icon(isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.bgCard,
              foregroundColor: isBookmarked ? AppColors.accentPrimary : AppColors.textSecondary,
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

  Widget _buildProgressBars() {
    return AnimatedBuilder(
      animation: _progressController,
      builder: (context, child) {
        return Column(
          children: [
            // Course progress
            LinearProgressIndicator(
              value: _courseProgress * _progressController.value,
              minHeight: 4,
              backgroundColor: AppColors.bgTertiary,
              color: AppColors.accentSecondary,
            ),
            const SizedBox(height: 8),
            // Lesson progress
            LinearProgressIndicator(
              value: _lessonProgress * _progressController.value,
              minHeight: 3,
              backgroundColor: AppColors.bgTertiary,
              color: AppColors.accentPrimary,
            ),
          ],
        );
      },
    );
  }

  Widget _buildLessonHeader(lr.Lesson lesson) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'STEP ${_currentStepIndex + 1} OF ${lesson.steps.length}',
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
      ],
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildStepContent(lr.LessonStep step) {
    switch (step.type) {
      case lr.LessonStepType.explanation:
        return _buildExplanationStep(step);
      case lr.LessonStepType.multipleChoice:
        return _buildMultipleChoiceStep(step);
      case lr.LessonStepType.fillInBlank:
        return _buildFillInBlankStep(step);
      case lr.LessonStepType.codeOrdering:
        return _buildCodeOrderingStep(step);
    }
  }

  Widget _buildExplanationStep(lr.LessonStep step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.content ?? '',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary,
              height: 1.7,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildMultipleChoiceStep(lr.LessonStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.question ?? '',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        ...step.options!.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;
          final isCorrect = index == step.correctAnswer;
          final isSelected = index == _selectedAnswer;

          Color borderColor = AppColors.borderDefault;
          Color bgColor = AppColors.bgCard;
          Color textColor = AppColors.textPrimary;
          IconData? trailingIcon;

          if (_stepAnswered) {
            if (isCorrect) {
              borderColor = AppColors.accentSuccess;
              bgColor = AppColors.accentSuccessSoft;
              textColor = AppColors.accentSuccess;
              trailingIcon = Icons.check_circle_rounded;
            } else if (isSelected) {
              borderColor = AppColors.accentError;
              bgColor = AppColors.accentErrorSoft;
              textColor = AppColors.accentError;
              trailingIcon = Icons.cancel_rounded;
            }
          } else if (isSelected) {
            borderColor = AppColors.accentPrimary;
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _stepAnswered ? null : () => _selectAnswer(index, isCorrect),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          option,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: textColor,
                            fontWeight: isCorrect && _stepAnswered ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (trailingIcon != null)
                        Icon(trailingIcon, color: textColor, size: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_stepAnswered) ...[
          const SizedBox(height: 16),
          _buildExplanationCard(step),
        ],
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildFillInBlankStep(lr.LessonStep step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.question ?? '',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          onChanged: (value) => _fillInBlankAnswer = value.trim().toLowerCase(),
          onSubmitted: _stepAnswered ? null : (_) => _checkFillInBlank(step),
          decoration: InputDecoration(
            hintText: 'Type your answer...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.bgCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: _stepAnswered
                    ? (_stepCorrect ? AppColors.accentSuccess : AppColors.accentError)
                    : AppColors.borderDefault,
                width: 2,
              ),
            ),
            enabled: !_stepAnswered,
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        if (_stepAnswered) ...[
          const SizedBox(height: 16),
          _buildExplanationCard(step),
        ],
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  void _checkFillInBlank(lr.LessonStep step) {
    final userAnswer = _fillInBlankAnswer?.trim().toLowerCase() ?? '';
    final correct = userAnswer == step.answer?.toLowerCase();
    setState(() {
      _stepAnswered = true;
      _stepCorrect = correct;
      _answeredSteps[_currentStepIndex] = correct ? 1 : 0;
    });
    _saveProgress();
  }

  Widget _buildCodeOrderingStep(lr.LessonStep step) {
    final snippets = step.snippets ?? [];
    final currentOrder = _codeOrderAnswer ?? List.generate(snippets.length, (i) => i);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.question ?? '',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Drag to reorder (tap to move up/down)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        ...currentOrder.asMap().entries.map((entry) {
          final displayIndex = entry.key;
          final snippetIndex = entry.value;
          final snippet = snippets[snippetIndex];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _stepAnswered ? null : () => _moveCodeSnippet(displayIndex, -1),
                onLongPress: _stepAnswered ? null : () => _moveCodeSnippet(displayIndex, 1),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D1117),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _stepAnswered
                          ? (_isCodeOrderCorrect(step) ? AppColors.accentSuccess : AppColors.accentError)
                          : AppColors.borderDefault,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${displayIndex + 1}.',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          color: Color(0xFFD2A8FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          snippet,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: Color(0xFFC7F9CC),
                            height: 1.6,
                          ),
                        ),
                      ),
                      if (!_stepAnswered)
                        Icon(
                          Icons.drag_indicator_rounded,
                          color: AppColors.textMuted,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
        if (_stepAnswered) ...[
          const SizedBox(height: 16),
          _buildExplanationCard(step),
        ],
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  void _moveCodeSnippet(int index, int direction) {
    final currentStep = _getCurrentStep();
    if (currentStep == null) return;
    final snippets = currentStep.snippets ?? [];
    final newOrder = List<int>.from(_codeOrderAnswer ?? List.generate(
      snippets.length, (i) => i));
    final newIndex = index + direction;
    if (newIndex >= 0 && newIndex < newOrder.length) {
      final temp = newOrder[index];
      newOrder[index] = newOrder[newIndex];
      newOrder[newIndex] = temp;
      setState(() => _codeOrderAnswer = newOrder);
    }
  }

  bool _isCodeOrderCorrect(lr.LessonStep step) {
    if (_codeOrderAnswer == null || step.correctOrder == null) return false;
    if (_codeOrderAnswer!.length != step.correctOrder!.length) return false;
    for (int i = 0; i < _codeOrderAnswer!.length; i++) {
      if (_codeOrderAnswer![i] != step.correctOrder![i]) return false;
    }
    return true;
  }

  Widget _buildExplanationCard(lr.LessonStep step) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _stepCorrect
            ? AppColors.accentSuccessSoft
            : AppColors.accentPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _stepCorrect
              ? AppColors.accentSuccess.withValues(alpha: 0.3)
              : AppColors.accentPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _stepCorrect ? Icons.check_circle_rounded : Icons.info_rounded,
            color: _stepCorrect ? AppColors.accentSuccess : AppColors.accentPrimary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              step.explanation ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _stepCorrect ? AppColors.accentSuccess : AppColors.accentPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  void _selectAnswer(int index, bool isCorrect) {
    setState(() {
      _selectedAnswer = index;
      _stepAnswered = true;
      _stepCorrect = isCorrect;
      _answeredSteps[_currentStepIndex] = index;
    });
    _saveProgress();
  }

  Widget _buildBottomAction() {
    final lesson = _getCurrentLesson();
    final step = _getCurrentStep();

    if (lesson == null || step == null) {
      return _buildCompletionAction();
    }

    if (_isCompleted) {
      return _buildCompletionAction();
    }

    final isLastStep = _currentStepIndex == lesson.steps.length - 1;
    final isLastLesson = _currentLessonIndex == _allLessons.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            if (!_stepAnswered)
              Text(
                'Select an answer to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _stepAnswered ? _nextStep : null,
              icon: Icon(isLastStep ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded),
              label: Text(
                isLastStep
                    ? (isLastLesson ? 'Complete Course' : 'Next Lesson')
                    : 'Next Step',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: _stepAnswered ? AppColors.accentPrimary : AppColors.bgTertiary,
                foregroundColor: _stepAnswered ? AppColors.textOnAccent : AppColors.textMuted,
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
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    final lesson = _getCurrentLesson();
    if (lesson == null) return;

    if (_currentStepIndex < lesson.steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _selectedAnswer = null;
        _fillInBlankAnswer = null;
        _codeOrderAnswer = null;
        _stepAnswered = false;
        _stepCorrect = false;
      });
      _progressController.forward(from: 0);
      _saveProgress();
    } else {
      _completeLesson();
    }
  }

  void _completeLesson() {
    final lesson = _getCurrentLesson();
    if (lesson == null) return;

    // Mark lesson as completed
    if (_currentLessonIndex < _allLessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
        _currentStepIndex = 0;
        _selectedAnswer = null;
        _fillInBlankAnswer = null;
        _codeOrderAnswer = null;
        _stepAnswered = false;
        _stepCorrect = false;
      });
      _progressController.forward(from: 0);
      _awardXp(lesson.xpReward);
    } else {
      setState(() => _isCompleted = true);
      _awardXp(lesson.xpReward);
      _showCompletionDialog();
    }
  }

  Future<void> _awardXp(int amount) async {
    final provider = context.read<AppProvider>();
    await provider.addXp(amount);
  }

  Future<void> _saveProgress() async {
    final lesson = _getCurrentLesson();
    if (lesson == null) return;

    await LessonProgressRepository.saveProgress(
      courseId: widget.courseId,
      lessonId: lesson.id,
      currentStepIndex: _currentStepIndex,
      answeredSteps: _answeredSteps,
      isFinished: _isCompleted,
    );
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
            const Expanded(child: Text('Course Complete!')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '+${_allLessons.fold(0, (sum, l) => sum + l.xpReward)} XP earned',
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

  Widget _buildCompletionScreen() {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.celebration_rounded, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  'Course Complete!',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'ve completed all lessons!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Home'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.accentPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
          label: const Text('Back to Home'),
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