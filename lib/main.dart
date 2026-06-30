import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/config/tenant_config.dart';
import 'core/config/app_provider.dart';
import 'core/theme/app_theme.dart';
import 'screens/shell_screen.dart';
import 'screens/login_screen.dart';
import 'flavors/nova_cellars_config.dart';

/// Entry point — receives the TenantConfig from the flavor file.
/// Each flavor's main_<flavor>.dart calls this with its own config.
void main() => runVenueApp(kNovaCellarsConfig);

void runVenueApp(TenantConfig config) {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(NovaVenueApp(config: config));
}

class NovaVenueApp extends StatelessWidget {
  final TenantConfig config;
  const NovaVenueApp({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(config),
      child: Builder(builder: (context) {
        final theme = AppTheme(config).build();
        return MaterialApp(
          title: config.appName,
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Consumer<AppProvider>(
            builder: (_, provider, __) =>
                provider.isLoggedIn ? ShellScreen(config: config) : LoginScreen(config: config),
          ),
        );
      }),
    );
  }
}
