# Chef's Kiss — Production Support & Incident Runbook

Standard Operating Procedures (SOP), troubleshooting workflows, and incident triage runbooks for **Chef's Kiss**.

---

## 1. Zero-Data-Loss Backup & Recovery Runbook

### Scenario A: User reports corrupt local database or failed app launch
1. **Diagnosis**:
   - Check if SQLite database file is locked or corrupted (`StorageFailure` on app startup).
2. **Immediate Recovery Steps**:
   - **Do NOT clear application data without verifying backup availability.**
   - If user has cloud sync enabled, all recipes are safely preserved in the cloud operation log and remote vault.
   - Instruct user to download their latest encrypted backup package (`.json` or cloud snapshot).
   - Use `BackupRepository.restoreBackupJson` with `DuplicatePolicy.replace` or `keepBoth`.
3. **Automated Verification**:
   - Run `dart test test/data/drift_backup_test.dart` to verify checksum validation.

---

## 2. Multi-Device Sync & Conflict Resolution Triage

### Scenario B: User reports conflicting edits between two devices
1. **Convergence Behavior**:
   - If device A edited recipe servings and device B edited ingredients, the **3-Way Convergence Engine** auto-merges both edits automatically.
   - If device A and device B edited the recipe title simultaneously, a `SyncConflict` record is generated.
2. **Resolution Procedure**:
   - Open **Settings & Data** → **Cloud Sync & Vault**.
   - Tap the active **Sync Conflict** banner.
   - Review side-by-side diff between "Your Device" and "Cloud Version".
   - Select **Keep Local**, **Use Cloud**, or **Smart Merge**.

---

## 3. GDPR Compliance & Account Deletion Procedure

### Scenario C: User requests complete remote data erasure (Right to be Forgotten)
1. **Execution**:
   - Open **Settings & Data** → **Cloud Sync & Vault** → Menu → **Delete Account & Purge Cloud (GDPR)**.
   - `InMemoryCloudSyncServer.purgeUserData` atomically deletes:
     - All user operation log records in `_userOperations`.
     - All encrypted remote backup snapshots in `_userVaults`.
     - All session tokens and credentials.
2. **Local Data**:
   - Local SQLite database on the device remains untouched unless the user explicitly chooses **Reset All Local Data**.

---

## 4. Cook Mode & Timer Audit Matrix

### Scenario D: Background timer behavior across platforms
1. **Architecture**:
   - All timers store **absolute UTC target epoch timestamps** (`endsAtEpochMs = now + duration`).
   - Timers do NOT rely on continuous background CPU ticking.
2. **On App Resume / Wake**:
   - The state machine recalculates `remainingSeconds = max(0, (endsAtEpochMs - now) ~/ 1000)`.
   - If `now >= endsAtEpochMs`, timer status transitions immediately to `expired` with visual and haptic alert.
