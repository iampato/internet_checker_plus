part of internet_checker_plus;

class CheckerOptions {
  final Uri uri;
  final HttpMethod method;
  final Duration timeout;
  CheckerOptions({
    required this.uri,
    required this.method,
    required this.timeout,
  });
}
