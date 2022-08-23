
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