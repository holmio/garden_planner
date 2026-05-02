import 'package:equatable/equatable.dart';
import '../../../domain/entities/terrace.dart';

abstract class TerraceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTerraces extends TerraceEvent {}

class AddTerrace extends TerraceEvent {
  final Terrace terrace;
  AddTerrace(this.terrace);
  @override
  List<Object?> get props => [terrace];
}

class UpdateTerracePosition extends TerraceEvent {
  final String id;
  final double x;
  final double y;
  UpdateTerracePosition(this.id, this.x, this.y);
  @override
  List<Object?> get props => [id, x, y];
}

class UpdateTerraceSize extends TerraceEvent {
  final String id;
  final double width;
  final double height;
  UpdateTerraceSize(this.id, this.width, this.height);
  @override
  List<Object?> get props => [id, width, height];
}

class SaveLayout extends TerraceEvent {}

class ResetLayout extends TerraceEvent {}
