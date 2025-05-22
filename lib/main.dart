// lib/app_navigation_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/provider_tasks_screen.dart';
import 'screens/riverpod_tasks_screen.dart';
import 'screens/bloc_tasks_screen.dart';
import 'blocs/task_bloc/task_bloc.dart';
import 'blocs/task_bloc/task_event.dart';

/// Main entry point of the application.
/// 
/// This demonstrates three different state management approaches:
/// 1. Provider: Simple state management using ChangeNotifier
/// 2. BLoC: Complex state management using events and states
/// 3. Riverpod: Modern state management with compile-time safety
void main() {
  runApp(
    // ProviderScope is required for Riverpod to work
    // It creates a container for all providers in the app
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          // Provider pattern: Simple state management using ChangeNotifier
          provider.ChangeNotifierProvider(create: (_) => TaskProvider()),
          
          // BLoC pattern: Complex state management using events and states
          BlocProvider(create: (_) => TaskBloc()..add(const LoadTasks())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

/// Root widget of the application.
/// 
/// Sets up the MaterialApp with theme and navigation.
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'State Management Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppNavigationShell(),
    );
  }
}

/// Navigation shell that manages the bottom navigation bar and screen switching.
/// 
/// This widget demonstrates how to:
/// 1. Switch between different state management implementations
/// 2. Maintain navigation state
/// 3. Handle screen transitions
class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _selectedIndex = 0;

  /// List of screens for each state management approach
  static const List<Widget> _widgetOptions = <Widget>[
    RiverpodTasksScreen(), // Modern state management with Riverpod
    ProviderTasksScreen(), // Simple state management with Provider
    BlocTasksScreen(),     // Complex state management with BLoC
  ];

  /// Handles bottom navigation bar item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt),
            label: 'Riverpod',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.layers),
            label: 'Provider',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.memory),
            label: 'BLoC',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}