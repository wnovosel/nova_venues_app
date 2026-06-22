import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/tenant_config.dart';
import '../../core/config/app_provider.dart';
import '../../core/theme/app_theme.dart';

class MenuScreen extends StatefulWidget {
  final TenantConfig config;
  const MenuScreen({super.key, required this.config});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<Map<String, dynamic>> _venues = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final api = context.read<AppProvider>().api;
      final res = await api.getMenuVenues();
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
      appBar: AppBar(title: const Text('Menu')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _venues.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final v = _venues[i];
                return _VenueCard(
                  config: widget.config,
                  theme: theme,
                  venue: v,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => MenuDetailScreen(
                        config: widget.config, slug: v['slug'], name: v['name']))),
                );
              },
            ),
    );
  }
}

class _VenueCard extends StatelessWidget {
  final TenantConfig config;
  final AppTheme theme;
  final Map<String, dynamic> venue;
  final VoidCallback onTap;
  const _VenueCard({required this.config, required this.theme,
      required this.venue, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: theme.cardDecoration(),
        child: Row(children: [
          // Venue image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: venue['hero_image_url'] != null
                ? Image.network(venue['hero_image_url'], width: 90, height: 90, fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _placeholder(theme))
                : _placeholder(theme),
          ),
          const SizedBox(width: 16),
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(venue['name'] ?? '', style: TextStyle(
                  fontFamily: config.headingFont, fontSize: 16,
                  fontWeight: FontWeight.w700, color: theme.textPrimary)),
              if (venue['description'] != null) ...[
                const SizedBox(height: 4),
                Text(venue['description'], maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: config.bodyFont,
                        fontSize: 12, color: theme.muted)),
              ],
            ]),
          )),
          Icon(Icons.chevron_right, color: theme.muted),
          const SizedBox(width: 8),
        ]),
      ),
    );
  }

  Widget _placeholder(AppTheme theme) => Container(
    width: 90, height: 90, color: Color(theme.config.primaryColor).withOpacity(0.1),
    child: Icon(Icons.restaurant, color: Color(theme.config.primaryColor), size: 32));
}

// ── Menu detail (items for one venue) ────────────────────────────────────────

class MenuDetailScreen extends StatefulWidget {
  final TenantConfig config;
  final String slug;
  final String name;
  const MenuDetailScreen({super.key, required this.config,
      required this.slug, required this.name});

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final api = context.read<AppProvider>().api;
      final res = await api.getMenuByVenue(widget.slug);
      setState(() { _data = res['data'] as Map<String, dynamic>?; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme    = AppTheme(widget.config);
    final sections = (_data?['sections'] as List? ?? []).cast<Map<String, dynamic>>();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(title: Text(widget.name)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sections.length,
              itemBuilder: (_, i) => _SectionWidget(
                  config: widget.config, theme: theme, section: sections[i]),
            ),
    );
  }
}

class _SectionWidget extends StatelessWidget {
  final TenantConfig config;
  final AppTheme theme;
  final Map<String, dynamic> section;
  const _SectionWidget({required this.config, required this.theme, required this.section});

  @override
  Widget build(BuildContext context) {
    final items = (section['items'] as List? ?? []).cast<Map<String, dynamic>>();
    final subs  = (section['subcategories'] as List? ?? []).cast<Map<String, dynamic>>();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(section['category'] ?? '', style: TextStyle(
            fontFamily: config.headingFont, fontSize: 18,
            fontWeight: FontWeight.w700, color: theme.primary)),
      ),
      ...items.map((item) => _MenuItemTile(config: config, theme: theme, item: item)),
      ...subs.map((sub) => _SectionWidget(config: config, theme: theme, section: sub)),
      Divider(color: theme.border),
    ]);
  }
}

class _MenuItemTile extends StatelessWidget {
  final TenantConfig config;
  final AppTheme theme;
  final Map<String, dynamic> item;
  const _MenuItemTile({required this.config, required this.theme, required this.item});

  @override
  Widget build(BuildContext context) {
    final price = item['price'];
    final priceLabel = item['price_label'];
    final priceStr = priceLabel ?? (price != null ? '\$${(price as num).toStringAsFixed(2)}' : '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item['name'] ?? '', style: TextStyle(
              fontFamily: config.bodyFont, fontSize: 15,
              fontWeight: FontWeight.w600, color: theme.textPrimary)),
          if (item['description'] != null) ...[
            const SizedBox(height: 3),
            Text(item['description'], style: TextStyle(
                fontFamily: config.bodyFont, fontSize: 12, color: theme.muted)),
          ],
        ])),
        if (priceStr.isNotEmpty) ...[
          const SizedBox(width: 12),
          Text(priceStr, style: TextStyle(
              fontFamily: config.bodyFont, fontSize: 14,
              fontWeight: FontWeight.w700, color: theme.primary)),
        ],
      ]),
    );
  }
}
