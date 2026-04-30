import 'package:equatable/equatable.dart';
import '../../../domain/entities/terrace.dart';

abstract class TerraceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TerraceInitial extends TerraceState {}

class TerraceLoading extends TerraceState {}

class TerraceLoaded extends TerraceState {
  final List<Terrace> terraces;
  final bool hasUnsavedChanges;

  TerraceLoaded(this.terraces, {this.hasUnsavedChanges = false});

  @override
  List<Object?> get props => [terraces, hasUnsavedChanges];
}

class TerraceError extends TerraceState {
  final String message;
  TerraceError(this.message);

  @override
  List<Object?> get props => [message];
}
