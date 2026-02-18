import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_agenda_ai/core/constants/app_colors.dart';
import 'package:smart_agenda_ai/features/events/data/models/event.dart';
import 'package:smart_agenda_ai/features/events/presentation/providers/event_providers.dart';
import 'package:dio/dio.dart';

import 'package:smart_agenda_ai/core/theme/event_theme_helper.dart';
import 'package:smart_agenda_ai/core/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:smart_agenda_ai/features/events/data/repositories/event_repository.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  final Event? eventToEdit;

  const CreateEventScreen({super.key, this.eventToEdit});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  
  String _selectedCategory = "Personnel";
  double _importanceScore = 2.0;
  bool _isLoading = false;
  
  final List<String> _categories = ["Travail", "Personnel", "Santé", "Social", "Finance", "Autre"];

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      final e = widget.eventToEdit!;
      _titleController.text = e.title;
      _locationController.text = e.location ?? "";
      _selectedDate = e.startTime;
      _startTime = TimeOfDay.fromDateTime(e.startTime);
      _endTime = TimeOfDay.fromDateTime(e.endTime);
      
      final meta = e.metadata ?? {};
      if (meta['suggested_category'] != null && _categories.contains(meta['suggested_category'])) {
        _selectedCategory = meta['suggested_category'];
      }
      
      // CRITICAL FIX: Strict Clamping for Slider (1.0 - 4.0)
      if (meta['importance_score'] != null) {
        try {
          double val = (meta['importance_score'] as num).toDouble();
          if (val > 4.0) val = 4.0;
          if (val < 1.0) val = 1.0;
          _importanceScore = val;
        } catch (_) {
          _importanceScore = 2.0; // Fallback safe
        }
      } else {
        _importanceScore = 2.0;
      }
      
      if (meta['note'] != null) {
        _noteController.text = meta['note'];
      }
    } else {
      _selectedDate = DateTime.now();
      _startTime = TimeOfDay.now();
      _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
    }
  }

  String _getPriorityLabel(int score) {
    switch (score) {
      case 1: return "Faible";
      case 2: return "Moyenne";
      case 3: return "Haute";
      case 4: return "Urgente";
      default: return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouvel Événement'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Titre',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                ),
                validator: (val) => val == null || val.isEmpty ? 'Requis' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _locationController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Lieu',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                ),
              ),
              const SizedBox(height: 30),
              // Date Picker
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Date', style: TextStyle(color: AppColors.textPrimary)),
                trailing: Text(
                  "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                  style: const TextStyle(color: AppColors.primary, fontSize: 16),
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),
              // Time Pickers
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Début', style: TextStyle(color: AppColors.textPrimary)),
                      subtitle: Text(
                        _startTime.format(context),
                        style: const TextStyle(color: AppColors.primary, fontSize: 18),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: _startTime);
                        if (picked != null) setState(() => _startTime = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Fin', style: TextStyle(color: AppColors.textPrimary)),
                      subtitle: Text(
                        _endTime.format(context),
                        style: const TextStyle(color: AppColors.primary, fontSize: 18),
                      ),
                      onTap: () async {
                        final picked = await showTimePicker(context: context, initialTime: _endTime);
                        if (picked != null) setState(() => _endTime = picked);
                      },
                    ),
                  ),

                ],
              ),
              const SizedBox(height: 30),
              
              // Categorie
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Catégorie',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                ),
                dropdownColor: AppColors.surface,
                items: _categories.map((c) => DropdownMenuItem(
                  value: c, 
                  child: Row(
                    children: [
                      Icon(Icons.circle, color: EventThemeHelper.getCategoryColor(c), size: 12),
                      const SizedBox(width: 8),
                      Text(c, style: const TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                )).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 20),

              // Priorité (1-4)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Priorité", style: TextStyle(color: AppColors.textSecondary)),
                      Text(
                         "${_getPriorityLabel(_importanceScore.toInt())} (${_importanceScore.toInt()}/4)",
                         style: TextStyle(
                           color: EventThemeHelper.getPriorityColor(_importanceScore.toInt()), 
                           fontWeight: FontWeight.bold
                         )
                      ),
                    ],
                  ),
                  Slider(
                    value: _importanceScore,
                    min: 1,
                    max: 4,
                    divisions: 3,
                    activeColor: EventThemeHelper.getPriorityColor(_importanceScore.toInt()),
                    onChanged: (val) => setState(() => _importanceScore = val),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Note
               TextFormField(
                controller: _noteController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  labelStyle: TextStyle(color: AppColors.textSecondary),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        widget.eventToEdit != null ? 'MODIFIER' : 'CRÉER', 
                        style: const TextStyle(color: Colors.white, fontSize: 16)
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit({bool ignoreConflicts = false}) async {
    if (_formKey.currentState!.validate()) {
      final start = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _startTime.hour, _startTime.minute
      );
      final end = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day,
        _endTime.hour, _endTime.minute
      );

      final isEdit = widget.eventToEdit != null;
      
      final eventData = Event(
        id: isEdit ? widget.eventToEdit!.id : "", 
        title: _titleController.text,
        startTime: start,
        endTime: end,
        location: _locationController.text.isNotEmpty ? _locationController.text : null,
        status: "confirmed",
        metadata: {
          'suggested_category': _selectedCategory,
          'importance_score': _importanceScore.toInt(),
          if (_noteController.text.isNotEmpty) 'note': _noteController.text,
        }
      );

      setState(() => _isLoading = true);
      try {
        if (isEdit) {
           await ref.read(eventsProvider.notifier).updateEvent(eventData, force: ignoreConflicts);
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Événement modifié')));
        } else {
           await ref.read(eventsProvider.notifier).createEvent(eventData, ignoreConflicts: ignoreConflicts);
           if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Événement créé')));
        }
        
        // --- NOTIFICATION SCHEDULING ---
        final reminderTime = start.subtract(const Duration(minutes: 15));
        if (reminderTime.isAfter(DateTime.now())) {
           final notifId = eventData.title.hashCode;
           await NotificationService().scheduleNotification(
             notifId, 
             "Rappel : ${eventData.title}", 
             "Ça commence dans 15 min ! (${DateFormat('HH:mm').format(start)})", 
             reminderTime
           );
        }

        if (mounted) Navigator.pop(context);
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
        if (e is ConflictException) {
          _showConflictDialog(eventData, e);
        } else if (e is DuplicateException) {
          _showError(e.message);
        } else {
          _showError(e);
        }
      }
    }
  }

  void _showConflictDialog(Event event, ConflictException conflict) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 10),
            Text("Conflit Détecté", style: TextStyle(color: AppColors.textPrimary)),
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
            
            // Suggestion de l'IA
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
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    // Mettre à jour les champs et relancer
                    final newStart = DateTime.parse(s['start_time']).toLocal();
                    final newEnd = DateTime.parse(s['end_time']).toLocal();
                    setState(() {
                      _selectedDate = newStart;
                      _startTime = TimeOfDay.fromDateTime(newStart);
                      _endTime = TimeOfDay.fromDateTime(newEnd);
                    });
                    _submit(); // Re-submit with new times
                  },
                  child: Text(s['label']),
                ),
              )),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ANNULER", style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(context);
              _submit(ignoreConflicts: true); // Force anyway
            },
            child: const Text("MAINTENIR QUAND MÊME", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showError(dynamic e) {
    if (!mounted) return;
    String msg = 'Erreur survenue';
    if (e is DioException) {
      msg = "Erreur réseau : ${e.message}";
    } else {
      msg = "Erreur : $e";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      )
    );
  }
}
