import 'package:equatable/equatable.dart';

const Object _unset = Object();

class Terrace extends Equatable {
  final String id;
  final String name;
  final double x;
  final double y;
  final double width;
  final double height;
  final String? sunExposure;
  final String? irrigationType;
  final String? plantName;
  final String? plantDescription;
  final String? plantImagePath;
  final String? plantDetailPath;
  final int? daysToHarvest;
  final DateTime? plantingDate;
  final DateTime? expectedHarvestDate;
  final bool harvestReminderEnabled;

  const Terrace({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.sunExposure,
    this.irrigationType,
    this.plantName,
    this.plantDescription,
    this.plantImagePath,
    this.plantDetailPath,
    this.daysToHarvest,
    this.plantingDate,
    this.expectedHarvestDate,
    this.harvestReminderEnabled = false,
  });

  Terrace copyWith({
    String? id,
    String? name,
    double? x,
    double? y,
    double? width,
    double? height,
    Object? sunExposure = _unset,
    Object? irrigationType = _unset,
    Object? plantName = _unset,
    Object? plantDescription = _unset,
    Object? plantImagePath = _unset,
    Object? plantDetailPath = _unset,
    Object? daysToHarvest = _unset,
    Object? plantingDate = _unset,
    Object? expectedHarvestDate = _unset,
    bool? harvestReminderEnabled,
  }) {
    return Terrace(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      sunExposure: sunExposure == _unset
          ? this.sunExposure
          : sunExposure as String?,
      irrigationType: irrigationType == _unset
          ? this.irrigationType
          : irrigationType as String?,
      plantName: plantName == _unset ? this.plantName : plantName as String?,
      plantDescription: plantDescription == _unset
          ? this.plantDescription
          : plantDescription as String?,
      plantImagePath: plantImagePath == _unset
          ? this.plantImagePath
          : plantImagePath as String?,
      plantDetailPath: plantDetailPath == _unset
          ? this.plantDetailPath
          : plantDetailPath as String?,
      daysToHarvest: daysToHarvest == _unset
          ? this.daysToHarvest
          : daysToHarvest as int?,
      plantingDate: plantingDate == _unset
          ? this.plantingDate
          : plantingDate as DateTime?,
      expectedHarvestDate: expectedHarvestDate == _unset
          ? this.expectedHarvestDate
          : expectedHarvestDate as DateTime?,
      harvestReminderEnabled:
          harvestReminderEnabled ?? this.harvestReminderEnabled,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    x,
    y,
    width,
    height,
    sunExposure,
    irrigationType,
    plantName,
    plantDescription,
    plantImagePath,
    plantDetailPath,
    daysToHarvest,
    plantingDate,
    expectedHarvestDate,
    harvestReminderEnabled,
  ];
}
