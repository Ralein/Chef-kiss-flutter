import 'package:meta/meta.dart';

@immutable
class RecipeCollection {
  final String id;
  final String profileId;
  final String name;
  final String colorToken;
  final String? description;
  final int sortOrder;
  final int createdAt;
  final int updatedAt;
  final List<String> recipeIds;

  const RecipeCollection({
    required this.id,
    required this.profileId,
    required this.name,
    this.colorToken = 'accent.herb',
    this.description,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.recipeIds = const [],
  });

  RecipeCollection copyWith({
    String? id,
    String? profileId,
    String? name,
    String? colorToken,
    String? description,
    int? sortOrder,
    int? createdAt,
    int? updatedAt,
    List<String>? recipeIds,
  }) {
    return RecipeCollection(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      name: name ?? this.name,
      colorToken: colorToken ?? this.colorToken,
      description: description ?? this.description,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      recipeIds: recipeIds ?? this.recipeIds,
    );
  }
}
