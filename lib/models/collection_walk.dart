import 'package:cloud_firestore/cloud_firestore.dart';

class CollectionWalk {
  final String id;
  final double radius;
  final List<GeoPoint> points;

  const CollectionWalk({
    required this.id,
    required this.radius,
    required this.points,
  });

  factory CollectionWalk.fromJson(String id, Map<String, dynamic> json) {
    return CollectionWalk(
      id: id,
      radius: json['radius'],
      points: List<GeoPoint>.from(json['points']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'radius': radius,
      'points': points,
    };
  }
}
