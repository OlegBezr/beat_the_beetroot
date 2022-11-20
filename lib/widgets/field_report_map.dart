import 'dart:async';

import 'package:beat_the_beetroot/constants.dart';
import 'package:beat_the_beetroot/firebase/firestore_refs.dart';
import 'package:beat_the_beetroot/models/collection_walk.dart';
import 'package:beat_the_beetroot/models/field.dart';
import 'package:beat_the_beetroot/utils/walk_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FieldReportMap extends StatefulWidget {
  const FieldReportMap({super.key, required this.field});

  final Field field;

  @override
  State<FieldReportMap> createState() => _FieldReportMapState();
}

class _FieldReportMapState extends State<FieldReportMap> {
  final Completer<GoogleMapController> _controller = Completer();
  late CollectionReference<CollectionWalk> _collectionWalksRef;
  late Stream<QuerySnapshot<CollectionWalk>> _stream;

  @override
  void initState() {
    super.initState();
    _collectionWalksRef = collectionWalksRef(widget.field.id);
    _stream = _collectionWalksRef.snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Что-то пошло не так')),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: Text('Загрузка')),
          );
        }

        final walksDocs = snapshot.data!.docs;
        final walks = walksDocs.map((snapshot) {
          return snapshot.data();
        }).toList();

        final walkHoles = walks.map((walk) {
          return WalkUtils.walkToPolygon(walk);
        }).toList();

        return GoogleMap(
          zoomControlsEnabled: true,
          rotateGesturesEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.field.center.latitude,
              widget.field.center.longitude,
            ),
            zoom: Constants.defaultZoom,
          ),
          polygons: {
            Polygon(
              polygonId: PolygonId(widget.field.id),
              points: widget.field.contour
                  .map((e) => LatLng(e.latitude, e.longitude))
                  .toList(),
              holes: [
                ...walkHoles,
              ],
              strokeWidth: 1,
              strokeColor: Colors.grey,
              fillColor: Colors.red.withOpacity(0.2),
            ),
          },
        );
      },
    );
  }
}
