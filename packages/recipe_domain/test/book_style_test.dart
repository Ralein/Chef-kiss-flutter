import 'dart:convert';

import 'package:recipe_domain/recipe_domain.dart';
import 'package:test/test.dart';

void main() {
  test('BookStyle round-trips and tolerates bad input', () {
    const style = BookStyle(
      spineColor: '#123456',
      textColor: '#E8D5A3',
      font: SpineFont.serifItalic,
      textSize: SpineScale.large,
      height: SpineScale.small,
      width: SpineScale.large,
      pattern: SpinePattern.ribs,
      display: BookDisplay.cover,
    );
    expect(BookStyle.fromJson(style.toJson()), style);
    expect(BookStyle.fromJson(null), const BookStyle());
    expect(BookStyle.fromJson({'spineColor': 'red', 'font': 'comic'}), const BookStyle());
    expect(const BookStyle().isDefault, isTrue);
    expect(style.copyWith(clearSpineColor: true).spineColor, isNull);
  });

  test('backups keep the visual side of a recipe', () {
    const sticker = ScrapbookSticker(
      id: 's', content: 'food-tomato', type: 'doodle', pageSide: 'left', x: 10, y: 20, rotation: 5, scale: 1.2);
    final recipe = Recipe(
      id: 'r',
      profileId: 'default',
      title: 'Soup',
      baseServings: Rational(2),
      createdAt: 1,
      updatedAt: 2,
      coverImage: 'assets/illustrations/sketchbook_ramen.jpg',
      chefTip: 'Salt the water.',
      theme: ScrapbookTheme.matchaSage,
      moodStamps: const ['Cozy'],
      stickers: const [sticker],
      bookStyle: const BookStyle(spineColor: '#204030', display: BookDisplay.cover),
      ingredients: [
        RecipeIngredient(id: 'i', recipeId: 'r', displayName: 'Leek', position: 1, icon: 'leaf', iconColor: '#4A6B53'),
      ],
    );
    final pkg = ChefBackupPackage(
      manifest: const BackupManifest(
        exportedAt: 0,
        profileId: 'default',
        recipeCount: 1,
        collectionCount: 0,
        sha256Checksum: '',
      ),
      profile: const UserProfile(id: 'default', createdAt: 0, updatedAt: 0),
      recipes: [recipe],
      collections: const [],
    );
    final restored = ChefBackupPackage.fromJsonString(jsonEncode(pkg.toJson())).recipes.single;
    expect(restored.coverImage, recipe.coverImage);
    expect(restored.chefTip, 'Salt the water.');
    expect(restored.theme, ScrapbookTheme.matchaSage);
    expect(restored.moodStamps, ['Cozy']);
    expect(restored.stickers.single.id, 's');
    expect(restored.bookStyle, recipe.bookStyle);
    expect(restored.ingredients.single.icon, 'leaf');
  });
}
