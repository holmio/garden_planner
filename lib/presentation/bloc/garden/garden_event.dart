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

class UpdateGardenSize extends GardenEvent {
  final double width;
  final double height;
  UpdateGardenSize(this.width, this.height);
  @override
  List<Object?> get props => [width, height];
}

class SaveGarden extends GardenEvent {}

class ResetGarden extends GardenEvent {}
