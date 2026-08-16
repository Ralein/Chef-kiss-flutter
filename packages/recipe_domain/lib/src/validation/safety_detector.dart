import 'package:meta/meta.dart';
import '../models/recipe.dart';

enum SafetyAlertType {
  allergen,
  temperatureWarning,
  handlingSafety,
  ambiguity,
}

enum SafetySeverity {
  info,
  warning,
  critical,
}

@immutable
class SafetyAlert {
  final SafetyAlertType type;
  final SafetySeverity severity;
  final String title;
  final String message;
  final String? ingredientId;
  final String? stepId;

  const SafetyAlert({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    this.ingredientId,
    this.stepId,
  });

  @override
  String toString() => 'SafetyAlert($type, severity: $severity, $title: $message)';
}

class SafetyDetector {
  const SafetyDetector();

  static const Map<String, List<String>> _allergenCatalog = {
    'Dairy': ['milk', 'butter', 'cheese', 'cream', 'yogurt', 'parmesan', 'mozzarella', 'cheddar', 'ghee', 'whey', 'ricotta'],
    'Gluten / Wheat': ['flour', 'wheat', 'bread', 'pasta', 'spaghetti', 'penne', 'barley', 'rye', 'couscous', 'soy sauce', 'breadcrumbs'],
    'Peanuts / Tree Nuts': ['peanut', 'peanut butter', 'almond', 'walnut', 'pecan', 'cashew', 'hazelnut', 'pine nut', 'pistachio', 'macadamia'],
    'Eggs': ['egg', 'eggs', 'egg white', 'egg yolk', 'mayonnaise'],
    'Fish & Shellfish': ['shrimp', 'salmon', 'tuna', 'cod', 'crab', 'lobster', 'clam', 'mussel', 'anchovy', 'fish sauce', 'tilapia', 'prawn'],
    'Soy': ['soy', 'tofu', 'edamame', 'miso', 'tempeh', 'soy milk', 'tamari'],
    'Sesame': ['sesame', 'tahini', 'sesame oil'],
  };

  /// Analyzes a recipe draft and returns all detected allergens, safety warnings, and ambiguities.
  List<SafetyAlert> analyzeRecipe(Recipe recipe) {
    final alerts = <SafetyAlert>[];

    // 1. Check Allergens across all ingredients
    final detectedAllergens = <String, List<String>>{};
    for (final ing in recipe.ingredients) {
      final name = ing.displayName.toLowerCase();
      for (final entry in _allergenCatalog.entries) {
        final allergenGroup = entry.key;
        final keywords = entry.value;
        for (final kw in keywords) {
          if (RegExp('\\b$kw\\b', caseSensitive: false).hasMatch(name)) {
            detectedAllergens.putIfAbsent(allergenGroup, () => []).add(ing.displayName);
            break;
          }
        }
      }
    }

    for (final entry in detectedAllergens.entries) {
      alerts.add(SafetyAlert(
        type: SafetyAlertType.allergen,
        severity: SafetySeverity.info,
        title: 'Contains ${entry.key}',
        message: 'Contains ingredients: ${entry.value.join(", ")}.',
      ));
    }

    // 2. Check Raw Poultry / Meat safe cooking temperatures in steps
    final hasPoultry = recipe.ingredients.any((i) =>
        i.displayName.toLowerCase().contains('chicken') ||
        i.displayName.toLowerCase().contains('turkey') ||
        i.displayName.toLowerCase().contains('duck'));

    final hasGroundMeat = recipe.ingredients.any((i) =>
        i.displayName.toLowerCase().contains('ground beef') ||
        i.displayName.toLowerCase().contains('ground pork') ||
        i.displayName.toLowerCase().contains('mince'));

    if (hasPoultry) {
      alerts.add(const SafetyAlert(
        type: SafetyAlertType.temperatureWarning,
        severity: SafetySeverity.warning,
        title: 'Poultry Safe Minimum Temperature',
        message: 'Ensure all poultry is cooked to an internal temperature of at least 74°C (165°F).',
      ));
    }

    if (hasGroundMeat) {
      alerts.add(const SafetyAlert(
        type: SafetyAlertType.temperatureWarning,
        severity: SafetySeverity.warning,
        title: 'Ground Meat Safe Internal Temperature',
        message: 'Ensure ground meats reach an internal temperature of at least 71°C (160°F).',
      ));
    }

    // 3. Check for Ambiguities (missing durations on cooking steps, missing ingredient quantities)
    for (final step in recipe.steps) {
      final act = step.actionKey?.toLowerCase() ?? '';
      final isCookingAction = act == 'bake' || act == 'roast' || act == 'boil' || act == 'fry' || act == 'simmer';
      if (isCookingAction && (step.durationSeconds == null || step.durationSeconds == 0)) {
        alerts.add(SafetyAlert(
          type: SafetyAlertType.ambiguity,
          severity: SafetySeverity.info,
          title: 'Unspecified Cooking Duration',
          message: 'Step ${step.position} ("$act") does not specify an exact duration.',
          stepId: step.id,
        ));
      }
    }

    return alerts;
  }
}
