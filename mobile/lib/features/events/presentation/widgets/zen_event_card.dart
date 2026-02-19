import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:smart_agenda_ai/core/constants/app_colors.dart';
import 'package:smart_agenda_ai/features/events/data/models/event.dart';
import 'package:smart_agenda_ai/core/theme/event_theme_helper.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_agenda_ai/features/events/presentation/providers/event_providers.dart';
import 'package:smart_agenda_ai/features/events/presentation/screens/details/event_details_screen.dart';

class ZenEventCard extends ConsumerWidget {
  final Event event;
  final VoidCallback? onTap;

  const ZenEventCard({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Check for past event
    final isPast = event.endTime.isBefore(DateTime.now());

    // INFO METADATA
    final meta = event.metadata ?? {};
    final String? category = meta['suggested_category'];
    final int priority = meta['importance_score'] is int ? meta['importance_score'] : 0;
    
    // COULEURS (Priority: ID -> Dynamic Cache, then Fallback -> Name)
    Color categoryColor;
    if (event.categoryId != null) {
      categoryColor = EventThemeHelper.getCategoryColorById(event.categoryId);
    } else {
      categoryColor = EventThemeHelper.getCategoryColor(category);
    }

    // Gray out if past
    if (isPast) {
      categoryColor = Color.lerp(categoryColor, Colors.grey, 0.6)!;
    }

    final Color priorityColor = isPast 
      ? Colors.grey.withOpacity(0.5) 
      : EventThemeHelper.getPriorityColor(priority);

    return Opacity(
      opacity: isPast ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isPast 
              ? AppColors.textSecondary.withOpacity(0.05) 
              : AppColors.textSecondary.withOpacity(0.1), 
            width: 1
          ),
          boxShadow: isPast ? [] : [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                 children: [
                   // BANDEAU COULEUR GAUCHE
                   Positioned(
                     left: 0, 
                     top: 0, 
                     bottom: 0, 
                     width: 6,
                     child: Container(color: categoryColor),
                   ),
                   
                   // CONTENU
                   Padding(
                    padding: const EdgeInsets.only(left: 26, top: 20, right: 20, bottom: 20),
                    child: Row(
                      children: [
                         // MINIATURE
                         Container(
                           width: 48,
                           height: 48,
                           margin: const EdgeInsets.only(right: 12),
                           decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(12),
                             image: DecorationImage(
                               opacity: isPast ? 0.5 : 1.0,
                               image: AssetImage(EventThemeHelper.getCategoryImage(event.metadata?['suggested_category'])),
                               fit: BoxFit.cover,
                             ),
                             boxShadow: isPast ? [] : [
                               BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                             ]
                           ),
                           child: isPast 
                             ? Center(child: Icon(Icons.check_circle, color: categoryColor, size: 24))
                             : null,
                         ),
  
                        // Colonne Heure
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // JOUR
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: categoryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                DateFormat('d', 'fr_FR').format(event.startTime),
                                style: TextStyle(
                                  color: categoryColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                                DateFormat('EEE', 'fr_FR').format(event.startTime).toUpperCase(),
                                style: TextStyle(
                                  color: categoryColor.withOpacity(0.8),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                            ),
                            const SizedBox(height: 8),
                            // HEURE
                            Text(
                              DateFormat('HH:mm').format(event.startTime),
                              style: TextStyle(
                                color: isPast ? AppColors.textSecondary : AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                decoration: isPast ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ],
                        ),
                        
                        // Séparateur vertical
                        Container(
                          height: 40,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          color: AppColors.textSecondary.withOpacity(0.2),
                        ),
  
                        // Info Evénement
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      event.title,
                                      style: TextStyle(
                                        color: isPast ? AppColors.textSecondary : AppColors.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        decoration: isPast ? TextDecoration.lineThrough : null,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  // Indicateur Priorité
                                  if (priority > 0 && !isPast)
                                    Container(
                                      width: 8,
                                      height: 8,
                                      margin: const EdgeInsets.only(left: 8),
                                      decoration: BoxDecoration(
                                        color: priorityColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [BoxShadow(color: priorityColor.withOpacity(0.4), blurRadius: 4)]
                                      ),
                                    )
                                ],
                              ),
                              if (event.location != null) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.location_on_outlined, 
                                      size: 14, 
                                      color: AppColors.textSecondary.withOpacity(0.8)
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        event.location!,
                                        style: TextStyle(
                                          color: AppColors.textSecondary.withOpacity(0.8),
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (isPast)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    "TERMINÉ",
                                    style: TextStyle(
                                      color: categoryColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        
                        // Icone de statut
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (hasConflict && !isPast)
                              const Tooltip(
                                message: "Chevauchement avec un autre événement",
                                child: Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                              ),
                            const SizedBox(width: 4),
                            if (event.status == 'tentative' && !isPast)
                               Icon(Icons.help_outline, color: AppColors.error.withOpacity(0.8))
                            else if (isPast)
                               Icon(Icons.check_circle_outline, color: categoryColor, size: 20)
                            else 
                               Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.5)),
                          ],
                        ),
                      ],
                    ),
                  ),
                 ],
              ),
            ),
          ),
        ),
      ).animate(target: isPast ? 0 : 1).fadeIn().slideX(begin: 0.1, end: 0, curve: Curves.easeOut),
    );
  }
}
  }
}
