import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/garden.dart';
import '../../../domain/entities/garden_size.dart';
import '../../../domain/entities/terrace.dart';
import '../../../domain/repositories/garden_repository.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'garden_event.dart';
import 'garden_state.dart';

class GardenBloc extends Bloc<GardenEvent, GardenState> {
  final GardenRepository gardenRepository;
  final AuthRepository authRepository;

  Garden _savedGarden = const Garden();
  Garden _currentGarden = const Garden();

  GardenBloc({required this.gardenRepository, required this.authRepository})
    : super(GardenInitial()) {
    on<LoadGarden>(_onLoadGarden);
    on<AddTerrace>(_onAddTerrace);
    on<UpdateTerracePosition>(_onUpdateTerracePosition);
    on<UpdateTerraceSize>(_onUpdateTerraceSize);
    on<UpdateGardenSize>(_onUpdateGardenSize);
    on<SaveGarden>(_onSaveGarden);
    on<ResetGarden>(_onResetGarden);
  }

  Future<void> _onLoadGarden(
    LoadGarden event,
    Emitter<GardenState> emit,
  ) async {
    emit(GardenLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(GardenError('Please sign in before loading your garden.'));
        return;
      }
      _savedGarden = await gardenRepository.getGarden(user.id);
      _currentGarden = _savedGarden;
      emit(GardenLoaded(garden: _currentGarden));
    } catch (e) {
      emit(
        GardenError(
          'Could not load your garden. Please check your connection and try again.',
        ),
      );
    }
  }

  void _onAddTerrace(AddTerrace event, Emitter<GardenState> emit) {
    _currentGarden = _currentGarden.copyWith(
      terraces: List.from(_currentGarden.terraces)..add(event.terrace),
    );
    _emitLoaded(emit);
  }

  void _onUpdateTerracePosition(
    UpdateTerracePosition event,
    Emitter<GardenState> emit,
  ) {
    final terraces = List<Terrace>.from(_currentGarden.terraces);
    final index = terraces.indexWhere((t) => t.id == event.id);
    if (index != -1) {
      final t = terraces[index];
      terraces[index] = t.copyWith(x: event.x, y: event.y);
      _currentGarden = _currentGarden.copyWith(terraces: terraces);
      _emitLoaded(emit);
    }
  }

  void _onUpdateTerraceSize(
    UpdateTerraceSize event,
    Emitter<GardenState> emit,
  ) {
    final terraces = List<Terrace>.from(_currentGarden.terraces);
    final index = terraces.indexWhere((t) => t.id == event.id);
    if (index != -1) {
      final t = terraces[index];
      terraces[index] = t.copyWith(width: event.width, height: event.height);
      _currentGarden = _currentGarden.copyWith(terraces: terraces);
      _emitLoaded(emit);
    }
  }

  void _onUpdateGardenSize(UpdateGardenSize event, Emitter<GardenState> emit) {
    _currentGarden = _currentGarden.copyWith(
      size: GardenSize(width: event.width, height: event.height),
    );
    _emitLoaded(emit);
  }

  Future<void> _onSaveGarden(
    SaveGarden event,
    Emitter<GardenState> emit,
  ) async {
    final previousState = state;
    if (previousState is GardenLoaded) {
      emit(previousState.copyWith(isSaving: true, clearError: true));
    }

    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        _emitSaveFailure(
          emit,
          previousState,
          'Please sign in again before saving your garden.',
        );
        return;
      }

      await gardenRepository.saveGarden(user.id, _currentGarden);
      _savedGarden = _currentGarden;
      emit(GardenLoaded(garden: _currentGarden, hasUnsavedChanges: false));
    } catch (e) {
      _emitSaveFailure(
        emit,
        previousState,
        'Could not save your garden. Your edits are still on screen.',
      );
    }
  }

  void _onResetGarden(ResetGarden event, Emitter<GardenState> emit) {
    _currentGarden = _savedGarden;
    emit(GardenLoaded(garden: _currentGarden, hasUnsavedChanges: false));
  }

  void _emitLoaded(Emitter<GardenState> emit) {
    emit(GardenLoaded(garden: _currentGarden, hasUnsavedChanges: true));
  }

  void _emitSaveFailure(
    Emitter<GardenState> emit,
    GardenState previousState,
    String message,
  ) {
    if (previousState is GardenLoaded) {
      emit(
        previousState.copyWith(
          garden: _currentGarden,
          hasUnsavedChanges: true,
          isSaving: false,
          errorMessage: message,
        ),
      );
      return;
    }

    emit(GardenError(message));
  }
}
