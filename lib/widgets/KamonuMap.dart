import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

/*Todo: On Location Update only make the Map "dirty" do not scroll "automatically"
 to the new deliverd location... ony do this when forced to*/
class KamonuMap extends StatefulWidget {
  KamonuMap({Key? key}) : super(key: key);

  // This widget holds the main Map functionality for now :)
  _KamonuMapState kamonuMapState= _KamonuMapState();
  @override
  State<KamonuMap> createState() => kamonuMapState;
  Future<void> reportHomelessPerson() async {
    await kamonuMapState.reportHomelessPerson();
  }
}

class _KamonuMapState extends State<KamonuMap> {

  GoogleMapController? controller;
  static const LatLng center =  LatLng(50.83579299159458, 12.893697118936261);

  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  MarkerId? selectedMarker;
  int _markerIdCounter = 1;
  LatLng? markerPosition;
  Location _location = Location();

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
    _location.onLocationChanged.listen((l) {
      if (l.latitude != null && l.longitude != null) {
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: LatLng(l.latitude!, l.longitude!), zoom: 15),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld = markers[previousMarkerId]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;

        markerPosition = null;
      });
    }
  }

  void _onMarkerDrag(MarkerId markerId, LatLng newPosition) async {
    setState(() {
      markerPosition = newPosition;
    });
  }

  void _onMarkerDragEnd(MarkerId markerId, LatLng newPosition) async {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        markerPosition = null;
      });
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                actions: <Widget>[
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
                content: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 66),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text('Old position: ${tappedMarker.position}'),
                        Text('New position: $newPosition'),
                      ],
                    )));
          });
    }
  }

  Future<void> reportHomelessPerson() async {
    final int markerCount = markers.length;

    if (markerCount == 12) {
      return;
    }

    final String markerIdVal = 'like_us_$_markerIdCounter';
    _markerIdCounter++;
    final MarkerId markerId = MarkerId(markerIdVal);
    double screenWidth = MediaQuery.of(context).size.width * MediaQuery.of(context).devicePixelRatio;
    double screenHeight = MediaQuery.of(context).size.height *
        MediaQuery.of(context).devicePixelRatio;

    double middleX = screenWidth / 2;
    double middleY = screenHeight / 2;

    ScreenCoordinate screenCoordinate = ScreenCoordinate(x: middleX.round(), y: middleY.round());

    LatLng? middlePoint = await controller?.getLatLng(screenCoordinate);
    middlePoint ??=  middlePoint=center;

    final Marker marker = Marker(
      markerId: markerId,
      position: middlePoint,
      infoWindow: InfoWindow(
          title: markerIdVal,
          snippet: 'he needs help!!!',
      ),

      onTap: () => _onMarkerTapped(markerId),
      onDragEnd: (LatLng position) => _onMarkerDragEnd(markerId, position),
      onDrag: (LatLng position) => _onMarkerDrag(markerId, position),
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  void _remove(MarkerId markerId) {
    setState(() {
      if (markers.containsKey(markerId)) {
        markers.remove(markerId);
      }
    });
  }

  void _changePosition(MarkerId markerId) {
    final Marker marker = markers[markerId]!;
    final LatLng current = marker.position;
    final Offset offset = Offset(
      center.latitude - current.latitude,
      center.longitude - current.longitude,
    );
    setState(() {
      markers[markerId] = marker.copyWith(
        positionParam: LatLng(
          center.latitude + offset.dy,
          center.longitude + offset.dx,
        ),
      );
    });
  }

  void _changeAnchor(MarkerId markerId) {
    final Marker marker = markers[markerId]!;
    final Offset currentAnchor = marker.anchor;
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    setState(() {
      markers[markerId] = marker.copyWith(
        anchorParam: newAnchor,
      );
    });
  }

  Future<void> _changeInfoAnchor(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final Offset currentAnchor = marker.infoWindow.anchor;
    final Offset newAnchor = Offset(1.0 - currentAnchor.dy, currentAnchor.dx);
    setState(() {
      markers[markerId] = marker.copyWith(
        infoWindowParam: marker.infoWindow.copyWith(
          anchorParam: newAnchor,
        ),
      );
    });
  }

  Future<void> _toggleDraggable(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    setState(() {
      markers[markerId] = marker.copyWith(
        draggableParam: !marker.draggable,
      );
    });
  }

  Future<void> _toggleFlat(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    setState(() {
      markers[markerId] = marker.copyWith(
        flatParam: !marker.flat,
      );
    });
  }

  Future<void> _changeInfo(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final String newSnippet = marker.infoWindow.snippet! + '*';
    setState(() {
      markers[markerId] = marker.copyWith(
        infoWindowParam: marker.infoWindow.copyWith(
          snippetParam: newSnippet,
        ),
      );
    });
  }

  Future<void> _changeAlpha(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final double current = marker.alpha;
    setState(() {
      markers[markerId] = marker.copyWith(
        alphaParam: current < 0.1 ? 1.0 : current * 0.75,
      );
    });
  }

  Future<void> _changeRotation(MarkerId markerId) async {
    final Marker marker = markers[markerId]!;
    final double current = marker.rotation;
    setState(() {
      markers[markerId] = marker.copyWith(
        rotationParam: current == 330.0 ? 0.0 : current + 30.0,
      );
    });
  }



  @override
  Widget build(BuildContext context) {
    return  GoogleMap(
          onMapCreated: _onMapCreated,
          //TODO: Store the Map position and restart at the stored position
          initialCameraPosition: const CameraPosition(
            target: center,
            zoom: 17.0,
          ),
          myLocationEnabled: true,
          markers: Set<Marker>.of(markers.values),
        );
  }
}