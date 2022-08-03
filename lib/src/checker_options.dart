part of internet_checker_plus;

class CheckerOptions {
  final Uri uri;
  final HttpMethod method;
  Duration timeout;
  CheckerOptions({
    required this.uri,
    required this.method,
    this.timeout = const Duration(seconds: 2),
  });
}
