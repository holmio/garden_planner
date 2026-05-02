import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/terrace.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/garden/garden_bloc.dart';
import '../bloc/garden/garden_event.dart';
import '../bloc/garden/garden_state.dart';
import '../widgets/garden_load_error.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/garden_canvas.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return MultiBlocListener(
      listeners: [
        BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) =>
              current is AuthError && current.previousUser != null,
          listener: (context, state) {
            final error = state as AuthError;
            _showSnackBar(
              context,
              message: error.message,
              backgroundColor: colors.error,
            );
          },
        ),
        BlocListener<GardenBloc, GardenState>(
          listenWhen: (previous, current) =>
              current is GardenLoaded &&
              current.errorMessage != null &&
              current.errorMessage !=
                  (previous is GardenLoaded ? previous.errorMessage : null),
          listener: (context, state) {
            final error = (state as GardenLoaded).errorMessage;
            if (error == null) return;

            _showSnackBar(
              context,
              message: error,
              backgroundColor: colors.error,
            );
          },
        ),
        BlocListener<GardenBloc, GardenState>(
          listenWhen: (previous, current) =>
              previous is GardenLoaded &&
              previous.isSaving &&
              current is GardenLoaded &&
              !current.isSaving &&
              !current.hasUnsavedChanges &&
              current.errorMessage == null,
          listener: (context, state) {
            _showSnackBar(
              context,
              message: 'Garden saved.',
              backgroundColor: colors.primary,
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: const HomeAppBar(),
        body: const _GardenBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addTerrace(context),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _addTerrace(BuildContext context) {
    final newTerrace = Terrace(
      id: const Uuid().v4(),
      name: 'New Bed',
      x: 100,
      y: 100,
      width: 150,
      height: 100,
    );
    context.read<GardenBloc>().add(AddTerrace(newTerrace));
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }
}

class _GardenBody extends StatelessWidget {
  const _GardenBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GardenBloc, GardenState>(
      builder: (context, state) {
        if (state is GardenLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is GardenError) {
          return GardenLoadError(message: state.message);
        }
        if (state is GardenLoaded) {
          return GardenCanvas(garden: state.garden);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
