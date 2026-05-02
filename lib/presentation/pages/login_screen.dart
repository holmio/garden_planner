import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_spacing.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';

class LoginScreen extends StatelessWidget {
  final String? errorMessage;

  const LoginScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.primaryContainer,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.yard, size: 100, color: colors.primary),
              const SizedBox(height: AppSpacing.lg),
              Text('Garden Planner', style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xxl),
              if (errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.sm + AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colors.errorContainer,
                    border: Border.all(color: colors.error),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.onErrorContainer),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm + AppSpacing.xs,
                  ),
                  backgroundColor: colors.surface,
                  foregroundColor: colors.primary,
                  textStyle: theme.textTheme.titleMedium,
                ),
                onPressed: () {
                  context.read<AuthBloc>().add(SignInWithGoogleEvent());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
