// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:aspire/helper/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DashBoardScreen extends StatefulWidget {
  @override
  DashBoardScreenState createState() => DashBoardScreenState();
  String? cancelReason;
  DashBoardScreen({this.cancelReason});
}

class DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LatLng? sourceLocation;
  Set<Marker> markers = {};  // Changed to Set<Marker> to handle markers better
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;

  double cameraZoom = 17.0, cameraTilt = 0;
  double cameraBearing = 30;
  int selectIndex = 0;
  String sourceLocationTitle = '';

  late StreamSubscription<ServiceStatus> serviceStatusStream;
  LocationPermission? permissionData;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case when permission is permanently denied
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    LatLng userLocation = LatLng(position.latitude, position.longitude);

    print("UserLocation ${userLocation}");

    // Update markers with the user's location
    setState(() {
      markers.add(
        Marker(
          markerId: MarkerId("MyLocation"),
          position: userLocation,
          infoWindow: InfoWindow(title: "Current Status"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });

    // Add nearby drivers (you can replace this with your actual driver data)
    getNearbyDrivers(userLocation);
  }

  // Function to add nearby driver markers
  Future<void> getNearbyDrivers(LatLng userLocation) async {
    // Mock data for nearby drivers (replace with actual API call)
    List<LatLng> driverLocations = [
      LatLng(userLocation.latitude + 0.01, userLocation.longitude + 0.01),
      LatLng(userLocation.latitude - 0.01, userLocation.longitude - 0.01),
       LatLng(userLocation.latitude + 0.05, userLocation.longitude + 0.03),
      LatLng(userLocation.latitude - 0.03, userLocation.longitude - 0.02),
    ];

    setState(() {
      for (var driverLocation in driverLocations) {
        markers.add(
          Marker(
            markerId: MarkerId(
                "driver_${driverLocation.latitude}_${driverLocation.longitude}"),
            position: driverLocation,
            infoWindow: InfoWindow(title: "Nearby Driver"),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // App Bar Text (Without the image)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Find My Bus",
                    style: TextStyle(
                        fontSize: 35,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
              // Google Map Display
              Container(
                height: Get.height * 0.7,
                child: GoogleMap(
                  padding: EdgeInsets.only(top: 42),
                  compassEnabled: true,
                  mapToolbarEnabled: false,
                  zoomControlsEnabled: false,
                  myLocationEnabled: false,
                  mapType: MapType.normal,
                  markers: markers,
                  polylines: _polyLines,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(25.3703262, 68.3534493),  // Default to Karachi coordinates
                    zoom: cameraZoom,
                    tilt: cameraTilt,
                    bearing: cameraBearing,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// // ignore_for_file: must_be_immutable

// import 'dart:async';
// import 'package:aspire/helper/app_text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class DashBoardScreen extends StatefulWidget {
//   @override
//   DashBoardScreenState createState() => DashBoardScreenState();
//   String? cancelReason;
//   DashBoardScreen({this.cancelReason});
// }

// class DashBoardScreenState extends State<DashBoardScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   LatLng? sourceLocation;

//   // List<TexIModel> list = getBookList();
//   List<Marker> markers = [];
//   Set<Polyline> _polyLines = Set<Polyline>();
//   List<LatLng> polylineCoordinates = [];
//   late PolylinePoints polylinePoints;
//   // OnRideRequest? servicesListData;

//   double cameraZoom = 17.0, cameraTilt = 0;

//   double cameraBearing = 30;
//   int onTapIndex = 0;

//   int selectIndex = 0;
//   String sourceLocationTitle = '';

//   late StreamSubscription<ServiceStatus> serviceStatusStream;

//   LocationPermission? permissionData;

//   late BitmapDescriptor riderIcon;
//   late BitmapDescriptor driverIcon;
//   // List<NearByDriverListModel>? nearDriverModel;

//   @override
//   void initState() {
//     super.initState();
//     init();
//     // locationPermission();
//   }

//   void init() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Show a dialog to inform the user about enabling permissions in settings
//       return;
//     }

//     Position position = await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//     );
//     LatLng userLocation = LatLng(position.latitude, position.longitude);

//     print("UserLocation ${userLocation}");
    
//     setState(() {
//       markers.add(
//         Marker(
//           markerId: MarkerId("MyLocation"),
//           position: userLocation,
//           infoWindow: InfoWindow(title: "Currecnt Status"),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         ),
//       );
//     });
//     print(markers);
//     getNearbyDrivers(userLocation);
//   }

// // Function to add nearby driver markers
//   Future<void> getNearbyDrivers(LatLng userLocation) async {
//     // Mock data for nearby drivers (replace with actual API call)
//     List<LatLng> driverLocations = [
//       LatLng(userLocation.latitude + 0.01, userLocation.longitude + 0.01),
//       LatLng(userLocation.latitude - 0.01, userLocation.longitude - 0.01),
//     ];

//     for (var driverLocation in driverLocations) {
//       setState(() {
//         markers.add(
//           Marker(
//             markerId: MarkerId(
//                 "driver_${driverLocation.latitude}_${driverLocation.longitude}"),
//             position: driverLocation,
//             infoWindow: InfoWindow(title: "Nearby Driver"),
//             icon:
//                 BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//             // icon: driverIcon, // You can customize this to your own icon
//           ),
//         );
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
    

//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               // if (sharedPref.getDouble(LATITUDE) != null &&
//               //     sharedPref.getDouble(LONGITUDE) != null)

//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "Find My Bus",
//                     style: TextStyle(
//                         fontSize: 35,
//                         color: Colors.blue,
//                         fontWeight: FontWeight.bold),
//                   ),
//                   Image.asset("assets/ic_car.png")
//                 ],
//               ),
//               SizedBox(
//                 height: 15,
//               ),
//               Container(
//                 height: Get.height * 0.7,
//                 child: GoogleMap(
//                   padding: EdgeInsets.only(top: 42),
//                   compassEnabled: true,
//                   mapToolbarEnabled: false,
//                   zoomControlsEnabled: false,
//                   myLocationEnabled: false,
//                   mapType: MapType.normal,
//                   // myLocationEnabled: false,
//                   markers: markers.map((e) => e).toSet(),
//                   polylines: _polyLines,
//                   initialCameraPosition: CameraPosition(
//                     target: LatLng(25.3960, 68.3578!),
//                     zoom: cameraZoom,
//                     tilt: cameraTilt,
//                     bearing: cameraBearing,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget topWidget() {
//   //   return Row(
//   //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //     children: [
//   //       inkWellWidget(
//   //         onTap: () {
//   //           _scaffoldKey.currentState!.openDrawer();
//   //         },
//   //         child: Container(
//   //           padding: EdgeInsets.all(4),
//   //           decoration: BoxDecoration(
//   //             color: Colors.white,
//   //             boxShadow: [
//   //               BoxShadow(
//   //                   color: Colors.black.withOpacity(0.2), spreadRadius: 1),
//   //             ],
//   //             borderRadius: BorderRadius.circular(defaultRadius),
//   //           ),
//   //           child: Icon(Icons.drag_handle),
//   //         ),
//   //       ),
//   //       inkWellWidget(
//   //         onTap: () {
//   //           launchScreen(context, NotificationScreen(),
//   //               pageRouteAnimation: PageRouteAnimation.Slide);
//   //         },
//   //         child: Container(
//   //           padding: EdgeInsets.all(4),
//   //           decoration: BoxDecoration(
//   //             color: Colors.white,
//   //             boxShadow: [
//   //               BoxShadow(
//   //                   color: Colors.black.withOpacity(0.2), spreadRadius: 1),
//   //             ],
//   //             borderRadius: BorderRadius.circular(defaultRadius),
//   //           ),
//   //           child: Icon(Ionicons.notifications_outline),
//   //         ),
//   //       ),
//   //     ],
//   //   );
//   // }

//   // void _triggerCanceledPopup() {
//   //   showDialog(
//   //     context: context,
//   //     barrierDismissible: false,
//   //     builder: (context) {
//   //       return AlertDialog(
//   //         title: Row(
//   //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   //           mainAxisSize: MainAxisSize.max,
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Expanded(
//   //                 child: Text(
//   //               "${language.rideCanceledByDriver}",
//   //               maxLines: 2,
//   //               style: boldTextStyle(),
//   //             )),
//   //             InkWell(
//   //               onTap: () {
//   //                 Navigator.pop(context);
//   //               },
//   //               child: Icon(Icons.clear),
//   //             ),
//   //           ],
//   //         ),
//   //         content: Column(
//   //           mainAxisSize: MainAxisSize.min,
//   //           mainAxisAlignment: MainAxisAlignment.start,
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             Text(
//   //               "${language.cancelledReason}",
//   //               style: secondaryTextStyle(),
//   //             ),
//   //             Text(
//   //               widget.cancelReason.validate(),
//   //               style: primaryTextStyle(),
//   //             ),
//   //           ],
//   //         ),
//   //       );
//   //     },
//   //   );
//   // }
// }
