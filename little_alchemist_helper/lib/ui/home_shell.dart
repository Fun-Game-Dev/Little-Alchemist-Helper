import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/l10n_ext.dart';
import '../state/app_controller.dart';
import 'screens/collection_screen.dart';
import 'screens/combo_lab_screen.dart';
import 'screens/deck_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/timed_events_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    DeckScreen(),
    CollectionScreen(),
    ComboLabScreen(),
    TimedEventsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    context.read<AppController>().setLocale(Localizations.localeOf(context));
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.appTitle)),
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (int i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.style_outlined),
            activeIcon: Icon(Icons.style),
            label: context.l10n.tabDeck,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark_outlined),
            activeIcon: Icon(Icons.collections_bookmark),
            label: context.l10n.tabCollection,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.science_outlined),
            activeIcon: Icon(Icons.science),
            label: context.l10n.tabCombo,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Эвенты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tune_outlined),
            activeIcon: Icon(Icons.tune),
            label: context.l10n.tabSettings,
          ),
        ],
      ),
    );
  }
}
