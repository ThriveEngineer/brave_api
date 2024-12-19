# Brave Search Flutter

A highly customizable Flutter package that provides a search interface using the Brave Search API. This package offers a rich set of features and customization options for creating a seamless search experience in your Flutter applications.
[pub.dev](https://pub.dev/packages/brave_api)
## Features

🔍 **Core Features**
- Full-featured search interface using Brave Search API
- Built-in WebView for Android
- External URL launcher for iOS
- Search result caching
- Error handling

🎨 **Customization Options**
- Fully customizable search screen
- Custom themes and styling
- Custom loading states
- Custom error handling
- Custom result rendering
- Custom animations and transitions

🛠️ **Advanced Features**
- Platform-specific behavior handling
- Extensive callback system
- Navigation controls
- Progress indicators
- JavaScript control
- Custom scroll physics

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  brave_api: ^1.0.1
```

Then run:
```bash
flutter pub get
```

## Setup

1. Initialize the package with your Brave Search API key:

```dart
void main() {
  BraveSearchConfig.initialize(apiKey: 'YOUR_BRAVE_API_KEY');
  runApp(MyApp());
}
```

2. Import the package:

```dart
import 'package:brave_api/brave_api.dart';
```

## Basic Usage

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BraveSearchScreen(
        title: 'Search',
        onResultSelected: (result) {
          print('Selected: ${result.title}');
        },
      ),
    );
  }
}
```

## Advanced Customization

### Custom Search Screen Styling

```dart
BraveSearchScreen(
  title: 'Custom Search',
  titleStyle: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.indigo,
  ),
  searchDecoration: InputDecoration(
    hintText: 'What are you looking for?',
    prefixIcon: Icon(Icons.search),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15),
    ),
  ),
  backgroundColor: Colors.grey[50],
  resultsPadding: EdgeInsets.all(16),
)
```

### Custom Loading and Error States

```dart
BraveSearchScreen(
  loadingIndicator: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircularProgressIndicator(),
      SizedBox(height: 16),
      Text('Searching...'),
    ],
  ),
  errorBuilder: (context, error) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline),
        Text('Error: $error'),
        ElevatedButton(
          onPressed: () => print('Retry'),
          child: Text('Retry'),
        ),
      ],
    ),
  ),
)
```

### Custom Result Rendering

```dart
BraveSearchScreen(
  resultBuilder: (context, result) => Card(
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: ListTile(
      title: Text(
        result.title,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(result.description),
      trailing: Icon(Icons.arrow_forward),
      onTap: () => print('Selected: ${result.title}'),
    ),
  ),
)
```

### Custom WebView Configuration

```dart
WebViewScreen(
  url: 'https://example.com',
  enableJavaScript: true,
  enableZoom: true,
  loadingIndicator: CircularProgressIndicator(),
  navigationActions: [
    IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () => print('Refresh'),
    ),
  ],
)
```

## Available Customization Options

### Search Screen Options
- `title`: Custom title for the search screen
- `titleStyle`: Custom style for the title
- `searchDecoration`: Custom decoration for the search input field
- `theme`: Custom theme for the entire search screen
- `appBar`: Custom app bar widget
- `loadingIndicator`: Custom loading indicator widget
- `errorBuilder`: Custom error widget builder
- `emptyResultsWidget`: Custom empty results widget
- `resultBuilder`: Custom search result builder
- `backgroundColor`: Custom background color
- `resultDivider`: Custom divider between results
- `animationDuration`: Animation duration for loading states
- `scrollPhysics`: Custom scroll physics for the results list
- `resultsPadding`: Custom padding for search results

### WebView Options
- `enableJavaScript`: Enable/disable JavaScript
- `enableZoom`: Enable/disable zoom controls
- `userAgent`: Custom user agent string
- `navigationDelegate`: Custom navigation handling
- `progressIndicatorBuilder`: Custom progress indicator
- `navigationActions`: Custom navigation controls

### Callback Options
- `onSearch`: Triggered when a search is performed
- `onResultSelected`: Triggered when a result is selected
- `onError`: Triggered when an error occurs

## Platform Specific Behavior

The package automatically handles platform-specific behaviors:
- Android: Opens results in an in-app WebView
- iOS: Opens results in the default browser using URL launcher

## Contributing

We welcome contributions! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
