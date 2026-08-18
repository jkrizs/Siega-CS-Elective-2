import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const MyApp());
}

// 1. Configure the Router with a nested sub-route
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const FruitListScreen(),
      routes: [
        // Sub-route: /fruit/:name
        GoRoute(
          path: 'fruit/:name',
          builder: (context, state) {
            final fruitName = state.pathParameters['name'] ?? 'Unknown';
            return FruitDetailScreen(fruitName: fruitName);
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Activity 2',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// 2. Home Page: List of Fruits
class FruitListScreen extends StatelessWidget {
  const FruitListScreen({super.key});

  final List<Map<String, String>> fruits = const [
    {'name': 'Apple', 'emoji': '🍎'},
    {'name': 'Banana', 'emoji': '🍌'},
    {'name': 'Orange', 'emoji': '🍊'},
    {'name': 'Grapes', 'emoji': '🍇'},
    {'name': 'Mango', 'emoji': '🥭'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruits List'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: SizedBox(
            width: 320,
            child: GridView.builder(
              itemCount: fruits.length,
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.95,
              ),
              itemBuilder: (context, index) {
                final fruit = fruits[index];
                final name = fruit['name']!;
                final emoji = fruit['emoji']!;

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      context.go('/fruit/$name');
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// 3. Detail Page: Shows the Fruit Illustration
class FruitDetailScreen extends StatelessWidget {
  final String fruitName;

  const FruitDetailScreen({super.key, required this.fruitName});

  // Map to find the matching illustration/emoji
  static const Map<String, String> fruitIllustrations = {
    'Apple': '🍎',
    'Banana': '🍌',
    'Orange': '🍊',
    'Grapes': '🍇',
    'Mango': '🥭',
  };

  @override
  Widget build(BuildContext context) {
    final emoji = fruitIllustrations[fruitName] ?? '❓';

    return Scaffold(
      appBar: AppBar(
        title: Text(fruitName),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: SizedBox(
              width: 300,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        fruitName,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Current Path: /fruit/$fruitName',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}