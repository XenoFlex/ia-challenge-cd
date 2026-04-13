import 'package:flutter/material.dart';

enum Difficulty { beginner, intermediate, advanced }

enum QuizCategory {
  iaGenerative,
  iaAgentique,
  workflowIA,
  risquesEthique,
  usagesCD,
}

extension QuizCategoryExt on QuizCategory {
  String get label => switch (this) {
        QuizCategory.iaGenerative => 'IA Générative',
        QuizCategory.iaAgentique => 'IA Agentique',
        QuizCategory.workflowIA => 'Workflows IA',
        QuizCategory.risquesEthique => 'Risques & Éthique',
        QuizCategory.usagesCD => 'Usages CD',
      };

  String get description => switch (this) {
        QuizCategory.iaGenerative => 'Fondamentaux, modèles, tokens, LLM…',
        QuizCategory.iaAgentique => 'Agents autonomes, outils, MCP…',
        QuizCategory.workflowIA => 'RAG, prompting, orchestration…',
        QuizCategory.risquesEthique => 'Hallucinations, biais, RGPD, AI Act…',
        QuizCategory.usagesCD => 'Bonnes pratiques au conseil départemental',
      };

  String get emoji => switch (this) {
        QuizCategory.iaGenerative => '🤖',
        QuizCategory.iaAgentique => '🧩',
        QuizCategory.workflowIA => '⚙️',
        QuizCategory.risquesEthique => '⚠️',
        QuizCategory.usagesCD => '🏛️',
      };

  Color get color => switch (this) {
        QuizCategory.iaGenerative => const Color(0xFF1B3A6B),
        QuizCategory.iaAgentique => const Color(0xFF6B3A9E),
        QuizCategory.workflowIA => const Color(0xFF1A7A5E),
        QuizCategory.risquesEthique => const Color(0xFFC0392B),
        QuizCategory.usagesCD => const Color(0xFF2980B9),
      };
}

extension DifficultyExt on Difficulty {
  String get label => switch (this) {
        Difficulty.beginner => 'Débutant',
        Difficulty.intermediate => 'Intermédiaire',
        Difficulty.advanced => 'Avancé',
      };

  String get description => switch (this) {
        Difficulty.beginner => 'Découverte des concepts de base',
        Difficulty.intermediate => 'Approfondissement des notions',
        Difficulty.advanced => 'Maîtrise des concepts techniques',
      };

  String get emoji => switch (this) {
        Difficulty.beginner => '🌱',
        Difficulty.intermediate => '⭐',
        Difficulty.advanced => '🚀',
      };

  Color get color => switch (this) {
        Difficulty.beginner => const Color(0xFF27AE60),
        Difficulty.intermediate => const Color(0xFFF39C12),
        Difficulty.advanced => const Color(0xFFE74C3C),
      };
}

class SettingsProvider extends ChangeNotifier {
  static final SettingsProvider instance = SettingsProvider._();
  SettingsProvider._();

  Difficulty _difficulty = Difficulty.beginner;
  final Set<QuizCategory> _enabledCategories = {
    QuizCategory.iaGenerative,
    QuizCategory.risquesEthique,
    QuizCategory.usagesCD,
  };

  Difficulty get difficulty => _difficulty;
  Set<QuizCategory> get enabledCategories =>
      Set.unmodifiable(_enabledCategories);

  void setDifficulty(Difficulty d) {
    _difficulty = d;
    notifyListeners();
  }

  void toggleCategory(QuizCategory cat) {
    if (_enabledCategories.contains(cat)) {
      if (_enabledCategories.length > 1) _enabledCategories.remove(cat);
    } else {
      _enabledCategories.add(cat);
    }
    notifyListeners();
  }

  bool isCategoryEnabled(QuizCategory cat) =>
      _enabledCategories.contains(cat);

  /// Filter helper: beginner sees beginner only, intermediate sees
  /// beginner+intermediate, advanced sees all.
  bool matchesDifficulty(Difficulty itemDiff) => switch (_difficulty) {
        Difficulty.beginner => itemDiff == Difficulty.beginner,
        Difficulty.intermediate => itemDiff != Difficulty.advanced,
        Difficulty.advanced => true,
      };
}
