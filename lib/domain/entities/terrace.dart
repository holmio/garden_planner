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

  @override
  List<Object?> get props => [id, name, x, y, width, height, sunExposure, irrigationType];
}
