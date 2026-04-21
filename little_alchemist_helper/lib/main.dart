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
  double _bootstrapProgress = 0.0;
  String _bootstrapMessage = '';

  @override
  void initState() {
    super.initState();
    AppController.bootstrapWithProgress(
      onProgress: (String message, double progress) {
        if (!mounted) {
          return;
        }
        setState(() {
          _bootstrapMessage = message;
          _bootstrapProgress = progress;
        });
      },
    ).then(
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
        home: _BootstrapLoadingScreen(
          progress: _bootstrapProgress,
          message: _bootstrapMessage,
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

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen({
    required this.progress,
    required this.message,
  });

  final double progress;
  final String message;

  @override
  Widget build(BuildContext context) {
    final double clamped = progress.clamp(0.0, 1.0);
    final int percent = (clamped * 100).round();
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  context.l10n.appTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Text(
                  message.isEmpty ? context.l10n.bootstrapInitializing : message,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(value: clamped),
                const SizedBox(height: 8),
                Text(
                  '$percent%',
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
