# Open-Source License & Asset Registry

**Chef's Kiss** — Created by **Ralein Nova**  
All third-party open-source software libraries, packages, fonts, and assets incorporated in **Chef's Kiss** are inventoried below in compliance with their respective open-source license terms and obligations.

---

## 1. Dependencies & Framework Components

| Package / Artifact | Version | License (SPDX) | Copyright Owner / Source | Notice Obligation |
|---|---|---|---|---|
| **Flutter SDK** | `>=3.11.5` | `BSD-3-Clause` | The Flutter Authors | Include license notice in release builds |
| **flutter_riverpod** | `^2.6.1` | `MIT` | Remi Rousselet | Include MIT license notice |
| **go_router** | `^14.8.0` | `BSD-3-Clause` | Flutter Community / Google LLC | Include BSD license notice |
| **drift** | `^2.24.2` | `MIT` | Simon Binder | Include MIT license notice |
| **sqlite3** | `^2.5.0` | `MIT` | Simon Binder | Include MIT license notice |
| **sqlite3_flutter_libs** | `^0.5.28` | `MIT` | Simon Binder | Include MIT license notice |
| **path_provider** | `^2.1.5` | `BSD-3-Clause` | Flutter Community | Include BSD license notice |
| **path** | `^1.9.0` | `BSD-3-Clause` | Dart Team / Google LLC | Include BSD license notice |
| **uuid** | `^4.5.1` | `MIT` | Yulian Kuncheff | Include MIT license notice |
| **intl** | `^0.20.2` | `BSD-3-Clause` | Dart Team / Google LLC | Include BSD license notice |
| **crypto** | `^3.0.6` | `BSD-3-Clause` | Dart Team / Google LLC | Include BSD license notice |
| **meta** | `^1.15.0` | `BSD-3-Clause` | Dart Team / Google LLC | Include BSD license notice |

---

## 2. Typography & Fonts

| Font Family | Style / Format | License (SPDX) | Source |
|---|---|---|---|
| **Fraunces** | Variable Serif (Display) | `OFL-1.1` (SIL Open Font License) | Undercase Type / Google Fonts |
| **Inter** | Variable Sans (Body) | `OFL-1.1` (SIL Open Font License) | Rasmus Andersson / Google Fonts |
| **JetBrains Mono** | Monospace (Timers/Rationals) | `OFL-1.1` (SIL Open Font License) | JetBrains / Google Fonts |

---

## 3. Curated Visual Illustrations & Asset Tokens

| Asset Name | Canonical Key | Category | License / Attribution |
|---|---|---|---|
| `assets/seed/starter_recipes.json` | `recipe.seed.v1` | Curated Starter Recipes | CC0 / Public Domain Recipes |
| `linocut_pasta.webp` | `culinary.pasta` | Linocut Illustration | Proprietary Editorial License |
| `linocut_bakery.webp` | `culinary.bakery` | Linocut Illustration | Proprietary Editorial License |
| `linocut_soup.webp` | `culinary.soup` | Linocut Illustration | Proprietary Editorial License |
| `linocut_salad.webp` | `culinary.salad` | Linocut Illustration | Proprietary Editorial License |
| `linocut_dessert.webp` | `culinary.dessert` | Linocut Illustration | Proprietary Editorial License |

---

## 4. Policy Compliance

1. **Copyleft Audit**: No GPL, AGPL, or restrictive copyleft dependencies are utilized in client binaries.
2. **Attribution Surface**: License texts are programmatically accessible to users via the standard `LicensePage` (`showLicensePage()`).
3. **Automated CI Enforcement**: License compliance is validated during the CI build gate.
