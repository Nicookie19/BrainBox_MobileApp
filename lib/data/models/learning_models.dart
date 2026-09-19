import 'package:flutter/material.dart';

enum LearningCategory {
  webDevelopment(
    'Web Development',
    'globe',
    'Build websites and web applications',
  ),
  mobileDevelopment(
    'Mobile Development',
    'phone_android',
    'Create iOS and Android apps',
  ),
  programmingLanguages(
    'Programming Languages',
    'code',
    'Master popular programming languages',
  ),
  machineLearning(
    'Machine Learning',
    'psychology',
    'Learn AI and ML fundamentals',
  ),
  networking('Networking', 'router', 'Understand computer networks'),
  projectManagement(
    'Project Management',
    'assignment',
    'Manage software projects effectively',
  ),
  databases('Databases', 'storage', 'Design and manage databases'),
  devops('DevOps & Cloud', 'cloud', 'Deploy and scale applications');

  const LearningCategory(this.title, this.iconName, this.description);
  final String title;
  final String iconName;
  final String description;

  IconData get icon {
    switch (iconName) {
      case 'globe':
        return Icons.public_rounded;
      case 'phone_android':
        return Icons.phone_android_rounded;
      case 'code':
        return Icons.code_rounded;
      case 'psychology':
        return Icons.psychology_rounded;
      case 'router':
        return Icons.router_rounded;
      case 'assignment':
        return Icons.assignment_rounded;
      case 'storage':
        return Icons.storage_rounded;
      case 'cloud':
        return Icons.cloud_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color get color {
    switch (this) {
      case LearningCategory.webDevelopment:
        return const Color(0xFF3B82F6);
      case LearningCategory.mobileDevelopment:
        return const Color(0xFF10B981);
      case LearningCategory.programmingLanguages:
        return const Color(0xFF8B5CF6);
      case LearningCategory.machineLearning:
        return const Color(0xFFF59E0B);
      case LearningCategory.networking:
        return const Color(0xFFEF4444);
      case LearningCategory.projectManagement:
        return const Color(0xFF06B6D4);
      case LearningCategory.databases:
        return const Color(0xFF84CC16);
      case LearningCategory.devops:
        return const Color(0xFFF97316);
    }
  }
}

enum DifficultyLevel {
  beginner('Beginner', 1, Colors.green),
  intermediate('Intermediate', 2, Colors.orange),
  advanced('Advanced', 3, Colors.red);

  const DifficultyLevel(this.label, this.order, this.color);
  final String label;
  final int order;
  final Color color;
}

enum ContentType {
  lesson('Lesson', Icons.menu_book_rounded),
  quiz('Quiz', Icons.quiz_rounded),
  codingExercise('Coding Exercise', Icons.code_rounded),
  project('Project', Icons.folder_rounded);

  const ContentType(this.label, this.icon);
  final String label;
  final IconData icon;
}
