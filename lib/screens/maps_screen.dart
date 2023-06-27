import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:remindme/widgets/auto_complete_search_bar.dart';

import '../controller/get_controller.dart';

// ignore: must_be_immutable
class MapsScreen extends StatefulWidget {
  MapsScreen({Key? key}) : super(key: key);
  bool isFirst = true;

  @override
  State<MapsScreen> createState() => MapSampleState();
}

class MapSampleState extends State<MapsScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  double radius = 25.0;
  bool isInit = true;

  final Get_Controller get_controller = Get.find<Get_Controller>();

  CameraPosition? currentLocation;

  Set<Marker> markers = <Marker>{};
  Set<Circle> circles = <Circle>{};

  Map<String, dynamic> mapResult = {
    'sublocality': '-',
    'latitude': 0.0,
    'longitude': 0.0
  };

  @override
  void initState() {
    super.initState();
  }

  initWithArguments() async {
    if (Get.arguments != null) {
      if (Get.arguments.length == 1) {
        radius = Get.arguments['radius'];
      } else if (Get.arguments.length == 3) {
        radius = Get.arguments['radius'];
        final MarkerId markerId = MarkerId('selectedMarker');
        Marker marker = Marker(
          onTap: () {
            mapResult = {
              'sublocality': Get.arguments['sublocality'],
              'latitude': Get.arguments['LatLng'].latitude,
              'longitude': Get.arguments['LatLng'].longitude
            };
            showLocationBottomSheet(context, Get.arguments['sublocality'],
                Get.arguments['LatLng'], mapResult);
          },
          markerId: markerId,
          position: Get.arguments['LatLng'],
          visible: true,
          icon: BitmapDescriptor.defaultMarker,
        );
        markers.add(marker);

        final CircleId circleId = CircleId('selectedCircle');
        Circle circle = Circle(
          circleId: circleId,
          center: Get.arguments['LatLng'],
          radius: radius,
          strokeWidth: 1,
          strokeColor: Color.fromRGBO(126, 188, 255, 1),
          fillColor: Color.fromRGBO(126, 188, 255, 0.5),
        );
        circles.add(circle);

        GoogleMapController controller = await _controller.future;
        controller.animateCamera(
            CameraUpdate.newLatLngZoom(Get.arguments['LatLng'], 16.5));
      }
    }
  }

  getCurrentLocation() async {
    if (isInit) {
      isInit = false;
      initWithArguments();
    }

    CameraPosition? cameraPosition;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position p) {
      cameraPosition = CameraPosition(
        target: LatLng(p.latitude, p.longitude),
        zoom: 14.4746,
      );
    }).catchError((e) {
      debugPrint(e);
    });
    return cameraPosition;
  }

  _addMarkerLongPressed(
      BuildContext context, LatLng latlng, String address) async {
    if (address.isNotEmpty) {
      mapResult['sublocality'] = address;
      mapResult['latitude'] = latlng.latitude;
      mapResult['longitude'] = latlng.longitude;
    } else {
      await placemarkFromCoordinates(latlng.latitude, latlng.longitude)
          .then((List<Placemark> placemarks) {
        Placemark place = placemarks[0];

        mapResult['sublocality'] =
            place.subLocality!.isNotEmpty ? place.subLocality : place.locality;
        mapResult['latitude'] = latlng.latitude;
        mapResult['longitude'] = latlng.longitude;
      }).catchError((e) {
        debugPrint(e);
      });
    }

    showLocationBottomSheet(
        context, mapResult['sublocality'], latlng, mapResult);

    setState(() {
      final MarkerId markerId = MarkerId('selectedMarker');
      Marker marker = Marker(
        onTap: () {
          showLocationBottomSheet(
              context, mapResult['sublocality'], latlng, mapResult);
        },
        markerId: markerId,
        position: latlng,
        visible: true,
        icon: BitmapDescriptor.defaultMarker,
      );
      markers.add(marker);
      final CircleId circleId = CircleId('selectedCircle');
      Circle circle = Circle(
        circleId: circleId,
        center: latlng,
        radius: radius,
        strokeWidth: 1,
        strokeColor: Color.fromRGBO(126, 188, 255, 1),
        fillColor: Color.fromRGBO(126, 188, 255, 0.5),
      );
      circles.add(circle);
    });

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(latlng, 16.5));
  }

  Future<dynamic> showLocationBottomSheet(BuildContext context, String address,
      LatLng latlng, Map<String, dynamic> mapResult) {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.all(15),
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 255, 255, 0.8),
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15),
                    topLeft: Radius.circular(15)),
              ),
              width: double.infinity,
              height: 190,
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 38, 85, 40),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color.fromARGB(255, 96, 125, 97),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Latitude: ' + latlng.latitude.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 96, 125, 97),
                    ),
                  ),
                  SizedBox(
                    height: 2,
                  ),
                  Text(
                    'Longitude: ' + latlng.longitude.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 96, 125, 97),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 50),
                            backgroundColor: Colors
                                .green //Color.fromARGB(255, 252, 139, 26),
                            ),
                        onPressed: () {
                          Navigator.pop(context);
                          Get.back(result: mapResult);
                        },
                        child: Text('Use this Location')),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  showSnackBar(BuildContext context, String title) {
    int length = Get.arguments == null ? 0 : Get.arguments.length;
    if (widget.isFirst && length == 1) {
      widget.isFirst = false;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          content: Text(
            title,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.green,
      body: SafeArea(
        child: FutureBuilder(
          future: getCurrentLocation(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Future.delayed(
                Duration(seconds: 2),
                () => showSnackBar(context, 'Tap and Hold to select Location'),
              );
              return Stack(
                children: [
                  GoogleMap(
                    onLongPress: (latlang) async {
                      _addMarkerLongPressed(context, latlang, '');
                    },
                    markers: markers,
                    circles: circles,
                    scrollGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    myLocationEnabled: true,
                    compassEnabled: true,
                    mapToolbarEnabled: true,
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                    initialCameraPosition: snapshot.data as CameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
                  AutoCompleteSearch(
                    getCoordinates: (latLng, address) {
                      _addMarkerLongPressed(context, latLng, address);
                    },
                  ),
                ],
              );
            } else {
              return Container(
                child: SpinKitFadingFour(
                  color: Colors.white,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
