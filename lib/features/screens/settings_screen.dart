import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/features/settings/settings_provider.dart';
import 'package:project/features/game/game_provider.dart';
import 'package:project/features/game/storage_service.dart';
import 'package:project/features/screens/home_screen.dart';
import 'package:project/features/widgets/custom_confirm_dialog.dart';

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
            width: 320, // Constrain width for a compact look
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
                  icon: Icons.music_note_rounded,
                  value: settingsProvider.isMusicEnabled,
                  onChanged: (val) => settingsProvider.toggleMusic(),
                ),
                const SizedBox(height: 12),
                _buildSettingRow(
                  title: 'Sound',
                  icon: Icons.volume_up_rounded,
                  value: settingsProvider.isSfxEnabled,
                  onChanged: (val) => settingsProvider.toggleSfx(),
                ),
                const SizedBox(height: 12),
                _buildSettingRow(
                  title: 'Vibration',
                  icon: Icons.vibration_rounded,
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
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffefe0d5), width: 2), // Subtle border
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xffa16d6d), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xffa16d6d),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
      onTap: () => _showRestartLevelConfirmation(context),
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
      builder: (ctx) => CustomConfirmDialog(
        title: 'Reset Progress',
        content: 'Are you sure you want to reset all your progress? This will lock all levels and clear your hints.',
        confirmText: 'RESET',
        cancelText: 'CANCEL',
        isDanger: true,
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () async {
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
      ),
    );
  }

  void _showRestartLevelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CustomConfirmDialog(
        title: 'Restart Level',
        content: 'Are you sure you want to clear your progress for this level?',
        confirmText: 'RESTART',
        cancelText: 'CANCEL',
        isDanger: true,
        onCancel: () => Navigator.of(ctx).pop(),
        onConfirm: () {
          context.read<GameProvider>().restartLevel();
          Navigator.of(ctx).pop(); // Close dialog
          Navigator.of(context).pop(); // Close settings
        },
      ),
    );
  }
}
