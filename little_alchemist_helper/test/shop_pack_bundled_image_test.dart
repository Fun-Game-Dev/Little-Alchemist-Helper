import 'package:flutter_test/flutter_test.dart';

import 'package:little_alchemist_helper/data/shop_pack_models.dart';
import 'package:little_alchemist_helper/services/card_image_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('occasionAllowlistFromPackScheduleOccasionsJson парсит список', () {
    expect(
      ShopPackBundle.occasionAllowlistFromPackScheduleOccasionsJson(
        '{"occasions":["Hammer","Sword"]}',
      ),
      <String>{'Hammer', 'Sword'},
    );
    expect(
      ShopPackBundle.occasionAllowlistFromPackScheduleOccasionsJson('{}'),
      isEmpty,
    );
  });

  test(
    'bundledShopPackImageAssetPath: Accursed из расписания, селектора и прямого имени',
    () async {
      final String? fromSchedule =
          await bundledShopPackImageAssetPath('2026_06_29_accursed.png');
      final String? fromSelector = await bundledShopPackImageAssetPath(
        'Accursed_Pack_Selector.png',
      );
      final String? direct =
          await bundledShopPackImageAssetPath('shop_pack_Accursed.png');

      void expectAccursedPath(String? path) {
        expect(path, isNotNull);
        expect(path, startsWith('assets/images/shop_packs/'));
        expect(
          path!.toLowerCase(),
          'assets/images/shop_packs/shop_pack_accursed.png',
        );
      }

      expectAccursedPath(fromSchedule);
      expectAccursedPath(fromSelector);
      expectAccursedPath(direct);
    },
  );

  test('resolveShopPackImageSource: Accursed без сети даёт asset', () async {
    final CardImageSource src = await resolveShopPackImageSource(
      scheduleImageFile: '2026_06_29_accursed.png',
      selectorFile: 'Accursed_Pack_Selector.png',
      wikiImageUrl: '',
      allowNetworkFetch: false,
    );
    expect(src.hasAsset, isTrue);
    expect(src.hasNetwork, isFalse);
    expect(
      src.assetPath!.toLowerCase(),
      'assets/images/shop_packs/shop_pack_accursed.png',
    );
  });
}
