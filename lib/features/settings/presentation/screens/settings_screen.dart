import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/l10n/l10n_ext.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          SwitchListTile(
            value: true,
            onChanged: null,
            title: Text(l10n.enableExpiryNotifications),
            subtitle: Text(l10n.expiryNotificationsSubtitle),
          ),
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(l10n.languageArabic),
            leading: const Icon(Icons.language_rounded),
          ),
        ],
      ),
    );
  }
}
