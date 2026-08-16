import '../models/recipe.dart';

class ValidationError {
  final String fieldPath;
  final String message;
  final bool isBlocking;

  const ValidationError({
    required this.fieldPath,
    required this.message,
    this.isBlocking = true,
  });

  @override
  String toString() => '[$fieldPath] $message (blocking: $isBlocking)';
}

class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  bool get hasErrors => errors.any((e) => e.isBlocking);
  List<ValidationError> get blockingErrors => errors.where((e) => e.isBlocking).toList();
  List<ValidationError> get warnings => errors.where((e) => !e.isBlocking).toList();
}

class RecipeValidator {
  const RecipeValidator();

  ValidationResult validateForReady(Recipe recipe) {
    final errors = <ValidationError>[];

    // 1. Title validation
    if (recipe.title.trim().isEmpty) {
      errors.add(const ValidationError(
        fieldPath: 'title',
        message: 'Recipe title cannot be empty to mark ready to cook.',
      ));
    }

    // 2. Servings validation
    if (recipe.baseServings.isZero || recipe.baseServings.isNegative) {
      errors.add(const ValidationError(
        fieldPath: 'baseServings',
        message: 'Base servings must be greater than zero.',
      ));
    }

    // 3. Ingredients validation
    if (recipe.ingredients.isEmpty) {
      errors.add(const ValidationError(
        fieldPath: 'ingredients',
        message: 'Recipe must have at least one ingredient.',
      ));
    } else {
      for (var i = 0; i < recipe.ingredients.length; i++) {
        final ing = recipe.ingredients[i];
        if (ing.displayName.trim().isEmpty) {
          errors.add(ValidationError(
            fieldPath: 'ingredients[$i].displayName',
            message: 'Ingredient at position ${i + 1} must have a name.',
          ));
        }
      }
    }

    // 4. Steps validation
    if (recipe.steps.isEmpty) {
      errors.add(const ValidationError(
        fieldPath: 'steps',
        message: 'Recipe must have at least one step.',
      ));
    } else {
      for (var i = 0; i < recipe.steps.length; i++) {
        final step = recipe.steps[i];
        if (step.instructionShort.trim().isEmpty) {
          errors.add(ValidationError(
            fieldPath: 'steps[$i].instructionShort',
            message: 'Step ${i + 1} must have an instruction.',
          ));
        }
      }
    }

    return ValidationResult(
      isValid: errors.where((e) => e.isBlocking).isEmpty,
      errors: errors,
    );
  }

  ValidationResult validateDraft(Recipe recipe) {
    final errors = <ValidationError>[];
    if (recipe.title.trim().isEmpty) {
      errors.add(const ValidationError(
        fieldPath: 'title',
        message: 'Title is empty (allowed in drafts, but recommended).',
        isBlocking: false,
      ));
    }
    return ValidationResult(
      isValid: true,
      errors: errors,
    );
  }
}
