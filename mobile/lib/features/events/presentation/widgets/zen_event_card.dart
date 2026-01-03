import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/event.dart';

import '../../../../core/theme/event_theme_helper.dart';

class ZenEventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const ZenEventCard({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
    final Color priorityColor = EventThemeHelper.getPriorityColor(priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.1), width: 1), // Uniform Border
        boxShadow: [
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
                  padding: const EdgeInsets.only(left: 26, top: 20, right: 20, bottom: 20), // Left padding Increased
                  child: Row(
                    children: [
                       // MINIATURE (New)
                       Container(
                         width: 48,
                         height: 48,
                         margin: const EdgeInsets.only(right: 12),
                         decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(12),
                           image: DecorationImage(
                             image: AssetImage(EventThemeHelper.getCategoryImage(event.metadata?['suggested_category'])),
                             fit: BoxFit.cover,
                           ),
                           boxShadow: [
                             BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                           ]
                         ),
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
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                // Indicateur Priorité (Point coloré)
                                if (priority > 0)
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
                          ],
                        ),
                      ),
                      
                      // Icone de statut
                      if (event.status == 'tentative')
                         Icon(Icons.warning_amber_rounded, color: AppColors.error.withOpacity(0.8))
                      else 
                         Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary.withOpacity(0.5)),
                    ],
                  ),
                ),
               ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.1, end: 0, curve: Curves.easeOut);
  }
}
