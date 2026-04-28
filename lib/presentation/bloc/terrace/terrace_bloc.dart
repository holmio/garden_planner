import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/terrace.dart';
import 'terrace_event.dart';
import 'terrace_state.dart';

class TerraceBloc extends Bloc<TerraceEvent, TerraceState> {
  List<Terrace> _savedTerraces = [];
  List<Terrace> _currentTerraces = [];

  TerraceBloc() : super(TerraceInitial()) {
    on<LoadTerraces>(_onLoadTerraces);
    on<AddTerrace>(_onAddTerrace);
    on<UpdateTerracePosition>(_onUpdateTerracePosition);
    on<SaveLayout>(_onSaveLayout);
    on<ResetLayout>(_onResetLayout);
  }

  void _onLoadTerraces(LoadTerraces event, Emitter<TerraceState> emit) {
    emit(TerraceLoading());
    // Mocking a database load
    _savedTerraces = [
      const Terrace(id: '1', name: 'Tomatoes', x: 100, y: 100, width: 200, height: 150, sunExposure: 'Full Sun'),
    ];
    _currentTerraces = List.from(_savedTerraces);
    emit(TerraceLoaded(_currentTerraces));
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

  void _onSaveLayout(SaveLayout event, Emitter<TerraceState> emit) {
    _savedTerraces = List.from(_currentTerraces);
    // TODO: Send to Firebase
    emit(TerraceLoaded(_currentTerraces, hasUnsavedChanges: false));
  }

  void _onResetLayout(ResetLayout event, Emitter<TerraceState> emit) {
    _currentTerraces = List.from(_savedTerraces);
    emit(TerraceLoaded(_currentTerraces, hasUnsavedChanges: false));
  }
}
