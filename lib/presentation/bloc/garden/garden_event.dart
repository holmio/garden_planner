import 'package:equatable/equatable.dart';
import '../../../domain/entities/terrace.dart';

abstract class GardenEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadGarden extends GardenEvent {}

class AddTerrace extends GardenEvent {
  final Terrace terrace;
  AddTerrace(this.terrace);
  @override
  List<Object?> get props => [terrace];
}

class UpdateTerracePosition extends GardenEvent {
  final String id;
  final double x;
  final double y;
  UpdateTerracePosition(this.id, this.x, this.y);
  @override
  List<Object?> get props => [id, x, y];
}

class UpdateTerraceSize extends GardenEvent {
  final String id;
  final double width;
  final double height;
  UpdateTerraceSize(this.id, this.width, this.height);
  @override
  List<Object?> get props => [id, width, height];
}

class UpdateTerracePlant extends GardenEvent {
  final String id;
  final String plantName;
  final String? plantDescription;
  final String? plantImagePath;
  final String? plantDetailPath;
  UpdateTerracePlant({
    required this.id,
    required this.plantName,
    this.plantDescription,
    this.plantImagePath,
    this.plantDetailPath,
  });
  @override
  List<Object?> get props => [
    id,
    plantName,
    plantDescription,
    plantImagePath,
    plantDetailPath,
  ];
}

class UpdateTerraceSunExposure extends GardenEvent {
  final String id;
  final String sunExposure;
  UpdateTerraceSunExposure(this.id, this.sunExposure);
  @override
  List<Object?> get props => [id, sunExposure];
}

class UpdateTerraceIrrigationType extends GardenEvent {
  final String id;
  final String irrigationType;
  UpdateTerraceIrrigationType(this.id, this.irrigationType);
  @override
  List<Object?> get props => [id, irrigationType];
}

class UpdateGardenSize extends GardenEvent {
  final double width;
  final double height;
  UpdateGardenSize(this.width, this.height);
  @override
  List<Object?> get props => [width, height];
}

class SaveGarden extends GardenEvent {}

class ResetGarden extends GardenEvent {}
