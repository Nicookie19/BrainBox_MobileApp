import 'dart:async';

import '../services/storage_service.dart';

class DailyChallengeRepository {
  static const String _completionKey = 'daily_challenge_completed_';
  static const String _scoreKey = 'daily_challenge_score_';
  static const String _xpAwardedKey = 'daily_challenge_xp_awarded_';
  static const String _lastPickKey = 'daily_challenge_last_pick_';
  static const int _questionsPerDay = 5;

  // Pool of at least 30 questions
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
      [
        'Copies array elements',
        'Deletes elements',
        'Sorts the array',
        'Reverses the array',
      ],
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
      [
        'Creates a grid',
        'Makes element a flex container',
        'Hides element',
        'Centers content',
      ],
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
      [
        'Centers items on cross axis',
        'Centers items on main axis',
        'Centers text',
        'Centers container',
      ],
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
      [
        'A loop',
        'A function with access to outer scope',
        'A variable',
        'An error',
      ],
      1,
      'A closure is a function that retains access to variables from its enclosing scope.',
    ),
    ChallengeQuestion(
      'What does SQL stand for?',
      [
        'Structured Query Language',
        'Simple Query Language',
        'Standard Query Logic',
        'System Query Language',
      ],
      0,
      'SQL stands for Structured Query Language.',
    ),

    // Additional questions to reach 30+
    ChallengeQuestion(
      'What does HTML stand for?',
      [
        'HyperText Markup Language',
        'HighText Machine Language',
        'HyperTool Markup Language',
        'HyperText Machine Language',
      ],
      0,
      'HTML stands for HyperText Markup Language.',
    ),
    ChallengeQuestion(
      'Which CSS property changes text color?',
      ['text-color', 'font-color', 'color', 'text-style'],
      2,
      'The color property sets the text color.',
    ),
    ChallengeQuestion(
      'What is the purpose of the alt attribute in HTML img tags?',
      [
        'Alternative text for accessibility',
        'Image alignment',
        'Image size',
        'Image format',
      ],
      0,
      'The alt attribute provides alternative text for screen readers and when images fail to load.',
    ),
    ChallengeQuestion(
      'Which HTTP method is used to create a resource?',
      ['GET', 'POST', 'PUT', 'DELETE'],
      1,
      'POST is used to create new resources on the server.',
    ),
    ChallengeQuestion(
      'What does API stand for?',
      [
        'Application Programming Interface',
        'Automated Program Integration',
        'Advanced Programming Interface',
        'Application Process Integration',
      ],
      0,
      'API stands for Application Programming Interface.',
    ),
    ChallengeQuestion(
      'What is the correct way to declare a constant in Dart?',
      ['var x = 10', 'final x = 10', 'const x = 10', 'static x = 10'],
      2,
      'const declares a compile-time constant in Dart.',
    ),
    ChallengeQuestion(
      'What is the time complexity of accessing an element in a hash map?',
      ['O(1)', 'O(log n)', 'O(n)', 'O(n²)'],
      0,
      'Hash maps provide average O(1) lookup by computing hash(key) to find the bucket directly.',
    ),
    ChallengeQuestion(
      'Which keyword is used to handle exceptions in Dart?',
      ['catch', 'try', 'throw', 'except'],
      0,
      'catch is used to catch exceptions thrown in a try block.',
    ),
    ChallengeQuestion(
      'What does the "async" keyword do in Dart?',
      [
        'Makes function synchronous',
        'Marks function as returning a Future',
        'Creates a new thread',
        'Pauses execution',
      ],
      1,
      'async marks a function as asynchronous and automatically wraps the return value in a Future.',
    ),
    ChallengeQuestion(
      'Which data structure is best for implementing a cache with LRU eviction?',
      ['Array', 'Linked List', 'Hash Map + Doubly Linked List', 'Binary Tree'],
      2,
      'Hash map for O(1) lookup + doubly linked list for O(1) move-to-front and eviction.',
    ),
  ];

  /// FNV-1a 32-bit hash for deterministic selection
  static int _fnv1aHash(String input) {
    int hash = 0x811c9dc5;
    for (int i = 0; i < input.length; i++) {
      hash ^= input.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  /// Gets the daily challenge questions for a specific date
  /// Uses FNV-1a hash of date key for deterministic, stable selection
  static List<ChallengeQuestion> getDailyQuestions(DateTime date) {
    final dateKey = _dateToString(date);

    // Check if we need to avoid repeating yesterday's pick
    final lastPickDate = _getLastPickDate();
    int startIndex = _fnv1aHash(dateKey) % _questionPool.length;

    // If this pick would be the same as yesterday's, advance by 1
    if (lastPickDate != null && _isConsecutiveDay(lastPickDate, date)) {
      final yesterdayKey = _dateToString(
        date.subtract(const Duration(days: 1)),
      );
      final yesterdayIndex = _fnv1aHash(yesterdayKey) % _questionPool.length;
      if (startIndex == yesterdayIndex) {
        startIndex = (startIndex + 1) % _questionPool.length;
      }
    }

    // Save this pick for next day's comparison
    _saveLastPickDate(date);

    // Select questions starting from startIndex
    final questions = <ChallengeQuestion>[];
    for (int i = 0; i < _questionsPerDay; i++) {
      final index = (startIndex + i) % _questionPool.length;
      questions.add(_questionPool[index]);
    }
    return questions;
  }

  /// Checks if two dates are consecutive days
  static bool _isConsecutiveDay(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return d1.difference(d2).inDays.abs() == 1;
  }

  /// Gets the last date a pick was made
  static DateTime? _getLastPickDate() {
    final str = StorageService.getString(_lastPickKey);
    if (str == null) return null;
    try {
      return DateTime.parse(str);
    } catch (_) {
      return null;
    }
  }

  /// Saves the last pick date
  static Future<void> _saveLastPickDate(DateTime date) async {
    await StorageService.setString(_lastPickKey, date.toIso8601String());
  }

  /// Checks if the daily challenge has been completed for a given date
  static bool isCompletedForDate(DateTime date) {
    final key = '$_completionKey${_dateToString(date)}';
    return StorageService.getBool(key, defaultValue: false);
  }

  /// Marks the daily challenge as completed for a given date
  static Future<void> markCompletedForDate(DateTime date, int score) async {
    final dateKey = _dateToString(date);
    final completionKey = '$_completionKey$dateKey';
    final scoreKey = '$_scoreKey$dateKey';
    final xpKey = '$_xpAwardedKey$dateKey';

    await StorageService.setBool(completionKey, true);
    await StorageService.setInt(scoreKey, score);
    await StorageService.setInt(xpKey, _calculateXp(score));
  }

  /// Calculates XP based on score (max 50 for 5/5)
  static int _calculateXp(int score) {
    return (score * 10).clamp(0, 50);
  }

  /// Gets the score for a completed daily challenge
  static int getScoreForDate(DateTime date) {
    final key = '$_scoreKey${_dateToString(date)}';
    return StorageService.getInt(key, defaultValue: 0);
  }

  /// Gets the XP awarded for a completed daily challenge
  static int getXpAwardedForDate(DateTime date) {
    final key = '$_xpAwardedKey${_dateToString(date)}';
    return StorageService.getInt(key, defaultValue: 0);
  }

  /// Checks if the date has rolled over since last check
  /// Returns true if a new day has started
  static bool hasDateRolledOver(DateTime lastCheck) {
    final now = DateTime.now();
    final lastLocal = DateTime(lastCheck.year, lastCheck.month, lastCheck.day);
    final nowLocal = DateTime(now.year, now.month, now.day);
    return nowLocal.isAfter(lastLocal);
  }

  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

class ChallengeQuestion {
  const ChallengeQuestion(
    this.text,
    this.options,
    this.answer,
    this.explanation,
  );
  final String text;
  final List<String> options;
  final int answer;
  final String explanation;
}
