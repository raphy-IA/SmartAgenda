import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../voice/presentation/notifiers/voice_controller.dart';
import '../providers/event_providers.dart';
import '../widgets/zen_event_card.dart';
import 'details/event_details_screen.dart';
import 'form/create_event_screen.dart';
import '../../../../core/services/notification_service.dart';

import '../../../../core/theme/event_theme_helper.dart';
import '../../data/repositories/category_repository.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    // Fetch Dynamic Categories on startup
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final repo = CategoryRepository();
      final cats = await repo.getCategories();
      EventThemeHelper.updateCache(cats);
      if (mounted) setState(() {}); // Refresh UI
    } catch (e) {
      print("Failed to load categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // --- DIAGNOSTIC ---
              // --- DIAGNOSTIC REMOVED ---
              const SizedBox(height: 20),
              // Header Zen
              _buildHeader(context),
              
              const SizedBox(height: 30),
              
              // Timeline Label
              Text(
                'Timeline',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.0,
                ),
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 16),
              
              // Liste des Events
              Expanded(
                child: eventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.spa_outlined, size: 64, color: AppColors.secondary),
                            const SizedBox(height: 16),
                            const Text(
                              'Aucun événement.\nProfitez du calme.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                            ),
                          ],
                        ).animate().fadeIn().scale(),
                      );
                    }

                    // 1. Trier par date
                    events.sort((a, b) => a.startTime.compareTo(b.startTime));

                    // 2. Grouper par mois
                    // Map<"Janvier 2026", List<Event>>
                    final Map<String, List<dynamic>> groupedEvents = {};
                    
                    for (var event in events) {
                      final String monthKey = DateFormat('MMMM yyyy', 'fr_FR').format(event.startTime);
                      // Capitalize first letter
                      final String formattedKey = monthKey[0].toUpperCase() + monthKey.substring(1);
                      
                      if (!groupedEvents.containsKey(formattedKey)) {
                        groupedEvents[formattedKey] = [];
                      }
                      groupedEvents[formattedKey]!.add(event);
                    }

                    // 3. Afficher la liste groupée
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: groupedEvents.length,
                      itemBuilder: (context, index) {
                        final String month = groupedEvents.keys.elementAt(index);
                        final List<dynamic> monthEvents = groupedEvents[month]!;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // En-tête mois
                            Container(
                              margin: const EdgeInsets.only(top: 24, bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Text(
                                month,
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            // Liste des events pour ce mois
                            ...monthEvents.map((event) => ZenEventCard(
                              event: event,
                              onTap: () => Navigator.push(
                                context, 
                                MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event))
                              ),
                            )).toList(),
                          ],
                        );
                      },
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, stack) => Center(child: Text('Erreur: $err', style: const TextStyle(color: AppColors.error))),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: VoiceFloatingActionButton(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Bonjour' : (now.hour < 18 ? 'Bon après-midi' : 'Bonsoir');

    // Get User Name from Supabase Auth
    final user = Supabase.instance.client.auth.currentUser;
    final userName = user?.userMetadata?['full_name']?.toString().split(' ').first ?? 'Alex';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart Agenda',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$greeting, $userName',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('d MMMM yyyy', 'fr_FR').format(now),
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateEventScreen())
            ),
          ),
        ),
      ],
    ).animate().fadeIn().slideY(begin: -0.5, end: 0);
  }



}

class VoiceFloatingActionButton extends ConsumerWidget {

  const VoiceFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceControllerProvider);
    final voiceController = ref.read(voiceControllerProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (voiceState.error != null)
           Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.error),
            ),
            child: Text(
              voiceState.error!,
              style: const TextStyle(color: AppColors.error, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(),

        if (voiceState.isProcessing)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                SizedBox(width: 8),
                Text("Analyse en cours...", style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.5, end: 0),

        if (voiceState.text.isNotEmpty && !voiceState.isProcessing)
           Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surface.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '"${voiceState.text}"',
              style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
            ),
          ).animate().fadeIn(),

        if (voiceState.text.isNotEmpty && !voiceState.isListening && !voiceState.isProcessing)
          // CAS 1 : Texte capturé -> Valider ou Annuler
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => voiceController.cancelRecording(),
                child: Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: AppColors.surface, shape: BoxShape.circle, border: Border.all(color: AppColors.error)),
                  child: const Icon(Icons.close, color: AppColors.error),
                ),
              ).animate().scale(),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: () => voiceController.submitCapturedText(),
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.success, Color(0xFF69F0AE)]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.4), blurRadius: 10, offset: const Offset(0,4))],
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 32),
                ),
              ).animate().scale(),
            ],
          )
        else
          // CAS 2 : Pas de texte à valider -> Mode Micro ou Stop
          Row(
             mainAxisSize: MainAxisSize.min,
             children: [
                // BOUTON LANGUE (Visible si pas en écoute)
                if (!voiceState.isListening)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: GestureDetector(
                      onTap: () => voiceController.toggleLanguage(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: voiceState.localeId == "fr-FR" ? AppColors.primary : AppColors.textSecondary),
                        ),
                        child: Text(
                          voiceState.localeId == "fr-FR" ? "FR" : "AUTO",
                          style: TextStyle(
                            color: voiceState.localeId == "fr-FR" ? AppColors.primary : AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12
                          ),
                        ),
                      ),
                    ),
                  ),

                // BOUTON MICRO / STOP
                GestureDetector(
                onTap: () {
                  if (voiceState.isListening) {
                    voiceController.stopAndSend(); 
                  } else {
                    voiceController.startListening();
                  }
                },
                child: Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: voiceState.isListening 
                        ? [AppColors.error, const Color(0xFFFF8A80)] // Rouge pour STOP
                        : [AppColors.primary, const Color(0xFF82B1FF)], // Bleu pour MICRO
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (voiceState.isListening ? AppColors.error : AppColors.primary).withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    voiceState.isListening ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ).animate(target: voiceState.isListening ? 1 : 0)
              .scale(begin: const Offset(1,1), end: const Offset(1.1, 1.1), duration: 500.ms, curve: Curves.easeInOut)
              .then().scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 500.ms),
             ],
          ),
      ],
    );
  }
}
