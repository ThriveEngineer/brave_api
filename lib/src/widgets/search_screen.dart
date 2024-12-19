import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/search_result.dart';
import '../config/brave_search_config.dart';
import 'web_view_screen.dart';

class BraveSearchScreen extends StatefulWidget {
  /// Custom title for the search screen
  final String? title;
  
  /// Custom style for the title
  final TextStyle? titleStyle;
  
  /// Custom decoration for the search input field
  final InputDecoration? searchDecoration;
  
  /// Custom builder for search results
  final Widget Function(BuildContext, SearchResult)? resultBuilder;

  /// Custom theme for the entire search screen
  final ThemeData? theme;

  /// Custom app bar widget
  final PreferredSizeWidget? appBar;

  /// Custom loading indicator widget
  final Widget? loadingIndicator;

  /// Custom error widget builder
  final Widget Function(BuildContext, String)? errorBuilder;

  /// Custom empty results widget
  final Widget? emptyResultsWidget;

  /// Callback when a search is performed
  final Function(String)? onSearch;

  /// Callback when a result is selected
  final Function(SearchResult)? onResultSelected;

  /// Custom scroll physics for the results list
  final ScrollPhysics? scrollPhysics;

  /// Custom padding for the search results
  final EdgeInsets? resultsPadding;

  /// Animation duration for loading states
  final Duration animationDuration;

  /// Whether to show the search icon
  final bool showSearchIcon;

  /// Whether to auto-focus the search field
  final bool autoFocus;

  /// Maximum lines for result description
  final int maxDescriptionLines;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom divider between results
  final Widget? resultDivider;

  /// Whether to show a clear button in the search field
  final bool showClearButton;

  /// Whether to persist search term between searches
  final bool persistSearchTerm;

  /// Custom transitions for navigation
  final Widget Function(BuildContext, Animation<double>, Animation<double>, Widget)?
      pageTransitionsBuilder;

  const BraveSearchScreen({
    Key? key,
    this.title,
    this.titleStyle,
    this.searchDecoration,
    this.resultBuilder,
    this.theme,
    this.appBar,
    this.loadingIndicator,
    this.errorBuilder,
    this.emptyResultsWidget,
    this.onSearch,
    this.onResultSelected,
    this.scrollPhysics,
    this.resultsPadding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    this.animationDuration = const Duration(milliseconds: 300),
    this.showSearchIcon = true,
    this.autoFocus = false,
    this.maxDescriptionLines = 2,
    this.backgroundColor,
    this.resultDivider,
    this.showClearButton = true,
    this.persistSearchTerm = false,
    this.pageTransitionsBuilder,
  }) : super(key: key);

  @override
  _BraveSearchScreenState createState() => _BraveSearchScreenState();
}

class _BraveSearchScreenState extends State<BraveSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  String? _error;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    widget.onSearch?.call(query);

    try {
      final response = await http.get(
        Uri.parse('https://api.search.brave.com/res/v1/web/search?q=${Uri.encodeComponent(query)}'),
        headers: {
          'Accept': 'application/json',
          'X-Subscription-Token': BraveSearchConfig.apiKey,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = (data['web']['results'] as List)
              .map((result) => SearchResult.fromJson(result))
              .toList();
          _isLoading = false;
        });
        _animationController.forward(from: 0.0);
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }

    if (!widget.persistSearchTerm) {
      _searchController.clear();
    }
  }

  Widget _buildSearchResult(BuildContext context, SearchResult result) {
    if (widget.resultBuilder != null) {
      return widget.resultBuilder!(context, result);
    }

    return Column(
      children: [
        ListTile(
          title: Text(
            result.title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            result.description,
            maxLines: widget.maxDescriptionLines,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14),
          ),
          onTap: () {
            widget.onResultSelected?.call(result);
            _handleResultTap(result);
          },
        ),
        if (widget.resultDivider != null) widget.resultDivider!,
      ],
    );
  }

  void _handleResultTap(SearchResult result) async {
    if (Platform.isAndroid) {
      Navigator.push(
        context,
        widget.pageTransitionsBuilder != null
            ? PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    WebViewScreen(url: result.url),
                transitionsBuilder: widget.pageTransitionsBuilder!,
              )
            : MaterialPageRoute(
                builder: (context) => WebViewScreen(url: result.url),
              ),
      );
    } else {
      final Uri url = Uri.parse(result.url);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not launch URL')),
          );
        }
      }
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: widget.loadingIndicator ?? const CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!) ??
          Center(child: Text('Error: $_error'));
    }

    if (_searchResults.isEmpty) {
      return widget.emptyResultsWidget ??
          const Center(child: Text('No results found'));
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView.builder(
        physics: widget.scrollPhysics,
        padding: widget.resultsPadding,
        itemCount: _searchResults.length,
        itemBuilder: (context, index) => _buildSearchResult(
          context,
          _searchResults[index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? Theme.of(context);

    return Theme(
      data: theme,
      child: Scaffold(
        backgroundColor: widget.backgroundColor,
        appBar: widget.appBar ??
            AppBar(
              title: Center(
                child: Text(
                  widget.title ?? 'Brave Search',
                  style: widget.titleStyle ?? TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                autofocus: widget.autoFocus,
                decoration: widget.searchDecoration ??
                    InputDecoration(
                      hintText: 'Search...',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.showClearButton && _searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchResults.clear();
                                });
                              },
                            ),
                          if (widget.showSearchIcon)
                            IconButton(
                              icon: const Icon(Icons.search),
                              onPressed: () => _performSearch(_searchController.text),
                            ),
                        ],
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                onSubmitted: _performSearch,
              ),
            ),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }
}