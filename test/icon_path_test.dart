import 'dart:io';

import 'package:cravvy_cooking_app/resources/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('icon_path assets test', () {
    expect(File(IconPath.arrowLeft).existsSync(), isTrue);
    expect(File(IconPath.apple).existsSync(), isTrue);
    expect(File(IconPath.calendar).existsSync(), isTrue);
    expect(File(IconPath.fire).existsSync(), isTrue);
    expect(File(IconPath.foodPlate).existsSync(), isTrue);
    expect(File(IconPath.google).existsSync(), isTrue);
    expect(File(IconPath.health).existsSync(), isTrue);
    expect(File(IconPath.plate).existsSync(), isTrue);
    expect(File(IconPath.strength).existsSync(), isTrue);
    expect(File(IconPath.target).existsSync(), isTrue);
  });
}
