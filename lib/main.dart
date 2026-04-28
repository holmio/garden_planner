import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'data/repositories/mock_auth_repository.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/terrace/terrace_bloc.dart';
import 'presentation/bloc/terrace/terrace_event.dart';
import 'presentation/pages/home_screen.dart';
import 'presentation/pages/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const GardenPlannerApp());
}

class GardenPlannerApp extends StatelessWidget {
  const GardenPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => MockAuthRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<MockAuthRepository>(),
            )..add(CheckAuthStatusEvent()),
          ),
          BlocProvider(
            create: (context) => TerraceBloc()..add(LoadTerraces()),
          ),
        ],
        child: MaterialApp(
          title: 'Garden Planner',
          theme: AppTheme.lightTheme,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator(color: Colors.green)),
                );
              } else if (state is Authenticated) {
                return const HomeScreen();
              } else {
                return const LoginScreen();
              }
            },
          ),
        ),
      ),
    );
  }
}
