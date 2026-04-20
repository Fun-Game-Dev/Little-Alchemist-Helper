import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n_ext.dart';
import '../../models/deck_profile.dart';
import '../../state/app_controller.dart';

class ImportScreen extends StatelessWidget {
  const ImportScreen({super.key});

  Rect? _shareOriginRect(BuildContext context) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) {
      return null;
    }
    final Offset origin = renderObject.localToGlobal(Offset.zero);
    return origin & renderObject.size;
  }

  Future<bool> _confirmReplaceCollection(BuildContext context) async {
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(context.l10n.importReplaceCollectionTitle),
        content: Text(context.l10n.importReplaceCollectionBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(context.l10n.importReplaceCollectionConfirm),
          ),
        ],
      ),
    );
    return ok == true;
  }

  Future<void> _showNotFoundCardsDialog(
    BuildContext context,
    List<String> notFoundCardNames,
  ) async {
    if (notFoundCardNames.isEmpty) {
      return;
    }
    final String names = notFoundCardNames.join('\n');
    await showDialog<void>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: Text(context.l10n.importNotFoundTitle),
        content: SingleChildScrollView(
          child: SelectableText(
            context.l10n.importNotFoundBody(names),
          ),
        ),
        actions: <Widget>[
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.actionDone),
          ),
        ],
      ),
    );
  }

  Future<_DeckExportChoice?> _pickDeckExportChoice(
    BuildContext context,
    AppController app,
  ) async {
    final List<DeckProfile> decks = app.deckProfiles;
    if (decks.isEmpty) {
      return null;
    }
    final _DeckExportChoice? result = await showModalBottomSheet<_DeckExportChoice>(
      context: context,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: Text(context.l10n.importDeckSettingsExportAll),
                onTap: () => Navigator.pop(
                  sheetContext,
                  const _DeckExportChoice(exportAllDecks: true),
                ),
              ),
              for (final DeckProfile deck in decks)
                ListTile(
                  title: Text(context.l10n.importDeckSettingsExportOne(deck.name)),
                  onTap: () => Navigator.pop(
                    sheetContext,
                    _DeckExportChoice(
                      exportAllDecks: false,
                      deckId: deck.id,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(context.l10n.importDataTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(context.l10n.importDataOrder),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () => app.pickAndLoadUserCatalogOverlayJson(),
          icon: const Icon(Icons.layers_outlined),
          label: Text(context.l10n.importPickPatch),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => app.clearUserCatalogOverlayAndReload(),
          icon: const Icon(Icons.layers_clear_outlined),
          label: Text(context.l10n.importResetPatch),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () => app.exportDownloadedCardImagesZip(
            sharePositionOrigin: _shareOriginRect(context),
          ),
          icon: const Icon(Icons.ios_share_outlined),
          label: Text(context.l10n.importShareZip),
        ),
        const Divider(height: 32),
        Text(
          context.l10n.importUserCollectionTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(context.l10n.importSimpleFormatHint),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () async {
            await app.exportCollectionToSimpleTextFile(
              sharePositionOrigin: _shareOriginRect(context),
            );
          },
          icon: const Icon(Icons.ios_share_outlined),
          label: Text(context.l10n.importShareCollectionTxt),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () async {
            if (app.ownedComboEntries.isNotEmpty) {
              final bool confirmed = await _confirmReplaceCollection(context);
              if (!confirmed) {
                return;
              }
            }
            final CollectionTextImportResult? importResult =
                await app.importCollectionFromSimpleTextFile();
            if (importResult == null || !context.mounted) {
              return;
            }
            await _showNotFoundCardsDialog(context, importResult.notFoundCardNames);
          },
          icon: const Icon(Icons.download_for_offline_outlined),
          label: Text(context.l10n.importLoadCollectionTxt),
        ),
        const Divider(height: 32),
        Text(
          context.l10n.importDeckSettingsTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(context.l10n.importDeckSettingsHint),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () async {
            final _DeckExportChoice? choice = await _pickDeckExportChoice(context, app);
            if (!context.mounted) {
              return;
            }
            if (choice == null) {
              return;
            }
            await app.exportDeckSettingsToJsonFile(
              exportAllDecks: choice.exportAllDecks,
              singleDeckId: choice.deckId,
              sharePositionOrigin: _shareOriginRect(context),
            );
          },
          icon: const Icon(Icons.ios_share_outlined),
          label: Text(context.l10n.importExportDeckSettings),
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: () async {
            await app.importDeckSettingsFromJsonFile();
          },
          icon: const Icon(Icons.upload_file_outlined),
          label: Text(context.l10n.importLoadDeckSettings),
        ),
        const Divider(height: 32),
        OutlinedButton.icon(
          onPressed: () async {
            final bool? ok = await showDialog<bool>(
              context: context,
              builder: (BuildContext ctx) => AlertDialog(
                title: Text(context.l10n.importClearCollectionQuestion),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(context.l10n.actionCancel),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: Text(context.l10n.actionClear),
                  ),
                ],
              ),
            );
            if (ok == true && context.mounted) {
              await app.clearCollection();
            }
          },
          icon: const Icon(Icons.delete_outline),
          label: Text(context.l10n.importClearCollection),
        ),
        const SizedBox(height: 24),
        if (app.loadMessage != null) ...<Widget>[
          Text(
            context.l10n.importLastMessage,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          SelectableText(
            app.loadMessage!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}

class _DeckExportChoice {
  const _DeckExportChoice({
    required this.exportAllDecks,
    this.deckId,
  });

  final bool exportAllDecks;
  final String? deckId;
}
