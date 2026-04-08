import 'dart:io';

import 'package:cravvy_cooking_app/resources/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('icon_path assets test', () {
    expect(File(IconPath.arrowLeft).existsSync(), isTrue);
    expect(File(IconPath.apple).existsSync(), isTrue);
    expect(File(IconPath.google).existsSync(), isTrue);
  });
}
