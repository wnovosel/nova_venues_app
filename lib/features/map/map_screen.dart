import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/tenant_config.dart';
import '../../core/config/app_provider.dart';
import '../../core/theme/app_theme.dart';

// ── Map Screen ───────────────────────────────────────────────────────────────

class MapScreen extends StatefulWidget {
  final TenantConfig config;
  const MapScreen({super.key, required this.config});
  @override State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Map<String, dynamic>> _venues = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final api = context.read<AppProvider>().api;
      final res = await api.getVenues();
      final list = (res['data']?['venues'] ?? res['venues']) as List? ?? [];
      setState(() { _venues = list.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme(widget.config);
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(title: const Text('Our Venues')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _venues.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final v = _venues[i];
                return Container(
                  decoration: theme.cardDecoration(),
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(v['name'] ?? '', style: TextStyle(
                          fontFamily: widget.config.headingFont, fontSize: 16,
                          fontWeight: FontWeight.w700, color: theme.textPrimary)),
                      if (v['tagline'] != null)
                        Text(v['tagline'], style: TextStyle(
                            color: theme.muted, fontSize: 12, fontFamily: widget.config.bodyFont)),
                      if (v['hours'] != null) ...[
                        const SizedBox(height: 6),
                        Row(children: [
                          Icon(Icons.access_time, size: 13, color: theme.primary),
                          const SizedBox(width: 4),
                          Text(v['hours'], style: TextStyle(
                              color: theme.primary, fontSize: 12,
                              fontFamily: widget.config.bodyFont)),
                        ]),
                      ],
                    ])),
                    Icon(Icons.chevron_right, color: theme.muted),
                  ]),
                );
              }),
    );
  }
}

// ── Account Screen ────────────────────────────────────────────────────────────

class AccountScreen extends StatelessWidget {
  final TenantConfig config;
  const AccountScreen({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final theme    = AppTheme(config);
    final provider = context.watch<AppProvider>();
    final user     = provider.user;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // User info
          Container(
            decoration: theme.cardDecoration(),
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              CircleAvatar(
                backgroundColor: Color(config.primaryColor).withOpacity(0.15),
                radius: 28,
                child: Text(
                  (user?['first_name'] ?? user?['display_name'] ?? 'G')
                      .substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
                      color: Color(config.primaryColor)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(user?['display_name'] ?? user?['first_name'] ?? 'Guest',
                    style: TextStyle(fontFamily: config.headingFont, fontSize: 17,
                        fontWeight: FontWeight.w700, color: theme.textPrimary)),
                Text(user?['email'] ?? '',
                    style: TextStyle(fontFamily: config.bodyFont,
                        fontSize: 13, color: theme.muted)),
              ])),
            ]),
          ),

          const SizedBox(height: 24),

          // Links
          _tile(theme, Icons.language_outlined, 'Website', () {
            // TODO: re-enable url_launcher once Xcode Cloud module resolution is fixed
          }),
          _tile(theme, Icons.email_outlined, 'Contact Support', () {
            // TODO: re-enable url_launcher once Xcode Cloud module resolution is fixed
          }),

          const SizedBox(height: 24),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Sign Out'),
              onPressed: () => provider.logout(),
            ),
          ),

          const SizedBox(height: 12),
          Center(child: Text('${config.appName} · Powered by Nova',
              style: TextStyle(color: theme.muted, fontSize: 11,
                  fontFamily: config.bodyFont))),
        ],
      ),
    );
  }

  Widget _tile(AppTheme theme, IconData icon, String label, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: theme.primary),
        title: Text(label, style: TextStyle(
            fontFamily: config.bodyFont, color: theme.textPrimary)),
        trailing: Icon(Icons.chevron_right, color: theme.muted),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
      );
}
