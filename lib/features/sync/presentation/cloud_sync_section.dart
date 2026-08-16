import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_domain/recipe_domain.dart';
import 'package:app_contracts/app_contracts.dart';
import 'package:design_tokens/design_tokens.dart';
import '../../../app/providers.dart';
import 'sync_conflict_dialog.dart';

class CloudSyncSection extends ConsumerStatefulWidget {
  const CloudSyncSection({super.key});

  @override
  ConsumerState<CloudSyncSection> createState() => _CloudSyncSectionState();
}

class _CloudSyncSectionState extends ConsumerState<CloudSyncSection> {
  bool _isSyncingManual = false;

  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AuthModalDialog(),
    );
  }

  void _showCreateRemoteBackupDialog(BuildContext context) {
    final passController = TextEditingController();
    var isUploading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Encrypted Cloud Backup'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your recipes will be encrypted client-side using AES-256 before being sent to the remote vault. Only you have the key.',
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: ChefSpacing.space4),
                TextField(
                  controller: passController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Passphrase (Required to restore)',
                    border: const OutlineInputBorder(),
                    errorText: errorMessage,
                  ),
                ),
                if (isUploading) ...[
                  const SizedBox(height: ChefSpacing.space4),
                  const LinearProgressIndicator(),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isUploading
                    ? null
                    : () async {
                        final pass = passController.text;
                        if (pass.trim().isEmpty) {
                          setModalState(() => errorMessage = 'Passphrase cannot be empty');
                          return;
                        }
                        setModalState(() {
                          isUploading = true;
                          errorMessage = null;
                        });

                        final repo = ref.read(remoteBackupRepositoryProvider);
                        final res = await repo.createAndUploadBackup(passphrase: pass);

                        if (!ctx.mounted) return;

                        if (res.isSuccess) {
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Encrypted backup uploaded successfully!')),
                          );
                        } else {
                          setModalState(() {
                            isUploading = false;
                            errorMessage = res.error?.message ?? 'Upload failed';
                          });
                        }
                      },
                child: const Text('Encrypt & Upload'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showRemoteSnapshotsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _RemoteSnapshotsModalDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.chefColors;
    final textTheme = context.chefText;

    final sessionAsync = ref.watch(authSessionStreamProvider);
    final syncStateAsync = ref.watch(syncStateStreamProvider);
    final conflictsAsync = ref.watch(pendingConflictsStreamProvider);

    final session = sessionAsync.value ?? ref.watch(authRepositoryProvider).getCurrentSession();
    final syncState = syncStateAsync.value ?? const SyncEngineState();
    final conflicts = conflictsAsync.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: colors.surfacePaper,
        borderRadius: BorderRadius.circular(ChefRadius.card),
        border: Border.all(color: colors.surfaceRaised),
      ),
      padding: const EdgeInsets.all(ChefSpacing.space4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Account Status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(ChefSpacing.space2),
                decoration: BoxDecoration(
                  color: session.isAuthenticated ? colors.accentHerb.withValues(alpha: 0.15) : colors.surfaceRaised,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  session.isAuthenticated ? Icons.cloud_done : Icons.cloud_off_outlined,
                  color: session.isAuthenticated ? colors.accentHerb : colors.contentSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: ChefSpacing.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cloud Sync & Vault', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    Text(
                      session.isAuthenticated
                          ? 'Signed in as ${session.user?.email}'
                          : 'Sign in to synchronize across your devices',
                      style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary),
                    ),
                  ],
                ),
              ),
              if (!session.isAuthenticated)
                FilledButton.tonal(
                  onPressed: () => _showAuthDialog(context),
                  child: const Text('Sign In'),
                )
              else
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (val) async {
                    if (val == 'sign_out') {
                      await ref.read(authRepositoryProvider).signOut();
                    } else if (val == 'delete_account') {
                      _showDeleteAccountDialog(context);
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'sign_out', child: Text('Sign Out')),
                    const PopupMenuItem(value: 'delete_account', child: Text('Delete Account & Purge Cloud (GDPR)')),
                  ],
                ),
            ],
          ),

          if (session.isAuthenticated) ...[
            const Divider(height: ChefSpacing.space6),

            // Pending Conflicts Banner
            if (conflicts.isNotEmpty) ...[
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => SyncConflictDialog(conflict: conflicts.first),
                  );
                },
                borderRadius: BorderRadius.circular(ChefRadius.card),
                child: Container(
                  padding: const EdgeInsets.all(ChefSpacing.space3),
                  decoration: BoxDecoration(
                    color: colors.stateWarning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(ChefRadius.card),
                    border: Border.all(color: colors.stateWarning.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: colors.stateWarning),
                      const SizedBox(width: ChefSpacing.space3),
                      Expanded(
                        child: Text(
                          '${conflicts.length} sync conflict requires your review.',
                          style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Text('Resolve', style: TextStyle(color: colors.accentTomato, fontWeight: FontWeight.bold)),
                      const SizedBox(width: ChefSpacing.space1),
                      const Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: ChefSpacing.space4),
            ],

            // Sync Status & Trigger
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: syncState.isSyncing
                                  ? colors.accentTomato
                                  : syncState.hasConflicts
                                      ? colors.stateWarning
                                      : colors.accentHerb,
                            ),
                          ),
                          const SizedBox(width: ChefSpacing.space2),
                          Text(
                            syncState.isSyncing
                                ? 'Syncing with cloud...'
                                : syncState.hasConflicts
                                    ? 'Conflicts pending'
                                    : 'Up to date',
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (syncState.lastSyncAt != null)
                        Text(
                          'Last synchronized: ${DateTime.fromMillisecondsSinceEpoch(syncState.lastSyncAt!).toLocal().toString().substring(11, 16)}',
                          style: textTheme.bodySmall?.copyWith(color: colors.contentSecondary, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  icon: _isSyncingManual
                      ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.sync, size: 16),
                  label: const Text('Sync Now'),
                  onPressed: _isSyncingManual
                      ? null
                      : () async {
                          setState(() => _isSyncingManual = true);
                          final mediator = ref.read(syncMediatorProvider);
                          final res = await mediator.synchronize();
                          if (mounted) {
                            setState(() => _isSyncingManual = false);
                            if (context.mounted && res.isSuccess) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Sync complete!')),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
            const Divider(height: ChefSpacing.space6),

            // Encrypted Remote Vault Options
            Text('Zero-Knowledge Encrypted Vault', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: ChefSpacing.space2),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.enhanced_encryption_outlined, color: colors.accentTomato),
              title: const Text('Create Encrypted Cloud Backup'),
              subtitle: const Text('Protect recipe snapshots with your own secret passphrase.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showCreateRemoteBackupDialog(context),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.cloud_download_outlined, color: colors.accentHerb),
              title: const Text('Manage Cloud Snapshots'),
              subtitle: const Text('View and restore encrypted snapshots in your remote vault.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showRemoteSnapshotsDialog(context),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account & Purge Data?'),
        content: const Text(
          'This will permanently delete your cloud account, all remote operations, and all encrypted backups per GDPR compliance. Local data will remain untouched.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: context.chefColors.stateDanger),
            onPressed: () async {
              Navigator.of(ctx).pop();
              final res = await ref.read(authRepositoryProvider).deleteAccount();
              if (mounted && context.mounted && res.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account and remote data purged successfully.')),
                );
              }
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

class _AuthModalDialog extends ConsumerStatefulWidget {
  const _AuthModalDialog();

  @override
  ConsumerState<_AuthModalDialog> createState() => _AuthModalDialogState();
}

class _AuthModalDialogState extends ConsumerState<_AuthModalDialog> {
  bool _isRegister = false;
  final _emailCtrl = TextEditingController(text: 'chef@example.com');
  final _passCtrl = TextEditingController(text: 'Password123!');
  final _nameCtrl = TextEditingController(text: 'Chef');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isRegister ? 'Create Cloud Account' : 'Sign In to Chef\'s Kiss'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isRegister) ...[
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Display Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: ChefSpacing.space3),
            ],
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: ChefSpacing.space3),
            TextField(
              controller: _passCtrl,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: ChefSpacing.space3),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
            if (_isLoading) ...[
              const SizedBox(height: ChefSpacing.space4),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _isRegister = !_isRegister),
          child: Text(_isRegister ? 'Have an account? Sign in' : 'Create new account'),
        ),
        FilledButton(
          onPressed: _isLoading
              ? null
              : () async {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });

                  final authRepo = ref.read(authRepositoryProvider);
                  final res = _isRegister
                      ? await authRepo.signUp(
                          email: _emailCtrl.text,
                          password: _passCtrl.text,
                          displayName: _nameCtrl.text,
                        )
                      : await authRepo.signIn(
                          email: _emailCtrl.text,
                          password: _passCtrl.text,
                        );

                  if (!mounted) return;

                  if (res.isSuccess) {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                    // Automatically trigger sync on login
                    ref.read(syncMediatorProvider).synchronize();
                  } else {
                    setState(() {
                      _isLoading = false;
                      _errorMessage = res.error?.message ?? 'Authentication failed';
                    });
                  }
                },
          child: Text(_isRegister ? 'Register' : 'Sign In'),
        ),
      ],
    );
  }
}

class _RemoteSnapshotsModalDialog extends ConsumerStatefulWidget {
  const _RemoteSnapshotsModalDialog();

  @override
  ConsumerState<_RemoteSnapshotsModalDialog> createState() => _RemoteSnapshotsModalDialogState();
}

class _RemoteSnapshotsModalDialogState extends ConsumerState<_RemoteSnapshotsModalDialog> {
  List<RemoteBackupSnapshotMeta>? _snapshots;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSnapshots();
  }

  Future<void> _loadSnapshots() async {
    final repo = ref.read(remoteBackupRepositoryProvider);
    final res = await repo.listSnapshots();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.isSuccess) {
          _snapshots = res.orNull;
        } else {
          _errorMessage = res.error?.message;
        }
      });
    }
  }

  void _restoreSnapshot(String snapshotId) {
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Encrypted Snapshot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the passphrase used when this snapshot was created:'),
            const SizedBox(height: ChefSpacing.space3),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Passphrase', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              final repo = ref.read(remoteBackupRepositoryProvider);
              final res = await repo.restoreSnapshot(
                snapshotId: snapshotId,
                passphrase: passCtrl.text,
              );
              if (mounted) {
                if (res.isSuccess) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Restored ${res.orNull} recipes successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res.error?.message ?? 'Restore failed')),
                  );
                }
              }
            },
            child: const Text('Decrypt & Restore'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remote Encrypted Vault Snapshots'),
      content: SizedBox(
        width: 480,
        height: 320,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                : (_snapshots == null || _snapshots!.isEmpty)
                    ? const Center(child: Text('No remote snapshots found.'))
                    : ListView.builder(
                        itemCount: _snapshots!.length,
                        itemBuilder: (context, idx) {
                          final item = _snapshots![idx];
                          final dateStr = DateTime.fromMillisecondsSinceEpoch(item.createdAt).toLocal().toString().substring(0, 16);
                          return ListTile(
                            title: Text(item.snapshotId, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('$dateStr • ${item.itemCount} recipes • ${(item.sizeBytes / 1024).toStringAsFixed(1)} KB'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.restore),
                                  tooltip: 'Restore',
                                  onPressed: () => _restoreSnapshot(item.snapshotId),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  tooltip: 'Delete',
                                  onPressed: () async {
                                    final repo = ref.read(remoteBackupRepositoryProvider);
                                    await repo.deleteSnapshot(item.snapshotId);
                                    _loadSnapshots();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
      ],
    );
  }
}
