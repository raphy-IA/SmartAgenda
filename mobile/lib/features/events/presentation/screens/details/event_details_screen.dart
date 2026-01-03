import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/event.dart';
import '../../providers/event_providers.dart';
import '../form/create_event_screen.dart';

import '../../../../../core/theme/event_theme_helper.dart';

class EventDetailsScreen extends ConsumerWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // METADATA
    final meta = event.metadata ?? {};
    final String? category = meta['suggested_category'];
    final String imageUrl = EventThemeHelper.getCategoryImage(category);

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Blanc sur l'image
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
               Navigator.push(
                 context,
                 MaterialPageRoute(builder: (_) => CreateEventScreen(eventToEdit: event))
               );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER IMAGE
            Stack(
              children: [
                SizedBox(
                  height: 250,
                  width: double.infinity,
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(color: AppColors.primary),
                  ),
                ),
                // Gradient pour lisibilité AppBar
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // CONTENT
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: AppColors.primary),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE d MMMM y', 'fr_FR').format(event.startTime),
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                          ),
                          Text(
                            '${DateFormat('HH:mm').format(event.startTime)} - ${DateFormat('HH:mm').format(event.endTime)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (event.location != null) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.secondary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            event.location!,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                  
                  // --- NOUVEAU: METADATA AI ---
                  const SizedBox(height: 24),
                  _buildMetadataSection(event),
      
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataSection(Event event) {
     final meta = event.metadata ?? {};
     final String? category = meta['suggested_category'];
     
     // CLAMP Priority for Display
     int rawScore = meta['importance_score'] is int ? meta['importance_score'] : 0;
     int displayScore = rawScore;
     if (rawScore > 4) displayScore = 4; // Clamp old values (e.g. 40) -> 4
     if (rawScore < 1) displayScore = 1;

     // USE THEME HELPER
     Color categoryColor = EventThemeHelper.getCategoryColor(category);
     Color priorityColor = EventThemeHelper.getPriorityColor(displayScore);

     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: AppColors.surface.withOpacity(0.5),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: AppColors.textSecondary.withOpacity(0.1)),
         boxShadow: [BoxShadow(color: categoryColor.withOpacity(0.05), blurRadius: 10)]
       ),
       child: Column(
         children: [
           Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: categoryColor.withOpacity(0.2),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(Icons.category_outlined, color: categoryColor, size: 20),
               ),
               const SizedBox(width: 12),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     "Catégorie",
                     style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12),
                   ),
                   Text(
                     category ?? 'Général',
                     style: TextStyle(color: categoryColor, fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                 ],
               ),
             ],
           ),
           const SizedBox(height: 16),
           Row(
             children: [
               Container(
                 padding: const EdgeInsets.all(8),
                 decoration: BoxDecoration(
                   color: priorityColor.withOpacity(0.2),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(Icons.flag_outlined, color: priorityColor, size: 20),
               ),
               const SizedBox(width: 12),
               Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     "Priorité",
                     style: TextStyle(color: AppColors.textSecondary.withOpacity(0.7), fontSize: 12),
                   ),
                   Text(
                     "Niveau $displayScore/4",
                     style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 16),
                   ),
                 ],
               ),
             ],
           ),
           // AFFICHAGE NOTE
           if (meta['note'] != null && meta['note'].toString().isNotEmpty) ...[
             const SizedBox(height: 16),
             const Divider(color: AppColors.textSecondary),
             const SizedBox(height: 8),
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  const Icon(Icons.notes, color: AppColors.textSecondary, size: 20),
                  const SizedBox(width: 12),
                   Expanded(
                   child: Text(
                     "${meta['note']}",
                     style: const TextStyle(color: AppColors.textPrimary, fontStyle: FontStyle.italic),
                   ),
                 ),
               ],
             ),
           ]
         ],
       ),
     );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Supprimer ?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Cette action est irréversible.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            child: const Text('Annuler', style: TextStyle(color: AppColors.textPrimary)),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('Supprimer', style: TextStyle(color: AppColors.error)),
            onPressed: () async {
              try {
                await ref.read(eventRepositoryProvider).deleteEvent(event.id);
                // Rafraîchir la liste
                ref.invalidate(eventsProvider);
                
                Navigator.pop(ctx); // Close Dialog
                Navigator.pop(context); // Close Screen
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Événement supprimé')));
              } catch (e) {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
              }
            },
          ),
        ],
      ),
    );
  }
}
