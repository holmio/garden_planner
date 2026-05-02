import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/garden_size.dart';
import '../../../domain/entities/terrace.dart';
import '../../../domain/repositories/terrace_repository.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'terrace_event.dart';
import 'terrace_state.dart';

class TerraceBloc extends Bloc<TerraceEvent, TerraceState> {
  final TerraceRepository terraceRepository;
  final AuthRepository authRepository;

  List<Terrace> _savedTerraces = [];
  List<Terrace> _currentTerraces = [];
  GardenSize _savedGardenSize = GardenSize.defaultSize;
  GardenSize _currentGardenSize = GardenSize.defaultSize;

  TerraceBloc({required this.terraceRepository, required this.authRepository})
    : super(TerraceInitial()) {
    on<LoadTerraces>(_onLoadTerraces);
    on<AddTerrace>(_onAddTerrace);
    on<UpdateTerracePosition>(_onUpdateTerracePosition);
    on<UpdateTerraceSize>(_onUpdateTerraceSize);
    on<UpdateGardenSize>(_onUpdateGardenSize);
    on<SaveLayout>(_onSaveLayout);
    on<ResetLayout>(_onResetLayout);
  }

  Future<void> _onLoadTerraces(
    LoadTerraces event,
    Emitter<TerraceState> emit,
  ) async {
    emit(TerraceLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(TerraceError('Please sign in before loading your garden.'));
        return;
      }
      _savedTerraces = await terraceRepository.getTerraces(user.id);
      _savedGardenSize = await terraceRepository.getGardenSize(user.id);
      _currentTerraces = List.from(_savedTerraces);
      _currentGardenSize = _savedGardenSize;
      emit(TerraceLoaded(_currentTerraces, gardenSize: _currentGardenSize));
    } catch (e) {
      emit(
        TerraceError(
          'Could not load your garden. Please check your connection and try again.',
        ),
      );
    }
  }

  void _onAddTerrace(AddTerrace event, Emitter<TerraceState> emit) {
    _currentTerraces = List.from(_currentTerraces)..add(event.terrace);
    _emitLoaded(emit);
  }

  void _onUpdateTerracePosition(
    UpdateTerracePosition event,
    Emitter<TerraceState> emit,
  ) {
    final index = _currentTerraces.indexWhere((t) => t.id == event.id);
    if (index != -1) {
      final t = _currentTerraces[index];
      _currentTerraces[index] = t.copyWith(x: event.x, y: event.y);
      _emitLoaded(emit);
    }
  }

  void _onUpdateTerraceSize(
    UpdateTerraceSize event,
    Emitter<TerraceState> emit,
  ) {
    final index = _currentTerraces.indexWhere((t) => t.id == event.id);
    if (index != -1) {
      final t = _currentTerraces[index];
      _currentTerraces[index] = t.copyWith(
        width: event.width,
        height: event.height,
      );
      _emitLoaded(emit);
    }
  }

  void _onUpdateGardenSize(UpdateGardenSize event, Emitter<TerraceState> emit) {
    _currentGardenSize = GardenSize(width: event.width, height: event.height);
    _emitLoaded(emit);
  }

  Future<void> _onSaveLayout(
    SaveLayout event,
    Emitter<TerraceState> emit,
  ) async {
    final previousState = state;
    if (previousState is TerraceLoaded) {
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

      await terraceRepository.saveTerraces(user.id, _currentTerraces);
      await terraceRepository.saveGardenSize(user.id, _currentGardenSize);
      _savedTerraces = List.from(_currentTerraces);
      _savedGardenSize = _currentGardenSize;
      emit(
        TerraceLoaded(
          _currentTerraces,
          gardenSize: _currentGardenSize,
          hasUnsavedChanges: false,
        ),
      );
    } catch (e) {
      _emitSaveFailure(
        emit,
        previousState,
        'Could not save your garden. Your edits are still on screen.',
      );
    }
  }

  void _onResetLayout(ResetLayout event, Emitter<TerraceState> emit) {
    _currentTerraces = List.from(_savedTerraces);
    _currentGardenSize = _savedGardenSize;
    emit(
      TerraceLoaded(
        _currentTerraces,
        gardenSize: _currentGardenSize,
        hasUnsavedChanges: false,
      ),
    );
  }

  void _emitLoaded(Emitter<TerraceState> emit) {
    emit(
      TerraceLoaded(
        List.from(_currentTerraces),
        gardenSize: _currentGardenSize,
        hasUnsavedChanges: true,
      ),
    );
  }

  void _emitSaveFailure(
    Emitter<TerraceState> emit,
    TerraceState previousState,
    String message,
  ) {
    if (previousState is TerraceLoaded) {
      emit(
        previousState.copyWith(
          terraces: List.from(_currentTerraces),
          gardenSize: _currentGardenSize,
          hasUnsavedChanges: true,
          isSaving: false,
          errorMessage: message,
        ),
      );
      return;
    }

    emit(TerraceError(message));
  }
}
