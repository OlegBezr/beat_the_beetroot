import 'package:cloud_firestore/cloud_firestore.dart';

class Field {
  final String id;
  final String name;
  final GeoPoint center;
  final List<GeoPoint> contour;

  const Field({
    required this.id,
    required this.name,
    required this.center,
    required this.contour,
  });

  factory Field.fromJson(String id, Map<String, dynamic> json) {
    return Field(
      id: id,
      name: json['name'],
      center: json['center'],
      contour: List<GeoPoint>.from(json['contour']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'center': center,
      'contour': contour,
    };
  }
}
