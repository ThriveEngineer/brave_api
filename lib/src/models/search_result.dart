class SearchResult {
  final String title;
  final String url;
  final String description;

  const SearchResult({
    required this.title,
    required this.url,
    required this.description,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'url': url,
      'description': description,
    };
  }
}