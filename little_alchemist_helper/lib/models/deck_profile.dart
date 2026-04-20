import 'package:flutter/foundation.dart';

import 'deck_settings.dart';

/// Saved deck with name and auto-build parameters.
@immutable
class DeckProfile {
  const DeckProfile({
    required this.id,
    required this.name,
    required this.settings,
  });

  final String id;
  final String name;
  final DeckSettings settings;

  DeckProfile copyWith({String? id, String? name, DeckSettings? settings}) {
    return DeckProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      settings: settings ?? this.settings,
    );
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'id': id,
      'name': name,
      'settings': settings.toJson(),
    };
  }

  static DeckProfile? fromJson(Map<String, Object?>? json) {
    if (json == null) {
      return null;
    }
    final String? id = json['id'] as String?;
    final String? name = json['name'] as String?;
    final Object? s = json['settings'];
    if (id == null || id.isEmpty || name == null || name.isEmpty) {
      return null;
    }
    if (s is! Map) {
      return null;
    }
    final Map<String, Object?> settingsMap = s.map(
      (Object? k, Object? v) => MapEntry<String, Object?>(k.toString(), v),
    );
    return DeckProfile(
      id: id,
      name: name,
      settings: DeckSettings.fromJson(settingsMap),
    );
  }
}
