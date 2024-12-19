import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String? title;
  final TextStyle? titleStyle;
  
  /// Custom app bar
  final PreferredSizeWidget? appBar;
  
  /// Custom loading indicator
  final Widget? loadingIndicator;
  
  /// Custom error widget builder
  final Widget Function(BuildContext, WebResourceError)? errorBuilder;
  
  /// Custom navigation controls
  final List<Widget>? navigationActions;
  
  /// Whether to enable JavaScript
  final bool enableJavaScript;
  
  /// Background color for the WebView
  final Color? backgroundColor;
  
  /// Custom progress indicator builder
  final Widget Function(BuildContext, double)? progressIndicatorBuilder;
  
  /// Whether to enable zoom controls
  final bool enableZoom;
  
  /// Initial scale for the WebView
  final double initialScale;
  
  /// Custom user agent string
  final String? userAgent;
  
  /// Whether to allow navigation between pages
  final bool allowNavigation;
  
  /// Navigation delegate for custom navigation handling
  final NavigationDelegate? navigationDelegate;

  const WebViewScreen({
    Key? key,
    required this.url,
    this.title,
    this.titleStyle,
    this.appBar,
    this.loadingIndicator,
    this.errorBuilder,
    this.navigationActions,
    this.enableJavaScript = true,
    this.backgroundColor,
    this.progressIndicatorBuilder,
    this.enableZoom = true,
    this.initialScale = 1.0,
    this.userAgent,
    this.allowNavigation = true,
    this.navigationDelegate,
  }) : super(key: key);

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    
    final AndroidWebViewController androidController = AndroidWebViewController(
      AndroidWebViewControllerCreationParams()
    );
    
    final navigationDelegate = widget.navigationDelegate ?? NavigationDelegate(
      onPageStarted: (String url) {
        setState(() {
          _isLoading = true;
        });
      },
      onProgress: (int progress) {
        setState(() {
          _progress = progress / 100;
        });
      },
      onPageFinished: (String url) {
        setState(() {
          _isLoading = false;
        });
      },
      onWebResourceError: (WebResourceError error) {
        if (mounted) {
          if (widget.errorBuilder != null) {
            widget.errorBuilder!(context, error);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading page: ${error.description}')),
            );
          }
        }
      },
      onNavigationRequest: (NavigationRequest request) {
        if (!widget.allowNavigation && request.url != widget.url) {
          return NavigationDecision.prevent;
        }
        return NavigationDecision.navigate;
      },
    );
    
    _controller = WebViewController.fromPlatform(androidController)
      ..setJavaScriptMode(widget.enableJavaScript 
          ? JavaScriptMode.unrestricted 
          : JavaScriptMode.disabled)
      ..setBackgroundColor(widget.backgroundColor ?? const Color(0x00000000))
      ..setNavigationDelegate(navigationDelegate);

    if (widget.userAgent != null) {
      _controller.setUserAgent(widget.userAgent);
    }

    if (widget.enableZoom) {
      _controller.enableZoom(true);
    }

    _controller.loadRequest(Uri.parse(widget.url));
  }

  List<Widget> _buildNavigationActions() {
    if (widget.navigationActions != null) {
      return widget.navigationActions!;
    }

    return [
      IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () async {
          if (await _controller.canGoBack()) {
            await _controller.goBack();
          }
        },
      ),
      IconButton(
        icon: const Icon(Icons.arrow_forward),
        onPressed: () async {
          if (await _controller.canGoForward()) {
            await _controller.goForward();
          }
        },
      ),
      IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: () => _controller.reload(),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.appBar ?? AppBar(
        title: Center(
          child: Text(
            widget.title ?? "Web View",
            style: widget.titleStyle ?? TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
          ),
        ),
        actions: _buildNavigationActions(),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) 
            Center(
              child: widget.loadingIndicator ?? const CircularProgressIndicator(),
            ),
             if (widget.progressIndicatorBuilder != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: widget.progressIndicatorBuilder!(context, _progress),
            )
          else if (_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(value: _progress),
            ),
        ],
      ),
    );
  }
}