import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/sms_provider.dart';
import 'screens/inbox_screen.dart';

import 'screens/permission_screen.dart';

/// Point d'entrée de l'application TestifySMS.
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force l'orientation portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    // Injection du SmsProvider à la racine de l'arbre de widgets
    ChangeNotifierProvider(
      create: (_) => SmsProvider(),
      child: const TestifySmsApp(),
    ),
  );
}

/// Widget racine de l'application.
class TestifySmsApp extends StatelessWidget {
  const TestifySmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TestifySMS',
      debugShowCheckedModeBanner: false,
      // Thèmes Material 3
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // Thème clair forcé
      home: const _AppInitializer(),
    );
  }
}

/// Widget d'initialisation : lance la vérification des permissions
/// puis route vers l'écran approprié.
class _AppInitializer extends StatefulWidget {
  const _AppInitializer();

  @override
  State<_AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<_AppInitializer> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await context.read<SmsProvider>().initialize();
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    // Écran de chargement initial
    if (!_initialized) {
      return const _SplashScreen();
    }

    // Routage selon l'état des permissions
    return Consumer<SmsProvider>(
      builder: (_, provider, __) {
        if (!provider.hasPermission) {
          return const PermissionScreen();
        }
        return const InboxScreen();
      },
    );
  }
}

// ─── Écran de démarrage (Splash) ──────────────────────────────────────────────

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo animé
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutBack,
              builder: (_, value, child) =>
                  Transform.scale(scale: value, child: child),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(80),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.sms_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'TestifySMS',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vérification des permissions...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
