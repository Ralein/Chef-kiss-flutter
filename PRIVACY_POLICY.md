# Privacy Policy for Chef's Kiss

**Last Updated:** November 8, 2026

**Chef's Kiss** ("we", "our", or "the app"), developed by Ralein Nova, is an illustrated personal recipe journal and calm cooking companion. We believe your recipes, meal notes, and kitchen memories belong solely to you. This Privacy Policy explains how information is handled when you use the mobile application **Chef's Kiss** (`com.chefskiss.chefs_kiss`).

---

## 1. Summary of Core Principles
- **Local-First:** All your recipes, cookbooks, notes, and custom shelves are stored locally on your device in a private SQLite database.
- **No Ads or Tracking:** We do not include third-party advertising SDKs, tracking pixels, or cross-app analytics brokers.
- **Your Data Stays Yours:** We do not sell, rent, or monetize your personal data.

---

## 2. Information We Access and How It Is Used

### A. Local Storage & Device Files
- **What:** Recipes, ingredients, instructions, cooking logs, book styles, and photos you add to your cookbooks.
- **Purpose:** To display and organize your personal recipe library and cooking journals.
- **Storage:** Stored locally on your device using encrypted/private app sandboxed storage. We do not maintain a central user account or copy your recipes to any external marketing server.

### B. Camera and Photo Library
- **What:** Photos taken with your camera or chosen from your gallery.
- **Purpose:** Used strictly when you choose to:
  - Set a cover or spine image for a cookbook.
  - Attach a photo of a cooked meal to your cooking journal.
  - Scan printed recipes, handwritten notes, or dishes for text/ingredient extraction.
- **Permissions:** Requested only when you initiate camera or photo selection features.

### C. AI-Powered Recipe Extraction & Assistance
- **What:** Recipe text, dish images, or URLs you explicitly submit for AI extraction or nutritional estimates.
- **Purpose:** When you use AI features (such as scanning a recipe card, extracting a recipe from text/URL, or generating dish ideas), the necessary text or image is sent securely via encrypted HTTPS to our AI service provider (such as the Chef's Kiss AI Gateway / Anthropic Claude API) solely to process and return the recipe structure.
- **Usage:** This data is processed transiently to generate your recipe response and is **not** used to train public models or build advertising profiles.

### D. Audio & Speech Synthesis (TTS)
- **What:** Spoken recipe steps during Hands-Free Cooking Mode.
- **Purpose:** The app utilizes your device's built-in text-to-speech (TTS) engine to read cooking steps aloud. Audio is processed locally by your operating system's speech synthesizer.

---

## 3. Third-Party Services
The app connects to third-party endpoints only when required for core user-requested functionality:
- **AI Processing:** When using AI features, requests are sent via encrypted HTTPS to secure model endpoints.
- **External Recipe Import:** When you choose to import a recipe from a URL you provide, the app fetches the public webpage HTML to extract schema data.

We do not use any third-party advertising networks, profiling trackers, or data aggregators.

---

## 4. Data Retention and Deletion
- Because your recipes and journal entries are stored locally on your device, you have complete control over your data.
- **Deletion:** You can delete individual recipes, journals, or books at any time inside the app. Uninstalling the app removes all local database files and cached photos from your device.
- **Export & Backup:** You can export your full recipe collection using the built-in backup tools.

---

## 5. Children's Privacy
Chef's Kiss is not directed toward children under the age of 13. We do not knowingly collect personal identifiable information from children.

---

## 6. Security
We take reasonable technical precautions to protect your data. All network communication (such as AI extraction or recipe imports) occurs exclusively over industry-standard encrypted channels (HTTPS / TLS).

---

## 7. Changes to This Privacy Policy
We may update this Privacy Policy from time to time. Any changes will be reflected by updating the "Last Updated" date at the top of this document. Continued use of the app constitutes acceptance of any updates.

---

## 8. Contact Us
If you have any questions or concerns regarding this Privacy Policy or your data privacy, please contact:

- **Developer:** Ralein Nova
- **Email:** [raleinnova@gmail.com](mailto:raleinnova@gmail.com)
- **Project Repository:** [https://github.com/Ralein/Chef-kiss-flutter](https://github.com/Ralein/Chef-kiss-flutter)

