import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/config/tenant_config.dart';
import '../core/config/app_provider.dart';
import '../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  final TenantConfig config;
  const LoginScreen({super.key, required this.config});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  TenantConfig get config => widget.config;

  @override
  Widget build(BuildContext context) {
    final theme    = AppTheme(config);
    final provider = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),

              // Logo / app name
              Text(
                config.appName,
                style: TextStyle(
                  fontFamily: config.headingFont,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: theme.primary,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                config.tagline,
                style: TextStyle(
                  fontFamily: config.bodyFont,
                  fontSize: 15,
                  color: theme.muted,
                ),
              ),

              const SizedBox(height: 52),

              // Email
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    color: theme.muted,
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              if (provider.error != null) ...[
                const SizedBox(height: 12),
                Text(provider.error!, style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
              ],

              const SizedBox(height: 28),

              // Sign in button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: provider.loading ? null : () async {
                    await provider.login(_emailCtrl.text.trim(), _passCtrl.text);
                  },
                  child: provider.loading
                      ? const SizedBox(height: 18, width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sign In'),
                ),
              ),

              const SizedBox(height: 16),

              // Guest / magic link option
              Center(
                child: TextButton(
                  onPressed: () => _showMagicLink(context, provider),
                  child: const Text('Send magic link instead'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMagicLink(BuildContext context, AppProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme(config).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _MagicLinkSheet(config: config, provider: provider),
    );
  }
}

class _MagicLinkSheet extends StatefulWidget {
  final TenantConfig config;
  final AppProvider provider;
  const _MagicLinkSheet({required this.config, required this.provider});

  @override
  State<_MagicLinkSheet> createState() => _MagicLinkSheetState();
}

class _MagicLinkSheetState extends State<_MagicLinkSheet> {
  final _ctrl = TextEditingController();
  bool _sent  = false;
  bool _busy  = false;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme(widget.config);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24,
          MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Magic Link', style: TextStyle(
              fontFamily: widget.config.headingFont,
              fontSize: 20, fontWeight: FontWeight.w700, color: theme.textPrimary)),
          const SizedBox(height: 16),
          if (!_sent) ...[
            TextField(controller: _ctrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : () async {
                  setState(() => _busy = true);
                  await widget.provider.api.authSendMagicLink(_ctrl.text.trim());
                  setState(() { _sent = true; _busy = false; });
                },
                child: _busy
                    ? const SizedBox(height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Send Link'),
              ),
            ),
          ] else ...[
            Text('Check your email for a sign-in link.',
                style: TextStyle(color: theme.muted, fontSize: 14)),
            const SizedBox(height: 16),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ],
      ),
    );
  }
}
