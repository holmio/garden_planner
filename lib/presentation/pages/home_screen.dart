import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../domain/entities/terrace.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/terrace/terrace_bloc.dart';
import '../bloc/terrace/terrace_event.dart';
import '../bloc/terrace/terrace_state.dart';
import '../widgets/garden_load_error.dart';
import '../widgets/home_app_bar.dart';
import '../widgets/terrace_canvas.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              backgroundColor: Colors.red.shade700,
            );
          },
        ),
        BlocListener<TerraceBloc, TerraceState>(
          listenWhen: (previous, current) =>
              current is TerraceLoaded &&
              current.errorMessage != null &&
              current.errorMessage !=
                  (previous is TerraceLoaded ? previous.errorMessage : null),
          listener: (context, state) {
            final error = (state as TerraceLoaded).errorMessage;
            if (error == null) return;

            _showSnackBar(
              context,
              message: error,
              backgroundColor: Colors.red.shade700,
            );
          },
        ),
        BlocListener<TerraceBloc, TerraceState>(
          listenWhen: (previous, current) =>
              previous is TerraceLoaded &&
              previous.isSaving &&
              current is TerraceLoaded &&
              !current.isSaving &&
              !current.hasUnsavedChanges &&
              current.errorMessage == null,
          listener: (context, state) {
            _showSnackBar(
              context,
              message: 'Garden saved.',
              backgroundColor: Colors.green.shade700,
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: const HomeAppBar(),
        body: const _GardenBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _addTerrace(context),
          backgroundColor: Colors.green,
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
    context.read<TerraceBloc>().add(AddTerrace(newTerrace));
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
    return BlocBuilder<TerraceBloc, TerraceState>(
      builder: (context, state) {
        if (state is TerraceLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is TerraceError) {
          return GardenLoadError(message: state.message);
        }
        if (state is TerraceLoaded) {
          return TerraceCanvas(terraces: state.terraces);
        }

        return const SizedBox.shrink();
      },
    );
  }
}
