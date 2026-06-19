import 'dart:io';

import 'package:cravvy_cooking_app/resources/resources.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('image_path assets test', () {
    expect(File(ImagePath.appName).existsSync(), isTrue);
    expect(File(ImagePath.onboarding1).existsSync(), isTrue);
    expect(File(ImagePath.onboarding2).existsSync(), isTrue);
    expect(File(ImagePath.onboarding3).existsSync(), isTrue);
    expect(File(ImagePath.sticketLogo).existsSync(), isTrue);
  });
}
