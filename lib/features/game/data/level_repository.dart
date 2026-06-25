import 'dart:convert';
import 'package:flutter/services.dart';

import 'package:project/features/models/ui_level.dart';

class LevelRepository {
  Future<List<UiLevel>> loadLevels() async {
    final jsonString = await rootBundle.loadString('assets/data/levels.json');

    final List<dynamic> jsonData = jsonDecode(jsonString);

    return jsonData.map((item) {
      return UiLevel.fromJson(item);
    }).toList();
  }
}