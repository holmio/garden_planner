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

  const Terrace({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.sunExposure,
    this.irrigationType,
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
  ];
}
