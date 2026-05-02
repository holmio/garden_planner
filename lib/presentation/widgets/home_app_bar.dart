import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/garden/garden_bloc.dart';
import '../bloc/garden/garden_event.dart';
import '../bloc/garden/garden_state.dart';
import '../pages/history_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('My Garden'),
      actions: [
        const _LayoutActions(),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HistoryScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () {
            context.read<AuthBloc>().add(SignOutEvent());
          },
        ),
      ],
    );
  }
}

class _LayoutActions extends StatelessWidget {
  const _LayoutActions();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GardenBloc, GardenState>(
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;

        if (state is! GardenLoaded || !state.hasUnsavedChanges) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            TextButton.icon(
              onPressed: state.isSaving
                  ? null
                  : () => context.read<GardenBloc>().add(ResetGarden()),
              icon: Icon(Icons.undo, color: colors.onPrimary),
              label: Text('Reset', style: TextStyle(color: colors.onPrimary)),
            ),
            TextButton.icon(
              onPressed: state.isSaving
                  ? null
                  : () => context.read<GardenBloc>().add(SaveGarden()),
              icon: state.isSaving
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onPrimary,
                      ),
                    )
                  : Icon(Icons.save, color: colors.onPrimary),
              label: Text(
                state.isSaving ? 'Saving' : 'Save',
                style: TextStyle(color: colors.onPrimary),
              ),
            ),
          ],
        );
      },
    );
  }
}
