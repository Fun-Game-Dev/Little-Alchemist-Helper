import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/l10n_ext.dart';
import '../../models/combo_tier.dart';
import '../../state/app_controller.dart';
import 'import_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openWikiSite(BuildContext context) async {
    final Uri uri = Uri.parse('https://little-alchemist.fandom.com/wiki/Little_Alchemist_Wiki');
    final bool opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.settingsWikiOpenFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppController app = context.watch<AppController>();
    final Map<ComboTier, int> rarityCounts = app.catalogRarityCounts;
    final Map<String, Map<ComboTier, int>> abilityRarityCounts =
        app.catalogAbilityRarityCounts;
    final List<String> abilityOrder = abilityRarityCounts.keys.toList()
      ..sort((String a, String b) {
        const String orbAbility = 'orb';
        final bool isAOrb = a.toLowerCase() == orbAbility;
        final bool isBOrb = b.toLowerCase() == orbAbility;
        if (isAOrb && !isBOrb) {
          return -1;
        }
        if (isBOrb && !isAOrb) {
          return 1;
        }
        if (a == AppControllerCatalogExtension.noAbilityKey) {
          return 1;
        }
        if (b == AppControllerCatalogExtension.noAbilityKey) {
          return -1;
        }
        return a.toLowerCase().compareTo(b.toLowerCase());
      });
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text(context.l10n.settingsComboCatalogTitle, style: Theme.of(context).textTheme.titleLarge),
        SwitchListTile(
          title: Text(context.l10n.settingsSyntheticOnyxTitle),
          subtitle: Text(context.l10n.settingsSyntheticOnyxSubtitle),
          value: app.augmentSyntheticOnyxCatalog,
          onChanged: (bool v) => app.setAugmentSyntheticOnyxCatalog(v),
        ),
        const Divider(height: 32),
        Text(context.l10n.settingsFilesTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          context.l10n.settingsFilesHint,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (BuildContext routeContext) => Scaffold(
                  appBar: AppBar(title: Text(routeContext.l10n.importDataTitle)),
                  body: const SafeArea(child: ImportScreen()),
                ),
              ),
            );
          },
          icon: const Icon(Icons.folder_open_outlined),
          label: Text(context.l10n.settingsOpenFilesScreen),
        ),
        const Divider(height: 32),
        Text(context.l10n.settingsMedia, style: Theme.of(context).textTheme.titleLarge),
        SwitchListTile(
          title: Text(context.l10n.settingsLoadWikiImages),
          subtitle: Text(context.l10n.settingsLoadWikiImagesSubtitle),
          value: app.loadCardImages,
          onChanged: app.setLoadCardImages,
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(context.l10n.settingsWikiThanksTitle),
          subtitle: Text(context.l10n.settingsWikiThanksSubtitle),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _openWikiSite(context),
            icon: const Icon(Icons.open_in_new),
            label: Text(context.l10n.settingsWikiOpenSite),
          ),
        ),
        const Divider(height: 32),
        Text(context.l10n.settingsCatalogStatsTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(context.l10n.settingsCatalogStatsTotal(app.catalogCount)),
        const SizedBox(height: 8),
        Text('${context.l10n.tierBronze}: ${rarityCounts[ComboTier.bronze] ?? 0}'),
        Text('${context.l10n.tierSilver}: ${rarityCounts[ComboTier.silver] ?? 0}'),
        Text('${context.l10n.tierGold}: ${rarityCounts[ComboTier.gold] ?? 0}'),
        Text('${context.l10n.tierDiamond}: ${rarityCounts[ComboTier.diamond] ?? 0}'),
        Text('${context.l10n.tierOnyx}: ${rarityCounts[ComboTier.onyx] ?? 0}'),
        const SizedBox(height: 12),
        Text(
          context.l10n.settingsCatalogStatsByAbilityTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final String ability in abilityOrder) ...<Widget>[
          if (ability.toLowerCase() == 'orb') const SizedBox(height: 4),
          Text(
            ability == AppControllerCatalogExtension.noAbilityKey
                ? context.l10n.settingsCatalogStatsNoAbility
                : ability,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Builder(
            builder: (BuildContext abilityContext) {
              final Map<ComboTier, int> byTier =
                  abilityRarityCounts[ability] ?? const <ComboTier, int>{};
              return Text(
                '${abilityContext.l10n.tierBronze}: ${byTier[ComboTier.bronze] ?? 0}  '
                '${abilityContext.l10n.tierSilver}: ${byTier[ComboTier.silver] ?? 0}  '
                '${abilityContext.l10n.tierGold}: ${byTier[ComboTier.gold] ?? 0}  '
                '${abilityContext.l10n.tierDiamond}: ${byTier[ComboTier.diamond] ?? 0}  '
                '${abilityContext.l10n.tierOnyx}: ${byTier[ComboTier.onyx] ?? 0}',
                style: Theme.of(abilityContext).textTheme.bodySmall,
              );
            },
          ),
          if (ability.toLowerCase() == 'orb')
            const SizedBox(height: 12)
          else
            const SizedBox(height: 8),
        ],
        const Divider(height: 32),
        Text(context.l10n.settingsAppInfoTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(context.l10n.settingsAppVersion(app.appVersion)),
        Text(context.l10n.settingsAppBuild(app.appBuildNumber)),
      ],
    );
  }
}
