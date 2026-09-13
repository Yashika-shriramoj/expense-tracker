import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'login.dart';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase with your project credentials
  await Supabase.initialize(
    url: 'https://lnfxtgiflcgwnbllxzvh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxuZnh0Z2lmbGNnd25ibGx4enZoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODkyODA3ODIsImV4cCI6MjEwNDg1Njc4Mn0.B8eTLyiXAmlyUMTK-hvP-ULNW7eTm1gLpF5bY-Z7p2s',
  );

  runApp(const MyApp());
}

// Global shortcut for easy access across the app (replaces firebaseAuth)
final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Expense Tracker',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFE05C8A), // a richer rose/pink
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFFAF7F8),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFE05C8A),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFE05C8A),
          ),
        ),

      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          // Show a loading indicator while Supabase resolves current auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Check if a session exists (user is signed in)
          final session = snapshot.data?.session ?? supabase.auth.currentSession;

          if (session != null) {
            return const HomePage();
          }

          // Otherwise, show LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}