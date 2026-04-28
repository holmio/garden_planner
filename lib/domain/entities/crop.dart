import 'package:equatable/equatable.dart';

class Crop extends Equatable {
  final String id;
  final String terraceId;
  final String apiPlantId;
  final String customName;
  final DateTime plantDate;
  final DateTime expectedHarvestDate;
  final String status;
  final int year;

  const Crop({
    required this.id,
    required this.terraceId,
    required this.apiPlantId,
    required this.customName,
    required this.plantDate,
    required this.expectedHarvestDate,
    required this.status,
    required this.year,
  });

  @override
  List<Object?> get props => [
        id,
        terraceId,
        apiPlantId,
        customName,
        plantDate,
        expectedHarvestDate,
        status,
        year,
      ];
}
