import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/data/models/course_models.dart';
import 'package:brainbox/data/models/learning_models.dart';

class PathCard extends StatelessWidget {
  const PathCard({
    required this.course,
    super.key,
  });

  final Course course;

  @override
  Widget build(BuildContext context) {
    final colors = _getCourseColors(course.category);
    
    return InkWell(
      onTap: () {
        // Navigate to course detail
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 170,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(course.category.icon, color: Colors.white, size: 24),
            ),
            const Spacer(),
            Text(
              course.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              course.shortDescription,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 12,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.menu_book_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
                Text(
                  '${course.lessonCount} lessons',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(Icons.schedule_rounded, size: 14, color: Colors.white.withValues(alpha: 0.8)),
                const SizedBox(width: 4),
                Text(
                  '${course.estimatedHours}h',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                course.difficulty.label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  List<Color> _getCourseColors(LearningCategory category) {
    switch (category) {
      case LearningCategory.webDevelopment:
        return [const Color(0xFF06B6D4), const Color(0xFF0891B2)];
      case LearningCategory.mobileDevelopment:
        return [const Color(0xFF8B5CF6), const Color(0xFF7C3AED)];
      case LearningCategory.programmingLanguages:
        return [const Color(0xFF10B981), const Color(0xFF059669)];
      case LearningCategory.machineLearning:
        return [const Color(0xFFF59E0B), const Color(0xFFD97706)];
      case LearningCategory.networking:
        return [const Color(0xFFEF4444), const Color(0xFFDC2626)];
      case LearningCategory.databases:
        return [const Color(0xFF84CC16), const Color(0xFF65A30D)];
      case LearningCategory.devops:
        return [const Color(0xFFF97316), const Color(0xFFEA580C)];
      case LearningCategory.projectManagement:
        return [const Color(0xFFEC4899), const Color(0xFFDB2777)];
    }
  }
}