import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';
import '../../../app/app_shell.dart';
import '../../../app/audio_chime_service.dart';
import '../../../app/chef_toast_service.dart';
import '../../recipe_editor/presentation/sticker_tray_modal.dart';
import '../../recipe_editor/presentation/culinary_icon_picker_popover.dart';
import '../../recipe_editor/presentation/picture_upload_modal.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  bool _isLocalEditMode = false;
  late int _servings;
  final Set<String> _checkedIngredients = {};

  // Timers
  final Map<String, int> _activeTimers = {};
  final Set<String> _runningTimers = {};
  Timer? _timerTicker;

  // Real-time drag tracking for stickers
  final Map<String, Offset> _liveDragDeltas = {};

  // Mobile Page Controller for Swipeable Book Flip
  late PageController _pageController;
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _servings = 2;
    _startTimerTicker();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(lastViewedRecipeIdProvider.notifier).state = widget.recipeId;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timerTicker?.cancel();
    super.dispose();
  }

  void _startTimerTicker() {
    _timerTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_runningTimers.isEmpty) return;
      setState(() {
        for (final tId in _runningTimers.toList()) {
          if ((_activeTimers[tId] ?? 0) > 0) {
            _activeTimers[tId] = _activeTimers[tId]! - 1;
            if (_activeTimers[tId] == 0) {
              _runningTimers.remove(tId);
              audioChime.playTimerComplete();
              ChefToastService.show(
                context: context,
                title: 'Step Timer Finished!',
                description: 'Time to check your heat and kitchen timing.',
                type: ChefToastType.alarm,
                duration: const Duration(seconds: 6),
              );
            }
          }
        }
      });
    });
  }

  void _toggleTimer(String timerId, int durationSeconds) {
    audioChime.playTap();
    setState(() {
      if (!_activeTimers.containsKey(timerId)) {
        _activeTimers[timerId] = durationSeconds;
      }
      if (_runningTimers.contains(timerId)) {
        _runningTimers.remove(timerId);
      } else {
        _runningTimers.add(timerId);
        audioChime.playTimerStart();
      }
    });
  }

  void _resetTimer(String timerId, int durationSeconds) {
    audioChime.playTap();
    setState(() {
      _runningTimers.remove(timerId);
      _activeTimers[timerId] = durationSeconds;
    });
  }

  void _openStickerTray(Recipe recipe, String side) {
    audioChime.playTap();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StickerTrayModal(
        targetPageSide: side,
        onTargetPageSideChanged: (_) {},
        onAddSticker: (sticker) async {
          final placedSticker = sticker.copyWith(
            pageSide: side,
            x: 50.0,
            y: 50.0,
          );
          final updatedStickers = [...recipe.stickers, placedSticker];
          final updated = recipe.copyWith(stickers: updatedStickers);
          await ref.read(recipeRepositoryProvider).saveRecipe(updated);
          if (!mounted) return;
          ChefToastService.show(
            context: context,
            title: 'Sticker placed on page',
            description: 'Drag it anywhere on the page to customize',
            type: ChefToastType.success,
          );
        },
        onAddWashiTape: (tape) async {
          final placedTape = tape.copyWith(
            pageSide: side,
            x: 50.0,
            y: 20.0,
          );
          final updatedTapes = [...recipe.washiTapes, placedTape];
          final updated = recipe.copyWith(washiTapes: updatedTapes);
          await ref.read(recipeRepositoryProvider).saveRecipe(updated);
          if (!mounted) return;
          ChefToastService.show(
            context: context,
            title: 'Washi tape attached',
            type: ChefToastType.success,
          );
        },
      ),
    );
  }

  void _openPictureModal(Recipe recipe) {
    audioChime.playTap();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PictureUploadModal(
        initialImage: recipe.coverImage,
        initialCaption: recipe.polaroidCaption,
        initialRotation: recipe.polaroidRotation ?? -2.0,
        onSave: (image, caption, rotation) async {
          final updated = recipe.copyWith(
            coverImage: image,
            polaroidCaption: caption,
            polaroidRotation: rotation,
          );
          await ref.read(recipeRepositoryProvider).saveRecipe(updated);
          if (!mounted) return;
          ChefToastService.show(
            context: context,
            title: 'Polaroid updated',
            type: ChefToastType.success,
          );
        },
      ),
    );
  }

  void _adjustPolaroidTilt(Recipe recipe, double deltaDegrees) async {
    audioChime.playTap();
    final current = recipe.polaroidRotation ?? -2.0;
    final next = (current + deltaDegrees).clamp(-15.0, 15.0);
    final updated = recipe.copyWith(polaroidRotation: next);
    await ref.read(recipeRepositoryProvider).saveRecipe(updated);
  }

  void _openIconPickerForIngredient(Recipe recipe, int ingIndex) {
    audioChime.playTap();
    final ing = recipe.ingredients[ingIndex];
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CulinaryIconPickerModal(
        currentIcon: ing.icon,
        currentColor: ing.iconColor,
        onIconSelected: (iconKey, colorHex) async {
          final updatedList = [...recipe.ingredients];
          updatedList[ingIndex] = ing.copyWith(icon: iconKey, iconColor: colorHex);
          final updated = recipe.copyWith(ingredients: updatedList);
          await ref.read(recipeRepositoryProvider).saveRecipe(updated);
          if (!mounted) return;
          ChefToastService.show(
            context: context,
            title: 'Ingredient icon updated',
            type: ChefToastType.success,
          );
        },
      ),
    );
  }

  void _editRecipeTitle(Recipe recipe) async {
    audioChime.playTap();
    final titleController = TextEditingController(text: recipe.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Recipe Title',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1A18)),
        ),
        content: TextField(
          controller: titleController,
          autofocus: true,
          style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w800, fontSize: 14),
          cursorColor: const Color(0xFFC85A32),
          decoration: InputDecoration(
            hintText: 'Recipe title',
            hintStyle: const TextStyle(color: Color(0xFF8C827A)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0D2))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B625B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC85A32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(titleController.text.trim()),
            child: const Text('Save Title', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && mounted) {
      final updated = recipe.copyWith(title: newTitle);
      await ref.read(recipeRepositoryProvider).saveRecipe(updated);
      if (!mounted) return;
      ChefToastService.show(context: context, title: 'Title updated', type: ChefToastType.success);
    }
  }

  void _editChefTip(Recipe recipe) async {
    audioChime.playTap();
    final tipController = TextEditingController(text: recipe.chefTip ?? '');
    final newTip = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          "Edit Chef's Tip Note",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1A18)),
        ),
        content: TextField(
          controller: tipController,
          maxLines: 3,
          autofocus: true,
          style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
          cursorColor: const Color(0xFFC85A32),
          decoration: InputDecoration(
            hintText: 'Add a helpful chef tip or kitchen secret...',
            hintStyle: const TextStyle(color: Color(0xFF8C827A)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE8E0D2))),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B625B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC85A32),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(tipController.text.trim()),
            child: const Text('Save Tip', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (newTip != null && mounted) {
      final updated = recipe.copyWith(chefTip: newTip);
      await ref.read(recipeRepositoryProvider).saveRecipe(updated);
      if (!mounted) return;
      ChefToastService.show(context: context, title: 'Chef tip updated', type: ChefToastType.success);
    }
  }

  void _editIngredient(Recipe recipe, int index) async {
    audioChime.playTap();
    final ing = recipe.ingredients[index];
    final nameController = TextEditingController(text: ing.displayName);
    final qtyController = TextEditingController(text: ing.quantity?.toDouble().toString() ?? '1');
    final unitController = TextEditingController(text: ing.unitCode ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Ingredient', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1A18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
              cursorColor: const Color(0xFFC85A32),
              decoration: InputDecoration(
                labelText: 'Ingredient Name',
                labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                    cursorColor: const Color(0xFFC85A32),
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                    cursorColor: const Color(0xFFC85A32),
                    decoration: InputDecoration(
                      labelText: 'Unit (g, tbsp, ml)',
                      labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(false);
              _openIconPickerForIngredient(recipe, index);
            },
            child: const Text('Change Icon', style: TextStyle(color: Color(0xFFC85A32), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC85A32), foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final doubleQty = double.tryParse(qtyController.text) ?? 1.0;
      final updatedList = [...recipe.ingredients];
      updatedList[index] = ing.copyWith(
        displayName: nameController.text.trim(),
        quantity: Rational((doubleQty * 10).round(), 10),
        unitCode: unitController.text.trim(),
      );
      await ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(ingredients: updatedList));
      if (!mounted) return;
      ChefToastService.show(context: context, title: 'Ingredient saved', type: ChefToastType.success);
    }
  }

  void _addNewIngredient(Recipe recipe) async {
    audioChime.playTap();
    final nameController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final unitController = TextEditingController(text: 'tbsp');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add New Ingredient', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1A18))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              autofocus: true,
              style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
              cursorColor: const Color(0xFFC85A32),
              decoration: InputDecoration(
                labelText: 'Ingredient Name (e.g. Olive Oil)',
                labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                    cursorColor: const Color(0xFFC85A32),
                    decoration: InputDecoration(
                      labelText: 'Qty',
                      labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: unitController,
                    style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                    cursorColor: const Color(0xFFC85A32),
                    decoration: InputDecoration(
                      labelText: 'Unit',
                      labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B625B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC85A32), foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Add Item'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.trim().isNotEmpty && mounted) {
      final doubleQty = double.tryParse(qtyController.text) ?? 1.0;
      final newIng = RecipeIngredient(
        id: 'ing-${DateTime.now().millisecondsSinceEpoch}',
        recipeId: recipe.id,
        displayName: nameController.text.trim(),
        quantity: Rational((doubleQty * 10).round(), 10),
        unitCode: unitController.text.trim(),
        position: recipe.ingredients.length + 1,
        icon: 'utensils',
        iconColor: '#C85A32',
      );
      await ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(ingredients: [...recipe.ingredients, newIng]));
      if (!mounted) return;
      ChefToastService.show(context: context, title: 'Ingredient added', type: ChefToastType.success);
    }
  }

  void _editStep(Recipe recipe, int index) async {
    audioChime.playTap();
    final step = recipe.steps[index];
    final actionController = TextEditingController(text: step.actionKey ?? 'Cook');
    final shortController = TextEditingController(text: step.instructionShort);
    final detailController = TextEditingController(text: step.instructionDetail ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Step ${index + 1}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1A18))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: actionController,
                style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                cursorColor: const Color(0xFFC85A32),
                decoration: InputDecoration(
                  labelText: 'Action Tag (e.g. WHISK, SIMMER, BAKE)',
                  labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: shortController,
                style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                cursorColor: const Color(0xFFC85A32),
                decoration: InputDecoration(
                  labelText: 'Headline Instruction',
                  labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailController,
                maxLines: 3,
                style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w600, fontSize: 12),
                cursorColor: const Color(0xFFC85A32),
                decoration: InputDecoration(
                  labelText: 'Detail Instruction',
                  labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B625B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC85A32), foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Save Step'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final updatedList = [...recipe.steps];
      updatedList[index] = step.copyWith(
        actionKey: actionController.text.trim(),
        instructionShort: shortController.text.trim(),
        instructionDetail: detailController.text.trim(),
      );
      await ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(steps: updatedList));
      if (!mounted) return;
      ChefToastService.show(context: context, title: 'Step updated', type: ChefToastType.success);
    }
  }

  void _addNewStep(Recipe recipe) async {
    audioChime.playTap();
    final actionController = TextEditingController(text: 'SIMMER');
    final shortController = TextEditingController();
    final detailController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Step Method', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E1A18))),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: actionController,
                style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                cursorColor: const Color(0xFFC85A32),
                decoration: InputDecoration(
                  labelText: 'Action Tag (e.g. BAKE, FOLD, SEAR)',
                  labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: shortController,
                autofocus: true,
                style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w700, fontSize: 13),
                cursorColor: const Color(0xFFC85A32),
                decoration: InputDecoration(
                  labelText: 'Headline Instruction',
                  labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailController,
                maxLines: 2,
                style: const TextStyle(color: Color(0xFF1E1A18), fontWeight: FontWeight.w600, fontSize: 12),
                cursorColor: const Color(0xFFC85A32),
                decoration: InputDecoration(
                  labelText: 'Detail Instruction',
                  labelStyle: const TextStyle(color: Color(0xFF6B625B), fontSize: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B625B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC85A32), foregroundColor: Colors.white),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Add Step'),
          ),
        ],
      ),
    );

    if (result == true && shortController.text.trim().isNotEmpty && mounted) {
      final newStep = RecipeStep(
        id: 'st-${DateTime.now().millisecondsSinceEpoch}',
        recipeId: recipe.id,
        position: recipe.steps.length + 1,
        actionKey: actionController.text.trim(),
        instructionShort: shortController.text.trim(),
        instructionDetail: detailController.text.trim(),
      );
      await ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(steps: [...recipe.steps, newStep]));
      if (!mounted) return;
      ChefToastService.show(context: context, title: 'Step added', type: ChefToastType.success);
    }
  }

  void _deleteRecipe(Recipe recipe) async {
    audioChime.playTap();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFAF7F2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Recipe Note?',
          style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF1E1A18)),
        ),
        content: Text(
          'Are you sure you want to delete "${recipe.title}" from your cookbook keepsake?',
          style: const TextStyle(color: Color(0xFF4B3E38), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B625B), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC7382B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete Note', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(recipeRepositoryProvider).deleteRecipe(recipe.id);
      if (!mounted) return;
      ChefToastService.show(
        context: context,
        title: 'Recipe Deleted',
        type: ChefToastType.info,
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(singleRecipeProvider(widget.recipeId));
    final isGlobalEditMode = ref.watch(isStudioEditModeProvider);
    final isEditMode = _isLocalEditMode || isGlobalEditMode;

    return recipeAsync.when(
      data: (recipe) {
        if (recipe == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Recipe Not Found')),
            body: const Center(child: Text('This recipe note does not exist.')),
          );
        }

        final baseServings = recipe.baseServings.numerator > 0 ? recipe.baseServings.numerator : 2;
        final scaleFactor = _servings / baseServings;
        final allRecipes = ref.watch(recipesStreamProvider).asData?.value ?? [];
        final currentIdx = allRecipes.indexWhere((r) => r.id == recipe.id);
        final totalRecipes = allRecipes.length;

        return Scaffold(
          backgroundColor: const Color(0xFFF4EDE2),
          appBar: AppBar(
            backgroundColor: const Color(0xFFFAF7F2),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF1E1A18)),
              onPressed: () {
                audioChime.playTap();
                context.pop();
              },
            ),
            title: GestureDetector(
              onTap: isEditMode ? () => _editRecipeTitle(recipe) : null,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      recipe.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1E1A18),
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isEditMode) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.edit, size: 14, color: Color(0xFFC85A32)),
                  ],
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isEditMode ? Icons.done : Icons.edit_outlined,
                  color: isEditMode ? const Color(0xFF4A6B53) : const Color(0xFF1E1A18),
                ),
                tooltip: isEditMode ? 'Done Editing' : 'Edit Note',
                onPressed: () {
                  audioChime.playTap();
                  final next = !isEditMode;
                  setState(() => _isLocalEditMode = next);
                  ref.read(isStudioEditModeProvider.notifier).state = next;
                  ChefToastService.show(
                    context: context,
                    title: next ? 'Edit Mode Activated' : 'View Mode Activated',
                    description: next ? 'Tap any text/photo or drag stickers freely' : 'Clean reading view',
                    type: next ? ChefToastType.success : ChefToastType.info,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.play_circle_fill, size: 26),
                color: const Color(0xFFC85A32),
                tooltip: 'Start Cook Mode',
                onPressed: () {
                  audioChime.playTap();
                  context.push('/cook/${recipe.id}');
                },
              ),
              const SizedBox(width: 6),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              if (isWide) {
                // 💻 Desktop Dual-Page Open Book Spread
                return Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 1120),
                    margin: const EdgeInsets.all(ChefSpacing.space4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF7),
                      borderRadius: BorderRadius.circular(ChefRadius.card),
                      border: Border.all(color: const Color(0xFFE8E0D2), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isEditMode)
                          _buildEditBanner(context, recipe, _currentPageIndex == 0 ? 'left' : 'right'),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Page Spread
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(ChefSpacing.space5),
                                  child: _buildLeftPage(context, recipe, scaleFactor, isEditMode),
                                ),
                              ),

                              // Center Book Spine
                              Container(
                                width: 2,
                                color: const Color(0xFFE8E0D2),
                              ),

                              // Right Page Spread
                              Expanded(
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.all(ChefSpacing.space5),
                                  child: _buildRightPage(context, recipe, isEditMode),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 📱 Mobile Spread with Swipeable Book PageView & Flipper
              return Column(
                children: [
                  // Cookbook Recipe Flipper Bar (Prev / Next Recipe)
                  if (totalRecipes > 1 && currentIdx != -1)
                    Container(
                      color: const Color(0xFFEDE5D8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            style: TextButton.styleFrom(
                              foregroundColor: currentIdx > 0 ? const Color(0xFFC85A32) : const Color(0xFF8C827A).withValues(alpha: 0.4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            icon: const Icon(Icons.arrow_back_ios, size: 12),
                            label: const Text('Prev Recipe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            onPressed: currentIdx > 0
                                ? () {
                                    audioChime.playPageFlip();
                                    final prev = allRecipes[currentIdx - 1];
                                    context.pushReplacement('/recipe/${prev.id}');
                                  }
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCFAF7),
                              borderRadius: BorderRadius.circular(ChefRadius.pill),
                              border: Border.all(color: const Color(0xFFE8E0D2)),
                            ),
                            child: Text(
                              'Recipe ${currentIdx + 1} of $totalRecipes',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF2C2623)),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: currentIdx < totalRecipes - 1 ? const Color(0xFFC85A32) : const Color(0xFF8C827A).withValues(alpha: 0.4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            ),
                            onPressed: currentIdx < totalRecipes - 1
                                ? () {
                                    audioChime.playPageFlip();
                                    final next = allRecipes[currentIdx + 1];
                                    context.pushReplacement('/recipe/${next.id}');
                                  }
                                : null,
                            child: const Row(
                              children: [
                                Text('Next Recipe', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Page Tab Selector
                  Container(
                    color: const Color(0xFFFAF7F2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            backgroundColor: const Color(0xFFFCFAF7),
                            selectedColor: const Color(0xFFC85A32),
                            side: BorderSide(
                              color: _currentPageIndex == 0 ? const Color(0xFFC85A32) : const Color(0xFFE8E0D2),
                              width: 1.5,
                            ),
                            label: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 14,
                                    color: _currentPageIndex == 0 ? Colors.white : const Color(0xFF4A3E39),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '1. Mise en Place',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: _currentPageIndex == 0 ? Colors.white : const Color(0xFF4A3E39),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            selected: _currentPageIndex == 0,
                            onSelected: (_) {
                              audioChime.playPageFlip();
                              _pageController.animateToPage(0, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            backgroundColor: const Color(0xFFFCFAF7),
                            selectedColor: const Color(0xFFC85A32),
                            side: BorderSide(
                              color: _currentPageIndex == 1 ? const Color(0xFFC85A32) : const Color(0xFFE8E0D2),
                              width: 1.5,
                            ),
                            label: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.format_list_numbered,
                                    size: 14,
                                    color: _currentPageIndex == 1 ? Colors.white : const Color(0xFF4A3E39),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '2. Method Steps',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                      color: _currentPageIndex == 1 ? Colors.white : const Color(0xFF4A3E39),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            selected: _currentPageIndex == 1,
                            onSelected: (_) {
                              audioChime.playPageFlip();
                              _pageController.animateToPage(1, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Edit Mode Top Action Banner
                  if (isEditMode)
                    _buildEditBanner(context, recipe, _currentPageIndex == 0 ? 'left' : 'right'),

                  // Swipeable Book PageView
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (idx) {
                        audioChime.playPageFlip();
                        setState(() => _currentPageIndex = idx);
                      },
                      children: [
                        // Left Page: Mise en Place
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCFAF7),
                            borderRadius: BorderRadius.circular(ChefRadius.card),
                            border: Border.all(color: const Color(0xFFE8E0D2), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              left: ChefSpacing.space4,
                              right: ChefSpacing.space4,
                              top: ChefSpacing.space4,
                              bottom: 96 + MediaQuery.of(context).padding.bottom,
                            ),
                            child: _buildLeftPage(context, recipe, scaleFactor, isEditMode),
                          ),
                        ),

                        // Right Page: Method Steps
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFCFAF7),
                            borderRadius: BorderRadius.circular(ChefRadius.card),
                            border: Border.all(color: const Color(0xFFE8E0D2), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.only(
                              left: ChefSpacing.space4,
                              right: ChefSpacing.space4,
                              top: ChefSpacing.space4,
                              bottom: 96 + MediaQuery.of(context).padding.bottom,
                            ),
                            child: _buildRightPage(context, recipe, isEditMode),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Swipe Indicator Dots
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: _currentPageIndex == 0 ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPageIndex == 0 ? const Color(0xFFC85A32) : const Color(0xFFD3C9BE),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: _currentPageIndex == 1 ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _currentPageIndex == 1 ? const Color(0xFFC85A32) : const Color(0xFFD3C9BE),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, _) => Scaffold(body: Center(child: Text('Error loading recipe: $err'))),
    );
  }

  Widget _buildEditBanner(BuildContext context, Recipe recipe, String targetSide) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF0EB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF3D9CE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit, size: 16, color: Color(0xFFC85A32)),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Edit Mode Active • Tap items or drag stickers',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFC85A32)),
            ),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC85A32),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.add, size: 14),
            label: const Text('Add Sticker', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () => _openStickerTray(recipe, targetSide),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFC7382B)),
            tooltip: 'Delete Note',
            onPressed: () => _deleteRecipe(recipe),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftPage(BuildContext context, Recipe recipe, double scaleFactor, bool isEditMode) {
    final rotationAngle = (recipe.polaroidRotation ?? -2.0) * (3.14159 / 180);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Polaroid Image Frame with Live Tilt & Quick Controls
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: isEditMode ? () => _openPictureModal(recipe) : null,
                child: Transform.rotate(
                  angle: rotationAngle,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 240,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFCFAF7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFE8E0D2), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: AspectRatio(
                                aspectRatio: 4 / 3,
                                child: recipe.coverImage != null && recipe.coverImage!.startsWith('http')
                                    ? Image.network(
                                        recipe.coverImage!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xFFF3ECE1),
                                          child: const Icon(Icons.broken_image, size: 36, color: Color(0xFFC85A32)),
                                        ),
                                      )
                                    : Image.asset(
                                        recipe.coverImage ?? 'assets/illustrations/sketchbook_pasta.jpg',
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xFFF3ECE1),
                                          child: const Icon(Icons.restaurant_menu, size: 36, color: Color(0xFFC85A32)),
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              recipe.polaroidCaption ?? recipe.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E1A18),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Top Washi Tape Corner
                      const Positioned(
                        top: -6,
                        left: 20,
                        child: WashiTape(
                          width: 54,
                          height: 14,
                          rotation: -0.06,
                          pattern: WashiTapePattern.terracotta,
                        ),
                      ),

                      // Edit Camera Badge (Only in Edit Mode)
                      if (isEditMode)
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFF1E1A18), shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 14),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Polaroid Quick Tilt Controls in Edit Mode
              if (isEditMode) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.rotate_left, size: 18, color: Color(0xFFC85A32)),
                      tooltip: 'Tilt Left',
                      onPressed: () => _adjustPolaroidTilt(recipe, -2.0),
                    ),
                    GestureDetector(
                      onTap: () => _openPictureModal(recipe),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDE5D8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Tilt: ${(recipe.polaroidRotation ?? -2.0).toStringAsFixed(1)}° • Tap to edit',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1E1A18)),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.rotate_right, size: 18, color: Color(0xFFC85A32)),
                      tooltip: 'Tilt Right',
                      onPressed: () => _adjustPolaroidTilt(recipe, 2.0),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: ChefSpacing.space4),

        // Mood Badges
        if (recipe.moodStamps.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: recipe.moodStamps.map((stamp) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF7F2),
                  borderRadius: BorderRadius.circular(ChefRadius.pill),
                  border: Border.all(color: const Color(0xFFE8E0D2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 12, color: Color(0xFFC85A32)),
                    const SizedBox(width: 4),
                    Text(
                      stamp,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF2C2623)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: ChefSpacing.space3),

        // Chef's Tip Sticky Note
        if (recipe.chefTip != null && recipe.chefTip!.isNotEmpty)
          GestureDetector(
            onTap: isEditMode ? () => _editChefTip(recipe) : null,
            child: Container(
              padding: const EdgeInsets.all(ChefSpacing.space3),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF8EB),
                borderRadius: BorderRadius.circular(ChefRadius.card),
                border: Border.all(color: const Color(0xFFF3D9CE)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFFD9822B)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recipe.chefTip!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF2C2623),
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (isEditMode) const Icon(Icons.edit, size: 14, color: Color(0xFFD9822B)),
                ],
              ),
            ),
          ),
        const SizedBox(height: ChefSpacing.space4),

        // Ingredients Header with Serving Stepper & Add Button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mise en Place',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E1A18)),
            ),
            Row(
              children: [
                if (isEditMode)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFC85A32), size: 20),
                    tooltip: 'Add Ingredient',
                    onPressed: () => _addNewIngredient(recipe),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE5D8),
                    borderRadius: BorderRadius.circular(ChefRadius.pill),
                    border: Border.all(color: const Color(0xFFDFD6C9)),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_servings > 1) {
                            audioChime.playTap();
                            setState(() => _servings--);
                          }
                        },
                        child: const Icon(Icons.remove, size: 16, color: Color(0xFF1E1A18)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          '$_servings serv',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E1A18)),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          audioChime.playTap();
                          setState(() => _servings++);
                        },
                        child: const Icon(Icons.add, size: 16, color: Color(0xFF1E1A18)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: ChefSpacing.space3),

        // Ingredient Checklist
        ...recipe.ingredients.asMap().entries.map((entry) {
          final idx = entry.key;
          final ing = entry.value;
          final isChecked = _checkedIngredients.contains(ing.id);

          double? scaledQty;
          if (ing.quantity != null) {
            scaledQty = (ing.quantity!.toDouble() * scaleFactor);
          }

          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: () {
                if (isEditMode) {
                  _editIngredient(recipe, idx);
                } else {
                  audioChime.playTap();
                  setState(() {
                    if (isChecked) {
                      _checkedIngredients.remove(ing.id);
                    } else {
                      _checkedIngredients.add(ing.id);
                    }
                  });
                }
              },
              borderRadius: BorderRadius.circular(ChefRadius.card),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isChecked ? const Color(0xFFEDE5D8).withValues(alpha: 0.5) : Colors.white,
                  borderRadius: BorderRadius.circular(ChefRadius.card),
                  border: Border.all(
                    color: isChecked ? const Color(0xFFDFD6C9) : const Color(0xFFE8E0D2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 18,
                      color: isChecked ? const Color(0xFF4A6B53) : const Color(0xFF8C827A),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: isEditMode ? () => _openIconPickerForIngredient(recipe, idx) : null,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBF0EB),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          getCulinaryIconData(ing.icon),
                          size: 16,
                          color: const Color(0xFFC85A32),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ing.displayName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked ? const Color(0xFF8C827A) : const Color(0xFF1E1A18),
                        ),
                      ),
                    ),
                    if (scaledQty != null)
                      Text(
                        '${scaledQty.toStringAsFixed(scaledQty.truncateToDouble() == scaledQty ? 0 : 1)} ${ing.unitCode ?? ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFC85A32),
                        ),
                      ),
                    if (isEditMode) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 14, color: Color(0xFFC85A32)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _editIngredient(recipe, idx),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () async {
                          final updated = recipe.ingredients.where((item) => item.id != ing.id).toList();
                          await ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(ingredients: updated));
                        },
                        child: const Icon(Icons.close, size: 16, color: Color(0xFFC7382B)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: ChefSpacing.space4),

        // Interactive Placed Stickers Section
        _buildPlacedStickers(context, recipe, 'left', isEditMode),

        // Add Sticker Action (Only in Edit Mode)
        if (isEditMode) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _openStickerTray(recipe, 'left'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC85A32).withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 16, color: Color(0xFFC85A32)),
                  SizedBox(width: 6),
                  Text(
                    '+ Add Sticker / Washi Tape to Mise en Place',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFC85A32)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRightPage(BuildContext context, Recipe recipe, bool isEditMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Step-by-Step Method',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF1E1A18)),
            ),
            if (isEditMode)
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFFC85A32), size: 20),
                tooltip: 'Add Step',
                onPressed: () => _addNewStep(recipe),
              ),
          ],
        ),
        const SizedBox(height: ChefSpacing.space3),

        ...recipe.steps.asMap().entries.map((entry) {
          final idx = entry.key;
          final step = entry.value;

          return Container(
            margin: const EdgeInsets.only(bottom: ChefSpacing.space3),
            padding: const EdgeInsets.all(ChefSpacing.space3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ChefRadius.card),
              border: Border.all(color: const Color(0xFFE8E0D2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(
                            color: Color(0xFFC85A32),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (step.actionKey != null && step.actionKey!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF4F0),
                              borderRadius: BorderRadius.circular(ChefRadius.pill),
                            ),
                            child: Text(
                              step.actionKey!.toUpperCase(),
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Color(0xFF4A6B53)),
                            ),
                          ),
                      ],
                    ),
                    if (isEditMode)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 16, color: Color(0xFFC85A32)),
                            onPressed: () => _editStep(recipe, idx),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 16, color: Color(0xFFC7382B)),
                            onPressed: () async {
                              final updated = recipe.steps.where((item) => item.id != step.id).toList();
                              await ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(steps: updated));
                            },
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: isEditMode ? () => _editStep(recipe, idx) : null,
                  child: Text(
                    step.instructionShort,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF1E1A18)),
                  ),
                ),
                if (step.instructionDetail != null && step.instructionDetail!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: isEditMode ? () => _editStep(recipe, idx) : null,
                    child: Text(
                      step.instructionDetail!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF382E28),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],

                // Step Timers
                if (step.timers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: step.timers.map((timer) {
                      final timeLeft = _activeTimers[timer.id] ?? timer.durationSeconds;
                      final isRunning = _runningTimers.contains(timer.id);

                      final mins = timeLeft ~/ 60;
                      final secs = timeLeft % 60;
                      final timeStr = '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isRunning ? const Color(0xFFFBEFF1) : const Color(0xFFFAF7F2),
                          borderRadius: BorderRadius.circular(ChefRadius.pill),
                          border: Border.all(color: isRunning ? const Color(0xFFC85A32) : const Color(0xFFE8E0D2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, size: 14, color: isRunning ? const Color(0xFFC85A32) : const Color(0xFF6B625B)),
                            const SizedBox(width: 4),
                            Text(timeStr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: isRunning ? const Color(0xFFC85A32) : const Color(0xFF1E1A18))),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () => _toggleTimer(timer.id, timer.durationSeconds),
                              child: Icon(isRunning ? Icons.pause : Icons.play_arrow, size: 14, color: const Color(0xFFC85A32)),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => _resetTimer(timer.id, timer.durationSeconds),
                              child: const Icon(Icons.refresh, size: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          );
        }),
        const SizedBox(height: ChefSpacing.space4),

        // Interactive Placed Stickers Section
        _buildPlacedStickers(context, recipe, 'right', isEditMode),

        // Add Sticker Action (Only in Edit Mode)
        if (isEditMode) ...[
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _openStickerTray(recipe, 'right'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7F2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC85A32).withValues(alpha: 0.5), width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.style_outlined, size: 16, color: Color(0xFFC85A32)),
                  SizedBox(width: 6),
                  Text(
                    '+ Add Sticker / Washi Tape to Method Steps',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFFC85A32)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlacedStickers(BuildContext context, Recipe recipe, String pageSide, bool isEditMode) {
    final pageStickers = recipe.stickers.where((s) => s.pageSide == pageSide).toList();
    final pageWashi = recipe.washiTapes.where((w) => w.pageSide == pageSide).toList();
    if (pageStickers.isEmpty && pageWashi.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFC85A32)),
              const SizedBox(width: 6),
              Text(
                isEditMode
                    ? 'Placed Stickers & Washi (${pageStickers.length + pageWashi.length}) • Drag anywhere'
                    : 'Artisanal Keepsake Stickers',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E1A18)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Washi Tapes
          if (pageWashi.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: pageWashi.map((w) {
                final pat = WashiTapePattern.values.firstWhere(
                  (p) => p.name == w.pattern,
                  orElse: () => WashiTapePattern.terracotta,
                );
                final liveDelta = _liveDragDeltas[w.id] ?? Offset.zero;

                return GestureDetector(
                  onPanUpdate: isEditMode
                      ? (details) {
                          setState(() {
                            _liveDragDeltas[w.id] = (_liveDragDeltas[w.id] ?? Offset.zero) + details.delta;
                          });
                        }
                      : null,
                  onPanEnd: isEditMode
                      ? (_) {
                          final currentDelta = _liveDragDeltas.remove(w.id) ?? Offset.zero;
                          final newX = (w.x + currentDelta.dx * 0.25).clamp(0.0, 100.0);
                          final updated = recipe.washiTapes.map((item) {
                            if (item.id == w.id) return item.copyWith(x: newX);
                            return item;
                          }).toList();
                          ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(washiTapes: updated));
                        }
                      : null,
                  onTap: isEditMode
                      ? () {
                          audioChime.playTap();
                          final updated = recipe.washiTapes.where((item) => item.id != w.id).toList();
                          ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(washiTapes: updated));
                          ChefToastService.show(context: context, title: 'Washi tape removed', type: ChefToastType.info);
                        }
                      : null,
                  child: Transform.translate(
                    offset: liveDelta,
                    child: Stack(
                      children: [
                        WashiTape(width: w.width, height: 16, pattern: pat),
                        if (isEditMode)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(color: Color(0xFFC7382B), shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 10, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

          // Stickers
          if (pageStickers.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: pageStickers.map((s) {
                final stampWidget = renderCulinaryStampById(
                  s.content.isNotEmpty ? s.content : (s.iconId ?? 'food-donut'),
                  size: 56 * s.scale,
                  rotation: s.rotation,
                );
                final liveDelta = _liveDragDeltas[s.id] ?? Offset.zero;

                return GestureDetector(
                  onPanUpdate: isEditMode
                      ? (details) {
                          setState(() {
                            _liveDragDeltas[s.id] = (_liveDragDeltas[s.id] ?? Offset.zero) + details.delta;
                          });
                        }
                      : null,
                  onPanEnd: isEditMode
                      ? (_) {
                          final currentDelta = _liveDragDeltas.remove(s.id) ?? Offset.zero;
                          final newX = (s.x + currentDelta.dx * 0.25).clamp(0.0, 100.0);
                          final newY = (s.y + currentDelta.dy * 0.25).clamp(0.0, 100.0);
                          final updated = recipe.stickers.map((item) {
                            if (item.id == s.id) return item.copyWith(x: newX, y: newY);
                            return item;
                          }).toList();
                          ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(stickers: updated));
                        }
                      : null,
                  onTap: isEditMode
                      ? () {
                          audioChime.playTap();
                          final updated = recipe.stickers.where((item) => item.id != s.id).toList();
                          ref.read(recipeRepositoryProvider).saveRecipe(recipe.copyWith(stickers: updated));
                          ChefToastService.show(context: context, title: 'Sticker removed', type: ChefToastType.info);
                        }
                      : null,
                  child: Transform.translate(
                    offset: liveDelta,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        stampWidget ?? const SizedBox.shrink(),
                        if (isEditMode)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(color: Color(0xFFC7382B), shape: BoxShape.circle),
                              child: const Icon(Icons.close, size: 10, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
