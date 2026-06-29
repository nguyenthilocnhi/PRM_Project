import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/features/settings/settings_provider.dart';
import 'package:project/features/game/game_provider.dart';
import 'package:project/features/game/storage_service.dart';
import 'package:project/features/screens/home_screen.dart';

class SettingsDialog extends StatelessWidget {
  final bool isGameScreen;
  const SettingsDialog({super.key, this.isGameScreen = false});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topRight,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            decoration: BoxDecoration(
              color: const Color(0xfffff8df), // Beige background
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Settings',
                  style: TextStyle(
                    color: Color(0xffa16d6d), // Text color matching the theme roughly
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSettingRow(
                  title: 'Music',
                  value: settingsProvider.isMusicEnabled,
                  onChanged: (val) => settingsProvider.toggleMusic(),
                ),
                const SizedBox(height: 12),
                _buildSettingRow(
                  title: 'Sound',
                  value: settingsProvider.isSfxEnabled,
                  onChanged: (val) => settingsProvider.toggleSfx(),
                ),
                const SizedBox(height: 12),
                _buildSettingRow(
                  title: 'Vibration',
                  value: settingsProvider.isVibrationEnabled,
                  onChanged: (val) => settingsProvider.toggleVibration(),
                ),
                const SizedBox(height: 24),
                isGameScreen ? _buildRestartLevelButton(context) : _buildResetButton(context),
              ],
            ),
          ),
          Positioned(
            top: -12,
            right: -12,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xff1597f5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffefe0d5), width: 2), // Subtle border
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xffa16d6d),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xffa16d6d),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showResetDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffefe0d5), width: 2),
        ),
        child: const Text(
          'Reset Progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xffa16d6d),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRestartLevelButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<GameProvider>().restartLevel();
        Navigator.of(context).pop();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xffefe0d5), width: 2),
        ),
        child: const Text(
          'Restart Level',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xffa16d6d),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Progress?', style: TextStyle(color: Colors.red)),
        content: const Text('Are you sure you want to reset all your progress? This will lock all levels and clear your hints. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.black87)),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              Navigator.of(ctx).pop();
              final storage = StorageService();
              await storage.clearAllData();
              
              if (context.mounted) {
                await context.read<GameProvider>().loadInitialData();
                navigator.pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('RESET', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
