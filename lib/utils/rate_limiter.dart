class RateLimiter {
  final Duration minInterval;
  DateTime? _lastCalled;

  RateLimiter(this.minInterval);

  bool shouldAllow() {
    final now = DateTime.now();

    if (_lastCalled == null ||
        now.difference(_lastCalled!) >= minInterval) {
      _lastCalled = now;
      return true;
    }

    return false;
  }
}
