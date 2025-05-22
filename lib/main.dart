// lib/app_navigation_shell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart';
import 'screens/provider_tasks_screen.dart';
import 'screens/riverpod_tasks_screen.dart';
import 'screens/bloc_tasks_screen.dart';
import 'blocs/task_bloc/task_bloc.dart';
import 'blocs/task_bloc/task_event.dart';

void main() {
  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => TaskProvider()),
          BlocProvider(create: (_) => TaskBloc()..add(const LoadTasks())),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

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

class AppNavigationShell extends StatefulWidget {
  const AppNavigationShell({super.key});

  @override
  State<AppNavigationShell> createState() => _AppNavigationShellState();
}

class _AppNavigationShellState extends State<AppNavigationShell> {
  int _selectedIndex = 0;

  // Define the screens that the BottomNavigationBar will switch between
  static const List<Widget> _widgetOptions = <Widget>[
    RiverpodTasksScreen(), // Your existing Riverpod screen
    ProviderTasksScreen(), // Placeholder for Provider screen
    BlocTasksScreen(),     // Placeholder for BLoC screen
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The body will be the currently selected screen from _widgetOptions
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
        selectedItemColor: Theme.of(context).primaryColor, // Use theme color
        onTap: _onItemTapped,
      ),
    );
  }
}