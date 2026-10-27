import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/errors/failure_messages.dart';
import '../../../../core/widgets/app_button/app_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(forgotPasswordNotifierProvider.notifier).submit(
          tel: _phoneController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ForgotPasswordState>(forgotPasswordNotifierProvider, (_, next) {
      next.whenOrNull(
        error: (code) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failureMessage(code, AppLocalizations.of(context))),
              backgroundColor: AppColors.error,
            ),
          );
        },
        success: () {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context).resetPasswordRequestSent)),
          );
        },
      );
    });

    final state = ref.watch(forgotPasswordNotifierProvider);
    final isLoading = state is ForgotPasswordLoading;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: Colors.transparent,
        title: Text(AppLocalizations.of(context).resetPasswordTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).resetPasswordHeadline,
                style: AppTypography.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              AppLocalizations.of(context).resetPasswordInstruction,
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).resetPasswordPhoneLabel,
                  hintText: AppLocalizations.of(context).resetPasswordPhoneHint,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return AppLocalizations.of(context).resetPasswordPhoneRequired;
                  }
                  final normalized = value.replaceAll(RegExp(r'\s+'), '');
                  if (!RegExp(r'^[0-9]{6,20}$').hasMatch(normalized)) {
                    return AppLocalizations.of(context).resetPasswordPhoneInvalid;
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: AppLocalizations.of(context).commonSend,
              onPressed: isLoading ? null : _submit,
              isLoading: isLoading,
            ),
            const SizedBox(height: AppSpacing.md),
            Center(
              child: TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: Text(AppLocalizations.of(context).resetPasswordBackToLogin),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
