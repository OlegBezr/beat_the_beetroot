import 'package:beat_the_beetroot/models/collection_walk.dart';
import 'package:beat_the_beetroot/utils/math_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mt;

class WalkUtils {
  static List<LatLng> walkToPolygon(CollectionWalk walk) {
    List<LatLng> points = [];

    double perpHeading = 0;
    mt.LatLng newPoint;
    for (int i = 0; i < walk.points.length - 1; i++) {
      final point1 = walk.points[i];
      final point2 = walk.points[i + 1];

      final heading = mt.SphericalUtil.computeHeading(
        mt.LatLng(point1.latitude, point1.longitude),
        mt.LatLng(point2.latitude, point2.longitude),
      );
      perpHeading = MathUtils.wrap(heading + 90, -180, 180).toDouble();
      newPoint = mt.SphericalUtil.computeOffset(
        mt.LatLng(point1.latitude, point1.longitude),
        walk.radius,
        perpHeading,
      );
      points.add(LatLng(newPoint.latitude, newPoint.longitude));
    }
    newPoint = mt.SphericalUtil.computeOffset(
      mt.LatLng(walk.points.last.latitude, walk.points.last.longitude),
      walk.radius,
      perpHeading,
    );
    points.add(LatLng(newPoint.latitude, newPoint.longitude));

    for (int i = walk.points.length - 1; i > 0; i--) {
      final point1 = walk.points[i];
      final point2 = walk.points[i - 1];

      final heading = mt.SphericalUtil.computeHeading(
        mt.LatLng(point1.latitude, point1.longitude),
        mt.LatLng(point2.latitude, point2.longitude),
      );
      perpHeading = MathUtils.wrap(heading + 90, -180, 180).toDouble();
      newPoint = mt.SphericalUtil.computeOffset(
        mt.LatLng(point1.latitude, point1.longitude),
        walk.radius,
        perpHeading,
      );
      points.add(LatLng(newPoint.latitude, newPoint.longitude));
    }
    newPoint = mt.SphericalUtil.computeOffset(
      mt.LatLng(walk.points.first.latitude, walk.points.first.longitude),
      walk.radius,
      perpHeading,
    );
    points.add(LatLng(newPoint.latitude, newPoint.longitude));

    return points;
  }
}
