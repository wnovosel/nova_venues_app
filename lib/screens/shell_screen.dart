import 'package:flutter/material.dart';
import '../core/config/tenant_config.dart';
import '../core/theme/app_theme.dart';
import '../features/home/home_screen.dart';
import '../features/menu/menu_screen.dart';
import '../features/events/events_screen.dart';
import '../features/map/map_screen.dart';
import '../features/account/account_screen.dart';

/// Root tab shell. Tabs are built dynamically from TenantConfig feature flags.
/// A venue with enableMenu=false simply never sees the Menu tab.
class ShellScreen extends StatefulWidget {
  final TenantConfig config;
  const ShellScreen({super.key, required this.config});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  TenantConfig get config => widget.config;

  List<_Tab> get _tabs {
    final theme = AppTheme(config);
    return [
      _Tab(label: 'Home',    icon: Icons.home_outlined,      active: Icons.home,            screen: HomeScreen(config: config)),
      if (config.enableMenu)
        _Tab(label: 'Menu',  icon: Icons.restaurant_menu_outlined, active: Icons.restaurant_menu, screen: MenuScreen(config: config)),
      if (config.enableEvents)
        _Tab(label: 'Events',icon: Icons.event_outlined,     active: Icons.event,           screen: EventsScreen(config: config)),
      if (config.enableMap)
        _Tab(label: 'Map',   icon: Icons.map_outlined,       active: Icons.map,             screen: MapScreen(config: config)),
      _Tab(label: 'Account', icon: Icons.person_outline,     active: Icons.person,          screen: AccountScreen(config: config)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tabs   = _tabs;
    final theme  = AppTheme(config);
    final safeIdx = _index.clamp(0, tabs.length - 1);

    return Scaffold(
      body: IndexedStack(
        index: safeIdx,
        children: tabs.map((t) => t.screen).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIdx,
        onTap: (i) => setState(() => _index = i),
        items: tabs.map((t) => BottomNavigationBarItem(
          icon:       Icon(t.icon),
          activeIcon: Icon(t.active),
          label:      t.label,
        )).toList(),
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData active;
  final Widget screen;
  const _Tab({required this.label, required this.icon, required this.active, required this.screen});
}
