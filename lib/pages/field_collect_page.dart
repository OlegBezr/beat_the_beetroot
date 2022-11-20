import 'dart:async';
import 'dart:math';

import 'package:beat_the_beetroot/constants.dart';
import 'package:beat_the_beetroot/firebase/firestore_refs.dart';
import 'package:beat_the_beetroot/models/collection_walk.dart';
import 'package:beat_the_beetroot/models/field.dart';
import 'package:beat_the_beetroot/utils/walk_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

class FieldCollectPage extends StatefulWidget {
  const FieldCollectPage(
      {super.key, required this.field, required this.collectorRadius});

  final Field field;
  final double collectorRadius;

  @override
  State<FieldCollectPage> createState() => _FieldCollectPageState();
}

class _FieldCollectPageState extends State<FieldCollectPage> {
  final Completer<GoogleMapController> _controller = Completer();
  late CollectionReference<CollectionWalk> _collectionWalksRef;
  late Stream<QuerySnapshot<CollectionWalk>> _stream;
  late StreamSubscription _sub;

  late Polyline _walkPolyline;

  Future<bool> get _locationPermissionGranted async {
    return await Permission.location.request().isGranted;
  }

  @override
  void initState() {
    super.initState();
    _walkPolyline = Polyline(
      polylineId: const PolylineId('walk'),
      color: Colors.blue,
      endCap: Cap.roundCap,
      startCap: Cap.roundCap,
      width: max(1, (widget.collectorRadius * 2).toInt()),
    );
    _collectionWalksRef = collectionWalksRef(widget.field.id);
    _stream = _collectionWalksRef.snapshots();
    getCurrentLocation();
    _locationPermissionGranted;
  }

  LocationData? currentLocation;
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) async {
        currentLocation = location;
      },
    );

    GoogleMapController googleMapController = await _controller.future;
    _sub = location.onLocationChanged.listen(
      (newLoc) async {
        currentLocation = newLoc;
        final zoom = await googleMapController.getZoomLevel();
        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: zoom,
              target: LatLng(
                newLoc.latitude!,
                newLoc.longitude!,
              ),
            ),
          ),
        );
        setState(() {
          _walkPolyline = _walkPolyline.copyWith(
            pointsParam: [
              ..._walkPolyline.points,
              LatLng(newLoc.latitude!, newLoc.longitude!),
            ],
          );
        });
      },
    );
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

        return Scaffold(
          extendBody: true,
          appBar: AppBar(
            title: Text('Поле ${widget.field.name}'),
            centerTitle: true,
          ),
          body: GoogleMap(
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
            myLocationButtonEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            polylines: {_walkPolyline},
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
          ),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 5,
              left: 20,
              right: 20,
            ),
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  _sub.cancel();
                  _collectionWalksRef.add(
                    CollectionWalk(
                      id: '',
                      radius: widget.collectorRadius,
                      points: _walkPolyline.points
                          .map((e) => GeoPoint(
                                e.latitude,
                                e.longitude,
                              ))
                          .toList(),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                child: const Center(
                  child: Text(
                    'Закончить сбор',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
