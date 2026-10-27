import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:agri_mada/l10n/app_localizations.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../app/theme/app_typography.dart';
import '../providers/sync_provider.dart';

String _syncErrorMessage(SyncErrorReason reason, AppLocalizations loc) =>
    switch (reason) {
      SyncErrorReason.reauthRequired => loc.errorSessionExpired,
      SyncErrorReason.serverUnreachable => loc.syncErrorServerUnreachable,
      SyncErrorReason.failed => loc.syncErrorFailed,
    };

class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);

    return switch (syncState) {
      SyncSyncing() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              AppLocalizations.of(context).syncInProgress,
              style: AppTypography.caption.copyWith(
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      SyncError(:final reason) => Tooltip(
          message: _syncErrorMessage(reason, AppLocalizations.of(context)),
          child: Semantics(
            label: _syncErrorMessage(reason, AppLocalizations.of(context)),
            child: const Icon(
              Icons.sync_problem,
              color: AppColors.severityHigh,
              size: 18,
            ),
          ),
        ),
      SyncSuccess() => const Icon(
          Icons.cloud_done_outlined,
          color: AppColors.primary,
          size: 18,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}
