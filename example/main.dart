import 'package:brave_api/brave_api.dart';
import 'package:brave_api/search_screen.dart';
import 'package:flutter/material.dart';

void main() {
  BraveSearchConfig.initialize(apiKey: 'YOUR_BRAVE_API_KEY');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brave Search Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: BraveSearchScreen(
        // Custom title and styling
        title: 'Custom Search',
        titleStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.indigo,
        ),
        
        // Custom search field decoration
        searchDecoration: InputDecoration(
          hintText: 'What are you looking for?',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.indigo),
          ),
        ),
        
        // Custom loading indicator
        loadingIndicator: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.indigo),
            SizedBox(height: 16),
            Text('Searching...'),
          ],
        ),
        
        // Custom empty results widget
        emptyResultsWidget: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 48),
              const SizedBox(height: 16),
              Text(
                'No results found',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
        
        // Custom error builder
        errorBuilder: (context, error) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () {
                  // Handle retry
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        
        // Custom result builder
        resultBuilder: (context, result) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              result.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(result.description),
                const SizedBox(height: 4),
                Text(
                  result.url,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        
        // Additional customization options
        backgroundColor: Colors.grey[50],
        autoFocus: true,
        maxDescriptionLines: 3,
        showClearButton: true,
        persistSearchTerm: false,
        resultDivider: const Divider(height: 1),
        
        // Custom page transitions
        pageTransitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        
        // Callbacks
        onSearch: (query) {
          print('Searching for: $query');
        },
        onResultSelected: (result) {
          print('Selected result: ${result.title}');
        },
      ),
    );
  }
}