import 'package:flutter/foundation.dart';

enum HealthGoal { loseWeight, buildMuscle, maintain, manageCondition }

enum DietType {
  none,
  vegetarian,
  vegan,
  keto,
  paleo,
  mediterranean,
  glutenFree,
  dairyFree,
  lowCarb,
  highProtein,
}

extension HealthGoalExt on HealthGoal {
  String get title {
    switch (this) {
      case HealthGoal.loseWeight:
        return 'Lose Weight';
      case HealthGoal.buildMuscle:
        return 'Build Muscle';
      case HealthGoal.maintain:
        return 'Stay Healthy';
      case HealthGoal.manageCondition:
        return 'Manage Condition';
    }
  }

  String get subtitle {
    switch (this) {
      case HealthGoal.loseWeight:
        return 'Burn fat & feel lighter';
      case HealthGoal.buildMuscle:
        return 'Gain strength & mass';
      case HealthGoal.maintain:
        return 'Keep my current weight';
      case HealthGoal.manageCondition:
        return 'Eat for my health needs';
    }
  }

  String get emoji {
    switch (this) {
      case HealthGoal.loseWeight:
        return '🔥';
      case HealthGoal.buildMuscle:
        return '💪';
      case HealthGoal.maintain:
        return '⚖️';
      case HealthGoal.manageCondition:
        return '❤️';
    }
  }
}

extension DietTypeExt on DietType {
  String get label {
    switch (this) {
      case DietType.none:
        return 'No Restriction';
      case DietType.vegetarian:
        return 'Vegetarian';
      case DietType.vegan:
        return 'Vegan';
      case DietType.keto:
        return 'Keto';
      case DietType.paleo:
        return 'Paleo';
      case DietType.mediterranean:
        return 'Mediterranean';
      case DietType.glutenFree:
        return 'Gluten-Free';
      case DietType.dairyFree:
        return 'Dairy-Free';
      case DietType.lowCarb:
        return 'Low Carb';
      case DietType.highProtein:
        return 'High Protein';
    }
  }

  String get emoji {
    switch (this) {
      case DietType.none:
        return '🍽️';
      case DietType.vegetarian:
        return '🥦';
      case DietType.vegan:
        return '🌱';
      case DietType.keto:
        return '🥑';
      case DietType.paleo:
        return '🦴';
      case DietType.mediterranean:
        return '🫒';
      case DietType.glutenFree:
        return '🌾';
      case DietType.dairyFree:
        return '🥛';
      case DietType.lowCarb:
        return '🥩';
      case DietType.highProtein:
        return '💪';
    }
  }
}

class OnboardingProvider extends ChangeNotifier {
  HealthGoal? _selectedGoal;
  final Set<DietType> _selectedDiets = {};

  HealthGoal? get selectedGoal => _selectedGoal;
  Set<DietType> get selectedDiets => Set.unmodifiable(_selectedDiets);

  void selectGoal(HealthGoal goal) {
    _selectedGoal = goal;
    notifyListeners();
  }

  void toggleDiet(DietType diet) {
    if (diet == DietType.none) {
      _selectedDiets.clear();
      _selectedDiets.add(DietType.none);
    } else {
      _selectedDiets.remove(DietType.none);
      if (_selectedDiets.contains(diet)) {
        _selectedDiets.remove(diet);
      } else {
        _selectedDiets.add(diet);
      }
    }
    notifyListeners();
  }

  bool isDietSelected(DietType diet) => _selectedDiets.contains(diet);

  bool get canProceedGoal => _selectedGoal != null;
  bool get canProceedDiet => _selectedDiets.isNotEmpty;
}
