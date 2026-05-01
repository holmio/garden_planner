import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';

class LoginScreen extends StatelessWidget {
  final String? errorMessage;

  const LoginScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.yard, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Garden Planner',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 48),
              if (errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade800),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Sign in with Google'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.green.shade800,
                  textStyle: const TextStyle(fontSize: 18),
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
