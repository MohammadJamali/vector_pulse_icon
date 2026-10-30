import 'package:flutter/services.dart';

import 'svg_document.dart';
import 'svg_parser.dart';

/// Loads and parses SVG assets, caching each document by asset key.
class SvgLoader {
  SvgLoader({this.bundle, this.parser = const SvgParser()});

  /// The loader [VectorPulseIcon] uses when none is given.
  static final shared = SvgLoader();

  /// Defaults to [rootBundle].
  final AssetBundle? bundle;
  final SvgParser parser;
  final _cache = <String, Future<SvgDocument>>{};

  Future<SvgDocument> load(String asset) => _cache.putIfAbsent(asset, () async {
    try {
      return parser.parse(await (bundle ?? rootBundle).loadString(asset));
    } catch (_) {
      _cache.remove(asset);
      rethrow;
    }
  });

  void evict(String asset) => _cache.remove(asset);

  void clear() => _cache.clear();
}
