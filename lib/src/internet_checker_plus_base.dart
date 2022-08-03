import 'dart:async';
import 'dart:io';

import 'package:internet_checker_plus/internet_checker_plus.dart';

class InternetCheckerPlus {
  final CheckerOptions checkerOptions;
  final Duration checkInterval;

  ConnectionStatus? _lastStatus;
  Timer? _timerHandle;
  final StreamController<ConnectionStatus> _statusController =
      StreamController<ConnectionStatus>.broadcast();

  InternetCheckerPlus({
    required this.checkerOptions,
    required this.checkInterval,
  }) {
    _statusController.onListen = () {
      _maybeEmitStatusUpdate();
    };
    // stop sending status updates when no one is listening
    _statusController.onCancel = () {
      _timerHandle?.cancel();
      _lastStatus = null; // reset last status
    };
  }

  Future<void> _maybeEmitStatusUpdate([
    Timer? timer,
  ]) async {
    // just in case
    _timerHandle?.cancel();
    timer?.cancel();

    final ConnectionStatus currentStatus = await _hasConnection;

    // only send status update if last status differs from current
    // and if someone is actually listening
    if (_lastStatus != currentStatus && _statusController.hasListener) {
      _statusController.add(currentStatus);
    }

    // start new timer only if there are listeners
    if (!_statusController.hasListener) return;
    _timerHandle = Timer(checkInterval, _maybeEmitStatusUpdate);

    // update last status
    _lastStatus = currentStatus;
  }

  Future<HttpClientRequest> getRequest(
    HttpClient client,
    CheckerOptions options,
  ) async {
    switch (options.method) {
      case HttpMethod.get:
        return await client.getUrl(options.uri);
      case HttpMethod.post:
        return await client.postUrl(options.uri);
      case HttpMethod.put:
        return await client.putUrl(options.uri);
      case HttpMethod.delete:
        return await client.deleteUrl(options.uri);
      default:
        throw Exception('Unknown HTTP method');
    }
  }

  Future<int?> _isHostReachable(
    CheckerOptions options,
  ) async {
    try {
      final client = HttpClient();
      final request = await getRequest(
        client,
        options,
      );
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        "application/json; charset=UTF-8",
      );
      final response = await request.close().timeout(options.timeout);
      return response.statusCode;
    } catch (e) {
      return null;
    }
  }

  /// Initiates a request to each address in [addresses].
  /// If at least one of the addresses is reachable
  /// we assume an internet connection is available and return `true`.
  /// `false` otherwise.
  Future<ConnectionStatus> get _hasConnection async {
    final statusCode = await _isHostReachable(
      checkerOptions,
    );
    if (statusCode != null) {
      return statusCode == 200
          ? ConnectionStatus.connected
          : ConnectionStatus.disconnected;
    } else {
      return ConnectionStatus.disconnected;
    }
  }

  Stream<ConnectionStatus> get onStatusChange => _statusController.stream;

  bool get hasListeners => _statusController.hasListener;

  bool get isActivelyChecking => _statusController.hasListener;

  ConnectionStatus? get lastStatus => _lastStatus;
  void close() {
    _statusController.close();
  }
}
