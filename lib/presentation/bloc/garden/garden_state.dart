import 'package:equatable/equatable.dart';
import '../../../domain/entities/garden.dart';

abstract class GardenState extends Equatable {
  @override
  List<Object?> get props => [];
}

class GardenInitial extends GardenState {}

class GardenLoading extends GardenState {}

class GardenLoaded extends GardenState {
  final Garden garden;
  final bool hasUnsavedChanges;
  final bool isSaving;
  final String? errorMessage;

  GardenLoaded({
    this.garden = const Garden(),
    this.hasUnsavedChanges = false,
    this.isSaving = false,
    this.errorMessage,
  });

  GardenLoaded copyWith({
    Garden? garden,
    bool? hasUnsavedChanges,
    bool? isSaving,
    String? errorMessage,
    bool clearError = false,
  }) {
    return GardenLoaded(
      garden: garden ?? this.garden,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    garden,
    hasUnsavedChanges,
    isSaving,
    errorMessage,
  ];
}

class GardenError extends GardenState {
  final String message;
  GardenError(this.message);

  @override
  List<Object?> get props => [message];
}
