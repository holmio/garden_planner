import 'package:equatable/equatable.dart';

import 'garden_size.dart';
import 'terrace.dart';

class Garden extends Equatable {
  static const String defaultGardenId = 'default';
  static const String defaultGardenName = 'My Garden';

  final String id;
  final String name;
  final GardenSize size;
  final List<Terrace> terraces;

  const Garden({
    this.id = defaultGardenId,
    this.name = defaultGardenName,
    this.size = GardenSize.defaultSize,
    this.terraces = const [],
  });

  Garden copyWith({
    String? id,
    String? name,
    GardenSize? size,
    List<Terrace>? terraces,
  }) {
    return Garden(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      terraces: terraces ?? this.terraces,
    );
  }

  @override
  List<Object?> get props => [id, name, size, terraces];
}
