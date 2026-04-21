// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Little Alchemist Helper';

  @override
  String startupError(Object error) {
    return 'Error de inicio: $error';
  }

  @override
  String get tabDeck => 'Mazo';

  @override
  String get tabCollection => 'Coleccion';

  @override
  String get tabCombo => 'Combinaciones';

  @override
  String get tabImport => 'Archivos';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get actionCancel => 'Cancelar';

  @override
  String get actionDelete => 'Eliminar';

  @override
  String get actionSave => 'Guardar';

  @override
  String get actionClear => 'Limpiar';

  @override
  String get actionDone => 'Listo';

  @override
  String get labelSort => 'Ordenar';

  @override
  String get labelCollection => 'Coleccion';

  @override
  String get labelAll => 'Todo';

  @override
  String get presenceInCollection => 'En coleccion';

  @override
  String get presenceNotInCollection => 'No en coleccion';

  @override
  String get sortByName => 'Nombre';

  @override
  String get sortByRarity => 'Rareza';

  @override
  String get sortByPower => 'Poder';

  @override
  String get tierBronze => 'Bronce';

  @override
  String get tierSilver => 'Plata';

  @override
  String get tierGold => 'Oro';

  @override
  String get tierDiamond => 'Diamante';

  @override
  String get tierOnyx => 'Onix';

  @override
  String get levelFused => 'Fusion';

  @override
  String levelShort(Object level) {
    return 'Nv. $level';
  }

  @override
  String get rarityUnknown => '-';

  @override
  String get deckActive => 'Mazo activo';

  @override
  String get deckProfile => 'Perfil';

  @override
  String get deckNew => 'Nuevo mazo';

  @override
  String get deckDeleteThis => 'Eliminar este mazo';

  @override
  String get deckDeleteConfirmTitle => 'Eliminar mazo?';

  @override
  String deckDeleteConfirmBody(Object name) {
    return '\"$name\" se eliminara.';
  }

  @override
  String get deckOptimizeButton => 'Crear mejor set';

  @override
  String get deckEditSettings => 'Ajustes y auto-llenado';

  @override
  String get saveFailedGeneric => 'No se pudieron guardar los cambios.';

  @override
  String get settingsMedia => 'Medios';

  @override
  String get settingsLoadWikiImages => 'Cargar imagenes de wiki';

  @override
  String get settingsLoadWikiImagesSubtitle => 'Usar imagenes de cartas de Little Alchemist Wiki. Desactivado por defecto.';

  @override
  String get settingsWikiThanksTitle => 'Agradecimientos';

  @override
  String get settingsWikiThanksSubtitle => 'Las imagenes de cartas son proporcionadas por la comunidad de Little Alchemist Wiki.';

  @override
  String get settingsWikiOpenSite => 'Abrir Little Alchemist Wiki';

  @override
  String get settingsWikiOpenFailed => 'No se pudo abrir el sitio wiki.';

  @override
  String get settingsCatalogStatsTitle => 'Estadisticas del catalogo por rareza';

  @override
  String settingsCatalogStatsTotal(Object count) {
    return 'Cartas totales: $count';
  }

  @override
  String get settingsAppInfoTitle => 'Acerca de la app';

  @override
  String settingsAppVersion(Object version) {
    return 'Version: $version';
  }

  @override
  String settingsAppBuild(Object build) {
    return 'Build: $build';
  }

  @override
  String collectionDeleteOneFromGroup(Object name, Object count) {
    return 'Eliminar una \"$name\"? El grupo tiene $count duplicados.';
  }

  @override
  String collectionDeleteOne(Object name) {
    return 'Eliminar \"$name\" de la coleccion?';
  }

  @override
  String get collectionDeleteTitle => 'Quitar de la coleccion';

  @override
  String collectionLimitWarning(Object limit, Object names) {
    return 'Tienes mas de $limit cartas con el mismo nombre: $names. Este conjunto no se permite en un mazo.';
  }

  @override
  String get collectionAddOne => 'Una carta';

  @override
  String get collectionAddMany => 'Agregar en lote';

  @override
  String get collectionCollapseDuplicates => 'Agrupar duplicados';

  @override
  String collectionHint(Object limit) {
    return 'Cada fila es una carta. Para editar, elimina y agrega de nuevo. Limite del mazo: hasta $limit cartas con un nombre.';
  }

  @override
  String collectionStats(Object kinds, Object copies) {
    return '$kinds tipos - $copies copias';
  }

  @override
  String get collectionEmpty => 'La coleccion esta vacia. Agrega cartas con los botones de arriba.';

  @override
  String collectionDuplicatesCount(Object count) {
    return 'x$count duplicados';
  }

  @override
  String get collectionDeleteOneTooltip => 'Eliminar una';

  @override
  String get collectionAddToCollection => 'Agregar a la coleccion';

  @override
  String get deckNameRequired => 'Ingresa el nombre del mazo.';

  @override
  String get deckName => 'Nombre del mazo';

  @override
  String get deckSeedCard => 'Carta semilla';

  @override
  String get deckNotSelected => 'No seleccionada';

  @override
  String get deckSeedHint => 'Elige una carta de la coleccion. Sera la primera.';

  @override
  String deckLevel(Object level) {
    return 'Nivel: $level';
  }

  @override
  String get deckSelectCard => 'Elegir carta';

  @override
  String get deckPickSeed => 'Carta semilla';

  @override
  String get deckFillType => 'Modo de llenado';

  @override
  String get deckFillHint => 'Despues de la carta semilla, las cartas se agregan una por una.';

  @override
  String deckSize(Object size) {
    return 'Tamano del mazo: $size';
  }

  @override
  String deckMaxNonFusion(Object count) {
    return 'Maximo de cartas no Fusion: $count';
  }

  @override
  String get deckRarityRules => 'Reglas de rareza';

  @override
  String deckMinComboTier(Object tier) {
    return 'Rareza minima de combo considerada: $tier';
  }

  @override
  String get deckRarityRulesHint => 'Define el nivel minimo para cada rareza.';

  @override
  String deckMinLevel(Object level) {
    return 'Nivel minimo: $level';
  }

  @override
  String get deckNoSeedCandidates => 'No hay cartas semilla adecuadas en la coleccion.';

  @override
  String get deckPickSeedTitle => 'Elige carta semilla de la coleccion';

  @override
  String get comboLabIntro => 'Elige dos cartas y niveles. Que falte un resultado Fusion para una pareja puede ser normal.';

  @override
  String get comboCardA => 'Carta A';

  @override
  String get comboCardB => 'Carta B';

  @override
  String get comboChange => 'Cambiar';

  @override
  String get comboPickA => 'Elegir carta A';

  @override
  String get comboPickB => 'Elegir carta B';

  @override
  String get comboResult => 'Resultado Fusion';

  @override
  String get comboPickBoth => 'Elige ambas cartas.';

  @override
  String comboNoRecipe(Object a, Object b) {
    return 'No hay receta Fusion para \"$a\" + \"$b\".';
  }

  @override
  String comboBattleLevel(Object level) {
    return 'Nivel de batalla $level';
  }

  @override
  String comboBaseStats(Object attack, Object defense) {
    return 'Estadisticas base: $attack / $defense';
  }

  @override
  String get comboMaterialsDoubleOnyx => 'Materiales: dos niveles onyx.';

  @override
  String get comboMaterialsMixed => 'Materiales: un onyx y un nivel inferior.';

  @override
  String get importDataTitle => 'Archivos';

  @override
  String get importDataOrder => 'Orden de construccion del catalogo:\n1) AlchemyCardData.json integrado\n2) suplemento assets/data_from_exel.txt\n3) CombinationPatch.json integrado\n4) parche JSON de usuario opcional (solo aditivo).';

  @override
  String get importPickPatch => 'Elegir parche JSON de usuario';

  @override
  String get importResetPatch => 'Restablecer solo parche de usuario';

  @override
  String get importClearCollectionQuestion => 'Limpiar coleccion?';

  @override
  String get importClearCollection => 'Limpiar coleccion de cartas combo';

  @override
  String get importLastMessage => 'Ultimo mensaje';

  @override
  String get catalogNoCards => 'Sin cartas';

  @override
  String get catalogPickCard => 'Elegir carta';

  @override
  String catalogInstanceLevel(Object level) {
    return 'Nivel de instancia: $level';
  }

  @override
  String get catalogLevelWillBeSaved => 'El nivel se usara para la siguiente adicion.';

  @override
  String catalogFrameRarity(Object tier, Object rarity) {
    return 'Rareza del marco: $tier ($rarity).';
  }

  @override
  String get catalogSearchHint => 'Buscar en catalogo';

  @override
  String get catalogRarityFilterTitle => 'Filtro de rareza de datos';

  @override
  String catalogBulkIntro(Object kinds) {
    return 'Las cartas del catalogo se agregaran por filtros (ahora $kinds tipos).';
  }

  @override
  String catalogAllowOverLimit(Object limit) {
    return 'Permitir sobrepasar limite ($limit por nombre de mazo)';
  }

  @override
  String get catalogOverLimitHint => 'Si esta desactivado, se omiten copias extra por nombre.';

  @override
  String get catalogCopiesPerCard => 'Copias por carta';

  @override
  String catalogAllNewLevel(Object level) {
    return 'Nivel para todas las cartas nuevas: $level';
  }

  @override
  String get catalogLimitNotApplied => 'No se aplica limite por nombre.';

  @override
  String catalogLimitAppliedHint(Object limit) {
    return 'Con limite $limit por nombre, algunas copias pueden omitirse.';
  }

  @override
  String get catalogBulkAddTitle => 'Agregar en lote';

  @override
  String catalogBulkAddConfirm(Object total, Object kinds, Object copies, Object level, Object limitLine) {
    return 'Agregar hasta $total cartas ($kinds x $copies), nivel $level.\n\n$limitLine';
  }

  @override
  String catalogAddAll(Object kinds) {
    return 'Agregar todo ($kinds tipos)';
  }

  @override
  String get importReplaceCollectionTitle => 'Reemplazar la coleccion actual?';

  @override
  String get importReplaceCollectionBody => 'La coleccion actual no esta vacia. Al importar, los datos actuales se borraran y se reemplazaran con el contenido del archivo.';

  @override
  String get importReplaceCollectionConfirm => 'Reemplazar';

  @override
  String get importNotFoundTitle => 'Cartas no encontradas';

  @override
  String importNotFoundBody(Object names) {
    return 'Estas cartas no estan en el catalogo y no se importaron:\n\n$names';
  }

  @override
  String get importShareZip => 'Compartir ZIP con imagenes recien descargadas';

  @override
  String get importUserCollectionTitle => 'Coleccion del usuario';

  @override
  String get importSimpleFormatHint => 'Formato simple: una carta por linea -> carta:nivel';

  @override
  String get importShareCollectionTxt => 'Compartir coleccion (TXT)';

  @override
  String get importLoadCollectionTxt => 'Importar coleccion desde TXT';

  @override
  String get importDeckSettingsTitle => 'Ajustes de mazos';

  @override
  String get importDeckSettingsHint => 'Exporta/importa solo parametros de auto-construccion de mazos. Las entradas invalidas se omiten al importar.';

  @override
  String get importExportDeckSettings => 'Exportar ajustes de mazos (JSON)';

  @override
  String get importLoadDeckSettings => 'Importar ajustes de mazos (JSON)';

  @override
  String get importDeckSettingsExportAll => 'Exportar todos los mazos';

  @override
  String importDeckSettingsExportOne(Object name) {
    return 'Exportar \"$name\"';
  }

  @override
  String get settingsDecksTitle => 'Mazos';

  @override
  String get settingsDecksHint => 'Gestiona perfiles de mazo y parametros de auto-construccion en Mazo -> Ajustes y autollenado.';

  @override
  String get settingsComboCatalogTitle => 'Catalogo de combos';

  @override
  String get settingsSyntheticOnyxTitle => 'Resultados sinteticos Fusion onyx';

  @override
  String get settingsSyntheticOnyxSubtitle => 'Agrega copias onyx con A/D mejorados y filas extra de resultado para dos materiales onyx.';

  @override
  String get settingsFilesTitle => 'Archivos';

  @override
  String get settingsFilesHint => 'Importar/exportar datos, parches y archivos de servicio de la app.';

  @override
  String get settingsOpenFilesScreen => 'Abrir pantalla de archivos';

  @override
  String get settingsCatalogStatsByAbilityTitle => 'Desglose por habilidad y rareza';

  @override
  String get settingsCatalogStatsNoAbility => 'Sin habilidad';

  @override
  String get deckFocusAttack => 'Ataque';

  @override
  String get deckFocusDefense => 'Defensa';

  @override
  String get deckFocusSumStats => 'Suma de estadisticas';

  @override
  String deckStatusSummary(Object focus, Object size, Object seed) {
    return '$focus · tamano $size · semilla: $seed';
  }

  @override
  String get deckSeedNone => 'ninguna';

  @override
  String get deckNeedAtLeastOneCard => 'Agrega al menos una carta de combo a la coleccion.';

  @override
  String deckNotEnoughCardsForSize(Object size) {
    return 'La coleccion tiene menos cartas que el tamano del mazo ($size).';
  }

  @override
  String get deckTapBuildHint => 'Toca el boton de arriba para construir.';

  @override
  String get deckHeuristicApprox => 'Se uso una heuristica rapida; el resultado es aproximado.';

  @override
  String deckPoolTruncated(Object count) {
    return 'Se usaron las $count mejores cartas por puntuacion individual (limite del pool).';
  }

  @override
  String deckScoreSummary(Object total, Object attack, Object defense, Object combo) {
    return 'Puntuacion: $total (ataque $attack · defensa $defense · combo $combo)';
  }

  @override
  String deckDefaultName(Object index) {
    return 'Mazo $index';
  }

  @override
  String deckComboVsStatsBalance(Object value) {
    return 'Balance estadisticas/combo: $value';
  }

  @override
  String get deckComboVsStatsBalanceHint => '0 - solo estadisticas elegidas, 1 - solo cantidad de combos';

  @override
  String deckComboVsHandBalance(Object value) {
    return 'Balance combo / mano aleatoria: $value';
  }

  @override
  String get deckComboVsHandBalanceHint => '0 - solo eleccion por pares (stats/combos arriba), 1 - solo fuerza esperada de una mano aleatoria de 5 por rareza';

  @override
  String comboResultId(Object id) {
    return 'id $id';
  }

  @override
  String comboPreviewStatsFromSheet(Object attack, Object defense) {
    return 'A/D de fusion_onyx_stats: $attack / $defense';
  }

  @override
  String comboPreviewStatsEstimated(Object attack, Object defense) {
    return 'A/D estimado: $attack / $defense';
  }

  @override
  String get loadSaveDecksStorageFailed => 'No se pudieron guardar los mazos en el almacenamiento. La configuracion de mazos puede perderse al reiniciar.';

  @override
  String loadCatalogLoaded(Object count) {
    return 'Catalogo cargado: AlchemyCardData + Excel + parches ($count cartas)';
  }

  @override
  String loadCatalogError(Object error) {
    return 'Error al cargar catalogo: $error';
  }

  @override
  String loadOpenFilePickerFailed(Object error) {
    return 'No se pudo abrir el selector de archivos: $error';
  }

  @override
  String get loadImportPatchCancelled => 'Importacion de parche cancelada: no se selecciono archivo.';

  @override
  String get loadCouldNotReadFile => 'No se pudo leer el archivo.';

  @override
  String loadFileInvalidJson(Object error) {
    return 'El archivo no es JSON valido: $error';
  }

  @override
  String loadPatchSavedCatalogRebuilt(Object count) {
    return 'Parche guardado; catalogo reconstruido ($count cartas)';
  }

  @override
  String loadPatchAppliedSessionOnly(Object count) {
    return 'Parche aplicado para la sesion actual ($count cartas), ruta no guardada';
  }

  @override
  String loadUserPatchReset(Object count) {
    return 'Parche de usuario restablecido; catalogo ($count cartas)';
  }

  @override
  String get loadNoStoragePermission => 'No hay permiso para guardar archivos. Permite acceso al almacenamiento en ajustes de la app.';

  @override
  String get loadNoImageDataForExport => 'No hay datos de imagen para exportar.';

  @override
  String get loadNoNewDownloadedFilesForExport => 'No hay archivos descargados nuevos para exportar (las imagenes de assets/images se excluyen).';

  @override
  String get loadShareSheetOpenedSaveToFiles => 'Se abrio la pantalla Compartir del sistema. Elige Guardar en Archivos y carpeta de destino.';

  @override
  String loadExportedImagesZip(Object count, Object path) {
    return 'Imagenes exportadas: $count\nZIP: $path';
  }

  @override
  String loadZipSavedToAppFiles(Object path) {
    return 'El dialogo de guardado del sistema no esta disponible. ZIP guardado en archivos de la app:\n$path';
  }

  @override
  String loadZipExportError(Object error) {
    return 'Error al exportar ZIP: $error';
  }

  @override
  String get loadCollectionEmptyNothingToExport => 'La coleccion esta vacia, nada para exportar.';

  @override
  String get loadNoValidCardsForExport => 'No se encontraron cartas validas para exportar.';

  @override
  String loadExportedCards(Object count, Object path) {
    return 'Cartas exportadas: $count\nArchivo: $path';
  }

  @override
  String loadCollectionFileSavedToAppFiles(Object path) {
    return 'El dialogo de guardado del sistema no esta disponible. Archivo de coleccion guardado en archivos de la app:\n$path';
  }

  @override
  String loadCollectionExportError(Object error) {
    return 'Error al exportar coleccion: $error';
  }

  @override
  String get loadImportCollectionCancelled => 'Importacion de coleccion cancelada: no se selecciono archivo.';

  @override
  String get loadCouldNotReadCollectionFile => 'No se pudo leer el archivo de coleccion.';

  @override
  String loadImportCompleted(Object imported, Object skipped, Object notFound) {
    return 'Importacion completada: $imported cartas. Lineas omitidas: $skipped. Cartas no encontradas: $notFound.';
  }

  @override
  String get loadCouldNotSaveDecks => 'No se pudieron guardar los mazos.';

  @override
  String get loadDeckSettingsExportFailedNoDeck => 'Selecciona un mazo para exportar.';

  @override
  String get loadDeckSettingsExportEmpty => 'No hay ajustes de mazo para exportar.';

  @override
  String loadDeckSettingsExported(Object count, Object path) {
    return 'Ajustes de mazo exportados: $count\nArchivo: $path';
  }

  @override
  String loadDeckSettingsSavedToAppFiles(Object path) {
    return 'El dialogo de guardado del sistema no esta disponible. Archivo de ajustes de mazo guardado en archivos de la app:\n$path';
  }

  @override
  String loadDeckSettingsExportError(Object error) {
    return 'Error al exportar ajustes de mazo: $error';
  }

  @override
  String get loadImportDeckSettingsCancelled => 'Importacion de ajustes de mazo cancelada: no se selecciono archivo.';

  @override
  String get loadCouldNotReadDeckSettingsFile => 'No se pudo leer el archivo de ajustes de mazo.';

  @override
  String loadDeckSettingsInvalidJson(Object error) {
    return 'El archivo de ajustes de mazo no es JSON valido: $error';
  }

  @override
  String get loadDeckSettingsInvalidStructure => 'El archivo de ajustes de mazo tiene estructura invalida.';

  @override
  String get loadDeckSettingsUnsupportedFormat => 'Formato de archivo de ajustes de mazo no compatible.';

  @override
  String loadDeckSettingsNothingImported(Object skipped) {
    return 'No se importo ningun ajuste de mazo valido. Entradas omitidas: $skipped.';
  }

  @override
  String loadDeckSettingsImported(Object imported, Object skipped) {
    return 'Ajustes de mazo importados: $imported. Entradas invalidas omitidas: $skipped.';
  }

  @override
  String loadSyntheticOnyxEnabled(Object count) {
    return 'Catalogo ampliado con resultados sinteticos Fusion onyx ($count cartas)';
  }

  @override
  String loadSyntheticOnyxDisabled(Object count) {
    return 'Resultados sinteticos Fusion onyx desactivados ($count cartas)';
  }

  @override
  String get tabShopSeasons => 'Temporadas de tienda';

  @override
  String shopPackScheduleLoadError(Object error) {
    return 'No se pudo cargar el calendario de la tienda: $error';
  }

  @override
  String get shopPackInStoreNow => 'En la tienda ahora';

  @override
  String shopPackWindowDates(Object start, Object end) {
    return 'En tienda: $start – $end';
  }

  @override
  String get shopPackCardLevel => 'Nivel de cartas';

  @override
  String get shopPackCardsInPack => 'Cartas del sobre';

  @override
  String get shopPackNoContents => 'Aun no hay lista de cartas para este sobre. Anade nombres en shop_pack_contents.json.';

  @override
  String shopPackUnknownCard(Object name) {
    return 'No esta en el catalogo: $name';
  }

  @override
  String get shopPackNoRotationScheduled => 'Sin hueco en el calendario de rotacion de la app';

  @override
  String shopPackWikiOpenFailed(Object url) {
    return 'No se pudo abrir la wiki: $url';
  }

  @override
  String get shopPackOtherCategory => 'Otros sobres (fuera de la rotacion de la app)';

  @override
  String shopPackGoldCombo(Object card) {
    return 'Gold: $card';
  }

  @override
  String shopPackOnyxCombo(Object card) {
    return 'Onyx: $card';
  }

  @override
  String get eventsShopTitle => 'Tienda';

  @override
  String get eventsShopSubtitle => 'Paquetes en la tienda';

  @override
  String get tabEvents => 'Eventos';

  @override
  String get eventsArenaTitle => 'Arena';

  @override
  String get eventsArenaSubtitle => 'Tienda de arena';

  @override
  String get eventsPortalTitle => 'Portal';

  @override
  String get eventsPortalSubtitle => 'Recompensas del portal';

  @override
  String get eventsExpandAll => 'Expandir todo';

  @override
  String get eventsCollapseAll => 'Contraer todo';

  @override
  String eventsDurationDays(Object days) {
    return '$days d';
  }

  @override
  String eventsDurationHours(Object hours) {
    return '$hours h';
  }

  @override
  String eventsDurationMinutes(Object minutes) {
    return '$minutes m';
  }

  @override
  String arenaCurrentInShop(Object ability, Object timeLeft) {
    return 'En tienda ahora: $ability, quedan $timeLeft';
  }

  @override
  String arenaCurrentWindow(Object timeLeft) {
    return 'En tienda ahora, quedan $timeLeft';
  }

  @override
  String arenaNextWindow(Object start, Object end, Object timeUntilStart) {
    return 'Siguiente: $start - $end (en $timeUntilStart)';
  }

  @override
  String get portalOpenEventFailed => 'No se pudo abrir la pagina del evento';

  @override
  String portalRemainingHours(Object hours) {
    return 'quedan $hours h';
  }

  @override
  String portalRemainingDays(Object days) {
    return 'quedan $days d';
  }

  @override
  String portalNowActive(Object eventName, Object bossName, Object remaining) {
    return 'Activo ahora: $eventName ($bossName), $remaining';
  }

  @override
  String portalClosedUntil(Object eventName, Object remaining) {
    return 'Portal cerrado, hasta $eventName: $remaining';
  }

  @override
  String portalNextWindow(Object eventName, Object start, Object end) {
    return 'Siguiente: $eventName ($start - $end)';
  }

  @override
  String portalBoss(Object bossName) {
    return 'Jefe: $bossName';
  }

  @override
  String portalActiveUntil(Object timeLeft) {
    return 'Activo ahora, termina en $timeLeft';
  }

  @override
  String portalDateRange(Object start, Object end) {
    return '$start - $end';
  }

  @override
  String get bootstrapInitializing => 'Inicializando...';

  @override
  String get bootstrapPreparingImageCache => 'Preparando cache de imagenes...';

  @override
  String get bootstrapLoadingSettings => 'Cargando ajustes...';

  @override
  String get bootstrapLoadingDecks => 'Cargando mazos guardados...';

  @override
  String get bootstrapReadingAppVersion => 'Leyendo version de la app...';

  @override
  String get bootstrapBuildingCatalog => 'Construyendo y validando catalogo...';

  @override
  String get bootstrapRecomputingDeck => 'Recalculando mazo inicial...';

  @override
  String get bootstrapDone => 'Listo';

  @override
  String get catalogProgressLoadOnyxSheet => 'Cargando tabla Onyx...';

  @override
  String get catalogProgressReadBaseCatalog => 'Leyendo catalogo base de cartas...';

  @override
  String get catalogProgressMergeExcel => 'Mezclando suplemento de Excel...';

  @override
  String get catalogProgressApplyComboPatch => 'Aplicando parche de combinaciones...';

  @override
  String get catalogProgressApplyUserPatch => 'Aplicando parche de usuario...';

  @override
  String get catalogProgressParseMergedCatalog => 'Parseando catalogo final...';

  @override
  String get catalogProgressAddSyntheticOnyx => 'Agregando cartas Onyx sinteticas...';

  @override
  String get catalogProgressFinalizeCatalog => 'Finalizando catalogo...';

  @override
  String get catalogProgressReady => 'Catalogo listo';
}
