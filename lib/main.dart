import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

import 'domain/repositories/auth_repository.dart';
import 'domain/repositories/terrace_repository.dart';
import 'data/datasources/firebase_auth_datasource.dart';
import 'data/datasources/firestore_datasource.dart';
import 'data/repositories/firebase_auth_repository_impl.dart';
import 'data/repositories/firebase_terrace_repository_impl.dart';

import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/auth/auth_event.dart';
import 'presentation/bloc/auth/auth_state.dart';
import 'presentation/bloc/terrace/terrace_bloc.dart';
import 'presentation/bloc/terrace/terrace_event.dart';
import 'presentation/pages/home_screen.dart';
import 'presentation/pages/login_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const GardenPlannerApp());
}

class GardenPlannerApp extends StatelessWidget {
  const GardenPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => FirebaseAuthRepositoryImpl(
            authDataSource: FirebaseAuthDataSource(),
          ),
        ),
        RepositoryProvider<TerraceRepository>(
          create: (context) => FirebaseTerraceRepositoryImpl(
            firestoreDataSource: FirestoreDataSource(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                AuthBloc(authRepository: context.read<AuthRepository>())
                  ..add(CheckAuthStatusEvent()),
          ),
          BlocProvider(
            create: (context) => TerraceBloc(
              terraceRepository: context.read<TerraceRepository>(),
              authRepository: context.read<AuthRepository>(),
            )..add(LoadTerraces()),
          ),
        ],
        child: MaterialApp(
          title: 'Garden Planner',
          theme: AppTheme.lightTheme,
          home: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  ),
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
