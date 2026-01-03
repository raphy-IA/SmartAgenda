import 'package:flutter/material.dart';
import '../../features/events/data/models/event.dart';
import '../../features/events/data/models/category.dart';

class EventThemeHelper {
  
  // DYNAMIC CACHE
  static final Map<String, Category> _idToCategory = {};
  static final Map<String, Category> _nameToCategory = {};

  static void updateCache(List<Category> categories) {
    _idToCategory.clear();
    _nameToCategory.clear();
    for (var cat in categories) {
      _idToCategory[cat.id] = cat;
      _nameToCategory[cat.name.toLowerCase().trim()] = cat;
    }
    print("[EventThemeHelper] Cache updated with ${categories.length} categories.");
  }

  static Color _parseHex(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse(hex, radix: 16));
  }
  
  // COULEURS CATÉGORIES (Hardcoded Fallbacks)
  static const Color _work = Color(0xFF2196F3);     // Blue
  static const Color _personal = Color(0xFF4CAF50); // Green
  static const Color _health = Color(0xFFF44336);   // Red
  static const Color _social = Color(0xFFFFC107);   // Amber
  static const Color _finance = Color(0xFF9C27B0);  // Purple
  static const Color _education = Color(0xFFFF5722); // Deep Orange
  static const Color _sport = Color(0xFFE91E63);     // Pink/Red
  static const Color _other = Color(0xFF9E9E9E);    // Grey

  // Lookup by ID (Priority)
  static Color getCategoryColorById(String? catId) {
    if (catId != null && _idToCategory.containsKey(catId)) {
      return _parseHex(_idToCategory[catId]!.colorHex);
    }
    return _other;
  }

  static Color getCategoryColor(String? checkCategory) {
    if (checkCategory == null) return _other;
    final cat = checkCategory.toLowerCase().trim();
    
    // 1. Dynamic Check
    if (_nameToCategory.containsKey(cat)) {
      return _parseHex(_nameToCategory[cat]!.colorHex);
    }
    
    // 2. Fallbacks Hardcoded (pour compatibilité immédiate)
    if (cat.contains("travail") || cat.contains("boulot")) return _work;
    if (cat.contains("perso")) return _personal;
    if (cat.contains("santé") || cat.contains("medecin")) return _health;
    if (cat.contains("social") || cat.contains("ami")) return _social;
    if (cat.contains("finance") || cat.contains("banque")) return _finance;
    if (cat.contains("étude") || cat.contains("cours") || cat.contains("formation")) return _education;
    if (cat.contains("sport") || cat.contains("match") || cat.contains("gym")) return _sport;
    
    return _other;
  }

  // COULEURS PRIORITÉS (1-4)
  static Color getPriorityColor(int score) {
    switch (score) {
      case 4: return const Color(0xFFD32F2F); // CRITIQUE (Rouge foncé)
      case 3: return const Color(0xFFF57C00); // HAUTE (Orange)
      case 2: return const Color(0xFF1976D2); // MOYENNE (Bleu)
      case 1: 
      default: return const Color(0xFF757575); // FAIBLE (Gris)
    }
  }

  // ASSETS LOCAUX
  static String getCategoryImage(String? checkCategory) {
    final cat = (checkCategory ?? "").toLowerCase().trim();
    
    const String basePath = "assets/images";
    
    if (cat.contains("travail")) return "$basePath/category_work.png";
    if (cat.contains("perso")) return "$basePath/category_personal.png";
    if (cat.contains("santé")) return "$basePath/category_health.png";
    if (cat.contains("social")) return "$basePath/category_social.png";
    if (cat.contains("finance")) return "$basePath/category_finance.png";
    if (cat.contains("étude") || cat.contains("cours") || cat.contains("formation")) return "$basePath/category_work.png"; // Re-use Work for now
    if (cat.contains("sport") || cat.contains("match") || cat.contains("gym")) return "$basePath/category_health.png"; // Re-use Health
    
    return "$basePath/category_other.png";
  }
}
