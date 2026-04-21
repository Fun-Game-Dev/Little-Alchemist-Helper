import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Little Alchemist Helper'**
  String get appTitle;

  /// No description provided for @startupError.
  ///
  /// In en, this message translates to:
  /// **'Startup error: {error}'**
  String startupError(Object error);

  /// No description provided for @tabDeck.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get tabDeck;

  /// No description provided for @tabCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get tabCollection;

  /// No description provided for @tabCombo.
  ///
  /// In en, this message translates to:
  /// **'Combo'**
  String get tabCombo;

  /// No description provided for @tabImport.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get tabImport;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @actionClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// No description provided for @actionDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// No description provided for @labelSort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get labelSort;

  /// No description provided for @labelCollection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get labelCollection;

  /// No description provided for @labelAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get labelAll;

  /// No description provided for @presenceInCollection.
  ///
  /// In en, this message translates to:
  /// **'In collection'**
  String get presenceInCollection;

  /// No description provided for @presenceNotInCollection.
  ///
  /// In en, this message translates to:
  /// **'Not in collection'**
  String get presenceNotInCollection;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortByRarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get sortByRarity;

  /// No description provided for @sortByPower.
  ///
  /// In en, this message translates to:
  /// **'Power'**
  String get sortByPower;

  /// No description provided for @tierBronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get tierBronze;

  /// No description provided for @tierSilver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get tierSilver;

  /// No description provided for @tierGold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get tierGold;

  /// No description provided for @tierDiamond.
  ///
  /// In en, this message translates to:
  /// **'Diamond'**
  String get tierDiamond;

  /// No description provided for @tierOnyx.
  ///
  /// In en, this message translates to:
  /// **'Onyx'**
  String get tierOnyx;

  /// No description provided for @levelFused.
  ///
  /// In en, this message translates to:
  /// **'Fusion'**
  String get levelFused;

  /// No description provided for @levelShort.
  ///
  /// In en, this message translates to:
  /// **'Lv. {level}'**
  String levelShort(Object level);

  /// No description provided for @rarityUnknown.
  ///
  /// In en, this message translates to:
  /// **'-'**
  String get rarityUnknown;

  /// No description provided for @deckActive.
  ///
  /// In en, this message translates to:
  /// **'Active deck'**
  String get deckActive;

  /// No description provided for @deckProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get deckProfile;

  /// No description provided for @deckNew.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get deckNew;

  /// No description provided for @deckDeleteThis.
  ///
  /// In en, this message translates to:
  /// **'Delete this deck'**
  String get deckDeleteThis;

  /// No description provided for @deckDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete deck?'**
  String get deckDeleteConfirmTitle;

  /// No description provided for @deckDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will be deleted.'**
  String deckDeleteConfirmBody(Object name);

  /// No description provided for @deckOptimizeButton.
  ///
  /// In en, this message translates to:
  /// **'Build best combo set'**
  String get deckOptimizeButton;

  /// No description provided for @deckEditSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings and auto-fill'**
  String get deckEditSettings;

  /// No description provided for @saveFailedGeneric.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes.'**
  String get saveFailedGeneric;

  /// No description provided for @settingsMedia.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get settingsMedia;

  /// No description provided for @settingsLoadWikiImages.
  ///
  /// In en, this message translates to:
  /// **'Load wiki images'**
  String get settingsLoadWikiImages;

  /// No description provided for @settingsLoadWikiImagesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use Little Alchemist Wiki images for cards. Disabled by default.'**
  String get settingsLoadWikiImagesSubtitle;

  /// No description provided for @settingsWikiThanksTitle.
  ///
  /// In en, this message translates to:
  /// **'Thanks'**
  String get settingsWikiThanksTitle;

  /// No description provided for @settingsWikiThanksSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Card images are provided by the Little Alchemist Wiki community.'**
  String get settingsWikiThanksSubtitle;

  /// No description provided for @settingsWikiOpenSite.
  ///
  /// In en, this message translates to:
  /// **'Open Little Alchemist Wiki'**
  String get settingsWikiOpenSite;

  /// No description provided for @settingsWikiOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open the wiki site.'**
  String get settingsWikiOpenFailed;

  /// No description provided for @settingsCatalogStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Catalog stats by rarity'**
  String get settingsCatalogStatsTitle;

  /// No description provided for @settingsCatalogStatsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total cards: {count}'**
  String settingsCatalogStatsTotal(Object count);

  /// No description provided for @settingsAppInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'About app'**
  String get settingsAppInfoTitle;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Version: {version}'**
  String settingsAppVersion(Object version);

  /// No description provided for @settingsAppBuild.
  ///
  /// In en, this message translates to:
  /// **'Build: {build}'**
  String settingsAppBuild(Object build);

  /// No description provided for @collectionDeleteOneFromGroup.
  ///
  /// In en, this message translates to:
  /// **'Delete one \"{name}\"? Group has {count} duplicates.'**
  String collectionDeleteOneFromGroup(Object name, Object count);

  /// No description provided for @collectionDeleteOne.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\" from collection?'**
  String collectionDeleteOne(Object name);

  /// No description provided for @collectionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from collection'**
  String get collectionDeleteTitle;

  /// No description provided for @collectionLimitWarning.
  ///
  /// In en, this message translates to:
  /// **'You have more than {limit} cards with one name: {names}. This set is not allowed in a deck.'**
  String collectionLimitWarning(Object limit, Object names);

  /// No description provided for @collectionAddOne.
  ///
  /// In en, this message translates to:
  /// **'One card'**
  String get collectionAddOne;

  /// No description provided for @collectionAddMany.
  ///
  /// In en, this message translates to:
  /// **'Bulk add'**
  String get collectionAddMany;

  /// No description provided for @collectionCollapseDuplicates.
  ///
  /// In en, this message translates to:
  /// **'Group duplicates'**
  String get collectionCollapseDuplicates;

  /// No description provided for @collectionHint.
  ///
  /// In en, this message translates to:
  /// **'Each row is one card. To edit, remove and add again. Deck limit: up to {limit} cards with one name.'**
  String collectionHint(Object limit);

  /// No description provided for @collectionStats.
  ///
  /// In en, this message translates to:
  /// **'{kinds} kinds - {copies} copies'**
  String collectionStats(Object kinds, Object copies);

  /// No description provided for @collectionEmpty.
  ///
  /// In en, this message translates to:
  /// **'Collection is empty. Add cards with buttons above.'**
  String get collectionEmpty;

  /// No description provided for @collectionDuplicatesCount.
  ///
  /// In en, this message translates to:
  /// **'x{count} duplicates'**
  String collectionDuplicatesCount(Object count);

  /// No description provided for @collectionDeleteOneTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete one'**
  String get collectionDeleteOneTooltip;

  /// No description provided for @collectionAddToCollection.
  ///
  /// In en, this message translates to:
  /// **'Add to collection'**
  String get collectionAddToCollection;

  /// No description provided for @deckNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter deck name.'**
  String get deckNameRequired;

  /// No description provided for @deckName.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deckName;

  /// No description provided for @deckSeedCard.
  ///
  /// In en, this message translates to:
  /// **'Seed card'**
  String get deckSeedCard;

  /// No description provided for @deckNotSelected.
  ///
  /// In en, this message translates to:
  /// **'Not selected'**
  String get deckNotSelected;

  /// No description provided for @deckSeedHint.
  ///
  /// In en, this message translates to:
  /// **'Pick a card from collection. It will be first.'**
  String get deckSeedHint;

  /// No description provided for @deckLevel.
  ///
  /// In en, this message translates to:
  /// **'Level: {level}'**
  String deckLevel(Object level);

  /// No description provided for @deckSelectCard.
  ///
  /// In en, this message translates to:
  /// **'Pick card'**
  String get deckSelectCard;

  /// No description provided for @deckPickSeed.
  ///
  /// In en, this message translates to:
  /// **'Seed card'**
  String get deckPickSeed;

  /// No description provided for @deckFillType.
  ///
  /// In en, this message translates to:
  /// **'Fill mode'**
  String get deckFillType;

  /// No description provided for @deckFillHint.
  ///
  /// In en, this message translates to:
  /// **'After seed card, cards are added one by one.'**
  String get deckFillHint;

  /// No description provided for @deckSize.
  ///
  /// In en, this message translates to:
  /// **'Deck size: {size}'**
  String deckSize(Object size);

  /// No description provided for @deckMaxNonFusion.
  ///
  /// In en, this message translates to:
  /// **'Max non-Fusion cards: {count}'**
  String deckMaxNonFusion(Object count);

  /// No description provided for @deckRarityRules.
  ///
  /// In en, this message translates to:
  /// **'Rarity rules'**
  String get deckRarityRules;

  /// No description provided for @deckMinComboTier.
  ///
  /// In en, this message translates to:
  /// **'Min combo rarity considered: {tier}'**
  String deckMinComboTier(Object tier);

  /// No description provided for @deckRarityRulesHint.
  ///
  /// In en, this message translates to:
  /// **'Set minimum level for each rarity.'**
  String get deckRarityRulesHint;

  /// No description provided for @deckMinLevel.
  ///
  /// In en, this message translates to:
  /// **'Min level: {level}'**
  String deckMinLevel(Object level);

  /// No description provided for @deckNoSeedCandidates.
  ///
  /// In en, this message translates to:
  /// **'No suitable seed cards in collection.'**
  String get deckNoSeedCandidates;

  /// No description provided for @deckPickSeedTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick seed card from collection'**
  String get deckPickSeedTitle;

  /// No description provided for @comboLabIntro.
  ///
  /// In en, this message translates to:
  /// **'Pick two cards and levels. Missing Fusion result for a pair can be normal.'**
  String get comboLabIntro;

  /// No description provided for @comboCardA.
  ///
  /// In en, this message translates to:
  /// **'Card A'**
  String get comboCardA;

  /// No description provided for @comboCardB.
  ///
  /// In en, this message translates to:
  /// **'Card B'**
  String get comboCardB;

  /// No description provided for @comboChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get comboChange;

  /// No description provided for @comboPickA.
  ///
  /// In en, this message translates to:
  /// **'Pick card A'**
  String get comboPickA;

  /// No description provided for @comboPickB.
  ///
  /// In en, this message translates to:
  /// **'Pick card B'**
  String get comboPickB;

  /// No description provided for @comboResult.
  ///
  /// In en, this message translates to:
  /// **'Fusion result'**
  String get comboResult;

  /// No description provided for @comboPickBoth.
  ///
  /// In en, this message translates to:
  /// **'Pick both cards.'**
  String get comboPickBoth;

  /// No description provided for @comboNoRecipe.
  ///
  /// In en, this message translates to:
  /// **'No Fusion recipe for \"{a}\" + \"{b}\".'**
  String comboNoRecipe(Object a, Object b);

  /// No description provided for @comboBattleLevel.
  ///
  /// In en, this message translates to:
  /// **'Battle Lv. {level}'**
  String comboBattleLevel(Object level);

  /// No description provided for @comboBaseStats.
  ///
  /// In en, this message translates to:
  /// **'Base stats: {attack} / {defense}'**
  String comboBaseStats(Object attack, Object defense);

  /// No description provided for @comboMaterialsDoubleOnyx.
  ///
  /// In en, this message translates to:
  /// **'Materials: two onyx tiers.'**
  String get comboMaterialsDoubleOnyx;

  /// No description provided for @comboMaterialsMixed.
  ///
  /// In en, this message translates to:
  /// **'Materials: one onyx and one lower tier.'**
  String get comboMaterialsMixed;

  /// No description provided for @importDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get importDataTitle;

  /// No description provided for @importDataOrder.
  ///
  /// In en, this message translates to:
  /// **'Catalog build order:\n1) built-in AlchemyCardData.json\n2) assets/data_from_exel.txt supplement\n3) built-in CombinationPatch.json\n4) optional user JSON patch (additive only).'**
  String get importDataOrder;

  /// No description provided for @importPickPatch.
  ///
  /// In en, this message translates to:
  /// **'Pick user JSON patch'**
  String get importPickPatch;

  /// No description provided for @importResetPatch.
  ///
  /// In en, this message translates to:
  /// **'Reset user patch only'**
  String get importResetPatch;

  /// No description provided for @importClearCollectionQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear collection?'**
  String get importClearCollectionQuestion;

  /// No description provided for @importClearCollection.
  ///
  /// In en, this message translates to:
  /// **'Clear combo-card collection'**
  String get importClearCollection;

  /// No description provided for @importLastMessage.
  ///
  /// In en, this message translates to:
  /// **'Last message'**
  String get importLastMessage;

  /// No description provided for @catalogNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards'**
  String get catalogNoCards;

  /// No description provided for @catalogPickCard.
  ///
  /// In en, this message translates to:
  /// **'Pick card'**
  String get catalogPickCard;

  /// No description provided for @catalogInstanceLevel.
  ///
  /// In en, this message translates to:
  /// **'Instance level: {level}'**
  String catalogInstanceLevel(Object level);

  /// No description provided for @catalogLevelWillBeSaved.
  ///
  /// In en, this message translates to:
  /// **'Level will be used for next add.'**
  String get catalogLevelWillBeSaved;

  /// No description provided for @catalogFrameRarity.
  ///
  /// In en, this message translates to:
  /// **'Frame rarity: {tier} ({rarity}).'**
  String catalogFrameRarity(Object tier, Object rarity);

  /// No description provided for @catalogSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search in catalog'**
  String get catalogSearchHint;

  /// No description provided for @catalogRarityFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Data rarity filter'**
  String get catalogRarityFilterTitle;

  /// No description provided for @catalogBulkIntro.
  ///
  /// In en, this message translates to:
  /// **'Cards from catalog will be added by filters (now {kinds} kinds).'**
  String catalogBulkIntro(Object kinds);

  /// No description provided for @catalogAllowOverLimit.
  ///
  /// In en, this message translates to:
  /// **'Allow over limit ({limit} per deck name)'**
  String catalogAllowOverLimit(Object limit);

  /// No description provided for @catalogOverLimitHint.
  ///
  /// In en, this message translates to:
  /// **'If off, extra copies by name are skipped.'**
  String get catalogOverLimitHint;

  /// No description provided for @catalogCopiesPerCard.
  ///
  /// In en, this message translates to:
  /// **'Copies per card'**
  String get catalogCopiesPerCard;

  /// No description provided for @catalogAllNewLevel.
  ///
  /// In en, this message translates to:
  /// **'Level for all new cards: {level}'**
  String catalogAllNewLevel(Object level);

  /// No description provided for @catalogLimitNotApplied.
  ///
  /// In en, this message translates to:
  /// **'Name limit is not applied.'**
  String get catalogLimitNotApplied;

  /// No description provided for @catalogLimitAppliedHint.
  ///
  /// In en, this message translates to:
  /// **'With limit {limit} per name, some copies may be skipped.'**
  String catalogLimitAppliedHint(Object limit);

  /// No description provided for @catalogBulkAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Bulk add'**
  String get catalogBulkAddTitle;

  /// No description provided for @catalogBulkAddConfirm.
  ///
  /// In en, this message translates to:
  /// **'Add up to {total} cards ({kinds} x {copies}), level {level}.\n\n{limitLine}'**
  String catalogBulkAddConfirm(Object total, Object kinds, Object copies, Object level, Object limitLine);

  /// No description provided for @catalogAddAll.
  ///
  /// In en, this message translates to:
  /// **'Add all ({kinds} kinds)'**
  String catalogAddAll(Object kinds);

  /// No description provided for @importReplaceCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace current collection?'**
  String get importReplaceCollectionTitle;

  /// No description provided for @importReplaceCollectionBody.
  ///
  /// In en, this message translates to:
  /// **'Current collection is not empty. Import will delete current data and replace it with file contents.'**
  String get importReplaceCollectionBody;

  /// No description provided for @importReplaceCollectionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get importReplaceCollectionConfirm;

  /// No description provided for @importNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Cards not found'**
  String get importNotFoundTitle;

  /// No description provided for @importNotFoundBody.
  ///
  /// In en, this message translates to:
  /// **'These cards are missing in catalog and were not imported:\n\n{names}'**
  String importNotFoundBody(Object names);

  /// No description provided for @importShareZip.
  ///
  /// In en, this message translates to:
  /// **'Share ZIP with newly downloaded images'**
  String get importShareZip;

  /// No description provided for @importUserCollectionTitle.
  ///
  /// In en, this message translates to:
  /// **'User collection'**
  String get importUserCollectionTitle;

  /// No description provided for @importSimpleFormatHint.
  ///
  /// In en, this message translates to:
  /// **'Simple file format: one card per line -> card:level'**
  String get importSimpleFormatHint;

  /// No description provided for @importShareCollectionTxt.
  ///
  /// In en, this message translates to:
  /// **'Share collection (TXT)'**
  String get importShareCollectionTxt;

  /// No description provided for @importLoadCollectionTxt.
  ///
  /// In en, this message translates to:
  /// **'Import collection from TXT'**
  String get importLoadCollectionTxt;

  /// No description provided for @importDeckSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck settings'**
  String get importDeckSettingsTitle;

  /// No description provided for @importDeckSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Export/import only deck auto-build settings. Invalid deck entries are skipped during import.'**
  String get importDeckSettingsHint;

  /// No description provided for @importExportDeckSettings.
  ///
  /// In en, this message translates to:
  /// **'Export deck settings (JSON)'**
  String get importExportDeckSettings;

  /// No description provided for @importLoadDeckSettings.
  ///
  /// In en, this message translates to:
  /// **'Import deck settings (JSON)'**
  String get importLoadDeckSettings;

  /// No description provided for @importDeckSettingsExportAll.
  ///
  /// In en, this message translates to:
  /// **'Export all decks'**
  String get importDeckSettingsExportAll;

  /// No description provided for @importDeckSettingsExportOne.
  ///
  /// In en, this message translates to:
  /// **'Export \"{name}\"'**
  String importDeckSettingsExportOne(Object name);

  /// No description provided for @settingsDecksTitle.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get settingsDecksTitle;

  /// No description provided for @settingsDecksHint.
  ///
  /// In en, this message translates to:
  /// **'Manage deck profiles and auto-build parameters in Deck -> Settings and auto-fill.'**
  String get settingsDecksHint;

  /// No description provided for @settingsComboCatalogTitle.
  ///
  /// In en, this message translates to:
  /// **'Combo catalog'**
  String get settingsComboCatalogTitle;

  /// No description provided for @settingsSyntheticOnyxTitle.
  ///
  /// In en, this message translates to:
  /// **'Synthetic onyx Fusion results'**
  String get settingsSyntheticOnyxTitle;

  /// No description provided for @settingsSyntheticOnyxSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adds onyx copies with boosted A/D and extra result rows for two onyx materials.'**
  String get settingsSyntheticOnyxSubtitle;

  /// No description provided for @settingsFilesTitle.
  ///
  /// In en, this message translates to:
  /// **'Files'**
  String get settingsFilesTitle;

  /// No description provided for @settingsFilesHint.
  ///
  /// In en, this message translates to:
  /// **'Import/export data, patches, and app service files.'**
  String get settingsFilesHint;

  /// No description provided for @settingsOpenFilesScreen.
  ///
  /// In en, this message translates to:
  /// **'Open files screen'**
  String get settingsOpenFilesScreen;

  /// No description provided for @settingsCatalogStatsByAbilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Breakdown by ability and rarity'**
  String get settingsCatalogStatsByAbilityTitle;

  /// No description provided for @settingsCatalogStatsNoAbility.
  ///
  /// In en, this message translates to:
  /// **'No ability'**
  String get settingsCatalogStatsNoAbility;

  /// No description provided for @deckFocusAttack.
  ///
  /// In en, this message translates to:
  /// **'Attack'**
  String get deckFocusAttack;

  /// No description provided for @deckFocusDefense.
  ///
  /// In en, this message translates to:
  /// **'Defense'**
  String get deckFocusDefense;

  /// No description provided for @deckFocusSumStats.
  ///
  /// In en, this message translates to:
  /// **'Total stats'**
  String get deckFocusSumStats;

  /// No description provided for @deckStatusSummary.
  ///
  /// In en, this message translates to:
  /// **'{focus} · size {size} · seed: {seed}'**
  String deckStatusSummary(Object focus, Object size, Object seed);

  /// No description provided for @deckSeedNone.
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get deckSeedNone;

  /// No description provided for @deckNeedAtLeastOneCard.
  ///
  /// In en, this message translates to:
  /// **'Add at least one combo card to collection.'**
  String get deckNeedAtLeastOneCard;

  /// No description provided for @deckNotEnoughCardsForSize.
  ///
  /// In en, this message translates to:
  /// **'Collection has fewer cards than deck size ({size}).'**
  String deckNotEnoughCardsForSize(Object size);

  /// No description provided for @deckTapBuildHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the button above to build.'**
  String get deckTapBuildHint;

  /// No description provided for @deckHeuristicApprox.
  ///
  /// In en, this message translates to:
  /// **'Fast heuristic used; result is approximate.'**
  String get deckHeuristicApprox;

  /// No description provided for @deckPoolTruncated.
  ///
  /// In en, this message translates to:
  /// **'Used top-{count} cards by solo score (pool limit).'**
  String deckPoolTruncated(Object count);

  /// No description provided for @deckScoreSummary.
  ///
  /// In en, this message translates to:
  /// **'Score: {total} (attack {attack} · defense {defense} · combo {combo})'**
  String deckScoreSummary(Object total, Object attack, Object defense, Object combo);

  /// No description provided for @deckDefaultName.
  ///
  /// In en, this message translates to:
  /// **'Deck {index}'**
  String deckDefaultName(Object index);

  /// No description provided for @deckComboVsStatsBalance.
  ///
  /// In en, this message translates to:
  /// **'Stats/Combo balance: {value}'**
  String deckComboVsStatsBalance(Object value);

  /// No description provided for @deckComboVsStatsBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'0 - only selected stats, 1 - only number of combos'**
  String get deckComboVsStatsBalanceHint;

  /// No description provided for @deckComboVsHandBalance.
  ///
  /// In en, this message translates to:
  /// **'Combo / random hand balance: {value}'**
  String deckComboVsHandBalance(Object value);

  /// No description provided for @deckComboVsHandBalanceHint.
  ///
  /// In en, this message translates to:
  /// **'0 - only pairwise picks (stats/combos above), 1 - only expected strength of a random 5-card hand by tier'**
  String get deckComboVsHandBalanceHint;

  /// No description provided for @comboResultId.
  ///
  /// In en, this message translates to:
  /// **'id {id}'**
  String comboResultId(Object id);

  /// No description provided for @comboPreviewStatsFromSheet.
  ///
  /// In en, this message translates to:
  /// **'A/D from fusion_onyx_stats: {attack} / {defense}'**
  String comboPreviewStatsFromSheet(Object attack, Object defense);

  /// No description provided for @comboPreviewStatsEstimated.
  ///
  /// In en, this message translates to:
  /// **'Estimated A/D: {attack} / {defense}'**
  String comboPreviewStatsEstimated(Object attack, Object defense);

  /// No description provided for @loadSaveDecksStorageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save decks to storage. Deck settings may be lost after restart.'**
  String get loadSaveDecksStorageFailed;

  /// No description provided for @loadCatalogLoaded.
  ///
  /// In en, this message translates to:
  /// **'Catalog loaded: AlchemyCardData + Excel + patches ({count} cards)'**
  String loadCatalogLoaded(Object count);

  /// No description provided for @loadCatalogError.
  ///
  /// In en, this message translates to:
  /// **'Catalog load error: {error}'**
  String loadCatalogError(Object error);

  /// No description provided for @loadOpenFilePickerFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open file picker: {error}'**
  String loadOpenFilePickerFailed(Object error);

  /// No description provided for @loadImportPatchCancelled.
  ///
  /// In en, this message translates to:
  /// **'Patch import cancelled: file not selected.'**
  String get loadImportPatchCancelled;

  /// No description provided for @loadCouldNotReadFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read file.'**
  String get loadCouldNotReadFile;

  /// No description provided for @loadFileInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'File is not valid JSON: {error}'**
  String loadFileInvalidJson(Object error);

  /// No description provided for @loadPatchSavedCatalogRebuilt.
  ///
  /// In en, this message translates to:
  /// **'Patch saved; catalog rebuilt ({count} cards)'**
  String loadPatchSavedCatalogRebuilt(Object count);

  /// No description provided for @loadPatchAppliedSessionOnly.
  ///
  /// In en, this message translates to:
  /// **'Patch applied for current session ({count} cards), path not saved'**
  String loadPatchAppliedSessionOnly(Object count);

  /// No description provided for @loadUserPatchReset.
  ///
  /// In en, this message translates to:
  /// **'User patch reset; catalog ({count} cards)'**
  String loadUserPatchReset(Object count);

  /// No description provided for @loadNoStoragePermission.
  ///
  /// In en, this message translates to:
  /// **'No permission to save files. Allow storage access in app settings.'**
  String get loadNoStoragePermission;

  /// No description provided for @loadNoImageDataForExport.
  ///
  /// In en, this message translates to:
  /// **'No image data available for export.'**
  String get loadNoImageDataForExport;

  /// No description provided for @loadNoNewDownloadedFilesForExport.
  ///
  /// In en, this message translates to:
  /// **'No newly downloaded files to export (images from assets/images are excluded).'**
  String get loadNoNewDownloadedFilesForExport;

  /// No description provided for @loadShareSheetOpenedSaveToFiles.
  ///
  /// In en, this message translates to:
  /// **'System Share sheet opened. Select Save to Files and destination folder.'**
  String get loadShareSheetOpenedSaveToFiles;

  /// No description provided for @loadExportedImagesZip.
  ///
  /// In en, this message translates to:
  /// **'Exported images: {count}\nZIP: {path}'**
  String loadExportedImagesZip(Object count, Object path);

  /// No description provided for @loadZipSavedToAppFiles.
  ///
  /// In en, this message translates to:
  /// **'System save dialog is unavailable. ZIP saved to app files:\n{path}'**
  String loadZipSavedToAppFiles(Object path);

  /// No description provided for @loadZipExportError.
  ///
  /// In en, this message translates to:
  /// **'ZIP export error: {error}'**
  String loadZipExportError(Object error);

  /// No description provided for @loadCollectionEmptyNothingToExport.
  ///
  /// In en, this message translates to:
  /// **'Collection is empty, nothing to export.'**
  String get loadCollectionEmptyNothingToExport;

  /// No description provided for @loadNoValidCardsForExport.
  ///
  /// In en, this message translates to:
  /// **'No valid cards found for export.'**
  String get loadNoValidCardsForExport;

  /// No description provided for @loadExportedCards.
  ///
  /// In en, this message translates to:
  /// **'Exported cards: {count}\nFile: {path}'**
  String loadExportedCards(Object count, Object path);

  /// No description provided for @loadCollectionFileSavedToAppFiles.
  ///
  /// In en, this message translates to:
  /// **'System save dialog is unavailable. Collection file saved to app files:\n{path}'**
  String loadCollectionFileSavedToAppFiles(Object path);

  /// No description provided for @loadCollectionExportError.
  ///
  /// In en, this message translates to:
  /// **'Collection export error: {error}'**
  String loadCollectionExportError(Object error);

  /// No description provided for @loadImportCollectionCancelled.
  ///
  /// In en, this message translates to:
  /// **'Collection import cancelled: file not selected.'**
  String get loadImportCollectionCancelled;

  /// No description provided for @loadCouldNotReadCollectionFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read collection file.'**
  String get loadCouldNotReadCollectionFile;

  /// No description provided for @loadImportCompleted.
  ///
  /// In en, this message translates to:
  /// **'Import completed: {imported} cards. Skipped lines: {skipped}. Cards not found: {notFound}.'**
  String loadImportCompleted(Object imported, Object skipped, Object notFound);

  /// No description provided for @loadCouldNotSaveDecks.
  ///
  /// In en, this message translates to:
  /// **'Could not save decks.'**
  String get loadCouldNotSaveDecks;

  /// No description provided for @loadDeckSettingsExportFailedNoDeck.
  ///
  /// In en, this message translates to:
  /// **'Select a deck to export.'**
  String get loadDeckSettingsExportFailedNoDeck;

  /// No description provided for @loadDeckSettingsExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'No deck settings to export.'**
  String get loadDeckSettingsExportEmpty;

  /// No description provided for @loadDeckSettingsExported.
  ///
  /// In en, this message translates to:
  /// **'Exported deck settings: {count}\nFile: {path}'**
  String loadDeckSettingsExported(Object count, Object path);

  /// No description provided for @loadDeckSettingsSavedToAppFiles.
  ///
  /// In en, this message translates to:
  /// **'System save dialog is unavailable. Deck settings file saved to app files:\n{path}'**
  String loadDeckSettingsSavedToAppFiles(Object path);

  /// No description provided for @loadDeckSettingsExportError.
  ///
  /// In en, this message translates to:
  /// **'Deck settings export error: {error}'**
  String loadDeckSettingsExportError(Object error);

  /// No description provided for @loadImportDeckSettingsCancelled.
  ///
  /// In en, this message translates to:
  /// **'Deck settings import cancelled: file not selected.'**
  String get loadImportDeckSettingsCancelled;

  /// No description provided for @loadCouldNotReadDeckSettingsFile.
  ///
  /// In en, this message translates to:
  /// **'Could not read deck settings file.'**
  String get loadCouldNotReadDeckSettingsFile;

  /// No description provided for @loadDeckSettingsInvalidJson.
  ///
  /// In en, this message translates to:
  /// **'Deck settings file is not valid JSON: {error}'**
  String loadDeckSettingsInvalidJson(Object error);

  /// No description provided for @loadDeckSettingsInvalidStructure.
  ///
  /// In en, this message translates to:
  /// **'Deck settings file has invalid structure.'**
  String get loadDeckSettingsInvalidStructure;

  /// No description provided for @loadDeckSettingsUnsupportedFormat.
  ///
  /// In en, this message translates to:
  /// **'Unsupported deck settings file format.'**
  String get loadDeckSettingsUnsupportedFormat;

  /// No description provided for @loadDeckSettingsNothingImported.
  ///
  /// In en, this message translates to:
  /// **'No valid deck settings imported. Skipped entries: {skipped}.'**
  String loadDeckSettingsNothingImported(Object skipped);

  /// No description provided for @loadDeckSettingsImported.
  ///
  /// In en, this message translates to:
  /// **'Deck settings imported: {imported}. Skipped invalid entries: {skipped}.'**
  String loadDeckSettingsImported(Object imported, Object skipped);

  /// No description provided for @loadSyntheticOnyxEnabled.
  ///
  /// In en, this message translates to:
  /// **'Catalog augmented with synthetic Fusion onyx results ({count} cards)'**
  String loadSyntheticOnyxEnabled(Object count);

  /// No description provided for @loadSyntheticOnyxDisabled.
  ///
  /// In en, this message translates to:
  /// **'Synthetic Fusion onyx results disabled ({count} cards)'**
  String loadSyntheticOnyxDisabled(Object count);

  /// No description provided for @tabShopSeasons.
  ///
  /// In en, this message translates to:
  /// **'Shop seasons'**
  String get tabShopSeasons;

  /// No description provided for @shopPackScheduleLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load shop schedule: {error}'**
  String shopPackScheduleLoadError(Object error);

  /// No description provided for @shopPackInStoreNow.
  ///
  /// In en, this message translates to:
  /// **'In shop now'**
  String get shopPackInStoreNow;

  /// No description provided for @shopPackWindowDates.
  ///
  /// In en, this message translates to:
  /// **'In shop: {start} – {end}'**
  String shopPackWindowDates(Object start, Object end);

  /// No description provided for @shopPackCardLevel.
  ///
  /// In en, this message translates to:
  /// **'Card level'**
  String get shopPackCardLevel;

  /// No description provided for @shopPackCardsInPack.
  ///
  /// In en, this message translates to:
  /// **'Cards in this pack'**
  String get shopPackCardsInPack;

  /// No description provided for @shopPackNoContents.
  ///
  /// In en, this message translates to:
  /// **'No card list for this pack yet. Add names in shop_pack_contents.json.'**
  String get shopPackNoContents;

  /// No description provided for @shopPackUnknownCard.
  ///
  /// In en, this message translates to:
  /// **'Not in catalog: {name}'**
  String shopPackUnknownCard(Object name);

  /// No description provided for @shopPackNoRotationScheduled.
  ///
  /// In en, this message translates to:
  /// **'No matching slot in app rotation schedule'**
  String get shopPackNoRotationScheduled;

  /// No description provided for @shopPackWikiOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open wiki: {url}'**
  String shopPackWikiOpenFailed(Object url);

  /// No description provided for @shopPackOtherCategory.
  ///
  /// In en, this message translates to:
  /// **'Other packs (not in app rotation)'**
  String get shopPackOtherCategory;

  /// No description provided for @shopPackGoldCombo.
  ///
  /// In en, this message translates to:
  /// **'Gold: {card}'**
  String shopPackGoldCombo(Object card);

  /// No description provided for @shopPackOnyxCombo.
  ///
  /// In en, this message translates to:
  /// **'Onyx: {card}'**
  String shopPackOnyxCombo(Object card);

  /// No description provided for @eventsShopTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get eventsShopTitle;

  /// No description provided for @eventsShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Packs in shop'**
  String get eventsShopSubtitle;

  /// No description provided for @tabEvents.
  ///
  /// In en, this message translates to:
  /// **'Events'**
  String get tabEvents;

  /// No description provided for @eventsArenaTitle.
  ///
  /// In en, this message translates to:
  /// **'Arena'**
  String get eventsArenaTitle;

  /// No description provided for @eventsArenaSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Arena shop'**
  String get eventsArenaSubtitle;

  /// No description provided for @eventsPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Portal'**
  String get eventsPortalTitle;

  /// No description provided for @eventsPortalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Portal rewards'**
  String get eventsPortalSubtitle;

  /// No description provided for @eventsExpandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get eventsExpandAll;

  /// No description provided for @eventsCollapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get eventsCollapseAll;

  /// No description provided for @eventsDurationDays.
  ///
  /// In en, this message translates to:
  /// **'{days} d'**
  String eventsDurationDays(Object days);

  /// No description provided for @eventsDurationHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h'**
  String eventsDurationHours(Object hours);

  /// No description provided for @eventsDurationMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} m'**
  String eventsDurationMinutes(Object minutes);

  /// No description provided for @arenaCurrentInShop.
  ///
  /// In en, this message translates to:
  /// **'In shop now: {ability}, {timeLeft} left'**
  String arenaCurrentInShop(Object ability, Object timeLeft);

  /// No description provided for @arenaCurrentWindow.
  ///
  /// In en, this message translates to:
  /// **'In shop now, {timeLeft} left'**
  String arenaCurrentWindow(Object timeLeft);

  /// No description provided for @arenaNextWindow.
  ///
  /// In en, this message translates to:
  /// **'Next: {start} - {end} (in {timeUntilStart})'**
  String arenaNextWindow(Object start, Object end, Object timeUntilStart);

  /// No description provided for @portalOpenEventFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open event page'**
  String get portalOpenEventFailed;

  /// No description provided for @portalRemainingHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} h left'**
  String portalRemainingHours(Object hours);

  /// No description provided for @portalRemainingDays.
  ///
  /// In en, this message translates to:
  /// **'{days} d left'**
  String portalRemainingDays(Object days);

  /// No description provided for @portalNowActive.
  ///
  /// In en, this message translates to:
  /// **'Now active: {eventName} ({bossName}), {remaining}'**
  String portalNowActive(Object eventName, Object bossName, Object remaining);

  /// No description provided for @portalClosedUntil.
  ///
  /// In en, this message translates to:
  /// **'Portal closed, until {eventName}: {remaining}'**
  String portalClosedUntil(Object eventName, Object remaining);

  /// No description provided for @portalNextWindow.
  ///
  /// In en, this message translates to:
  /// **'Next: {eventName} ({start} - {end})'**
  String portalNextWindow(Object eventName, Object start, Object end);

  /// No description provided for @portalBoss.
  ///
  /// In en, this message translates to:
  /// **'Boss: {bossName}'**
  String portalBoss(Object bossName);

  /// No description provided for @portalActiveUntil.
  ///
  /// In en, this message translates to:
  /// **'Active now, ends in {timeLeft}'**
  String portalActiveUntil(Object timeLeft);

  /// No description provided for @portalDateRange.
  ///
  /// In en, this message translates to:
  /// **'{start} - {end}'**
  String portalDateRange(Object start, Object end);

  /// No description provided for @bootstrapInitializing.
  ///
  /// In en, this message translates to:
  /// **'Initializing...'**
  String get bootstrapInitializing;

  /// No description provided for @bootstrapPreparingImageCache.
  ///
  /// In en, this message translates to:
  /// **'Preparing image cache...'**
  String get bootstrapPreparingImageCache;

  /// No description provided for @bootstrapLoadingSettings.
  ///
  /// In en, this message translates to:
  /// **'Loading settings...'**
  String get bootstrapLoadingSettings;

  /// No description provided for @bootstrapLoadingDecks.
  ///
  /// In en, this message translates to:
  /// **'Loading saved decks...'**
  String get bootstrapLoadingDecks;

  /// No description provided for @bootstrapReadingAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Reading app version...'**
  String get bootstrapReadingAppVersion;

  /// No description provided for @bootstrapBuildingCatalog.
  ///
  /// In en, this message translates to:
  /// **'Building and validating catalog...'**
  String get bootstrapBuildingCatalog;

  /// No description provided for @bootstrapRecomputingDeck.
  ///
  /// In en, this message translates to:
  /// **'Recomputing initial deck...'**
  String get bootstrapRecomputingDeck;

  /// No description provided for @bootstrapDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get bootstrapDone;

  /// No description provided for @catalogProgressLoadOnyxSheet.
  ///
  /// In en, this message translates to:
  /// **'Loading Onyx sheet...'**
  String get catalogProgressLoadOnyxSheet;

  /// No description provided for @catalogProgressReadBaseCatalog.
  ///
  /// In en, this message translates to:
  /// **'Reading base card catalog...'**
  String get catalogProgressReadBaseCatalog;

  /// No description provided for @catalogProgressMergeExcel.
  ///
  /// In en, this message translates to:
  /// **'Merging Excel supplement...'**
  String get catalogProgressMergeExcel;

  /// No description provided for @catalogProgressApplyComboPatch.
  ///
  /// In en, this message translates to:
  /// **'Applying combo patch...'**
  String get catalogProgressApplyComboPatch;

  /// No description provided for @catalogProgressApplyUserPatch.
  ///
  /// In en, this message translates to:
  /// **'Applying user patch...'**
  String get catalogProgressApplyUserPatch;

  /// No description provided for @catalogProgressParseMergedCatalog.
  ///
  /// In en, this message translates to:
  /// **'Parsing merged catalog...'**
  String get catalogProgressParseMergedCatalog;

  /// No description provided for @catalogProgressAddSyntheticOnyx.
  ///
  /// In en, this message translates to:
  /// **'Adding synthetic Onyx cards...'**
  String get catalogProgressAddSyntheticOnyx;

  /// No description provided for @catalogProgressFinalizeCatalog.
  ///
  /// In en, this message translates to:
  /// **'Finalizing catalog...'**
  String get catalogProgressFinalizeCatalog;

  /// No description provided for @catalogProgressReady.
  ///
  /// In en, this message translates to:
  /// **'Catalog ready'**
  String get catalogProgressReady;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'es', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
