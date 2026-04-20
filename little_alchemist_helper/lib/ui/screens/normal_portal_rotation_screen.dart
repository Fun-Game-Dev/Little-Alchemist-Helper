import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/portal_rotation_service.dart';
import '../../util/card_display_emojis.dart';

class NormalPortalRotationScreen extends StatefulWidget {
  const NormalPortalRotationScreen({super.key});

  @override
  State<NormalPortalRotationScreen> createState() =>
      _NormalPortalRotationScreenState();
}

class _NormalPortalRotationScreenState
    extends State<NormalPortalRotationScreen> {
  static const PortalRotationService _rotationService = PortalRotationService();

  Timer? _ticker;
  PortalRotationSnapshot _snapshot = _rotationService.snapshotAt();

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (Timer _) {
      if (!mounted) {
        return;
      }
      setState(() {
        _snapshot = _rotationService.snapshotAt();
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _openEventWiki(PortalEventEntry event) async {
    final Uri uri = Uri.parse(event.wikiPageUrl);
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!mounted || opened) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Не удалось открыть страницу события')),
    );
  }

  String _remainingLabel() {
    final Duration remaining = _snapshot.remaining;
    final int days = remaining.inDays;
    if (days <= 0) {
      final int hours = remaining.inHours;
      return 'осталось ${hours.clamp(1, 24)} ч';
    }
    return 'осталось $days д';
  }

  String _bannerLabel() {
    if (_snapshot.isPortalOpen) {
      final PortalEventEntry activeEvent = _snapshot.activeEvent!;
      return 'Сейчас идет: ${activeEvent.eventName} (${activeEvent.bossName}), ${_remainingLabel()}';
    }
    return 'Портал закрыт, до ${_snapshot.nextEvent.eventName} ${_remainingLabel()}';
  }

  String _nextEventWindowLabel(BuildContext context) {
    final DateTime now = DateTime.now().toUtc();
    final DateTime nextStart = _snapshot.isPortalOpen
        ? now.add(_snapshot.remaining).add(const Duration(days: 4))
        : now.add(_snapshot.remaining);
    final DateTime nextEnd = nextStart.add(const Duration(days: 10));
    final Locale locale = Localizations.localeOf(context);
    final DateFormat dateFormat = DateFormat.yMMMd(locale.toString());
    return 'Следующий: ${_snapshot.nextEvent.eventName} (${dateFormat.format(nextStart)} - ${dateFormat.format(nextEnd)})';
  }

  String _formatDurationLabel(Duration duration) {
    final int days = duration.inDays;
    if (days > 0) {
      return '$days д';
    }
    final int hours = duration.inHours;
    if (hours > 0) {
      return '$hours ч';
    }
    final int minutes = duration.inMinutes;
    return '${minutes.clamp(1, 59)} м';
  }

  @override
  Widget build(BuildContext context) {
    final Locale locale = Localizations.localeOf(context);
    final DateFormat itemDateFormat = DateFormat.MMMd(locale.toString());
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 24),
      itemCount: PortalRotationService.events.length + 1,
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return _CurrentPortalEventBanner(
            primaryLabel: _bannerLabel(),
            secondaryLabel: _nextEventWindowLabel(context),
          );
        }
        final PortalEventEntry event = PortalRotationService.events[index - 1];
        final PortalEventWindow window = _rotationService.nextWindowForEvent(
          event,
        );
        final bool isCurrent =
            _snapshot.isPortalOpen && identical(event, _snapshot.activeEvent);
        return _PortalEventCard(
          event: event,
          onTap: () => _openEventWiki(event),
          isCurrent: isCurrent,
          window: window,
          formatDurationLabel: _formatDurationLabel,
          dateFormat: itemDateFormat,
        );
      },
    );
  }
}

class _CurrentPortalEventBanner extends StatelessWidget {
  const _CurrentPortalEventBanner({
    required this.primaryLabel,
    required this.secondaryLabel,
  });

  final String primaryLabel;
  final String secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary, width: 1.4),
      ),
      child: Row(
        children: <Widget>[
          Icon(Icons.schedule, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  primaryLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  secondaryLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.9,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortalEventCard extends StatelessWidget {
  const _PortalEventCard({
    required this.event,
    required this.onTap,
    required this.isCurrent,
    required this.window,
    required this.formatDurationLabel,
    required this.dateFormat,
  });

  final PortalEventEntry event;
  final VoidCallback onTap;
  final bool isCurrent;
  final PortalEventWindow window;
  final String Function(Duration duration) formatDurationLabel;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isCurrent
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.45)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    event.iconAssetPath,
                    width: 72,
                    height: 96,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return ColoredBox(
                            color: theme.colorScheme.surfaceContainerHighest,
                            child: SizedBox(
                              width: 72,
                              height: 96,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          );
                        },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(
                        255,
                        222,
                        218,
                        218,
                      ).withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            event.eventName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Boss: ${event.bossName}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            window.isActiveNow
                                ? 'Идет сейчас, до конца ${formatDurationLabel(window.timeUntilEnd!)}'
                                : '${dateFormat.format(window.startUtc)} - ${dateFormat.format(window.endUtc)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _GccCardBadge(text: event.gccName),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GccCardBadge extends StatelessWidget {
  const _GccCardBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String emoji = rarityTierEmoji('rare');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
        ),
      ),
      child: Text(
        '$emoji $text',
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.tertiary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
