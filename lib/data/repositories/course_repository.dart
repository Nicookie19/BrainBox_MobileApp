import 'dart:convert';

import 'package:brainbox/data/services/storage_service.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/learning_models.dart';

class CourseRepository {
  static const String _coursesKey = 'available_courses';
  static const String _seedVersionKey = 'courses_seed_version';

  /// Bump when the bundled sample courses change so existing installs refresh.
  static const int _seedVersion = 2;

  // Initialize with sample data if no courses exist or the seed is outdated
  static Future<void> initializeSampleCourses() async {
    final existingCourses = await getAllCourses();
    final isCurrent = StorageService.getInt(_seedVersionKey) == _seedVersion;
    if (existingCourses.isEmpty || !isCurrent) {
      await saveCourses(_createSampleCourses());
      await StorageService.setInt(_seedVersionKey, _seedVersion);
    }
  }

  static Future<List<Course>> getAllCourses() async {
    final jsonString = StorageService.getString(_coursesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Course.fromJson(json)).toList();
    } catch (e) {
      // If corrupted, return empty list and let initialize fix it
      return [];
    }
  }

  static Future<void> saveCourses(List<Course> courses) async {
    final jsonList = courses.map((course) => course.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await StorageService.setString(_coursesKey, jsonString);
  }

  static Future<Course?> getCourseById(String courseId) async {
    final courses = await getAllCourses();
    for (final course in courses) {
      if (course.id == courseId) return course;
    }
    return null;
  }

  static List<Course> _createSampleCourses() {
    return [
      Course(
        id: 'frontend-foundations',
        title: 'Frontend Foundations',
        shortDescription: 'Learn HTML, CSS, and JavaScript basics',
        longDescription: 'Master the fundamentals of frontend development with hands-on projects and exercises.',
        category: LearningCategory.webDevelopment,
        difficulty: DifficultyLevel.beginner,
        thumbnailUrl: '',
        estimatedHours: 1,
        lessonCount: 4,
        quizCount: 4,
        projectCount: 0,
        prerequisites: [],
        learningOutcomes: [
          'Build responsive websites with HTML5 and CSS3',
          'Create interactive web applications with JavaScript',
          'Understand frontend development best practices'
        ],
        tags: ['html', 'css', 'javascript', 'frontend'],
        isFeatured: true,
        isNew: false,
        rating: 4.8,
        enrollmentCount: 1240,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Course(
        id: 'python-essentials',
        title: 'Python Essentials',
        shortDescription: 'Learn Python programming from scratch',
        longDescription: 'Comprehensive Python course covering basics to intermediate concepts with practical exercises.',
        category: LearningCategory.programmingLanguages,
        difficulty: DifficultyLevel.beginner,
        thumbnailUrl: '',
        estimatedHours: 1,
        lessonCount: 4,
        quizCount: 4,
        projectCount: 0,
        prerequisites: [],
        learningOutcomes: [
          'Write clean, efficient Python code',
          'Work with data structures and algorithms',
          'Build Python applications for various domains'
        ],
        tags: ['python', 'programming', 'backend'],
        isFeatured: true,
        isNew: true,
        rating: 4.9,
        enrollmentCount: 980,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        updatedAt: DateTime.now(),
      ),
      Course(
        id: 'data-structures',
        title: 'Data Structures',
        shortDescription: 'Master arrays, linked lists, stacks, queues, and hash maps',
        longDescription: 'Learn fundamental data structures with hands-on exercises. Understand when to use each structure and their time complexities.',
        category: LearningCategory.programmingLanguages,
        difficulty: DifficultyLevel.beginner,
        thumbnailUrl: '',
        estimatedHours: 1,
        lessonCount: 4,
        quizCount: 4,
        projectCount: 0,
        prerequisites: ['Programming basics'],
        learningOutcomes: [
          'Understand arrays, linked lists, stacks, queues, and hash maps',
          'Analyze time and space complexity of operations',
          'Choose the right data structure for any problem'
        ],
        tags: ['data-structures', 'algorithms', 'computer-science'],
        isFeatured: true,
        isNew: true,
        rating: 4.9,
        enrollmentCount: 850,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      Course(
        id: 'sql-basics',
        title: 'SQL Basics',
        shortDescription: 'Learn to query and manipulate data with SQL',
        longDescription: 'Master SQL fundamentals: SELECT, WHERE, JOINs, and aggregations. Query real datasets and build analytical skills.',
        category: LearningCategory.databases,
        difficulty: DifficultyLevel.beginner,
        thumbnailUrl: '',
        estimatedHours: 1,
        lessonCount: 4,
        quizCount: 4,
        projectCount: 0,
        prerequisites: [],
        learningOutcomes: [
          'Write SELECT queries with filtering and sorting',
          'Join multiple tables to answer complex questions',
          'Aggregate data with GROUP BY and window functions'
        ],
        tags: ['sql', 'databases', 'data-analysis'],
        isFeatured: true,
        isNew: true,
        rating: 4.8,
        enrollmentCount: 720,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        updatedAt: DateTime.now(),
      ),
      Course(
        id: 'flutter-from-zero',
        title: 'Flutter from Zero',
        shortDescription: 'Build beautiful mobile apps with Flutter',
        longDescription: 'Learn Flutter development from basics to building production-ready iOS and Android apps.',
        category: LearningCategory.mobileDevelopment,
        difficulty: DifficultyLevel.intermediate,
        thumbnailUrl: '',
        estimatedHours: 1,
        lessonCount: 4,
        quizCount: 4,
        projectCount: 0,
        prerequisites: ['Programming fundamentals'],
        learningOutcomes: [
          'Compose screens from widgets',
          'Lay out UIs with Row, Column and Container',
          'Manage state and navigate between screens'
        ],
        tags: ['flutter', 'mobile', 'dart', 'ios', 'android'],
        isFeatured: true,
        isNew: false,
        rating: 4.7,
        enrollmentCount: 750,
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
        updatedAt: DateTime.now(),
      ),
      Course(
        id: 'machine-learning-basics',
        title: 'Machine Learning Basics',
        shortDescription: 'Introduction to ML concepts and algorithms',
        longDescription: 'Learn the fundamentals of machine learning with practical Python implementations.',
        category: LearningCategory.machineLearning,
        difficulty: DifficultyLevel.intermediate,
        thumbnailUrl: '',
        estimatedHours: 1,
        lessonCount: 4,
        quizCount: 4,
        projectCount: 0,
        prerequisites: ['Python programming', 'Basic statistics'],
        learningOutcomes: [
          'Understand supervised and unsupervised learning',
          'Evaluate models and spot overfitting',
          'Follow the end-to-end machine learning workflow'
        ],
        tags: ['machine-learning', 'python', 'ai', 'data-science'],
        isFeatured: true,
        isNew: true,
        rating: 4.6,
        enrollmentCount: 620,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      Course(
        id: 'networking-fundamentals',
        title: 'Networking Fundamentals',
        shortDescription: 'Understand computer networks and protocols',
        longDescription: 'Learn how computer networks work from basics to advanced networking concepts.',
        category: LearningCategory.networking,
        difficulty: DifficultyLevel.beginner,
        thumbnailUrl: '',
        estimatedHours: 1,
        lessonCount: 4,
        quizCount: 4,
        projectCount: 0,
        prerequisites: [],
        learningOutcomes: [
          'Understand the OSI and TCP/IP models',
          'Read IP addresses and subnets',
          'Explain how TCP, UDP, DNS and DHCP work'
        ],
        tags: ['networking', 'tcp-ip', 'ccna', 'it-fundamentals'],
        isFeatured: false,
        isNew: false,
        rating: 4.4,
        enrollmentCount: 410,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
