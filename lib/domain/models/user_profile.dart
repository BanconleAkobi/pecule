import 'package:pecule/domain/models/user_level.dart';

class UserProfile {
  const UserProfile({
    required this.level,
    required this.mistakenLessonIds,
    required this.onboardingDone,
    required this.createdAt,
  });

  final UserLevel level;

  /// Leçons liées aux questions ratées, pour choisir les leçons conseillées.
  final List<String> mistakenLessonIds;

  final bool onboardingDone;
  final DateTime createdAt;
}
