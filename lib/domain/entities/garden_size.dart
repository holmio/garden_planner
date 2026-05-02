import 'package:equatable/equatable.dart';

class GardenSize extends Equatable {
  static const GardenSize defaultSize = GardenSize(width: 420, height: 760);

  final double width;
  final double height;

  const GardenSize({required this.width, required this.height});

  GardenSize copyWith({double? width, double? height}) {
    return GardenSize(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  List<Object?> get props => [width, height];
}
