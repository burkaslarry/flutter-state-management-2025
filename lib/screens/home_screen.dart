import 'package:flutter/material.dart';
import 'provider_tasks_screen.dart';
import 'bloc_tasks_screen.dart';
import 'riverpod_tasks_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('State Management Demo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildOptionCard(
              context,
              'Provider Demo',
              'Simple state management with Provider',
              Icons.settings,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProviderTasksScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              'BLoC Demo',
              'Complex state management with BLoC',
              Icons.block,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlocTasksScreen(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildOptionCard(
              context,
              'Riverpod Demo',
              'Modern state management with Riverpod',
              Icons.water_drop,
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RiverpodTasksScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 40),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
} 