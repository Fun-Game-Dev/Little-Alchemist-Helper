import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/shop_pack_models.dart';
import '../../data/special_pack_models.dart';
import '../../l10n/l10n_ext.dart';
import '../widgets/shop_pack_row.dart';

class ShopSeasonsController {
  ShopSeasonsController();

  final ValueNotifier<bool> allSectionsCollapsed = ValueNotifier<bool>(false);
  VoidCallback? _toggleAllCallback;

  void _bind(VoidCallback callback) {
    _toggleAllCallback = callback;
  }

  void toggleAllSections() {
    _toggleAllCallback?.call();
  }

  void dispose() {
    allSectionsCollapsed.dispose();
  }
}

class ShopSeasonsScreen extends StatefulWidget {
  const ShopSeasonsScreen({
    super.key,
    this.controller,
  });

  final ShopSeasonsController? controller;

  @override
  State<ShopSeasonsScreen> createState() => _ShopSeasonsScreenState();
}

class _ShopSeasonsScreenState extends State<ShopSeasonsScreen> {
  static const String _otherSectionKey = 'other';
  static const String _collapsedSectionsPrefsKey =
      'shop_seasons_collapsed_sections';
  Future<_ShopSeasonsData>? _dataFuture;
  final Set<String> _collapsedSectionKeys = <String>{};
  Set<String> _allSectionKeys = <String>{};

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
    widget.controller?._bind(_toggleAllSectionsFromController);
    unawaited(_restoreCollapsedSections());
  }

  @override
  void didUpdateWidget(covariant ShopSeasonsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller?._bind(_toggleAllSectionsFromController);
    }
  }

  Future<_ShopSeasonsData> _loadData() async {
    final String specialRaw =
        await rootBundle.loadString('assets/data/special_packs.json');
    final SpecialPackCatalog catalog = SpecialPackCatalog.parse(specialRaw);
    final String packsRaw =
        await rootBundle.loadString('assets/data/shop_packs.json');
    final String contentsRaw =
        await rootBundle.loadString('assets/data/shop_pack_contents.json');
    final ShopPackBundle schedule = ShopPackBundle.parse(packsRaw, contentsRaw);
    return _ShopSeasonsData(catalog: catalog, schedule: schedule);
  }

  String _formatShopWindow(
    BuildContext context,
    ShopPackEntry pack,
    int visibleDays,
  ) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat df = DateFormat.yMMMd(locale.toString());
    final DateTime lastInclusive =
        pack.shopStart.add(Duration(days: visibleDays - 1));
    return context.l10n.shopPackWindowDates(
      df.format(pack.shopStart),
      df.format(lastInclusive),
    );
  }

  SpecialPackEntry? _findSpecialForScheduleRow(
    ShopPackEntry row,
    SpecialPackCatalog catalog,
  ) {
    for (final SpecialPackEntry special in catalog.packs) {
      if (special.matchesSchedulePackName(row.displayName)) {
        return special;
      }
    }
    return null;
  }

  Future<void> _openWiki(SpecialPackEntry pack) async {
    final Uri uri = Uri.parse(pack.wikiPageUrl());
    final bool ok =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!mounted || ok) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.shopPackWikiOpenFailed(uri.toString()))),
    );
  }

  void _toggleSection(String sectionKey) {
    setState(() {
      if (_collapsedSectionKeys.contains(sectionKey)) {
        _collapsedSectionKeys.remove(sectionKey);
      } else {
        _collapsedSectionKeys.add(sectionKey);
      }
    });
    unawaited(_persistCollapsedSections());
  }

  void _setAllSectionsCollapsed({
    required Iterable<String> sectionKeys,
    required bool collapsed,
  }) {
    setState(() {
      if (collapsed) {
        _collapsedSectionKeys
          ..clear()
          ..addAll(sectionKeys);
      } else {
        _collapsedSectionKeys.clear();
      }
    });
    unawaited(_persistCollapsedSections());
  }

  void _toggleAllSectionsFromController() {
    final List<String> sectionKeys = _allSectionKeys.toList(growable: false);
    if (sectionKeys.isEmpty) {
      return;
    }
    final bool allCollapsed = sectionKeys.every(_collapsedSectionKeys.contains);
    _setAllSectionsCollapsed(
      sectionKeys: sectionKeys,
      collapsed: !allCollapsed,
    );
  }

  Future<void> _restoreCollapsedSections() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> saved =
        prefs.getStringList(_collapsedSectionsPrefsKey) ?? <String>[];
    if (!mounted) {
      return;
    }
    setState(() {
      _collapsedSectionKeys
        ..clear()
        ..addAll(saved);
    });
  }

  Future<void> _persistCollapsedSections() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _collapsedSectionsPrefsKey,
      _collapsedSectionKeys.toList(growable: false),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String sectionKey,
    required String title,
    required Color titleColor,
  }) {
    final bool isCollapsed = _collapsedSectionKeys.contains(sectionKey);
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _toggleSection(sectionKey),
        child: ListTile(
          dense: true,
          minTileHeight: 24,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          title: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: titleColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          trailing: Icon(
            isCollapsed ? Icons.expand_more : Icons.expand_less,
            color: titleColor,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ShopSeasonsData>(
      future: _dataFuture,
      builder: (BuildContext context, AsyncSnapshot<_ShopSeasonsData> snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (snap.hasError || snap.data == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                context.l10n.shopPackScheduleLoadError(
                  snap.error ?? 'unknown',
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        final _ShopSeasonsData data = snap.data!;
        final SpecialPackCatalog catalog = data.catalog;
        final ShopPackBundle schedule = data.schedule;
        final DateTime nowUtc = DateTime.now().toUtc();
        final Locale locale = Localizations.localeOf(context);
        final DateFormat monthTitle = DateFormat.yMMMM(locale.toString());

        final List<_PackRowModel> scheduled = <_PackRowModel>[];
        final Set<String> scheduledSpecialSlugs = <String>{};
        for (final ShopPackEntry row in schedule.packs) {
          final SpecialPackEntry? special = _findSpecialForScheduleRow(
            row,
            catalog,
          );
          if (special == null) {
            continue;
          }
          scheduledSpecialSlugs.add(special.wikiSlug);
          scheduled.add(
            _PackRowModel(
              special: special,
              displaySchedule: row,
              sortDate: row.shopStart,
              inShopNow: shopPackIsInWindow(
                shopStart: row.shopStart,
                visibleDays: schedule.shopVisibleDays,
                now: nowUtc,
              ),
            ),
          );
        }
        scheduled.sort(
          (_PackRowModel a, _PackRowModel b) => a.sortDate!.compareTo(b.sortDate!),
        );

        final List<_PackRowModel> others = catalog.packs
            .where(
              (SpecialPackEntry sp) => !scheduledSpecialSlugs.contains(sp.wikiSlug),
            )
            .map(
              (SpecialPackEntry sp) => _PackRowModel(
                special: sp,
                displaySchedule: null,
                sortDate: null,
                inShopNow: false,
              ),
            )
            .toList()
          ..sort(
            (_PackRowModel a, _PackRowModel b) => a.special.displayName
                .toLowerCase()
                .compareTo(b.special.displayName.toLowerCase()),
          );

        final List<Widget> children = <Widget>[];

        final Map<String, List<_PackRowModel>> byMonth =
            <String, List<_PackRowModel>>{};
        for (final _PackRowModel m in scheduled) {
          final DateTime d = m.sortDate!;
          final String key =
              '${d.year.toString().padLeft(4, '0')}_${d.month.toString().padLeft(2, '0')}';
          byMonth.putIfAbsent(key, () => <_PackRowModel>[]).add(m);
        }

        final List<String> monthKeys = byMonth.keys.toList()..sort();
        final List<String> allSectionKeys = <String>[
          ...monthKeys,
          if (others.isNotEmpty) _otherSectionKey,
        ];
        final bool allCollapsed = allSectionKeys.isNotEmpty &&
            allSectionKeys.every(_collapsedSectionKeys.contains);
        _allSectionKeys = allSectionKeys.toSet();
        widget.controller?.allSectionsCollapsed.value = allCollapsed;

        for (final String mk in monthKeys) {
          final List<_PackRowModel> monthRows = byMonth[mk]!;
          final DateTime monthDate = monthRows.first.sortDate!;
          children.add(
            _buildSectionHeader(
              context: context,
              sectionKey: mk,
              title: monthTitle.format(
                DateTime(monthDate.year, monthDate.month, 1),
              ),
              titleColor: Theme.of(context).colorScheme.primary,
            ),
          );
          if (!_collapsedSectionKeys.contains(mk)) {
            for (final _PackRowModel m in monthRows) {
              children.add(
                _buildPackRow(
                  context,
                  m,
                  schedule,
                ),
              );
            }
          }
        }

        if (others.isNotEmpty) {
          children.add(
            _buildSectionHeader(
              context: context,
              sectionKey: _otherSectionKey,
              title: context.l10n.shopPackOtherCategory,
              titleColor: Theme.of(context).colorScheme.outline,
            ),
          );
          if (!_collapsedSectionKeys.contains(_otherSectionKey)) {
            for (final _PackRowModel m in others) {
              children.add(
                _buildPackRow(
                  context,
                  m,
                  schedule,
                ),
              );
            }
          }
        }

        return ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 24),
          children: children,
        );
      },
    );
  }

  Widget _buildPackRow(
    BuildContext context,
    _PackRowModel m,
    ShopPackBundle schedule,
  ) {
    final SpecialPackEntry pack = m.special;
    final ShopPackEntry? sched = m.displaySchedule;
    final String subtitle = sched != null
        ? _formatShopWindow(context, sched, schedule.shopVisibleDays)
        : context.l10n.shopPackNoRotationScheduled;

    final String? goldLabel =
        sched != null && sched.gcc.isNotEmpty ? sched.gcc : null;
    final String? onyxLabel =
        sched != null && sched.occasion.isNotEmpty ? sched.occasion : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ShopPackRow(
        title: pack.displayName,
        subtitle: subtitle,
        scheduleImageFile: sched?.imageFile,
        selectorFile: pack.selectorFile,
        goldLabel: goldLabel,
        onyxLabel: onyxLabel,
        inShopNow: m.inShopNow,
        onTap: () => _openWiki(pack),
      ),
    );
  }
}

@immutable
class _ShopSeasonsData {
  const _ShopSeasonsData({
    required this.catalog,
    required this.schedule,
  });

  final SpecialPackCatalog catalog;
  final ShopPackBundle schedule;
}

@immutable
class _PackRowModel {
  const _PackRowModel({
    required this.special,
    required this.displaySchedule,
    required this.sortDate,
    required this.inShopNow,
  });

  final SpecialPackEntry special;
  final ShopPackEntry? displaySchedule;
  final DateTime? sortDate;
  final bool inShopNow;
}
