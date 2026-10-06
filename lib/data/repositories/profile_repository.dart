import 'package:pecule/core/clock.dart';
import 'package:pecule/data/local/user_profile_dao.dart';
import 'package:pecule/domain/models/quiz_outcome.dart';
import 'package:pecule/domain/models/user_profile.dart';

class ProfileRepository {
  ProfileRepository({required this._profiles, required this._clock});

  final UserProfileDao _profiles;
  final Clock _clock;

  /// Rien tant que le questionnaire n'a été ni fait ni passé : c'est le signe
  /// d'un premier lancement.
  Future<UserProfile?> getProfile() => _profiles.find();

  /// Enregistre le résultat du questionnaire, fait ou passé. Refaire le
  /// questionnaire garde la date de création du premier profil.
  Future<void> saveQuizOutcome(QuizOutcome outcome) async {
    final existing = await _profiles.find();
    await _profiles.save(
      UserProfile(
        level: outcome.level,
        mistakenLessonIds: outcome.mistakenLessonIds,
        onboardingDone: true,
        createdAt: existing?.createdAt ?? _clock.now(),
      ),
    );
  }
}
