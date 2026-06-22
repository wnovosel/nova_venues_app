import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/tenant_config.dart';
import '../../core/config/app_provider.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  final TenantConfig config;
  const HomeScreen({super.key, required this.config});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final api = context.read<AppProvider>().api;
      final res = await api.getDashboard();
      setState(() { _data = res['data'] as Map<String, dynamic>?; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  TenantConfig get config => widget.config;

  @override
  Widget build(BuildContext context) {
    final theme    = AppTheme(config);
    final provider = context.watch<AppProvider>();
    final user     = provider.user;

    return Scaffold(
      backgroundColor: theme.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            backgroundColor: theme.surface,
            title: Text(config.appName,
              style: TextStyle(
                fontFamily: config.headingFont,
                color: theme.primary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            actions: [
              if (config.enablePushNotifications)
                IconButton(
                  icon: Icon(Icons.notifications_outlined, color: theme.textPrimary),
                  onPressed: () {},
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: _loading
                ? const Padding(padding: EdgeInsets.only(top: 60),
                    child: Center(child: CircularProgressIndicator()))
                : _error != null
                    ? Padding(padding: const EdgeInsets.all(24),
                        child: Text(_error!, style: TextStyle(color: theme.muted)))
                    : _HomeBody(config: config, theme: theme, data: _data, user: user),
          ),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final TenantConfig config;
  final AppTheme theme;
  final Map<String, dynamic>? data;
  final Map<String, dynamic>? user;

  const _HomeBody({required this.config, required this.theme,
      required this.data, required this.user});

  @override
  Widget build(BuildContext context) {
    final firstName = user?['first_name'] ?? user?['display_name'] ?? 'Guest';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting
          Text('Welcome back,', style: TextStyle(
              fontFamily: config.bodyFont, fontSize: 14, color: theme.muted)),
          Text(firstName, style: TextStyle(
              fontFamily: config.headingFont, fontSize: 28,
              fontWeight: FontWeight.w700, color: theme.textPrimary)),

          const SizedBox(height: 24),

          // Hero card
          Container(
            width: double.infinity,
            height: 160,
            decoration: theme.heroDecoration(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(config.tagline, style: const TextStyle(
                    color: Colors.white, fontSize: 22,
                    fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                const SizedBox(height: 4),
                Text(config.appName, style: const TextStyle(
                    color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Quick action grid
          Text('Quick Actions', style: TextStyle(
              fontFamily: config.headingFont, fontSize: 16,
              fontWeight: FontWeight.w700, color: theme.textPrimary)),
          const SizedBox(height: 12),

          Row(children: [
            if (config.enableMenu)   Expanded(child: _ActionCard(theme: theme, config: config, icon: Icons.restaurant_menu, label: 'Menu')),
            if (config.enableMenu)   const SizedBox(width: 12),
            if (config.enableEvents) Expanded(child: _ActionCard(theme: theme, config: config, icon: Icons.event, label: 'Events')),
          ]),
          if (config.enableStore || config.enableMap) ...[
            const SizedBox(height: 12),
            Row(children: [
              if (config.enableStore) Expanded(child: _ActionCard(theme: theme, config: config, icon: Icons.shopping_bag_outlined, label: 'Shop')),
              if (config.enableStore) const SizedBox(width: 12),
              if (config.enableMap)   Expanded(child: _ActionCard(theme: theme, config: config, icon: Icons.map_outlined, label: 'Map')),
            ]),
          ],
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final AppTheme theme;
  final TenantConfig config;
  final IconData icon;
  final String label;
  const _ActionCard({required this.theme, required this.config,
      required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: theme.cardDecoration(),
      child: Column(children: [
        Icon(icon, color: theme.primary, size: 28),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(
            fontFamily: config.bodyFont, fontSize: 13,
            fontWeight: FontWeight.w600, color: theme.textPrimary)),
      ]),
    );
  }
}
