# AI features: setup & operations

Chef's Kiss uses **Claude (Anthropic)** for four features. Everything else in the app works fully offline.

| Feature | Where | Model call |
|---|---|---|
| Food scan (meal → calories, macros, allergens) | Scan tab → Meal | Vision + structured output |
| Ingredient scan (fridge/pantry → ingredients, ideas) | Scan tab → Ingredients | Vision + structured output |
| Recipe from a photo / web page / messy text | Add recipe → Scan a recipe, Import | Vision or text + structured output |
| Recipe generation | Add recipe → Create with AI | Text + structured output |
| Nutrition gap-filling for unknown ingredients | Recipe → Nutrition → "Estimate the rest with AI" | Text + structured output |

Recipe nutrition itself is computed **offline** from a USDA-derived reference table
(`packages/recipe_domain/lib/src/nutrition/food_catalog.dart`); AI only fills gaps when asked.

## Connection modes

The app picks the first available mode at startup (`lib/core/ai/ai_connection.dart`):

1. **Proxy (recommended for production).** Build with
   `--dart-define=CHEFS_KISS_AI_PROXY_URL=https://ai.example.com`. Requests go to your backend, which holds
   the Anthropic API key. Users never see or enter a key.
2. **Bring your own key.** If no proxy is configured, users can paste their own Anthropic API key in
   *Settings → AI & Scanning*. The key is verified with `GET /v1/models/{model}` (costs no tokens) before it is
   saved, and is stored in the OS keychain/keystore via `flutter_secure_storage`. In browsers the key lives in
   browser storage — the UI says so.
3. **Off.** AI features show a clear "Set up AI" card instead of failing or faking results.

### Build-time options

| `--dart-define` | Default | Purpose |
|---|---|---|
| `CHEFS_KISS_AI_PROXY_URL` | *(empty)* | Base URL of your proxy. Enables proxy mode. |
| `CHEFS_KISS_AI_PROXY_TOKEN` | *(empty)* | Sent as `Authorization: Bearer …` to the proxy. **Not a secret** — it ships in the app binary. Use it only to identify the build; do real auth per user. |
| `CHEFS_KISS_AI_MODEL` | `claude-opus-5-5` | Model id. |
| `CHEFS_KISS_ALLOW_USER_API_KEY` | `true` | Set `false` to hide the "bring your own key" option. |
| `APP_FLAVOR` | `production` in release, `dev` otherwise | `dev` / `staging` / `production`. Developer-preview features (in-memory cloud sync, illustration moderation) are never shown in production. |

Example production build:

```bash
flutter build ipa --release \
  --dart-define=APP_FLAVOR=production \
  --dart-define=CHEFS_KISS_AI_PROXY_URL=https://ai.example.com \
  --dart-define=CHEFS_KISS_ALLOW_USER_API_KEY=false
```

## Proxy contract

The client speaks the plain Claude Messages API, so a proxy is a thin pass-through. It must:

- Accept `POST /v1/messages` (JSON body, up to ~12 MB — photos are sent as base64) and
  `GET /v1/models/{model}` (connection check).
- Inject `x-api-key` server-side. Forward `anthropic-version` and `anthropic-beta` unchanged
  (the client uses `server-side-fallback-2026-07-01` for refusal fallbacks).
- Allow responses up to **150 s** (the client timeout); recipe generation with adaptive thinking can take a while.
- Authenticate users and rate-limit per user. Return `429` with `retry-after` when limiting; the client honors it.

Minimal reference (Cloudflare Worker) — add your own user authentication before shipping:

```js
export default {
  async fetch(req, env) {
    const { pathname } = new URL(req.url);
    const allowed = (req.method === 'POST' && pathname === '/v1/messages') ||
                    (req.method === 'GET' && pathname.startsWith('/v1/models/'));
    if (!allowed) return new Response('Not found', { status: 404 });
    // TODO: verify the signed-in user here and apply per-user rate limits.
    const headers = new Headers({
      'content-type': 'application/json',
      'x-api-key': env.ANTHROPIC_API_KEY,
      'anthropic-version': req.headers.get('anthropic-version') ?? '2026-10-21',
    });
    const beta = req.headers.get('anthropic-beta');
    if (beta) headers.set('anthropic-beta', beta);
    return fetch(`https://api.anthropic.com${pathname}`, {
      method: req.method,
      headers,
      body: req.method === 'POST' ? req.body : undefined,
    });
  },
};
```

## How requests are made

`lib/core/ai/claude_client.dart` is a small raw-HTTP client (Dart has no official Anthropic SDK). It follows
the SDKs' behavior:

- API version `2026-10-21`; no `temperature`/`top_p`/`top_k` (rejected on this version).
- Model `claude-opus-5-5` with adaptive thinking (the model default) and explicit `output_config.effort`
  (`medium` for scans and recipes, `low` for nutrition gap-filling).
- **Structured outputs** (`output_config.format` with a JSON schema) for every call — schemas live in
  `lib/core/ai/ai_prompts.dart`. All parsed values are re-validated client-side (clamped, defaulted).
- **Retries**: up to 2 on 408/409/429/5xx/network errors, honoring `x-should-retry`, `retry-after-ms` and
  `retry-after`; otherwise exponential backoff 0.5 s → 8 s with jitter. Server-requested waits longer than
  30 s fail fast with a friendly "rate limited" message instead of a frozen spinner.
- **Refusals** (`stop_reason: refusal`) and truncation (`max_tokens`) surface as typed failures, never as
  partial data. `fallbacks: "default"` lets Anthropic retry a declined request on its recommended fallback model.
- Images are sent before the text prompt; meals are downscaled to 1568 px, recipe pages to 2048 px so small
  print stays legible. HEIC and oversized originals are re-encoded on device.

Every request logs elapsed time, attempts and the `request-id` header (never prompts, photos or keys) through
`AppLogger`, which redacts recipe content.

## Privacy

Only what the user explicitly analyzes is sent: the photo, an optional note, pasted text, a web page's text, or
ingredient lines. Recipes, the food log and settings never leave the device. Make sure your privacy policy states
that this content is processed by Anthropic.

## Cost guidance

A meal photo at 1568 px is roughly ⌈1568/28⌉ × ⌈1176/28⌉ ≈ 2,350 image tokens plus prompt and output. At current
Claude Opus 5.5 list prices that is on the order of a few US cents per scan — confirm against your usage dashboard
and set per-user limits in the proxy accordingly.
