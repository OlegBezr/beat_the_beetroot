import 'dart:async';

import 'package:beat_the_beetroot/constants.dart';
import 'package:beat_the_beetroot/firebase/firestore_refs.dart';
import 'package:beat_the_beetroot/models/field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as maps_toolkit;
import 'package:permission_handler/permission_handler.dart';

class FieldMarkupPage extends StatefulWidget {
  const FieldMarkupPage({super.key, required this.fieldName});

  final String fieldName;

  @override
  State<FieldMarkupPage> createState() => _FieldMarkupPageState();
}

class _FieldMarkupPageState extends State<FieldMarkupPage> {
  final Completer<GoogleMapController> _controller = Completer();
  late StreamSubscription _sub;
  late Field _field;

  Future<bool> get _locationPermissionGranted async {
    return await Permission.location.request().isGranted;
  }

  Polyline _walkPolyline = const Polyline(
    polylineId: PolylineId('walk'),
    color: Colors.blue,
    endCap: Cap.roundCap,
    startCap: Cap.roundCap,
    width: 5,
  );

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _locationPermissionGranted;
  }

  LocationData? currentLocation;
  void getCurrentLocation() async {
    Location location = Location();
    location.getLocation().then(
      (location) {
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
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text('Поле ${widget.fieldName}'),
        centerTitle: true,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        initialCameraPosition: const CameraPosition(
          zoom: Constants.defaultZoom,
          target: LatLng(50, 50),
        ),
        myLocationButtonEnabled: false,
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        polylines: {_walkPolyline},
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
              final navigator = Navigator.of(context);
              _sub.cancel();

              final polygonPoints = _walkPolyline.points.map((e) {
                return maps_toolkit.LatLng(e.latitude, e.longitude);
              }).toList();

              final center = LatLng(
                polygonPoints.first.latitude,
                polygonPoints.first.longitude,
              );

              _field = Field(
                id: '',
                name: widget.fieldName,
                center: GeoPoint(center.latitude, center.longitude),
                contour: _walkPolyline.points.map((e) {
                  return GeoPoint(e.latitude, e.longitude);
                }).toList(),
              );

              fieldsRef.add(_field);
              navigator.pop();
            },
            child: const Center(
              child: Text(
                'Закончить разметку',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
