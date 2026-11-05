
/// MwpaConnectionException - the server could not be reached (no network,
/// refused, [timeout]) or sent something unreadable
class MwpaConnectionException implements Exception {
  final bool timeout;

  const MwpaConnectionException({this.timeout = false});

  @override
  String toString() => timeout
      ? 'Exception: Connection timeout, the server did not respond'
      : 'Exception: Connection error';
}

class MwpaException implements Exception {
  String _message = '';

  MwpaException([String message = 'Mwpa Exception']) {
    _message = message;
  }

  @override
  String toString() {
    return _message;
  }
}