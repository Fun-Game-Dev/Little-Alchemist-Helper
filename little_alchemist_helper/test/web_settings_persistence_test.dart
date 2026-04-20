import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:little_alchemist_helper/state/app_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Настройка loadCardImages сохраняется между запусками', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final AppController firstLaunchController = await AppController.bootstrap();
    await firstLaunchController.setLoadCardImages(true);
    expect(firstLaunchController.loadCardImages, isTrue);
    firstLaunchController.dispose();

    final AppController secondLaunchController = await AppController.bootstrap();
    expect(
      secondLaunchController.loadCardImages,
      isTrue,
      reason: 'Значение должно восстанавливаться из локального хранилища',
    );
    secondLaunchController.dispose();
  });
}
