import 'package:uni/model/entities/exam.dart';

/// Determines if the exam is highlighted or not.
bool isHighlighted(Exam exam) {
  return (exam.examType.contains('''EN''')) ||
      (exam.examType.contains('''MT'''));
}