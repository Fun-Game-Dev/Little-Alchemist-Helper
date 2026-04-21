import 'package:flutter/material.dart';

import '../../l10n/l10n_ext.dart';
import 'arena_shop_rotation_screen.dart';
import 'normal_portal_rotation_screen.dart';
import 'shop_seasons_screen.dart';

class TimedEventsScreen extends StatefulWidget {
  const TimedEventsScreen({super.key});

  @override
  State<TimedEventsScreen> createState() => _TimedEventsScreenState();
}

class _TimedEventsScreenState extends State<TimedEventsScreen> {
  late final ShopSeasonsController _shopController;

  @override
  void initState() {
    super.initState();
    _shopController = ShopSeasonsController();
  }

  @override
  void dispose() {
    _shopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<_EventCardModel> events = <_EventCardModel>[
      _EventCardModel(
        title: context.l10n.eventsShopTitle,
        subtitle: context.l10n.eventsShopSubtitle,
        imageAssetPath: 'assets/icons/list/Shop.png',
        screenBuilder: () => ShopSeasonsScreen(controller: _shopController),
        actionsBuilder: (BuildContext context) => <Widget>[
          ValueListenableBuilder<bool>(
            valueListenable: _shopController.allSectionsCollapsed,
            builder: (BuildContext context, bool allCollapsed, Widget? child) {
              return IconButton(
                tooltip: allCollapsed
                    ? context.l10n.eventsExpandAll
                    : context.l10n.eventsCollapseAll,
                onPressed: _shopController.toggleAllSections,
                icon: Icon(
                  allCollapsed ? Icons.unfold_more : Icons.unfold_less,
                ),
              );
            },
          ),
        ],
      ),
      _EventCardModel(
        title: context.l10n.eventsArenaTitle,
        subtitle: context.l10n.eventsArenaSubtitle,
        imageAssetPath: 'assets/icons/list/Arena.png',
        screenBuilder: () => const ArenaShopRotationScreen(),
      ),
      _EventCardModel(
        title: context.l10n.eventsPortalTitle,
        subtitle: context.l10n.eventsPortalSubtitle,
        imageAssetPath: 'assets/icons/list/Portal.png',
        screenBuilder: () => const NormalPortalRotationScreen(),
      ),
    ];

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      itemCount: events.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final _EventCardModel event = events[index];
        return _TimedEventCard(model: event);
      },
    );
  }
}

class _TimedEventCard extends StatelessWidget {
  const _TimedEventCard({required this.model});

  final _EventCardModel model;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => _EventDetailsPage(
                title: model.title,
                child: model.screenBuilder(),
                actions: model.actionsBuilder?.call(context),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              Image.asset(
                model.imageAssetPath,
                width: 64,
                height: 64,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      model.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      model.subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventCardModel {
  const _EventCardModel({
    required this.title,
    required this.subtitle,
    required this.imageAssetPath,
    required this.screenBuilder,
    this.actionsBuilder,
  });

  final String title;
  final String subtitle;
  final String imageAssetPath;
  final Widget Function() screenBuilder;
  final List<Widget> Function(BuildContext context)? actionsBuilder;
}

class _EventDetailsPage extends StatelessWidget {
  const _EventDetailsPage({
    required this.title,
    required this.child,
    this.actions,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: actions,
      ),
      body: SafeArea(child: child),
    );
  }
}
