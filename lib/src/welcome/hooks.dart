import 'dart:async';

import 'package:flutter_hooks/flutter_hooks.dart';

T useDebouncedBetter<T>(T data, Duration duration) {
  final timer = useState<Timer?>(null);
  final value = useState<T>(data);

  useEffect(() {
    timer.value?.cancel();
    timer.value = Timer(
      duration,
      () {
        value.value = data;
      },
    );

    return null;
  }, [data]);

  useEffect(() {
    return () {
      timer.value?.cancel();
      timer.value = null;
    };
  }, []);

  return value.value;
}
