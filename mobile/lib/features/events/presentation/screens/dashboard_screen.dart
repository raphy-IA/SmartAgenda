import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../voice/presentation/notifiers/voice_controller.dart';
import '../providers/event_providers.dart';
import '../widgets/zen_event_card.dart';
import '../widgets/calendar_widget.dart';
import 'details/event_details_screen.dart';
import 'form/create_event_screen.dart';
import '../../../../core/services/notification_service.dart';

import '../../../../core/theme/event_theme_helper.dart';
import '../../data/repositories/category_repository.dart';
import 'package:smart_agenda_ai/features/events/data/models/event.dart';
import 'package:smart_agenda_ai/features/events/data/repositories/event_repository.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  
  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final repo = CategoryRepository();
      final cats = await repo.getCategories();
      EventThemeHelper.updateCache(cats);
      if (mounted) setState(() {});
    } catch (e) {
      print("Failed to load categories: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(filteredEventsProvider);
    final allEventsAsync = ref.watch(eventsProvider); // For markers
    final selectedDate = ref.watch(selectedDateProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    final calendarFormat = ref.watch(calendarFormatProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              
              const SizedBox(height: 24),
              
              // --- CALENDRIER ---
              CustomCalendar(
                focusedDay: focusedDay,
                selectedDay: selectedDate,
                format: calendarFormat,
                events: allEventsAsync.maybeWhen(data: (d) => d,orElse: () => []),
                onDaySelected: (selected, focused) {
                  ref.read(focusedDayProvider.notifier).state = focused;
                  // Si on reclique sur le même jour, on déselectionne pour revenir au mode 30 jours
                  if (isSameDay(selectedDate, selected)) {
                    ref.read(selectedDateProvider.notifier).state = null;
                  } else {
                    ref.read(selectedDateProvider.notifier).state = selected;
                  }
                },
                onFormatChanged: (format) {
                  ref.read(calendarFormatProvider.notifier).state = format;
                },
                onPageChanged: (focused) {
                  ref.read(focusedDayProvider.notifier).state = focused;
                },
              ).animate().fadeIn(duration: 400.ms),

              const SizedBox(height: 30),
              
              // Timeline Label dynamique
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedDate != null 
                      ? 'PROGRAMME DU JOUR' 
                      : (calendarFormat == CalendarFormat.week 
                          ? 'PROGRAMME DE LA SEMAINE' 
                          : 'PROGRAMME DU MOIS'),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  if (selectedDate != null)
                    TextButton(
                      onPressed: () => ref.read(selectedDateProvider.notifier).state = null,
                      child: const Text('Voir tout', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                    ),
                ],
              ).animate().fadeIn(delay: 200.ms),
              
              const SizedBox(height: 12),
              
              // Liste des Events
              Expanded(
                child: eventsAsync.when(
                  data: (events) {
                    if (events.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.spa_outlined, size: 48, color: AppColors.secondary),
                            const SizedBox(height: 16),
                            Text(
                              selectedDate == null 
                                ? 'Aucun événement à venir.\nProfitez du calme.'
                                : 'Rien de prévu ce jour.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            ),
                          ],
                        ).animate().fadeIn(),
                      );
                    }

                    // Trier par date
                    events.sort((a, b) => a.startTime.compareTo(b.startTime));

                    // Liste simple (pas besoin de re-grouper par mois si on a peu d'events ou si c'est filtré par jour)
                    return ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return ZenEventCard(
                          event: event,
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (_) => EventDetailsScreen(event: event))
                          ),
                        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
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

  void _showVoiceConflictDialog(BuildContext context, WidgetRef ref, Event event, ConflictException conflict) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Consumer(
        builder: (context, ref, child) {
          final voiceState = ref.watch(voiceControllerProvider);
          final voiceController = ref.read(voiceControllerProvider.notifier);
          final isProcessing = voiceState.isProcessing;

          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 10),
                Text("Conflit Détecté (Voix)", style: TextStyle(color: AppColors.textPrimary)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  conflict.message,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Que souhaitez-vous faire ?",
                  style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                
                // Suggestions de l'IA
                if (conflict.suggestions.isNotEmpty) ...[
                  const Text("Suggestions de l'IA :", style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: 8),
                  ...conflict.suggestions.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        minimumSize: const Size(double.infinity, 45),
                      ),
                      onPressed: isProcessing ? null : () {
                        // On ne pop plus immédiatement pour garder le contrôle visuel si possible,
                        // mais VoiceController s'occupe de fermer via state change ou on pop après succès.
                        // En fait, resolveWithSuggestion s'occupe de tout. On pop juste avant de lancer.
                        Navigator.pop(context);
                        voiceController.resolveWithSuggestion(Map<String, dynamic>.from(s));
                      },
                      child: isProcessing 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(s['label']),
                    ),
                  )),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: isProcessing ? null : () {
                  Navigator.pop(context);
                  voiceController.clearConflict();
                },
                child: const Text("ANNULER", style: TextStyle(color: AppColors.textSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: isProcessing ? null : () {
                  Navigator.pop(context);
                  voiceController.forceCreateAfterConflict();
                },
                child: const Text("MAINTENIR QUAND MÊME", style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

class VoiceFloatingActionButton extends ConsumerWidget {

  const VoiceFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voiceState = ref.watch(voiceControllerProvider);
    final voiceController = ref.read(voiceControllerProvider.notifier);

    // ÉCOUTEUR DE CONFLIT
    ref.listen(voiceControllerProvider, (prev, next) {
      if (next.conflict != null && next.pendingEvent != null && next.conflict != prev?.conflict) {
        _showVoiceConflictDialog(context, ref, next.pendingEvent!, next.conflict!);
      }
    });

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

        if (voiceState.text.isNotEmpty && !voiceState.isListening && !voiceState.isProcessing && voiceState.conflict == null)
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
                          border: Border.all(
                            color: voiceState.mode == VoiceLanguageMode.auto
                              ? AppColors.textSecondary
                              : AppColors.primary
                          ),
                        ),
                        child: Text(
                          voiceState.mode.name.toUpperCase(),
                          style: TextStyle(
                            color: voiceState.mode == VoiceLanguageMode.auto
                              ? AppColors.textSecondary
                              : AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),

                // BOUTON MICRO / STOP
                GestureDetector(
                onTap: () {
                  if (voiceState.isListening) {
                    voiceController.stopListening(); 
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
