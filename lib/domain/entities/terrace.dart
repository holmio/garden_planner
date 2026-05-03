import 'package:equatable/equatable.dart';

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
  });

  Terrace copyWith({
    String? id,
    String? name,
    double? x,
    double? y,
    double? width,
    double? height,
    String? sunExposure,
    String? irrigationType,
    String? plantName,
    String? plantDescription,
    String? plantImagePath,
    String? plantDetailPath,
  }) {
    return Terrace(
      id: id ?? this.id,
      name: name ?? this.name,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      sunExposure: sunExposure ?? this.sunExposure,
      irrigationType: irrigationType ?? this.irrigationType,
      plantName: plantName ?? this.plantName,
      plantDescription: plantDescription ?? this.plantDescription,
      plantImagePath: plantImagePath ?? this.plantImagePath,
      plantDetailPath: plantDetailPath ?? this.plantDetailPath,
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
  ];
}
