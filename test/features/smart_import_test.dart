import 'dart:convert';

import 'package:app_contracts/app_contracts.dart';
import 'package:chefs_kiss/core/ai/claude_client.dart';
import 'package:chefs_kiss/features/imports/services/ai_recipe_mapper.dart';
import 'package:chefs_kiss/features/imports/services/ai_recipe_service.dart';
import 'package:chefs_kiss/features/imports/services/json_ld_recipe_parser.dart';
import 'package:chefs_kiss/features/imports/services/smart_recipe_extractor.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:test/test.dart';

const _pageWithJsonLd = '''
<html><head>
<script type="application/ld+json">{"@context":"https://schema.org","@type":"Organization","name":"Site"}</script>
<script type="application/ld+json">
{"@context":"https://schema.org","@graph":[{"@type":"WebPage"},{"@type":["Recipe"],
 "name":"Mom&#39;s Tomato &amp; Basil Soup","description":"<p>Cozy &amp; quick.</p>",
 "recipeYield":["4 servings"],"totalTime":"PT1H5M","image":{"url":"https://example.com/soup.jpg"},
 "recipeCuisine":"Italian",
 "recipeIngredient":["2 tbsp olive oil","1 onion, chopped","800 g canned tomatoes"],
 "recipeInstructions":[{"@type":"HowToSection","name":"Soup","itemListElement":[
   {"@type":"HowToStep","text":"Sauté the onion in oil for 5 minutes."},
   {"@type":"HowToStep","text":"Add tomatoes and simmer 20 minutes."}]}]}]}
</script></head><body>ignored</body></html>''';

const _html = {'content-type': 'text/html; charset=utf-8'};

Map<String, dynamic> _aiRecipe({bool isRecipe = true}) => {
      'is_recipe': isRecipe,
      'title': 'Lemon Garlic Chicken',
      'summary': 'Bright weeknight dinner.',
      'servings': 3,
      'total_minutes': 0,
      'difficulty': 'easy',
      'cuisine': 'Mediterranean',
      'ingredients': [
        {'quantity': 0.333, 'unit': 'Cup', 'name': 'olive oil', 'note': '', 'optional': false},
        {'quantity': 0, 'unit': '', 'name': 'salt', 'note': 'to taste', 'optional': false},
        {'quantity': 4, 'unit': '', 'name': 'chicken thighs', 'note': 'boneless', 'optional': false},
        {'quantity': 2, 'unit': '', 'name': '', 'note': '', 'optional': false},
      ],
      'steps': [
        {'instruction': 'Sear the chicken.', 'detail': '', 'action': 'sear', 'timer_minutes': 8, 'temperature_c': 0},
        {'instruction': 'Roast.', 'detail': 'Until 74°C inside.', 'action': 'Roast', 'timer_minutes': 20, 'temperature_c': 200},
        {'instruction': '', 'detail': 'empty step', 'action': '', 'timer_minutes': 0, 'temperature_c': 0},
      ],
      'chef_tip': 'Rest 5 minutes before slicing.',
      'tags': ['dinner', 'high protein'],
      'warnings': ['Servings were not stated; assumed 3.'],
    };

ClaudeClient _fakeClaude(Map<String, dynamic> json) => ClaudeClient(
      ClaudeConfig(baseUri: ClaudeConfig.anthropicApi, apiKey: 'k'),
      httpClient: MockClient((_) async => http.Response(
            jsonEncode({
              'stop_reason': 'end_turn',
              'content': [
                {'type': 'text', 'text': jsonEncode(json)},
              ],
              'usage': {'input_tokens': 1, 'output_tokens': 1},
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          )),
      sleep: (_) async {},
    );

ImportSource _source(ImportSourceKind kind, {String? text, String? url}) => ImportSource(
      id: 's',
      kind: kind,
      rawText: text,
      sourceUrl: url,
      sha256Checksum: 'x',
      byteSize: 0,
      createdAt: 0,
    );

void main() {
  group('JsonLdRecipeParser', () {
    test('finds the Recipe among several ld+json blocks, sections, entities and durations', () {
      final r = JsonLdRecipeParser().parse(_pageWithJsonLd, profileId: 'p', sourceUrl: 'https://example.com/soup')!;
      expect(r.title, "Mom's Tomato & Basil Soup");
      expect(r.summary, 'Cozy & quick.');
      expect(r.baseServings, Rational(4));
      expect(r.totalMinutes, 65);
      expect(r.coverImage, 'https://example.com/soup.jpg');
      expect(r.ingredients, hasLength(3));
      expect(r.steps.map((s) => s.instructionShort).first, contains('Sauté the onion'));
      expect(r.steps, hasLength(2));
      expect(r.labels.single.kind, 'cuisine');
      expect(r.notes.single.body, contains('example.com/soup'));
    });

    test('returns null when a page has no Recipe', () {
      expect(JsonLdRecipeParser().parse('<html><body>Hello</body></html>', profileId: 'p'), isNull);
    });

    test('parses ISO-8601 durations defensively', () {
      expect(JsonLdRecipeParser.parseIsoDurationMinutes('PT45M'), 45);
      expect(JsonLdRecipeParser.parseIsoDurationMinutes('P1DT2H'), 1560);
      expect(JsonLdRecipeParser.parseIsoDurationMinutes('PT'), isNull);
      expect(JsonLdRecipeParser.parseIsoDurationMinutes('45 minutes'), isNull);
    });

    test('htmlToText keeps content and drops scripts and markup', () {
      final text = JsonLdRecipeParser.htmlToText('<style>x{}</style><h1>Pie</h1><ul><li>1 cup flour</li></ul>');
      expect(text, contains('Pie'));
      expect(text, contains('• 1 cup flour'));
      expect(text, isNot(contains('x{}')));
    });
  });

  group('AiRecipeMapper', () {
    test('maps and sanitizes an AI recipe payload', () {
      final draft = const AiRecipeMapper().map(_aiRecipe(), origin: Origin.aiProposed);
      final r = draft.recipe;

      expect(r.title, 'Lemon Garlic Chicken');
      expect(r.status, RecipeStatus.draft);
      expect(r.baseServings, Rational(3));
      expect(r.difficulty, RecipeDifficulty.easy);
      expect(r.ingredients, hasLength(3), reason: 'nameless ingredient dropped');
      expect(r.ingredients[0].quantity, Rational(1, 3), reason: '0.333 snaps to 1/3');
      expect(r.ingredients[0].unitCode, 'cup');
      expect(r.ingredients[1].quantity, isNull);
      expect(r.ingredients[1].scalingPolicy, ScalingPolicy.toTaste);
      expect(r.ingredients[2].prepText, 'boneless');
      expect(r.steps, hasLength(2), reason: 'empty step dropped');
      expect(r.steps[0].actionKey, 'Sear');
      expect(r.steps[0].timers.single.durationSeconds, 480);
      expect(r.steps[1].temperatureF, 392);
      expect(r.totalMinutes, 28, reason: 'falls back to the sum of step timers');
      expect(r.labels.map((l) => l.labelId), containsAll(['cuisine:mediterranean', 'tag:high-protein']));
      expect(r.ingredients.map((i) => i.id).toSet(), hasLength(3), reason: 'fresh unique ids');
      expect(draft.warnings.single, contains('assumed 3'));
    });
  });

  group('SmartRecipeExtractor', () {
    test('uses page JSON-LD for URLs without spending an AI call', () async {
      var aiCalls = 0;
      final extractor = SmartRecipeExtractor(
        ai: () {
          aiCalls++;
          return AiRecipeService(_fakeClaude(_aiRecipe()));
        },
        fetcher: WebPageFetcher(MockClient((_) async => http.Response(_pageWithJsonLd, 200, headers: _html))),
      );
      final res = await extractor.extractDetailed(
        source: _source(ImportSourceKind.url, url: 'https://example.com/soup'),
        profileId: 'p',
      );
      expect(res.isSuccess, isTrue, reason: res.error?.message);
      expect(res.orNull!.engine, 'json-ld');
      expect(res.orNull!.confidence, greaterThan(0.9));
      expect(aiCalls, 1, reason: 'resolved once, but no request sent');
    });

    test('falls back to AI for pages without structured data', () async {
      final extractor = SmartRecipeExtractor(
        ai: () => AiRecipeService(_fakeClaude(_aiRecipe())),
        fetcher: WebPageFetcher(MockClient((_) async => http.Response('<p>Grandma\'s chicken…</p>', 200, headers: _html))),
      );
      final res = await extractor.extractDetailed(
        source: _source(ImportSourceKind.url, url: 'https://blog.example.com/x'),
        profileId: 'p',
      );
      expect(res.isSuccess, isTrue, reason: res.error?.message);
      expect(res.orNull!.engine, 'ai');
      expect(res.orNull!.notes, contains(contains('assumed 3')));
    });

    test('explains how to proceed when a page needs AI that is not configured', () async {
      final extractor = SmartRecipeExtractor(
        ai: () => null,
        fetcher: WebPageFetcher(MockClient((_) async => http.Response('<p>no data</p>', 200, headers: _html))),
      );
      final res = await extractor.extractDetailed(
        source: _source(ImportSourceKind.url, url: 'https://blog.example.com/x'),
        profileId: 'p',
      );
      expect(res.error, isA<CapabilityUnavailableFailure>());
      expect(res.error!.recoveryAction, contains('Paste'));
    });

    test('pasted text works offline via the heuristic parser', () async {
      final extractor = SmartRecipeExtractor(ai: () => null);
      final res = await extractor.extractDetailed(
        source: _source(ImportSourceKind.text, text: 'Toast\n\nIngredients:\n- 2 slices bread\n\nInstructions:\n1. Toast it.'),
        profileId: 'p',
      );
      expect(res.orNull!.engine, 'heuristic');
      expect(res.orNull!.recipe.ingredients, hasLength(1));
    });

    test('prompt generation requires AI and reports non-recipes clearly', () async {
      final noAi = await SmartRecipeExtractor(ai: () => null)
          .extractDetailed(source: _source(ImportSourceKind.prompt, text: 'tacos'), profileId: 'p');
      expect(noAi.error, isA<CapabilityUnavailableFailure>());

      final notRecipe = await SmartRecipeExtractor(ai: () => AiRecipeService(_fakeClaude(_aiRecipe(isRecipe: false))))
          .extractDetailed(source: _source(ImportSourceKind.prompt, text: 'tell me a joke'), profileId: 'p');
      expect(notRecipe.error, isA<ValidationFailure>());

      final ok = await SmartRecipeExtractor(ai: () => AiRecipeService(_fakeClaude(_aiRecipe())))
          .extractDetailed(source: _source(ImportSourceKind.prompt, text: 'lemon chicken'), profileId: 'me');
      expect(ok.orNull!.recipe.profileId, 'me');
      expect(ok.orNull!.recipe.origin, Origin.aiProposed);
      expect(ok.orNull!.notes.first, contains('Generated by AI'));
    });
  });
}
