import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:design_tokens/design_tokens.dart';
import 'package:uuid/uuid.dart';
import '../../../app/providers.dart';

class ImportSourceSheet extends ConsumerStatefulWidget {
  const ImportSourceSheet({super.key});

  @override
  ConsumerState<ImportSourceSheet> createState() => _ImportSourceSheetState();
}

class _ImportSourceSheetState extends ConsumerState<ImportSourceSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  void _loadSample(String sampleText) {
    setState(() {
      _textController.text = sampleText;
      _tabController.animateTo(0);
    });
  }

  static const String _samplePasta = '''# Creamy Lemon Ricotta Pasta
A quick 15-minute pasta with vibrant lemon zest, creamy whole milk ricotta, and fresh basil.
Servings: 4

Ingredients:
- 1 lb rigatoni or penne pasta
- 1 cup whole milk ricotta cheese
- 1/2 cup grated Parmigiano-Reggiano
- 2 lemons, zested and juiced
- 2 cloves garlic, minced
- 1/4 cup extra-virgin olive oil
- 1/2 cup fresh basil leaves, torn
- Salt and freshly cracked black pepper to taste

Instructions:
1. Bring a large pot of salted water to a boil and cook pasta for 10 minutes until al dente.
2. In a large bowl, whisk together ricotta, parmesan, lemon zest, lemon juice, minced garlic, and olive oil until smooth.
3. Reserve 1/2 cup pasta water, then drain pasta.
4. Toss hot pasta with ricotta sauce and reserved pasta water for 2 minutes until glossy.
5. Garnish with torn fresh basil and black pepper.''';

  static const String _sampleJsonLd = '''{
  "@context": "https://schema.org",
  "@type": "Recipe",
  "name": "Avocado & Poached Egg Tartine",
  "description": "Crisp toasted sourdough topped with mashed avocado, chili flakes, and a tender poached egg.",
  "recipeYield": "2 servings",
  "recipeIngredient": [
    "2 slices thick sourdough bread, toasted",
    "1 ripe avocado, mashed",
    "2 large eggs",
    "1 tbsp distilled white vinegar",
    "1/4 tsp red pepper flakes",
    "Flaky sea salt to taste"
  ],
  "recipeInstructions": [
    "Bring 3 inches of water to a gentle simmer in a skillet and add 1 tbsp white vinegar.",
    "Crack eggs into small cups and gently slide into simmering water for 3 minutes.",
    "Spread mashed avocado over warm toasted sourdough slices.",
    "Top with poached eggs, red pepper flakes, and flaky sea salt."
  ]
}''';

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(ChefSpacing.space4),
      decoration: BoxDecoration(
        color: colors.surfacePaper,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ChefRadius.card),
          topRight: Radius.circular(ChefRadius.card),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, color: colors.accentTomato, size: 24),
                  const SizedBox(width: ChefSpacing.space2),
                  Text('Smart Recipe Import', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: ChefSpacing.space2),

          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: colors.accentTomato,
            unselectedLabelColor: colors.contentSecondary,
            indicatorColor: colors.accentTomato,
            tabs: const [
              Tab(icon: Icon(Icons.paste_outlined, size: 18), text: 'Paste Text / JSON-LD'),
              Tab(icon: Icon(Icons.link_outlined, size: 18), text: 'Web URL'),
            ],
          ),
          const SizedBox(height: ChefSpacing.space3),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Paste text view
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        maxLines: null,
                        expands: true,
                        decoration: const InputDecoration(
                          hintText: 'Paste recipe ingredients & instructions or Schema.org JSON-LD here...',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: ChefSpacing.space2),
                    Text('Try a sample recipe:', style: textTheme.labelSmall),
                    const SizedBox(height: ChefSpacing.space1),
                    Wrap(
                      spacing: ChefSpacing.space2,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.ramen_dining, size: 14),
                          label: const Text('Lemon Ricotta Pasta'),
                          onPressed: () => _loadSample(_samplePasta),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.code, size: 14),
                          label: const Text('Schema.org JSON-LD'),
                          onPressed: () => _loadSample(_sampleJsonLd),
                        ),
                      ],
                    ),
                  ],
                ),

                // 2. URL view
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe Web Page URL',
                        hintText: 'https://example.com/recipes/grandmas-apple-pie',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.language),
                      ),
                    ),
                    const SizedBox(height: ChefSpacing.space4),
                    Container(
                      padding: const EdgeInsets.all(ChefSpacing.space4),
                      decoration: BoxDecoration(
                        color: colors.surfaceRaised,
                        borderRadius: BorderRadius.circular(ChefRadius.tile),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shield_outlined, color: colors.accentHerb, size: 22),
                          const SizedBox(width: ChefSpacing.space3),
                          Expanded(
                            child: Text(
                              'Local extraction strips tracking scripts and extracts only recipe facts privately.',
                              style: textTheme.bodyMedium?.copyWith(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: ChefSpacing.space3),

          // Submit CTA
          FilledButton.icon(
            icon: _isProcessing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.auto_awesome),
            label: Text(_isProcessing ? 'Analyzing Recipe...' : 'Extract Recipe Facts'),
            style: FilledButton.styleFrom(
              backgroundColor: colors.accentTomato,
              foregroundColor: colors.contentInverse,
              padding: const EdgeInsets.symmetric(vertical: ChefSpacing.space3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ChefRadius.pill)),
            ),
            onPressed: _isProcessing ? null : _handleExtract,
          ),
        ],
      ),
    );
  }

  void _handleExtract() async {
    final text = _tabController.index == 0 ? _textController.text.trim() : _urlController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste recipe text or enter a URL.')),
      );
      return;
    }

    setState(() => _isProcessing = true);

    final source = ImportSource(
      id: const Uuid().v4(),
      kind: _tabController.index == 0 ? ImportSourceKind.text : ImportSourceKind.url,
      rawText: text,
      sha256Checksum: text.hashCode.toString(),
      byteSize: text.length,
      createdAt: DateTime.now().toUtc().millisecondsSinceEpoch,
    );

    final res = await ref.read(importRepositoryProvider).createJob(
          profileId: 'default',
          source: source,
        );

    setState(() => _isProcessing = false);

    res.when(
      ok: (job) {
        Navigator.pop(context);
        context.push('/import/review/${job.id}');
      },
      err: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: ${failure.message}')),
        );
      },
    );
  }
}
