import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/config/tenant_config.dart';
import '../../core/config/app_provider.dart';
import '../../core/theme/app_theme.dart';

class EventsScreen extends StatefulWidget {
  final TenantConfig config;
  const EventsScreen({super.key, required this.config});
  @override State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<Map<String, dynamic>> _events = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final api = context.read<AppProvider>().api;
      final res = await api.getEvents();
      final list = (res['data']?['events'] ?? res['events']) as List? ?? [];
      setState(() { _events = list.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme(widget.config);
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(title: const Text('Events')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
              ? Center(child: Text('No upcoming events', style: TextStyle(color: theme.muted)))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final e = _events[i];
                    return Container(
                      decoration: theme.cardDecoration(),
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e['title'] ?? '', style: TextStyle(
                            fontFamily: widget.config.headingFont, fontSize: 16,
                            fontWeight: FontWeight.w700, color: theme.textPrimary)),
                        const SizedBox(height: 6),
                        if (e['starts_at'] != null)
                          Text(e['starts_at'].toString().substring(0, 10),
                              style: TextStyle(color: theme.muted, fontSize: 13,
                                  fontFamily: widget.config.bodyFont)),
                        if (e['location'] != null)
                          Text(e['location'], style: TextStyle(
                              color: theme.primary, fontSize: 13,
                              fontFamily: widget.config.bodyFont)),
                      ]),
                    );
                  }),
    );
  }
}
