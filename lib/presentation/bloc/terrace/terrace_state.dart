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
  final bool isSaving;
  final String? errorMessage;

  TerraceLoaded(
    this.terraces, {
    this.hasUnsavedChanges = false,
    this.isSaving = false,
    this.errorMessage,
  });

  TerraceLoaded copyWith({
    List<Terrace>? terraces,
    bool? hasUnsavedChanges,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TerraceLoaded(
      terraces ?? this.terraces,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    terraces,
    hasUnsavedChanges,
    isSaving,
    errorMessage,
  ];
}

class TerraceError extends TerraceState {
  final String message;
  TerraceError(this.message);

  @override
  List<Object?> get props => [message];
}
