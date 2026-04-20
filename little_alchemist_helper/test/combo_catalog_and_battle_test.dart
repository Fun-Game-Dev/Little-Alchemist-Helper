import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:little_alchemist_helper/data/card_catalog_parser.dart';
import 'package:little_alchemist_helper/data/catalog_json_merge.dart';
import 'package:little_alchemist_helper/data/excel_combo_base_builder.dart';
import 'package:little_alchemist_helper/data/fusion_onyx_sheet.dart';
import 'package:little_alchemist_helper/data/onyx_wiki_allowlist.dart';
import 'package:little_alchemist_helper/data/shop_pack_models.dart';
import 'package:little_alchemist_helper/data/synthetic_onyx_catalog_augment.dart';
import 'package:little_alchemist_helper/models/alchemy_card.dart';
import 'package:little_alchemist_helper/models/combo_battle_stats.dart';
import 'package:little_alchemist_helper/models/combo_tier.dart';
import 'package:little_alchemist_helper/services/combo_graph_lookup.dart';
import 'package:little_alchemist_helper/services/fusion_graph_normalizer.dart';
import 'package:little_alchemist_helper/util/catalog_fusion.dart';

/// Таблица вики A/D для материала Onyx по уровням 1…5 ([ComboBattleStats.scaledResultStats],
/// максимальная редкость материала — onyx).
void expectWikiOnyxMaterialStatTable({
  required AlchemyCard materialBase,
  required AlchemyCard fusionPartnerStub,
  required List<({int attack, int defense})> wikiByMaterialLevel,
}) {
  final Map<String, AlchemyCard> aug = SyntheticOnyxCatalogAugment.mergeIntoCatalog(
    base: <String, AlchemyCard>{
      materialBase.cardId: materialBase,
      fusionPartnerStub.cardId: fusionPartnerStub,
    },
    sheet: null,
    allowedOnyxMaterialDisplayNames: <String>{materialBase.displayName},
  );
  final String mid = SyntheticOnyxCatalogAugment.materialOnyxId(materialBase.cardId);
  expect(wikiByMaterialLevel, isNotEmpty);
  for (int i = 0; i < wikiByMaterialLevel.length; i++) {
    final ({int attack, int defense}) scaled = ComboBattleStats.scaledResultStats(
      resultBaseAttack: aug[mid]!.attack,
      resultBaseDefense: aug[mid]!.defense,
      resultLevel: i + 1,
      highestMaterialTier: ComboTier.onyx,
    );
    expect(scaled.attack, wikiByMaterialLevel[i].attack);
    expect(scaled.defense, wikiByMaterialLevel[i].defense);
  }
}

/// Общая таблица вики для Human (Onyx) и Wolf (Onyx) — совпадает по числам.
const List<({int attack, int defense})> kWikiHumanWolfOnyxLevels =
    <({int attack, int defense})>[
      (attack: 6, defense: 5),
      (attack: 10, defense: 9),
      (attack: 14, defense: 13),
      (attack: 18, defense: 17),
      (attack: 22, defense: 21),
    ];

void main() {
  group('Catalog merge + graph', () {
    test('патч дополняет Combinations', () {
      const String base = '''
{
  "X": {
    "DisplayName": "X",
    "Attack": 1,
    "Defense": 1,
    "Rarity": "Common",
    "FusionAbility": "Orb",
    "Picture": "X",
    "CardNum": "1",
    "Description": "",
    "Combinations": {},
    "isLTE": false
  },
  "Y": {
    "DisplayName": "Y",
    "Attack": 1,
    "Defense": 1,
    "Rarity": "Common",
    "FusionAbility": "Orb",
    "Picture": "Y",
    "CardNum": "2",
    "Description": "",
    "Combinations": {},
    "isLTE": false
  },
  "Z": {
    "DisplayName": "Z",
    "Attack": 2,
    "Defense": 2,
    "Rarity": "Rare",
    "FusionAbility": "Orb",
    "Picture": "Z",
    "CardNum": "3",
    "Description": "",
    "Combinations": {},
    "isLTE": false
  }
}
''';
      const String patch = '''
{
  "X": {
    "Combinations": { "Y": "Z" }
  }
}
''';
      final CardCatalogParser parser = const CardCatalogParser();
      final Map<String, AlchemyCard> cat = parser.parseJsonString(
        base,
        combinationPatchJson: patch,
      );
      expect(ComboGraphLookup.fusionResultCardId(cat['X']!, cat['Y']!), 'Z');
      expect(cat['Y']!.combinations['X'], 'Z');
      final Set<String> p = fusionParticipantCardIds(cat);
      expect(p.contains('X'), isTrue);
      expect(p.contains('Y'), isTrue);
    });

    test('нормализатор достраивает обратное ребро', () {
      final Map<String, AlchemyCard> raw = <String, AlchemyCard>{
        'A': const AlchemyCard(
          cardId: 'A',
          displayName: 'A',
          attack: 1,
          defense: 1,
          rarity: 'Common',
          fusionAbility: 'Orb',
          pictureKey: 'A',
          cardNum: '1',
          description: '',
          combinations: <String, String>{'B': 'C'},
          isLte: false,
          seasonalTag: null,
        ),
        'B': const AlchemyCard(
          cardId: 'B',
          displayName: 'B',
          attack: 1,
          defense: 1,
          rarity: 'Common',
          fusionAbility: 'Orb',
          pictureKey: 'B',
          cardNum: '2',
          description: '',
          combinations: <String, String>{},
          isLte: false,
          seasonalTag: null,
        ),
        'C': const AlchemyCard(
          cardId: 'C',
          displayName: 'C',
          attack: 3,
          defense: 3,
          rarity: 'Rare',
          fusionAbility: '',
          pictureKey: 'C',
          cardNum: '3',
          description: '',
          combinations: <String, String>{},
          isLte: false,
          seasonalTag: null,
        ),
      };
      final Map<String, AlchemyCard> n = normalizeUndirectedFusionGraph(raw);
      expect(n['B']!.combinations['A'], 'C');
    });
  });

  group('FusionOnyxSheet', () {
    test('парсинг тройки 0/1/2 оникс', () {
      const String raw = '{"A|B":[[10,5],[11,6],[12,7]]}';
      final FusionOnyxSheet? s = FusionOnyxSheet.parse(raw);
      expect(s, isNotNull);
      expect(s!.resultSumStats('A', 'B', 0), 15);
      expect(s.resultSumStats('B', 'A', 1), 17);
      expect(s.resultSumStats('A', 'B', 2), 19);
      final List<int>? p = s.resultAttackDefense('A', 'B', 1);
      expect(p, isNotNull);
      expect(p![0], 11);
      expect(p[1], 6);
    });
  });

  group('SyntheticOnyxCatalogAugment', () {
    test('добавляет синтетическую оникс-карту для результата Z (2 оникс в таблице)', () {
      const AlchemyCard x = AlchemyCard(
        cardId: 'X',
        displayName: 'X',
        attack: 1,
        defense: 1,
        rarity: 'Common',
        fusionAbility: '',
        pictureKey: 'X',
        cardNum: '1',
        description: '',
        combinations: <String, String>{'Y': 'Z'},
        isLte: false,
        seasonalTag: null,
      );
      const AlchemyCard y = AlchemyCard(
        cardId: 'Y',
        displayName: 'Y',
        attack: 1,
        defense: 1,
        rarity: 'Common',
        fusionAbility: '',
        pictureKey: 'Y',
        cardNum: '2',
        description: '',
        combinations: <String, String>{},
        isLte: false,
        seasonalTag: null,
      );
      const AlchemyCard z = AlchemyCard(
        cardId: 'Z',
        displayName: 'Z',
        attack: 3,
        defense: 3,
        rarity: 'Rare',
        fusionAbility: '',
        pictureKey: 'Z',
        cardNum: '3',
        description: '',
        combinations: <String, String>{},
        isLte: false,
        seasonalTag: null,
      );
      final Map<String, AlchemyCard> base = <String, AlchemyCard>{
        'X': x,
        'Y': y,
        'Z': z,
      };
      const String raw =
          '{"X|Y":[[3,3],[30,30],[40,40]]}';
      final FusionOnyxSheet? sheet = FusionOnyxSheet.parse(raw);
      expect(sheet, isNotNull);
      final Map<String, AlchemyCard> aug = SyntheticOnyxCatalogAugment.mergeIntoCatalog(
        base: base,
        sheet: sheet!,
        allowedOnyxMaterialDisplayNames: <String>{'X', 'Y', 'Z'},
      );
      final String mx = SyntheticOnyxCatalogAugment.materialOnyxId('X');
      final String my = SyntheticOnyxCatalogAugment.materialOnyxId('Y');
      expect(aug[mx], isNotNull);
      expect(aug[my], isNotNull);
      expect(aug[mx]!.attack, 5);
      expect(aug[mx]!.defense, 5);
      expect(
        ComboGraphLookup.fusionResultCardId(aug[mx]!, aug[my]!),
        'Z',
      );
      final String fid = SyntheticOnyxCatalogAugment.fullIdForFusionResult('Z');
      expect(aug[fid], isNotNull);
      expect(aug[fid]!.attack, 40);
      expect(aug[fid]!.defense, 40);
      expect(aug[fid]!.rarity, 'Onyx');
      expect(
        SyntheticOnyxCatalogAugment.baseFusionResultIdFromSynthetic(fid),
        'Z',
      );
    });

    test('без таблицы — только onyx-материалы', () {
      const AlchemyCard x = AlchemyCard(
        cardId: 'X',
        displayName: 'X',
        attack: 1,
        defense: 1,
        rarity: 'Common',
        fusionAbility: '',
        pictureKey: 'X',
        cardNum: '1',
        description: '',
        combinations: <String, String>{'Y': 'Z'},
        isLte: false,
        seasonalTag: null,
      );
      const AlchemyCard y = AlchemyCard(
        cardId: 'Y',
        displayName: 'Y',
        attack: 1,
        defense: 1,
        rarity: 'Common',
        fusionAbility: '',
        pictureKey: 'Y',
        cardNum: '2',
        description: '',
        combinations: <String, String>{},
        isLte: false,
        seasonalTag: null,
      );
      const AlchemyCard z = AlchemyCard(
        cardId: 'Z',
        displayName: 'Z',
        attack: 3,
        defense: 3,
        rarity: 'Rare',
        fusionAbility: '',
        pictureKey: 'Z',
        cardNum: '3',
        description: '',
        combinations: <String, String>{},
        isLte: false,
        seasonalTag: null,
      );
      final Map<String, AlchemyCard> base = <String, AlchemyCard>{
        'X': x,
        'Y': y,
        'Z': z,
      };
      final Map<String, AlchemyCard> aug = SyntheticOnyxCatalogAugment.mergeIntoCatalog(
        base: base,
        sheet: null,
        allowedOnyxMaterialDisplayNames: <String>{'X', 'Y'},
      );
      expect(aug[SyntheticOnyxCatalogAugment.materialOnyxId('X')], isNotNull);
      expect(
        aug.containsKey(SyntheticOnyxCatalogAugment.fullIdForFusionResult('Z')),
        isFalse,
      );
    });

    test('canonicalCatalogIdForFusionSheet снимает префиксы', () {
      expect(
        SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(
          SyntheticOnyxCatalogAugment.materialOnyxId('X'),
        ),
        'X',
      );
      expect(
        SyntheticOnyxCatalogAugment.canonicalCatalogIdForFusionSheet(
          SyntheticOnyxCatalogAugment.fullIdForFusionResult('Z'),
        ),
        'Z',
      );
    });

    test('материал Onyx: wiki Hammer 8/5 на уровне 1 (Common 4/1 + 4/4)', () {
      const AlchemyCard hammer = AlchemyCard(
        cardId: 'Hammer',
        displayName: 'Hammer',
        attack: 4,
        defense: 1,
        rarity: 'Common',
        fusionAbility: 'Orb',
        pictureKey: 'Hammer',
        cardNum: '80',
        description: '',
        combinations: <String, String>{'Adventure': 'Loot Hoarder'},
        isLte: false,
        seasonalTag: null,
      );
      final Map<String, AlchemyCard> aug = SyntheticOnyxCatalogAugment.mergeIntoCatalog(
        base: <String, AlchemyCard>{
          'Hammer': hammer,
          'Loot Hoarder': const AlchemyCard(
            cardId: 'Loot Hoarder',
            displayName: 'Loot Hoarder',
            attack: 1,
            defense: 1,
            rarity: 'Rare',
            fusionAbility: '',
            pictureKey: 'Loot Hoarder',
            cardNum: '1',
            description: '',
            combinations: <String, String>{},
            isLte: false,
            seasonalTag: null,
          ),
        },
        sheet: null,
        allowedOnyxMaterialDisplayNames: <String>{'Hammer'},
      );
      final String mid = SyntheticOnyxCatalogAugment.materialOnyxId('Hammer');
      expect(aug[mid]!.attack, 8);
      expect(aug[mid]!.defense, 5);
    });

    test(
      'материал Onyx: wiki Fairy Tale 6/7…22/23 (Rare 4/5 + 2/2; рост по уровню +4/+4)',
      () {
        const AlchemyCard fairyTale = AlchemyCard(
          cardId: 'Fairy Tale',
          displayName: 'Fairy Tale',
          attack: 4,
          defense: 5,
          rarity: 'Rare',
          fusionAbility: 'Orb',
          pictureKey: 'FairyTale',
          cardNum: '1116',
          description: '',
          combinations: <String, String>{'Adventure': 'Happily Ever After'},
          isLte: false,
          seasonalTag: null,
        );
        const AlchemyCard happilyEverAfter = AlchemyCard(
          cardId: 'Happily Ever After',
          displayName: 'Happily Ever After',
          attack: 1,
          defense: 1,
          rarity: 'Gold',
          fusionAbility: '',
          pictureKey: 'Happily Ever After',
          cardNum: '1',
          description: '',
          combinations: <String, String>{},
          isLte: false,
          seasonalTag: null,
        );
        expectWikiOnyxMaterialStatTable(
          materialBase: fairyTale,
          fusionPartnerStub: happilyEverAfter,
          wikiByMaterialLevel: const <({int attack, int defense})>[
            (attack: 6, defense: 7),
            (attack: 10, defense: 11),
            (attack: 14, defense: 15),
            (attack: 18, defense: 19),
            (attack: 22, defense: 23),
          ],
        );
      },
    );

    test(
      'материал Onyx: wiki Wealth 8/5…24/21 (Rare 6/3 + 2/2; как Hammer по уровням)',
      () {
        const AlchemyCard wealth = AlchemyCard(
          cardId: 'Wealth',
          displayName: 'Wealth',
          attack: 6,
          defense: 3,
          rarity: 'Rare',
          fusionAbility: 'Orb',
          pictureKey: 'Wealth',
          cardNum: '602',
          description: '',
          combinations: <String, String>{'Adventure': 'Mimic'},
          isLte: false,
          seasonalTag: null,
        );
        const AlchemyCard mimic = AlchemyCard(
          cardId: 'Mimic',
          displayName: 'Mimic',
          attack: 1,
          defense: 1,
          rarity: 'Rare',
          fusionAbility: '',
          pictureKey: 'Mimic',
          cardNum: '1',
          description: '',
          combinations: <String, String>{},
          isLte: false,
          seasonalTag: null,
        );
        expectWikiOnyxMaterialStatTable(
          materialBase: wealth,
          fusionPartnerStub: mimic,
          wikiByMaterialLevel: const <({int attack, int defense})>[
            (attack: 8, defense: 5),
            (attack: 12, defense: 9),
            (attack: 16, defense: 13),
            (attack: 20, defense: 17),
            (attack: 24, defense: 21),
          ],
        );
      },
    );

    test(
      'материал Onyx: wiki Human 6/5…22/21 (Uncommon 3/2 + 3/3)',
      () {
        const AlchemyCard human = AlchemyCard(
          cardId: 'Human',
          displayName: 'Human',
          attack: 3,
          defense: 2,
          rarity: 'Uncommon',
          fusionAbility: 'Orb',
          pictureKey: 'Human',
          cardNum: '85',
          description: '',
          combinations: <String, String>{'Adventure': 'The Party'},
          isLte: false,
          seasonalTag: null,
        );
        const AlchemyCard theParty = AlchemyCard(
          cardId: 'The Party',
          displayName: 'The Party',
          attack: 1,
          defense: 1,
          rarity: 'Gold',
          fusionAbility: '',
          pictureKey: 'The Party',
          cardNum: '1',
          description: '',
          combinations: <String, String>{},
          isLte: false,
          seasonalTag: null,
        );
        expectWikiOnyxMaterialStatTable(
          materialBase: human,
          fusionPartnerStub: theParty,
          wikiByMaterialLevel: kWikiHumanWolfOnyxLevels,
        );
      },
    );

    test(
      'материал Onyx: wiki Wolf 6/5…22/21 (Common 2/1 + 4/4)',
      () {
        const AlchemyCard wolf = AlchemyCard(
          cardId: 'Wolf',
          displayName: 'Wolf',
          attack: 2,
          defense: 1,
          rarity: 'Common',
          fusionAbility: 'Orb',
          pictureKey: 'Wolf',
          cardNum: '168',
          description: '',
          combinations: <String, String>{'Adventure': 'Familiar Companions'},
          isLte: false,
          seasonalTag: null,
        );
        const AlchemyCard familiarCompanions = AlchemyCard(
          cardId: 'Familiar Companions',
          displayName: 'Familiar Companions',
          attack: 1,
          defense: 1,
          rarity: 'Rare',
          fusionAbility: '',
          pictureKey: 'Familiar Companions',
          cardNum: '1',
          description: '',
          combinations: <String, String>{},
          isLte: false,
          seasonalTag: null,
        );
        expectWikiOnyxMaterialStatTable(
          materialBase: wolf,
          fusionPartnerStub: familiarCompanions,
          wikiByMaterialLevel: kWikiHumanWolfOnyxLevels,
        );
      },
    );
  });

  group('pack schedule occasions asset', () {
    test('bundled pack_schedule_occasions.json не пустой и согласован с shop_packs', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final String occRaw = await rootBundle.loadString(
        'assets/data/pack_schedule_occasions.json',
      );
      final String shopRaw = await rootBundle.loadString(
        'assets/data/shop_packs.json',
      );
      final Set<String> fromSchedule =
          ShopPackBundle.occasionAllowlistFromPackScheduleOccasionsJson(occRaw);
      final Set<String> fromShop =
          ShopPackBundle.uniqueOccasionDisplayNamesFromShopPacksJson(shopRaw);
      expect(fromSchedule.isNotEmpty, isTrue);
      expect(fromSchedule, fromShop);
    });

    test(
      'onyx_wiki_display_names.json парсится и содержит эталонные Onyx из вики',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final String wikiRaw = await rootBundle.loadString(
          'assets/data/onyx_wiki_display_names.json',
        );
        final Set<String> fromWiki =
            OnyxWikiAllowlist.displayNameSetFromBundledJson(wikiRaw);
        expect(fromWiki.length, greaterThanOrEqualTo(90));
        for (final String name in <String>[
          'Hammer',
          'Human',
          'Wolf',
          'Chinchilla',
        ]) {
          expect(fromWiki.contains(name), isTrue);
        }
      },
    );
  });

  group('ComboBattleStats', () {
    test('уровень результата: серебро vs золото', () {
      expect(
        ComboBattleStats.resultLevel(
          materialLevelA: 2,
          materialLevelB: 3,
          resultTier: ComboTier.silver,
        ),
        3,
      );
      expect(
        ComboBattleStats.resultLevel(
          materialLevelA: 2,
          materialLevelB: 3,
          resultTier: ComboTier.gold,
        ),
        4,
      );
    });

    test('масштаб статов по уровню', () {
      final ({int attack, int defense}) s = ComboBattleStats.scaledResultStats(
        resultBaseAttack: 10,
        resultBaseDefense: 5,
        resultLevel: 3,
        highestMaterialTier: ComboTier.silver,
      );
      expect(s.attack, 10 + 2 * 2);
      expect(s.defense, 5 + 2 * 2);
    });

    test('уровень 6 не добавляет A/D сверх уровня 5 (fusion)', () {
      final ({int attack, int defense}) at5 = ComboBattleStats.scaledResultStats(
        resultBaseAttack: 8,
        resultBaseDefense: 5,
        resultLevel: 5,
        highestMaterialTier: ComboTier.onyx,
      );
      final ({int attack, int defense}) at6 = ComboBattleStats.scaledResultStats(
        resultBaseAttack: 8,
        resultBaseDefense: 5,
        resultLevel: 6,
        highestMaterialTier: ComboTier.onyx,
      );
      expect(at5.attack, at6.attack);
      expect(at5.defense, at6.defense);
      expect(at5.attack, 8 + 4 * 4);
    });
  });

  group('Orb fusion filter (как Excel Power Query)', () {
    test('не-Orb не сохраняет исходящие Combinations', () {
      const String raw = '''
{
  "Bad": {
    "DisplayName": "Bad",
    "Attack": 1,
    "Defense": 1,
    "Rarity": "Common",
    "FusionAbility": "Critical",
    "Picture": "Bad",
    "CardNum": "1",
    "Description": "",
    "Combinations": { "Good": "Z" },
    "isLTE": false
  },
  "Good": {
    "DisplayName": "Good",
    "Attack": 1,
    "Defense": 1,
    "Rarity": "Common",
    "FusionAbility": "Orb",
    "Picture": "Good",
    "CardNum": "2",
    "Description": "",
    "Combinations": {},
    "isLTE": false
  },
  "Z": {
    "DisplayName": "Z",
    "Attack": 2,
    "Defense": 2,
    "Rarity": "Rare",
    "FusionAbility": "Critical",
    "Picture": "Z",
    "CardNum": "3",
    "Description": "",
    "Combinations": {},
    "isLTE": false
  }
}
''';
      final CardCatalogParser parser = const CardCatalogParser();
      final Map<String, AlchemyCard> cat = parser.parseJsonString(raw);
      expect(cat['Bad']!.combinations, isEmpty);
      expect(cat['Good']!.combinations, isEmpty);
    });
  });

  group('Собранный каталог vs таблица CMB Excel', () {
    test('8824 уникальных пар Orb+Orb (без синтетического оникса)', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final String alchemyRaw = await rootBundle.loadString(
        'assets/AlchemyCardData.json',
      );
      final String excelTsv = await rootBundle.loadString(
        'assets/data_from_exel.txt',
      );
      final Object? alchemyDecoded = jsonDecode(alchemyRaw);
      if (alchemyDecoded is! Map) {
        fail('AlchemyCardData.json');
      }
      final Map<String, Object?> root = jsonMapToStringKeyed(alchemyDecoded);
      final Map<String, Object?> excelRoot = ExcelComboBaseBuilder.buildRootMap(
        excelTsv,
      );
      mergeExcelSupplementIntoRoot(root, excelRoot);
      final String comboRaw = await rootBundle.loadString(
        'assets/CombinationPatch.json',
      );
      final String trimmedCombo = comboRaw.trim();
      if (trimmedCombo.isNotEmpty && trimmedCombo != '{}') {
        final Object? comboDecoded = jsonDecode(comboRaw);
        if (comboDecoded is Map) {
          mergeCombinationPatchIntoRoot(
            root,
            jsonMapToStringKeyed(comboDecoded),
          );
        }
      }
      final CardCatalogParser parser = const CardCatalogParser();
      final Map<String, AlchemyCard> cat = parser.parseJsonString(
        jsonEncode(root),
        combinationPatchJson: '',
      );
      // Unique Orb+Orb pairs: A->B and B->A edges are one pair; self-loop A->A (54 in CMB
      // Excel when CC_A==CC_B) contributes one pair and +1 to outgoing sum, not +2, so
      // pair count cannot be computed as (sum of edges) / 2.
      final Set<String> uniquePairKeys = <String>{};
      for (final MapEntry<String, AlchemyCard> e in cat.entries) {
        final String a = e.key;
        for (final String b in e.value.combinations.keys) {
          final int cmp = a.compareTo(b);
          final String key = cmp <= 0 ? '$a|$b' : '$b|$a';
          uniquePairKeys.add(key);
        }
      }
      expect(
        uniquePairKeys.length,
        8824,
        reason:
            'Должно совпадать с числом строк CMB в Excel (LA_v5-11) после Orb-фильтра',
      );
    });
  });
}
