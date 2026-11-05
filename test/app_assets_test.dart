import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:brainbox/core/constants/app_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every AppAssets path loads from the app bundle', () async {
    for (final path in AppAssets.all) {
      await rootBundle.load(path);
    }
  });
}
