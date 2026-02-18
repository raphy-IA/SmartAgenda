import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_agenda_ai/core/constants/app_colors.dart';
import 'package:smart_agenda_ai/features/profile/presentation/providers/profile_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Paramètres & Bien-être'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionHeader("MA CONSTITUTION (CHRONOTYPE)"),
            _buildInfoCard(
              "Dites à l'IA quand vous êtes au top de votre forme pour qu'elle y place vos tâches complexes.",
            ),
            const SizedBox(height: 10),
            _buildChronotypeSelector(context, ref, profile.chronotype),
            
            const SizedBox(height: 30),
            _buildSectionHeader("SÉCURITÉ ANTI-BURNOUT"),
            SwitchListTile(
              title: const Text("Mode FREEZE", style: TextStyle(color: AppColors.textPrimary)),
              subtitle: const Text("Désactive les tâches non-urgentes pour souffler.", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              value: profile.freezeMode,
              activeColor: AppColors.primary,
              onChanged: (_) => _handleAction(
                context, 
                () => ref.read(profileProvider.notifier).toggleFreezeMode(),
                "Mode FREEZE ${profile.freezeMode ? 'désactivé' : 'activé'}"
              ),
            ),
            
            const SizedBox(height: 10),
            ListTile(
              title: const Text("Limite de Travail Quotidienne", style: TextStyle(color: AppColors.textPrimary)),
              subtitle: Text("${profile.workCapacityLimit} heures", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              trailing: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
              onTap: () => _showLimitDialog(context, ref, profile.workCapacityLimit),
            ),
            
            const SizedBox(height: 40),
            _buildSectionHeader("À PROPOS"),
            const ListTile(
              title: Text("Version", style: TextStyle(color: AppColors.textPrimary)),
              trailing: Text("1.2.0 (Premium)", style: TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erreur : $err")),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildInfoCard(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildChronotypeSelector(BuildContext context, WidgetRef ref, String current) {
    return Column(
      children: [
        _buildChronoItem(context, ref, "matin", "Alouette (Matin)", "Pic d'énergie : 08h - 12h", Icons.wb_sunny_outlined, current == "matin"),
        _buildChronoItem(context, ref, "neutre", "Équilibré", "Pic d'énergie : Journée standard", Icons.access_time, current == "neutre"),
        _buildChronoItem(context, ref, "soir", "Hibou (Soir)", "Pic d'énergie : 17h - 21h", Icons.nightlight_round, current == "soir"),
      ],
    );
  }

  Future<void> _handleAction(BuildContext context, Future<void> Function() action, String successMsg) async {
    try {
      await action();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMsg), backgroundColor: AppColors.success, duration: const Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Échec : $e"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Widget _buildChronoItem(BuildContext context, WidgetRef ref, String value, String title, String sub, IconData icon, bool isSelected) {
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: isSelected ? AppColors.primary : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
      onTap: () => _handleAction(
        context, 
        () => ref.read(profileProvider.notifier).updateChronotype(value),
        "Constitution mise à jour ($title)"
      ),
    );
  }

  void _showLimitDialog(BuildContext context, WidgetRef ref, int current) {
    showDialog(
      context: context,
      builder: (context) {
        int val = current;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) => AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Text("Capacité de travail", style: TextStyle(color: AppColors.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Au delà de combien d'heures l'IA doit-elle vous alerter ?", style: TextStyle(fontSize: 13)),
                const SizedBox(height: 20),
                Text("$val heures", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                Slider(
                  value: val.toDouble(),
                  min: 4, max: 15,
                  divisions: 11,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setDialogState(() => val = v.toInt()),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text("ANNULER")),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  _handleAction(
                    context,
                    () => ref.read(profileProvider.notifier).updateWorkLimit(val),
                    "Limite mise à jour : $val heures"
                  );
                },
                child: const Text("ENREGISTRER"),
              ),
            ],
          ),
        );
      },
    );
  }
}
