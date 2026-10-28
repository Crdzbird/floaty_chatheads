import 'package:floaty_chatheads/src/floaty_proxy_stream.dart';

/// A [StreamKey] named [name] carrying a map of doubles.
StreamKey<Map<String, double>> proxyDoubleKey(String name) =>
    StreamKey<Map<String, double>>(
      name: name,
      toJson: (v) => v,
      fromJson: (j) => j.cast<String, double>(),
    );

/// A [StreamKey] named [name] carrying a map of ints.
StreamKey<Map<String, int>> proxyIntKey(String name) =>
    StreamKey<Map<String, int>>(
      name: name,
      toJson: (v) => v,
      fromJson: (j) => j.cast<String, int>(),
    );
