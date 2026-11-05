# Chef's Kiss — Support & Operations Runbook

How the app stores data, what can go wrong, and how to help a user recover.

---

## 1. Data & recovery

**Where data lives.** Everything is stored locally in SQLite (`chefs_kiss.sqlite` in the app documents
directory; IndexedDB/OPFS on the web). There is no server copy.

**Schema migrations.** The database is versioned (`AppDatabase.schemaVersion`). v2 added the food log
(`food_log_entries_table`). Upgrades run automatically on first launch after an update and are covered by
`test/data/food_log_repository_test.dart` ("migrates a v1 database to v2").

**Backups.** *Settings → Your data → Export backup* copies a JSON backup to the clipboard; *Restore from backup*
imports one with a duplicate policy (skip / replace / keep both). A restore is all-or-nothing: if any recipe fails
to save, nothing is restored and the user sees an error.

**Deleted recipes.** Deleting moves a recipe to *Recently deleted* (with Undo). From there it can be restored or
permanently removed. *Erase all data* deletes recipes, collections, cooking sessions and the food log, but keeps
preferences such as nutrition goals.

---

## 2. AI features

Setup and the proxy contract are in [AI_SETUP.md](AI_SETUP.md). Common user reports:

| Symptom | Likely cause | Resolution |
|---|---|---|
| "Set up AI to use …" card | No proxy configured and no user key | Add a key in *Settings → AI & Scanning*, or ship a proxy build |
| "The API key was not accepted" | Revoked/mistyped key (HTTP 401) | Replace the key |
| "This API key is not allowed…" | Key lacks access, or an org-level key needs a workspace (HTTP 403) | Use a workspace key, or fill *Advanced → Workspace ID* |
| "The AI model … is not available" | Model not enabled for the org (HTTP 404) | Enable it, or build with `CHEFS_KISS_AI_MODEL` |
| "rate limiting requests" | HTTP 429 with a long `retry-after` | Wait; raise limits in the Console or proxy |
| "temporarily unavailable" | 5xx / 529 overloaded after retries | Retry later; check status.anthropic.com |
| "declined to analyze" | Safety refusal (`stop_reason: refusal`) | Try another photo or text |
| "We couldn't find food in this photo" | The model reported `is_food: false` | Retake the photo |
| Key forgotten after restart (macOS) | Keychain unavailable for unsigned/sandboxed builds | Sign the app with a team and enable Keychain Sharing |

Logs include the Anthropic `request-id` for every failed call — include it when contacting Anthropic support.

---

## 3. Nutrition estimates

Recipe nutrition is computed offline from a USDA-derived reference table and kitchen conversions. The recipe
page states coverage ("estimated from 7 of 9 ingredients") and lists what was not counted. Users can fill gaps
with AI (stored per ingredient line; editing that line discards the stale estimate). Photo estimates can be off
by 20 % or more; the UI says so and never presents them as medical advice.

---

## 4. Cook Mode & timers

- Timers store an absolute end time, so they stay correct across navigation, dropped frames and backgrounding.
  They are shared app-wide: a timer started on the recipe page keeps running in Cook Mode and is shown in the
  navigation bar.
- Alerts are in-app (chime + toast). **Known limitations:** there are no OS notifications yet, so a timer that
  finishes while the app is in the background is announced when the user returns; and timers live in memory, so
  closing the app (not just backgrounding it) clears running timers.
- Cook Mode keeps the screen awake and records progress, so leaving and returning resumes at the same step.

---

## 5. Developer preview features

The *Cloud sync & vault* and *Illustration moderation* tools run against an **in-memory demo server** and are
only visible in `dev`/`staging` flavors (`AppEnvironment.flags`). Nothing synced there is persisted. They are
hidden in production builds; do not document them to end users.

---

## 6. Release checklist

1. `flutter analyze` and all test suites pass (CI runs them on every push).
2. `APP_FLAVOR=production` and the AI proxy `--dart-define`s are set.
3. Android: `android/key.properties` points at the upload keystore (release builds otherwise fall back to the
   debug key and must not be uploaded).
4. iOS: camera and photo-library usage strings are present in `Info.plist`.
5. macOS: network-client and user-selected-file entitlements are present; sign with a team for keychain access.
6. Web: run `tool/fetch_web_db_assets.sh` before `flutter build web` so `sqlite3.wasm` and `drift_worker.js` ship.
7. Privacy policy discloses that analyzed photos/text are processed by Anthropic.
