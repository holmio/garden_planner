import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/terrace/terrace_bloc.dart';
import '../bloc/terrace/terrace_event.dart';
import '../bloc/terrace/terrace_state.dart';
import '../pages/history_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('My Garden'),
      backgroundColor: Colors.green,
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
    return BlocBuilder<TerraceBloc, TerraceState>(
      builder: (context, state) {
        if (state is! TerraceLoaded || !state.hasUnsavedChanges) {
          return const SizedBox.shrink();
        }

        return Row(
          children: [
            TextButton.icon(
              onPressed: state.isSaving
                  ? null
                  : () => context.read<TerraceBloc>().add(ResetLayout()),
              icon: const Icon(Icons.undo, color: Colors.white),
              label: const Text('Reset', style: TextStyle(color: Colors.white)),
            ),
            TextButton.icon(
              onPressed: state.isSaving
                  ? null
                  : () => context.read<TerraceBloc>().add(SaveLayout()),
              icon: state.isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save, color: Colors.white),
              label: Text(
                state.isSaving ? 'Saving' : 'Save',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
