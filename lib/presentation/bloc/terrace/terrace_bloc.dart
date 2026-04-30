import 'package:flutter_bloc/flutter_bloc.dart';
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

  TerraceBloc({
    required this.terraceRepository,
    required this.authRepository,
  }) : super(TerraceInitial()) {
    on<LoadTerraces>(_onLoadTerraces);
    on<AddTerrace>(_onAddTerrace);
    on<UpdateTerracePosition>(_onUpdateTerracePosition);
    on<SaveLayout>(_onSaveLayout);
    on<ResetLayout>(_onResetLayout);
  }

  Future<void> _onLoadTerraces(LoadTerraces event, Emitter<TerraceState> emit) async {
    emit(TerraceLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(TerraceError("User not authenticated"));
        return;
      }
      _savedTerraces = await terraceRepository.getTerraces(user.id);
      _currentTerraces = List.from(_savedTerraces);
      emit(TerraceLoaded(_currentTerraces));
    } catch (e) {
      emit(TerraceError(e.toString()));
    }
  }

  void _onAddTerrace(AddTerrace event, Emitter<TerraceState> emit) {
    _currentTerraces = List.from(_currentTerraces)..add(event.terrace);
    emit(TerraceLoaded(_currentTerraces, hasUnsavedChanges: true));
  }

  void _onUpdateTerracePosition(UpdateTerracePosition event, Emitter<TerraceState> emit) {
    final index = _currentTerraces.indexWhere((t) => t.id == event.id);
    if (index != -1) {
      final t = _currentTerraces[index];
      _currentTerraces[index] = Terrace(
        id: t.id,
        name: t.name,
        x: event.x,
        y: event.y,
        width: t.width,
        height: t.height,
        sunExposure: t.sunExposure,
        irrigationType: t.irrigationType,
      );
      emit(TerraceLoaded(List.from(_currentTerraces), hasUnsavedChanges: true));
    }
  }

  Future<void> _onSaveLayout(SaveLayout event, Emitter<TerraceState> emit) async {
    try {
      final user = await authRepository.getCurrentUser();
      if (user == null) throw Exception("User not authenticated");

      await terraceRepository.saveTerraces(user.id, _currentTerraces);
      _savedTerraces = List.from(_currentTerraces);
      emit(TerraceLoaded(_currentTerraces, hasUnsavedChanges: false));
    } catch (e) {
      emit(TerraceError(e.toString()));
    }
  }

  void _onResetLayout(ResetLayout event, Emitter<TerraceState> emit) {
    _currentTerraces = List.from(_savedTerraces);
    emit(TerraceLoaded(_currentTerraces, hasUnsavedChanges: false));
  }
}
