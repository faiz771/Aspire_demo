// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart' as map;


// class MapController extends GetxController {
//   Completer<GoogleMapController> controller = Completer<GoogleMapController>();
//   final RxMap<MarkerId, Marker> markers = <MarkerId, Marker>{}.obs;
//   final MarkerId markerId = const MarkerId('mylocation');
//   var textController = TextEditingController();
//   final meetingDate = TextEditingController(),
//       meetingStartTime = TextEditingController(),
//       meetingEndTime = TextEditingController();
//   final RxList<AutocompletePrediction> predictions =
//       <AutocompletePrediction>[].obs;
//   Rx<Placemark> placemark = Placemark().obs;
//   //RxList<LocationModel> locations = <LocationModel>[].obs;
//   final MapsRoutes route = MapsRoutes();
//   final List<map.LatLng> points = <map.LatLng>[].obs;
//   final RxString distance = '0.0 KM'.obs;
//   bool initialLocaton = false;

//   // drawPoints() {
//   //   points.clear();
//   //   for (var element in locations) {
//   //     points.add(map.LatLng(element.lat, element.lang));
//   //   }
//   // }

//   Future<List<AutocompletePrediction>> searchPlaces(String query) async {
//     try {
//       _toggle();
//       final places = FlutterGooglePlacesSdk(Utils().kMapApi);
//       final predictions = await places.findAutocompletePredictions(query);
//       this.predictions.clear();
//       this.predictions.addAll(predictions.predictions);
//     } catch (e) {
//       Fluttertoast.showToast(msg: e.toString(), toastLength: Toast.LENGTH_LONG);
//     } finally {
//       _toggle();
//     }

//     return predictions;
//   }

//   decodeCoordinatesAndMoveCamera(lat, lang) async {
//     _toggle();
//     try {
//       if (GetPlatform.isWeb) {
//         GeoCoder geoCoder = GeoCoder();
//         Address address =
//             await geoCoder.getAddressFromLatLng(latitude: lat, longitude: lang);
//         currentPosition.value = Position(
//           longitude: lang,
//           latitude: lat,
//           timestamp: DateTime.now(),
//           accuracy: 1,
//           altitude: 0,
//           heading: 0,
//           speed: 0,
//           speedAccuracy: 0, altitudeAccuracy: 1, headingAccuracy: 1,
//         );

//         LogModel log = Get.find<LogController>().log.value;

//         log.lang = lang;
//         log.lat = lat;
//         log.location =
//             "${address.displayName},${address.addressDetails.city} ${address.addressDetails.country}";
//         textController.text = log.location;
//       } else {
//         var place = await placemarkFromCoordinates(lat, lang);
//         if (place.isNotEmpty) {
//           Placemark mark = place.first;
//           currentPosition.value = Position(
//             longitude: lang,
//             latitude: lat,
//             timestamp: DateTime.now(),
//             accuracy: 1,
//             altitude: 0,
//             heading: 0,
//             speed: 0,
//             speedAccuracy: 0, altitudeAccuracy: 1, headingAccuracy: 1,
//           );

//           LogModel log = Get.find<LogController>().log.value;

//           log.lang = lang;
//           log.lat = lat;
//           log.location =
//               "${mark.name},${mark.locality} ${mark.street}, ${mark.country}";
//           textController.text = log.location;
//         }
//         moveCamera(currentPosition.value);
//         updateMarker(lat, lang);
//       }
//     } catch (e) {
//       Fluttertoast.showToast(
//           msg: e.toString(), toastLength: Toast.LENGTH_LONG, webBgColor: 'red');
//     } finally {
//       _toggle();
//     }
//   }

//   decodeCoordinates(lat, lang) async {
//     var place = await placemarkFromCoordinates(
//         double.parse(lat.toString()), double.parse(lang.toString()));
//     if (place.isNotEmpty) {
//       Placemark mark = place.first;
//       placemark.value = mark;
//       return "${mark.name},${mark.locality} ${mark.street}, ${mark.country}";
//     }
//     return '';
//   }

//   decodeCoordinatesAndRefresh(lat, lang) async {
//     _toggle();
//     var place = await placemarkFromCoordinates(lat, lang);
//     if (place.isNotEmpty) {
//       Placemark mark = place.first;
//       placemark.value = mark;
//     }
//     _toggle();
//   }

//   decodeAddressAndMoveCamera(String address) async {
//     var locations = await locationFromAddress(address);
//     if (locations.isNotEmpty) {
//       var loc = locations.first;
//       currentPosition.value = Position(
//         longitude: loc.longitude,
//         latitude: loc.latitude,
//         timestamp: DateTime.now(),
//         accuracy: 1,
//         altitude: 0,
//         heading: 0,
//         speed: 0,
//         speedAccuracy: 0, altitudeAccuracy: 1, headingAccuracy: 1,
//       );
//       moveCamera(currentPosition.value);
//       updateMarker(loc.latitude, loc.longitude);
//       LogController m = Get.find();
//       m.log.value.lang = loc.longitude;
//       m.log.value.lat = loc.latitude;
//       m.log.value.location = address;
//       textController.text = address;
//       update();
//     }
//   }

//   void onSearchTextChanged(String value) async {
//     // final prediction = await places.findAutocompletePredictions(value);

//     // predictions.clear();
//     // predictions.addAll(prediction.predictions);
//     update();
//   }

//   RxBool busy = false.obs;
//   // final DryControl dry = DryControl();
//   final Rx<Position> currentPosition = Position(
//     longitude: -122.677433,
//     latitude: 45.521563,
//     timestamp: DateTime.now(),
//     accuracy: 0,
//     altitude: 10,
//     heading: 0,
//     speed: 0,
//     speedAccuracy: 0, altitudeAccuracy: 1, headingAccuracy: 1,
//   ).obs;

//   final map.LatLng initialLocation = const map.LatLng(45.521563, -122.677433);

//   updateMarker(lat, lang) async {
//     final Marker marker = Marker(
//       markerId: markerId,
//       position: map.LatLng(lat, lang),
//       draggable: true,
//       onDragEnd: (value) {
//         decodeCoordinatesAndMoveCamera(value.latitude, value.longitude);
//         currentPosition.value = Position(
//           longitude: value.longitude,
//           latitude: value.latitude,
//           timestamp: DateTime.now(),
//           accuracy: 0,
//           altitude: 0,
//           heading: 0,
//           speed: 0,
//           speedAccuracy: 0, altitudeAccuracy: 1, headingAccuracy: 1,
//         );
//         update();
//         moveCamera(currentPosition.value);
//       },
//     );

//     markers[markerId] = marker;
//     update();
//   }

//   moveCamera(Position position) async {
//     currentPosition.value = position;
//     var m = await controller.future;

//     m.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//             target: map.LatLng(position.latitude, position.longitude),
//             zoom: 16),
//       ),
//     );
//   }

//   getCurrentLocation() async {
//     try {
//       if (await Permission.location.isDenied) {
//         await Permission.location.request();
//       }

//       _toggle();
//       final position = await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.high);

//       if (controller.isCompleted) {
//         currentPosition.value = position;

//         moveCamera(position);
//         updateMarker(position.latitude, position.longitude);
//         var mark =
//             await decodeCoordinates(position.latitude, position.longitude);
//         if (initialLocaton) {
//           textController.text = mark.toString();
//         } else {
//           initialLocaton = true;
//         }
//       }
//     } catch (e) {
//       if (e is PermissionDeniedException) {
//         // Handle permission denied error
//         await Permission.location.request();
//       } else if (e is LocationServiceDisabledException) {
//         // Handle GPS disabled error
//         Geolocator.openLocationSettings();
//       } else {
//         // Fluttertoast.showToast(
//         //     msg: e.toString(),
//         //     toastLength: Toast.LENGTH_LONG,
//         //     webBgColor: 'red');
//       }
//     } finally {
//       _toggle();
//     }
//   }

//   _toggle() {
//     busy.toggle();
//     update();
//   }

//   bool isBusy() {
//     return busy.isTrue;
//   }
// }