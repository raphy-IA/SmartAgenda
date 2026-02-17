import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/event.dart';

class CustomCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final CalendarFormat format;
  final List<Event> events;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(CalendarFormat) onFormatChanged;
  final Function(DateTime) onPageChanged;

  const CustomCalendar({
    super.key,
    required this.focusedDay,
    this.selectedDay,
    required this.format,
    required this.events,
    required this.onDaySelected,
    required this.onFormatChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.only(bottom: 8),
      child: TableCalendar(
        locale: 'fr_FR',
        firstDay: DateTime.now().subtract(const Duration(days: 365)),
        lastDay: DateTime.now().add(const Duration(days: 365)),
        focusedDay: focusedDay,
        calendarFormat: format,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onFormatChanged: onFormatChanged,
        onPageChanged: onPageChanged,
        
        // --- DATA ---
        eventLoader: (day) {
          return events.where((e) => isSameDay(e.startTime, day)).toList();
        },

        // --- STYLING ---
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          formatButtonDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          formatButtonTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          titleCentered: true,
          titleTextStyle: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 17),
          leftChevronIcon: const Icon(Icons.chevron_left, color: AppColors.primary),
          rightChevronIcon: const Icon(Icons.chevron_right, color: AppColors.primary),
        ),

        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          selectedDecoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          markerDecoration: const BoxDecoration(
            color: AppColors.secondary,
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false,
          defaultTextStyle: const TextStyle(color: AppColors.textPrimary),
          weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
        ),

        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
          weekendStyle: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
        ),

        // Custom Dot Marker
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                bottom: 1,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }
}
