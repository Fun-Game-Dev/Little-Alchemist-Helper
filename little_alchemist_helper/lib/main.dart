import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'l10n/l10n_ext.dart';
import 'l10n/app_localizations.dart';
import 'state/app_controller.dart';
import 'ui/home_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LittleAlchemistBootstrap());
}

class LittleAlchemistBootstrap extends StatefulWidget {
  const LittleAlchemistBootstrap({super.key});

  @override
  State<LittleAlchemistBootstrap> createState() =>
      _LittleAlchemistBootstrapState();
}

class _LittleAlchemistBootstrapState extends State<LittleAlchemistBootstrap> {
  AppController? _controller;
  Object? _error;

  @override
  void initState() {
    super.initState();
    AppController.bootstrap().then(
      (AppController c) {
        if (mounted) {
          setState(() => _controller = c);
        }
      },
      onError: (Object e) {
        if (mounted) {
          setState(() => _error = e);
        }
      },
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (
          Locale? locale,
          Iterable<Locale> supportedLocales,
        ) {
          if (locale == null) {
            return const Locale('en');
          }
          for (final Locale supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
          return const Locale('en');
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Builder(
                builder: (BuildContext context) {
                  return Text(context.l10n.startupError(_error.toString()));
                },
              ),
            ),
          ),
        ),
      );
    }
    if (_controller == null) {
      return MaterialApp(
        onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (
          Locale? locale,
          Iterable<Locale> supportedLocales,
        ) {
          if (locale == null) {
            return const Locale('en');
          }
          for (final Locale supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
          return const Locale('en');
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator.adaptive()),
        ),
      );
    }
    return ChangeNotifierProvider<AppController>.value(
      value: _controller!,
      child: MaterialApp(
        onGenerateTitle: (BuildContext context) => context.l10n.appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (
          Locale? locale,
          Iterable<Locale> supportedLocales,
        ) {
          if (locale == null) {
            return const Locale('en');
          }
          for (final Locale supported in supportedLocales) {
            if (supported.languageCode == locale.languageCode) {
              return supported;
            }
          }
          return const Locale('en');
        },
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: const HomeShell(),
      ),
    );
  }
}
