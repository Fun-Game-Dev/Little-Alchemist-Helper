// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Little Alchemist Helper';

  @override
  String startupError(Object error) {
    return 'Ошибка запуска: $error';
  }

  @override
  String get tabDeck => 'Колода';

  @override
  String get tabCollection => 'Коллекция';

  @override
  String get tabCombo => 'Комбо';

  @override
  String get tabImport => 'Файлы';

  @override
  String get tabSettings => 'Настройки';

  @override
  String get actionCancel => 'Отмена';

  @override
  String get actionDelete => 'Удалить';

  @override
  String get actionSave => 'Сохранить';

  @override
  String get actionClear => 'Очистить';

  @override
  String get actionDone => 'Готово';

  @override
  String get labelSort => 'Сортировка';

  @override
  String get labelCollection => 'Коллекция';

  @override
  String get labelAll => 'Все';

  @override
  String get presenceInCollection => 'В коллекции';

  @override
  String get presenceNotInCollection => 'Нет в коллекции';

  @override
  String get sortByName => 'По имени';

  @override
  String get sortByRarity => 'По редкости';

  @override
  String get sortByPower => 'По силе';

  @override
  String get tierBronze => 'Бронза';

  @override
  String get tierSilver => 'Серебро';

  @override
  String get tierGold => 'Золото';

  @override
  String get tierDiamond => 'Алмаз';

  @override
  String get tierOnyx => 'Оникс';

  @override
  String get levelFused => 'Fusion';

  @override
  String levelShort(Object level) {
    return 'Ур. $level';
  }

  @override
  String get rarityUnknown => '-';

  @override
  String get deckActive => 'Активная колода';

  @override
  String get deckProfile => 'Профиль';

  @override
  String get deckNew => 'Новая колода';

  @override
  String get deckDeleteThis => 'Удалить эту колоду';

  @override
  String get deckDeleteConfirmTitle => 'Удалить колоду?';

  @override
  String deckDeleteConfirmBody(Object name) {
    return '\"$name\" будет удалена.';
  }

  @override
  String get deckOptimizeButton => 'Собрать лучший набор';

  @override
  String get deckEditSettings => 'Настройки и автозаполнение';

  @override
  String get saveFailedGeneric => 'Не удалось сохранить изменения.';

  @override
  String get settingsMedia => 'Медиа';

  @override
  String get settingsLoadWikiImages => 'Загружать картинки с вики';

  @override
  String get settingsLoadWikiImagesSubtitle => 'Использовать изображения карт из Little Alchemist Wiki. По умолчанию выключено.';

  @override
  String get settingsWikiThanksTitle => 'Благодарности';

  @override
  String get settingsWikiThanksSubtitle => 'Изображения карт предоставлены сообществом сайта Little Alchemist Wiki.';

  @override
  String get settingsWikiOpenSite => 'Открыть Little Alchemist Wiki';

  @override
  String get settingsWikiOpenFailed => 'Не удалось открыть сайт вики.';

  @override
  String get settingsCatalogStatsTitle => 'Статистика каталога по редкости';

  @override
  String settingsCatalogStatsTotal(Object count) {
    return 'Всего карт: $count';
  }

  @override
  String get settingsAppInfoTitle => 'О приложении';

  @override
  String settingsAppVersion(Object version) {
    return 'Версия: $version';
  }

  @override
  String settingsAppBuild(Object build) {
    return 'Билд: $build';
  }

  @override
  String collectionDeleteOneFromGroup(Object name, Object count) {
    return 'Удалить одну \"$name\"? В группе $count дубликатов.';
  }

  @override
  String collectionDeleteOne(Object name) {
    return 'Удалить \"$name\" из коллекции?';
  }

  @override
  String get collectionDeleteTitle => 'Удалить из коллекции';

  @override
  String collectionLimitWarning(Object limit, Object names) {
    return 'У вас больше $limit карт с одним названием: $names. Такой набор нельзя использовать в колоде.';
  }

  @override
  String get collectionAddOne => 'Одна карта';

  @override
  String get collectionAddMany => 'Массовое добавление';

  @override
  String get collectionCollapseDuplicates => 'Сгруппировать дубликаты';

  @override
  String collectionHint(Object limit) {
    return 'Каждая строка - одна карта. Для изменения удалите и добавьте снова. Лимит колоды: до $limit карт с одним названием.';
  }

  @override
  String collectionStats(Object kinds, Object copies) {
    return '$kinds видов - $copies копий';
  }

  @override
  String get collectionEmpty => 'Коллекция пуста. Добавьте карты кнопками выше.';

  @override
  String collectionDuplicatesCount(Object count) {
    return 'x$count дубликатов';
  }

  @override
  String get collectionDeleteOneTooltip => 'Удалить одну';

  @override
  String get collectionAddToCollection => 'Добавить в коллекцию';

  @override
  String get deckNameRequired => 'Введите название колоды.';

  @override
  String get deckName => 'Название колоды';

  @override
  String get deckSeedCard => 'Стартовая карта';

  @override
  String get deckNotSelected => 'Не выбрано';

  @override
  String get deckSeedHint => 'Выберите карту из коллекции. Она будет первой.';

  @override
  String deckLevel(Object level) {
    return 'Уровень: $level';
  }

  @override
  String get deckSelectCard => 'Выбрать карту';

  @override
  String get deckPickSeed => 'Стартовая карта';

  @override
  String get deckFillType => 'Режим заполнения';

  @override
  String get deckFillHint => 'После стартовой карты остальные добавляются по одной.';

  @override
  String deckSize(Object size) {
    return 'Размер колоды: $size';
  }

  @override
  String deckMaxNonFusion(Object count) {
    return 'Макс. карт без Fusion: $count';
  }

  @override
  String get deckRarityRules => 'Правила редкости';

  @override
  String deckMinComboTier(Object tier) {
    return 'Мин. редкость учитываемых комбинаций: $tier';
  }

  @override
  String get deckRarityRulesHint => 'Задайте минимальный уровень для каждой редкости.';

  @override
  String deckMinLevel(Object level) {
    return 'Мин. уровень: $level';
  }

  @override
  String get deckNoSeedCandidates => 'В коллекции нет подходящих стартовых карт.';

  @override
  String get deckPickSeedTitle => 'Выберите стартовую карту из коллекции';

  @override
  String get comboLabIntro => 'Выберите две карты и уровни. Отсутствие результата Fusion для пары может быть нормальным.';

  @override
  String get comboCardA => 'Карта A';

  @override
  String get comboCardB => 'Карта B';

  @override
  String get comboChange => 'Изменить';

  @override
  String get comboPickA => 'Выбрать карту A';

  @override
  String get comboPickB => 'Выбрать карту B';

  @override
  String get comboResult => 'Результат Fusion';

  @override
  String get comboPickBoth => 'Выберите обе карты.';

  @override
  String comboNoRecipe(Object a, Object b) {
    return 'Нет рецепта Fusion для \"$a\" + \"$b\".';
  }

  @override
  String comboBattleLevel(Object level) {
    return 'Боевой ур. $level';
  }

  @override
  String comboBaseStats(Object attack, Object defense) {
    return 'Базовые статы: $attack / $defense';
  }

  @override
  String get comboMaterialsDoubleOnyx => 'Материалы: два оникса.';

  @override
  String get comboMaterialsMixed => 'Материалы: один оникс и одна карта ниже по редкости.';

  @override
  String get importDataTitle => 'Файлы';

  @override
  String get importDataOrder => 'Порядок сборки каталога:\n1) встроенный AlchemyCardData.json\n2) дополнение assets/data_from_exel.txt\n3) встроенный CombinationPatch.json\n4) опциональный пользовательский JSON-патч (только добавление).';

  @override
  String get importPickPatch => 'Выбрать пользовательский JSON-патч';

  @override
  String get importResetPatch => 'Сбросить только пользовательский патч';

  @override
  String get importClearCollectionQuestion => 'Очистить коллекцию?';

  @override
  String get importClearCollection => 'Очистить коллекцию комбо-карт';

  @override
  String get importLastMessage => 'Последнее сообщение';

  @override
  String get catalogNoCards => 'Нет карт';

  @override
  String get catalogPickCard => 'Выбрать карту';

  @override
  String catalogInstanceLevel(Object level) {
    return 'Уровень экземпляра: $level';
  }

  @override
  String get catalogLevelWillBeSaved => 'Этот уровень будет использован при следующем добавлении.';

  @override
  String catalogFrameRarity(Object tier, Object rarity) {
    return 'Редкость рамки: $tier ($rarity).';
  }

  @override
  String get catalogSearchHint => 'Поиск в каталоге';

  @override
  String get catalogRarityFilterTitle => 'Фильтр редкости данных';

  @override
  String catalogBulkIntro(Object kinds) {
    return 'Карты из каталога будут добавлены по фильтрам (сейчас $kinds видов).';
  }

  @override
  String catalogAllowOverLimit(Object limit) {
    return 'Разрешить превышение лимита ($limit на название в колоде)';
  }

  @override
  String get catalogOverLimitHint => 'Если выключено, лишние копии по названию будут пропущены.';

  @override
  String get catalogCopiesPerCard => 'Копий на карту';

  @override
  String catalogAllNewLevel(Object level) {
    return 'Уровень для всех новых карт: $level';
  }

  @override
  String get catalogLimitNotApplied => 'Лимит названий не применяется.';

  @override
  String catalogLimitAppliedHint(Object limit) {
    return 'При лимите $limit на название часть копий может быть пропущена.';
  }

  @override
  String get catalogBulkAddTitle => 'Массовое добавление';

  @override
  String catalogBulkAddConfirm(Object total, Object kinds, Object copies, Object level, Object limitLine) {
    return 'Добавить до $total карт ($kinds x $copies), уровень $level.\n\n$limitLine';
  }

  @override
  String catalogAddAll(Object kinds) {
    return 'Добавить все ($kinds видов)';
  }

  @override
  String get importReplaceCollectionTitle => 'Заменить текущую коллекцию?';

  @override
  String get importReplaceCollectionBody => 'Текущая коллекция не пуста. При импорте текущие данные будут удалены и заменены содержимым файла.';

  @override
  String get importReplaceCollectionConfirm => 'Заменить';

  @override
  String get importNotFoundTitle => 'Карты не найдены';

  @override
  String importNotFoundBody(Object names) {
    return 'Эти карты отсутствуют в каталоге и не были импортированы:\n\n$names';
  }

  @override
  String get importShareZip => 'Поделиться ZIP с новыми скачанными картинками';

  @override
  String get importUserCollectionTitle => 'Коллекция пользователя';

  @override
  String get importSimpleFormatHint => 'Простой формат файла: одна карта на строку -> карта:уровень';

  @override
  String get importShareCollectionTxt => 'Поделиться коллекцией (TXT)';

  @override
  String get importLoadCollectionTxt => 'Импорт коллекции из TXT';

  @override
  String get importDeckSettingsTitle => 'Настройки колод';

  @override
  String get importDeckSettingsHint => 'Экспорт/импорт только параметров автосборки колод. Невалидные записи при импорте пропускаются.';

  @override
  String get importExportDeckSettings => 'Экспорт настроек колод (JSON)';

  @override
  String get importLoadDeckSettings => 'Импорт настроек колод (JSON)';

  @override
  String get importDeckSettingsExportAll => 'Экспортировать все колоды';

  @override
  String importDeckSettingsExportOne(Object name) {
    return 'Экспортировать \"$name\"';
  }

  @override
  String get settingsDecksTitle => 'Колоды';

  @override
  String get settingsDecksHint => 'Управляйте профилями колод и параметрами автосборки в Колода -> Настройки и автозаполнение.';

  @override
  String get settingsComboCatalogTitle => 'Каталог комбинаций';

  @override
  String get settingsSyntheticOnyxTitle => 'Синтетические результаты Fusion (оникс)';

  @override
  String get settingsSyntheticOnyxSubtitle => 'Добавляет оникс-копии с усиленными А/З и дополнительные строки результатов для двух оникс-материалов.';

  @override
  String get settingsFilesTitle => 'Файлы';

  @override
  String get settingsFilesHint => 'Импорт/экспорт данных, патчей и сервисных файлов приложения.';

  @override
  String get settingsOpenFilesScreen => 'Открыть экран файлов';

  @override
  String get settingsCatalogStatsByAbilityTitle => 'Разбивка по абилке и редкости';

  @override
  String get settingsCatalogStatsNoAbility => 'Без абилки';

  @override
  String get deckFocusAttack => 'Атака';

  @override
  String get deckFocusDefense => 'Защита';

  @override
  String get deckFocusSumStats => 'Сумма статов';

  @override
  String deckStatusSummary(Object focus, Object size, Object seed) {
    return '$focus · размер $size · старт: $seed';
  }

  @override
  String get deckSeedNone => 'не выбрано';

  @override
  String get deckNeedAtLeastOneCard => 'Добавьте хотя бы одну комбо-карту в коллекцию.';

  @override
  String deckNotEnoughCardsForSize(Object size) {
    return 'В коллекции меньше карт, чем размер колоды ($size).';
  }

  @override
  String get deckTapBuildHint => 'Нажмите кнопку выше, чтобы собрать колоду.';

  @override
  String get deckHeuristicApprox => 'Использована быстрая эвристика; результат приблизительный.';

  @override
  String deckPoolTruncated(Object count) {
    return 'Использованы топ-$count карт по одиночной оценке (лимит пула).';
  }

  @override
  String deckScoreSummary(Object total, Object attack, Object defense, Object combo) {
    return 'Счёт: $total (атака $attack · защита $defense · комбо $combo)';
  }

  @override
  String deckDefaultName(Object index) {
    return 'Колода $index';
  }

  @override
  String deckComboVsStatsBalance(Object value) {
    return 'Баланс статов/комбо: $value';
  }

  @override
  String get deckComboVsStatsBalanceHint => '0 - только выбранные статы, 1 - только количество комбинаций';

  @override
  String deckComboVsHandBalance(Object value) {
    return 'Баланс комбо / случайная рука: $value';
  }

  @override
  String get deckComboVsHandBalanceHint => '0 — только пары и комбо (статы/комбо выше), 1 — только ожидаемая сила случайной руки из 5 карт по тиру';

  @override
  String comboResultId(Object id) {
    return 'id $id';
  }

  @override
  String comboPreviewStatsFromSheet(Object attack, Object defense) {
    return 'A/D из fusion_onyx_stats: $attack / $defense';
  }

  @override
  String comboPreviewStatsEstimated(Object attack, Object defense) {
    return 'Оценочные A/D: $attack / $defense';
  }

  @override
  String get loadSaveDecksStorageFailed => 'Не удалось сохранить колоды в хранилище. Настройки колод могут быть потеряны после перезапуска.';

  @override
  String loadCatalogLoaded(Object count) {
    return 'Каталог загружен: AlchemyCardData + Excel + патчи ($count карт)';
  }

  @override
  String loadCatalogError(Object error) {
    return 'Ошибка загрузки каталога: $error';
  }

  @override
  String loadOpenFilePickerFailed(Object error) {
    return 'Не удалось открыть выбор файла: $error';
  }

  @override
  String get loadImportPatchCancelled => 'Импорт патча отменен: файл не выбран.';

  @override
  String get loadCouldNotReadFile => 'Не удалось прочитать файл.';

  @override
  String loadFileInvalidJson(Object error) {
    return 'Файл не является валидным JSON: $error';
  }

  @override
  String loadPatchSavedCatalogRebuilt(Object count) {
    return 'Патч сохранен; каталог пересобран ($count карт)';
  }

  @override
  String loadPatchAppliedSessionOnly(Object count) {
    return 'Патч применен для текущей сессии ($count карт), путь не сохранен';
  }

  @override
  String loadUserPatchReset(Object count) {
    return 'Пользовательский патч сброшен; каталог ($count карт)';
  }

  @override
  String get loadNoStoragePermission => 'Нет разрешения на сохранение файлов. Разрешите доступ к хранилищу в настройках приложения.';

  @override
  String get loadNoImageDataForExport => 'Нет данных об изображениях для экспорта.';

  @override
  String get loadNoNewDownloadedFilesForExport => 'Нет новых скачанных файлов для экспорта (изображения из assets/images не включаются).';

  @override
  String get loadShareSheetOpenedSaveToFiles => 'Открыт системный экран Поделиться. Выберите Сохранить в Файлы и папку назначения.';

  @override
  String loadExportedImagesZip(Object count, Object path) {
    return 'Экспортировано изображений: $count\nZIP: $path';
  }

  @override
  String loadZipSavedToAppFiles(Object path) {
    return 'Системный диалог сохранения недоступен. ZIP сохранен в файлы приложения:\n$path';
  }

  @override
  String loadZipExportError(Object error) {
    return 'Ошибка экспорта ZIP: $error';
  }

  @override
  String get loadCollectionEmptyNothingToExport => 'Коллекция пуста, экспортировать нечего.';

  @override
  String get loadNoValidCardsForExport => 'Не найдено валидных карт для экспорта.';

  @override
  String loadExportedCards(Object count, Object path) {
    return 'Экспортировано карт: $count\nФайл: $path';
  }

  @override
  String loadCollectionFileSavedToAppFiles(Object path) {
    return 'Системный диалог сохранения недоступен. Файл коллекции сохранен в файлы приложения:\n$path';
  }

  @override
  String loadCollectionExportError(Object error) {
    return 'Ошибка экспорта коллекции: $error';
  }

  @override
  String get loadImportCollectionCancelled => 'Импорт коллекции отменен: файл не выбран.';

  @override
  String get loadCouldNotReadCollectionFile => 'Не удалось прочитать файл коллекции.';

  @override
  String loadImportCompleted(Object imported, Object skipped, Object notFound) {
    return 'Импорт завершен: $imported карт. Пропущено строк: $skipped. Не найдено карт: $notFound.';
  }

  @override
  String get loadCouldNotSaveDecks => 'Не удалось сохранить колоды.';

  @override
  String get loadDeckSettingsExportFailedNoDeck => 'Выберите колоду для экспорта.';

  @override
  String get loadDeckSettingsExportEmpty => 'Нет настроек колод для экспорта.';

  @override
  String loadDeckSettingsExported(Object count, Object path) {
    return 'Экспортировано настроек колод: $count\nФайл: $path';
  }

  @override
  String loadDeckSettingsSavedToAppFiles(Object path) {
    return 'Системный диалог сохранения недоступен. Файл настроек колод сохранен в файлы приложения:\n$path';
  }

  @override
  String loadDeckSettingsExportError(Object error) {
    return 'Ошибка экспорта настроек колод: $error';
  }

  @override
  String get loadImportDeckSettingsCancelled => 'Импорт настроек колод отменен: файл не выбран.';

  @override
  String get loadCouldNotReadDeckSettingsFile => 'Не удалось прочитать файл настроек колод.';

  @override
  String loadDeckSettingsInvalidJson(Object error) {
    return 'Файл настроек колод не является валидным JSON: $error';
  }

  @override
  String get loadDeckSettingsInvalidStructure => 'Файл настроек колод имеет неверную структуру.';

  @override
  String get loadDeckSettingsUnsupportedFormat => 'Неподдерживаемый формат файла настроек колод.';

  @override
  String loadDeckSettingsNothingImported(Object skipped) {
    return 'Не импортировано ни одной валидной настройки колоды. Пропущено записей: $skipped.';
  }

  @override
  String loadDeckSettingsImported(Object imported, Object skipped) {
    return 'Импортировано настроек колод: $imported. Пропущено невалидных записей: $skipped.';
  }

  @override
  String loadSyntheticOnyxEnabled(Object count) {
    return 'Каталог дополнен синтетическими Fusion-результатами оникса ($count карт)';
  }

  @override
  String loadSyntheticOnyxDisabled(Object count) {
    return 'Синтетические Fusion-результаты оникса отключены ($count карт)';
  }

  @override
  String get tabShopSeasons => 'Сезоны магазина';

  @override
  String shopPackScheduleLoadError(Object error) {
    return 'Не удалось загрузить расписание магазина: $error';
  }

  @override
  String get shopPackInStoreNow => 'Сейчас в магазине';

  @override
  String shopPackWindowDates(Object start, Object end) {
    return 'В магазине: $start – $end';
  }

  @override
  String get shopPackCardLevel => 'Уровень карт';

  @override
  String get shopPackCardsInPack => 'Карты в пакете';

  @override
  String get shopPackNoContents => 'Список карт для этого пакета пока не задан. Добавьте имена в shop_pack_contents.json.';

  @override
  String shopPackUnknownCard(Object name) {
    return 'Нет в каталоге: $name';
  }

  @override
  String get shopPackNoRotationScheduled => 'Нет слота в расписании ротации приложения';

  @override
  String shopPackWikiOpenFailed(Object url) {
    return 'Не удалось открыть вики: $url';
  }

  @override
  String get shopPackOtherCategory => 'Прочие пакеты (нет в ротации приложения)';

  @override
  String shopPackGoldCombo(Object card) {
    return 'Gold: $card';
  }

  @override
  String shopPackOnyxCombo(Object card) {
    return 'Onyx: $card';
  }

  @override
  String get eventsShopTitle => 'Магазин';

  @override
  String get eventsShopSubtitle => 'Пакеты в магазине';

  @override
  String get eventsArenaTitle => 'Арена';

  @override
  String get eventsArenaSubtitle => 'Магазин арены';

  @override
  String get eventsPortalTitle => 'Портал';

  @override
  String get eventsPortalSubtitle => 'Награды за портал';
}
