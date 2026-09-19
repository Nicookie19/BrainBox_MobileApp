import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:brainbox/presentation/providers/app_provider.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> with TickerProviderStateMixin {
  static const List<_QuizQuestion> _questions = [
    _QuizQuestion(
      'What does Array.map() return?',
      ['A single value', 'A new array', 'Nothing', 'A string'],
      1,
      'Array.map() creates a new array with the results of calling a provided function on every element.',
    ),
    _QuizQuestion(
      'Which keyword creates a constant in JavaScript?',
      ['var', 'let', 'const', 'static'],
      2,
      'const creates a block-scoped constant that cannot be reassigned.',
    ),
    _QuizQuestion(
      'What is the result of 2 + "2" in JavaScript?',
      ['4', '22', 'Error', 'null'],
      1,
      'JavaScript converts the number to a string and concatenates, resulting in "22".',
    ),
    _QuizQuestion(
      'What does the spread operator (...) do?',
      ['Copies array elements', 'Deletes elements', 'Sorts the array', 'Reverses the array'],
      0,
      'The spread operator expands an iterable into individual elements, useful for copying arrays.',
    ),
    _QuizQuestion(
      'Which method removes the last element from an array?',
      ['pop()', 'push()', 'shift()', 'unshift()'],
      0,
      'pop() removes the last element from an array and returns that element.',
    ),
  ];

  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _finished = false;
  late AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _finished ? () => context.pop() : () => _showExitDialog(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          _finished ? 'Challenge Complete' : 'Daily Challenge',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!_finished) ...[
                      _buildQuestionCard(question),
                      const SizedBox(height: 24),
                      _buildAnswerOptions(question),
                      if (_answered) ...[
                        const SizedBox(height: 16),
                        _buildExplanation(question),
                      ],
                    ] else ...[
                      _buildCompletionCard(),
                    ],
                  ],
                ),
              ),
            ),
            if (!_finished) _buildBottomAction(),
            if (_finished) _buildFinishAction(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accentWarningSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.bolt_rounded, color: AppColors.accentWarning, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '50 XP available',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.accentWarning,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '${_currentIndex + 1}/${_questions.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              final progress = (_currentIndex + (_answered ? 1 : 0)) / _questions.length;
              return LinearProgressIndicator(
                value: progress * _progressController.value,
                minHeight: 8,
                backgroundColor: AppColors.bgTertiary,
                color: AppColors.accentWarning,
                borderRadius: BorderRadius.circular(4),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(_QuizQuestion question) {
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
            question.text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildAnswerOptions(_QuizQuestion question) {
    return Column(
      children: question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isCorrect = index == question.answer;
        final isSelected = index == _selectedAnswer;

        Color borderColor = AppColors.borderDefault;
        Color bgColor = AppColors.bgCard;
        Color textColor = AppColors.textPrimary;
        IconData? trailingIcon;

        if (_answered) {
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
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _answered ? null : () => _selectAnswer(index, isCorrect),
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
                          fontWeight: isCorrect && _answered ? FontWeight.w600 : FontWeight.w500,
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
      }).toList(),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildExplanation(_QuizQuestion question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _selectedAnswer == question.answer
            ? AppColors.accentSuccessSoft
            : AppColors.accentPrimarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _selectedAnswer == question.answer
              ? AppColors.accentSuccess.withValues(alpha: 0.3)
              : AppColors.accentPrimary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _selectedAnswer == question.answer
                ? Icons.check_circle_rounded
                : Icons.info_rounded,
            color: _selectedAnswer == question.answer
                ? AppColors.accentSuccess
                : AppColors.accentPrimary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              question.explanation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _selectedAnswer == question.answer
                    ? AppColors.accentSuccess
                    : AppColors.accentPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }

  Widget _buildCompletionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.accentPrimary, AppColors.accentPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Challenge Complete!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You answered ${_score}/${_questions.length} questions correctly',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '+50 XP',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale().slideY(begin: 0.3, end: 0);
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: _answered ? _nextQuestion : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.accentWarning,
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
          child: Text(_currentIndex == _questions.length - 1 ? 'Finish Challenge' : 'Next Question'),
        ),
      ),
    );
  }

  Widget _buildFinishAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: SafeArea(
        top: false,
        child: FilledButton(
          onPressed: () {
            context.read<AppProvider>().completeChallenge();
            context.pop();
          },
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
          child: const Text('Continue Learning'),
        ),
      ),
    );
  }

  void _selectAnswer(int index, bool isCorrect) {
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex == _questions.length - 1) {
      setState(() => _finished = true);
      _progressController.forward();
    } else {
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      _progressController.forward(from: 0);
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Exit Challenge?'),
        content: const Text('Your progress will be lost. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.accentError),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}

class _QuizQuestion {
  const _QuizQuestion(this.text, this.options, this.answer, this.explanation);
  final String text;
  final List<String> options;
  final int answer;
  final String explanation;
}