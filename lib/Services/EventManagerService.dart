
typedef EventCallback = void Function();

class EventManagerService {

  List<EventCallback> _listeners = [];

  void addListener(EventCallback callback) {
    _listeners.add(callback);
  }

  void removeListener(EventCallback callback) {
    _listeners.remove(callback);
  }

  void triggerEvent() {
    for (var listener in _listeners) {
      listener();
    }
  }

}