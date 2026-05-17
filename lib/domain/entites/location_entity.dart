import 'package:equatable/equatable.dart';

class LocationEntity extends Equatable {
  final double lat;
  final double lon;

  const LocationEntity({required this.lat, required this.lon});

  @override
  List<Object?> get props => [lat, lon];
}
