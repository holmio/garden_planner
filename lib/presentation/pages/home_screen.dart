import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/terrace.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/terrace/terrace_bloc.dart';
import '../bloc/terrace/terrace_event.dart';
import '../bloc/terrace/terrace_state.dart';
import 'history_screen.dart';
import 'terrace_detail_sheet.dart';

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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error.message),
                backgroundColor: Colors.red.shade700,
              ),
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

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red.shade700,
              ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Garden saved.'),
                backgroundColor: Colors.green.shade700,
              ),
            );
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Garden'),
          backgroundColor: Colors.green,
          actions: [
            BlocBuilder<TerraceBloc, TerraceState>(
              builder: (context, state) {
                if (state is TerraceLoaded && state.hasUnsavedChanges) {
                  return Row(
                    children: [
                      TextButton.icon(
                        onPressed: state.isSaving
                            ? null
                            : () => context.read<TerraceBloc>().add(
                                ResetLayout(),
                              ),
                        icon: const Icon(Icons.undo, color: Colors.white),
                        label: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: state.isSaving
                            ? null
                            : () =>
                                  context.read<TerraceBloc>().add(SaveLayout()),
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
                }
                return const SizedBox.shrink();
              },
            ),
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HistoryScreen(),
                  ),
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
        ),
        body: BlocBuilder<TerraceBloc, TerraceState>(
          builder: (context, state) {
            if (state is TerraceLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is TerraceError) {
              return _buildLoadError(context, state.message);
            }
            if (state is TerraceLoaded) {
              return InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(double.infinity),
                minScale: 0.1,
                maxScale: 4.0,
                constrained: false, // Allows panning outside the screen bounds
                child: Container(
                  width: 2000, // Large canvas size
                  height: 2000,
                  decoration: BoxDecoration(
                    color: Colors.brown.shade200,
                    border: Border.all(color: Colors.brown.shade800, width: 4),
                  ),
                  child: Stack(
                    children: [
                      // Grid background
                      Positioned.fill(
                        child: CustomPaint(painter: GridPainter()),
                      ),
                      // Render all terraces
                      ...state.terraces.map(
                        (terrace) => _buildDraggableTerrace(context, terrace),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            final newTerrace = Terrace(
              id: const Uuid().v4(),
              name: 'New Bed',
              x: 100, // Default spawn position
              y: 100,
              width: 150,
              height: 100,
            );
            context.read<TerraceBloc>().add(AddTerrace(newTerrace));
          },
          backgroundColor: Colors.green,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildLoadError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off, color: Colors.red.shade700, size: 48),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.read<TerraceBloc>().add(LoadTerraces()),
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableTerrace(BuildContext context, Terrace terrace) {
    return Positioned(
      left: terrace.x,
      top: terrace.y,
      child: GestureDetector(
        onPanUpdate: (details) {
          // Fluidly update the position while dragging
          final newX = terrace.x + details.delta.dx;
          final newY = terrace.y + details.delta.dy;
          context.read<TerraceBloc>().add(
            UpdateTerracePosition(terrace.id, newX, newY),
          );
        },
        onPanEnd: (details) {
          // Snap strictly to the 50x50 grid on release!
          final snappedX = (terrace.x / 50).round() * 50.0;
          final snappedY = (terrace.y / 50).round() * 50.0;
          context.read<TerraceBloc>().add(
            UpdateTerracePosition(terrace.id, snappedX, snappedY),
          );
        },
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => TerraceDetailSheet(terrace: terrace),
          );
        },
        child: Container(
          width: terrace.width,
          height: terrace.height,
          decoration: BoxDecoration(
            color: Colors.green.shade400,
            border: Border.all(color: Colors.green.shade900, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  '${terrace.name}\n${terrace.sunExposure ?? ''}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Resize handle visual indicator
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.open_in_full,
                    size: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.brown.shade300
      ..strokeWidth = 1;

    const double step = 50;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
