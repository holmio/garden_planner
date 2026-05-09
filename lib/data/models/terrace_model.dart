import '../../domain/entities/terrace.dart';

class TerraceModel extends Terrace {
  const TerraceModel({
    required super.id,
    required super.name,
    required super.x,
    required super.y,
    required super.width,
    required super.height,
    super.sunExposure,
    super.irrigationType,
    super.plantName,
    super.plantDescription,
    super.plantImagePath,
    super.plantDetailPath,
    super.daysToHarvest,
    super.plantingDate,
    super.expectedHarvestDate,
    super.harvestReminderEnabled,
  });

  factory TerraceModel.fromJson(Map<String, dynamic> json) {
    return TerraceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      sunExposure: json['sunExposure'] as String?,
      irrigationType: json['irrigationType'] as String?,
      plantName: json['plantName'] as String?,
      plantDescription: json['plantDescription'] as String?,
      plantImagePath: json['plantImagePath'] as String?,
      plantDetailPath: json['plantDetailPath'] as String?,
      daysToHarvest: _intFromJson(json['daysToHarvest']),
      plantingDate: _dateFromJson(json['plantingDate']),
      expectedHarvestDate: _dateFromJson(json['expectedHarvestDate']),
      harvestReminderEnabled: json['harvestReminderEnabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'sunExposure': sunExposure,
      'irrigationType': irrigationType,
      'plantName': plantName,
      'plantDescription': plantDescription,
      'plantImagePath': plantImagePath,
      'plantDetailPath': plantDetailPath,
      'daysToHarvest': daysToHarvest,
      'plantingDate': plantingDate?.toIso8601String(),
      'expectedHarvestDate': expectedHarvestDate?.toIso8601String(),
      'harvestReminderEnabled': harvestReminderEnabled,
    };
  }

  factory TerraceModel.fromEntity(Terrace terrace) {
    return TerraceModel(
      id: terrace.id,
      name: terrace.name,
      x: terrace.x,
      y: terrace.y,
      width: terrace.width,
      height: terrace.height,
      sunExposure: terrace.sunExposure,
      irrigationType: terrace.irrigationType,
      plantName: terrace.plantName,
      plantDescription: terrace.plantDescription,
      plantImagePath: terrace.plantImagePath,
      plantDetailPath: terrace.plantDetailPath,
      daysToHarvest: terrace.daysToHarvest,
      plantingDate: terrace.plantingDate,
      expectedHarvestDate: terrace.expectedHarvestDate,
      harvestReminderEnabled: terrace.harvestReminderEnabled,
    );
  }

  static DateTime? _dateFromJson(Object? value) {
    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static int? _intFromJson(Object? value) {
    if (value is int) return value;
    if (value is num) return value.round();
    if (value is String) return int.tryParse(value);

    return null;
  }
}
