import 'dart:math';

import '../services/storage_service.dart';

class DailyChallengeRepository {
  static const String _completionKey = 'daily_challenge_completed_';
  static const String _scoreKey = 'daily_challenge_score_';

  // Large pool of questions for daily rotation
  static final List<ChallengeQuestion> _questionPool = [
    // JavaScript
    ChallengeQuestion(
      'What does Array.map() return?',
      ['A single value', 'A new array', 'Nothing', 'A string'],
      1,
      'Array.map() creates a new array with the results of calling a provided function on every element.',
    ),
    ChallengeQuestion(
      'Which keyword creates a constant in JavaScript?',
      ['var', 'let', 'const', 'static'],
      2,
      'const creates a block-scoped constant that cannot be reassigned.',
    ),
    ChallengeQuestion(
      'What is the result of 2 + "2" in JavaScript?',
      ['4', '22', 'Error', 'null'],
      1,
      'JavaScript converts the number to a string and concatenates, resulting in "22".',
    ),
    ChallengeQuestion(
      'What does the spread operator (...) do?',
      ['Copies array elements', 'Deletes elements', 'Sorts the array', 'Reverses the array'],
      0,
      'The spread operator expands an iterable into individual elements, useful for copying arrays.',
    ),
    ChallengeQuestion(
      'Which method removes the last element from an array?',
      ['pop()', 'push()', 'shift()', 'unshift()'],
      0,
      'pop() removes the last element from an array and returns that element.',
    ),
    ChallengeQuestion(
      'What does === compare in JavaScript?',
      ['Value only', 'Value and type', 'Type only', 'Reference only'],
      1,
      '=== checks both value and type without type coercion.',
    ),
    ChallengeQuestion(
      'What is the output of typeof null?',
      ['"null"', '"object"', '"undefined"', '"boolean"'],
      1,
      'typeof null returns "object" - this is a known JavaScript quirk.',
    ),
    ChallengeQuestion(
      'Which method adds elements to the end of an array?',
      ['push()', 'pop()', 'shift()', 'unshift()'],
      0,
      'push() adds one or more elements to the end of an array.',
    ),

    // Python
    ChallengeQuestion(
      'What is the output of: print(type([]) is list)?',
      ['True', 'False', 'Error', 'None'],
      0,
      '[] creates a list, and type([]) is list evaluates to True.',
    ),
    ChallengeQuestion(
      'Which keyword defines a function in Python?',
      ['function', 'def', 'func', 'lambda'],
      1,
      'def is used to define a function in Python.',
    ),
    ChallengeQuestion(
      'What does len("hello") return?',
      ['5', '6', 'Error', 'None'],
      0,
      'len() returns the number of characters in a string.',
    ),
    ChallengeQuestion(
      'What is the output of: print(2 ** 3)?',
      ['6', '8', '9', 'Error'],
      1,
      '** is the exponentiation operator. 2 ** 3 = 2³ = 8.',
    ),
    ChallengeQuestion(
      'Which method removes an item from a list by value?',
      ['remove()', 'delete()', 'pop()', 'discard()'],
      0,
      'remove(value) removes the first occurrence of value from the list.',
    ),
    ChallengeQuestion(
      'What does range(3) produce?',
      ['[1, 2, 3]', '[0, 1, 2]', '[3, 2, 1]', '[0, 1, 2, 3]'],
      1,
      'range(n) generates integers from 0 to n-1.',
    ),

    // CSS
    ChallengeQuestion(
      'Which CSS property controls text size?',
      ['font-size', 'text-size', 'font-style', 'text-style'],
      0,
      'font-size sets the size of the font.',
    ),
    ChallengeQuestion(
      'What does display: flex do?',
      ['Creates a grid', 'Makes element a flex container', 'Hides element', 'Centers content'],
      1,
      'display: flex makes an element a flex container, enabling flexbox layout for its children.',
    ),
    ChallengeQuestion(
      'Which property creates space between flex items?',
      ['margin', 'gap', 'padding', 'border'],
      1,
      'gap creates space between flex items without using margins.',
    ),
    ChallengeQuestion(
      'What does justify-content: center do?',
      ['Centers items on cross axis', 'Centers items on main axis', 'Centers text', 'Centers container'],
      1,
      'justify-content aligns items along the main axis. center places them in the middle.',
    ),

    // General CS
    ChallengeQuestion(
      'What is the time complexity of binary search?',
      ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
      1,
      'Binary search divides the search space in half each iteration, giving O(log n).',
    ),
    ChallengeQuestion(
      'Which data structure uses LIFO?',
      ['Queue', 'Stack', 'Array', 'Linked List'],
      1,
      'Stack follows Last In, First Out (LIFO) principle.',
    ),
    ChallengeQuestion(
      'What does HTTP status 404 mean?',
      ['Server error', 'Not found', 'Unauthorized', 'Forbidden'],
      1,
      '404 means the requested resource was not found on the server.',
    ),
    ChallengeQuestion(
      'What is a closure in programming?',
      ['A loop', 'A function with access to outer scope', 'A variable', 'An error'],
      1,
      'A closure is a function that retains access to variables from its enclosing scope.',
    ),
    ChallengeQuestion(
      'What does SQL stand for?',
      ['Structured Query Language', 'Simple Query Language', 'Standard Query Logic', 'System Query Language'],
      0,
      'SQL stands for Structured Query Language.',
    ),
  ];

  /// Gets the daily challenge questions for a specific date
  static List<ChallengeQuestion> getDailyQuestions(DateTime date) {
    final seed = _dateToSeed(date);
    final random = Random(seed);
    final shuffled = List<ChallengeQuestion>.from(_questionPool);
    shuffled.shuffle(random);
    return shuffled.take(5).toList();
  }

  /// Converts a date to a deterministic seed
  static int _dateToSeed(DateTime date) {
    final utcDate = DateTime(date.year, date.month, date.day);
    return utcDate.millisecondsSinceEpoch ~/ 86400000; // Days since epoch
  }

  /// Checks if the daily challenge has been completed for a given date
  static bool isCompletedForDate(DateTime date) {
    final key = '$_completionKey${_dateToString(date)}';
    return StorageService.getBool(key, defaultValue: false);
  }

  /// Marks the daily challenge as completed for a given date
  static Future<void> markCompletedForDate(DateTime date, int score) async {
    final completionKey = '$_completionKey${_dateToString(date)}';
    final scoreKey = '$_scoreKey${_dateToString(date)}';
    await StorageService.setBool(completionKey, true);
    await StorageService.setInt(scoreKey, score);
  }

  /// Gets the score for a completed daily challenge
  static int getScoreForDate(DateTime date) {
    final key = '$_scoreKey${_dateToString(date)}';
    return StorageService.getInt(key, defaultValue: 0);
  }

  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class ChallengeQuestion {
  const ChallengeQuestion(this.text, this.options, this.answer, this.explanation);
  final String text;
  final List<String> options;
  final int answer;
  final String explanation;
}