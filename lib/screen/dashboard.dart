// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:aspire/helper/app_common.dart';
import 'package:aspire/screen/dashboard/search_prediction_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class DashBoardScreen extends StatefulWidget {
  @override
  DashBoardScreenState createState() => DashBoardScreenState();
  String? cancelReason;
  DashBoardScreen({this.cancelReason});
}

class DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  LatLng? sourceLocation;
  Set<Marker> markers = {}; // Changed to Set<Marker> to handle markers better
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

  List<PredictionModel> listAddress = [];
  //  TextEditingController sourceLocation = TextEditingController();
  TextEditingController destinationLocation = TextEditingController();

  FocusNode sourceFocus = FocusNode();
  FocusNode desFocus = FocusNode();
  LatLng userLocation = LatLng(25.3703262,
                        68.3534493);
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
     userLocation = LatLng(position.latitude, position.longitude);
     
    // Update markers with the user's location
    setState(() {
      markers.add(
        Marker(
            markerId: MarkerId("My Location"),
            position: userLocation,
            infoWindow: InfoWindow(title: "Current Location "),
            icon: AssetMapBitmap("assets/ic_source_pin.png",
                height: 40, width: 40)
            // icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
      );
    });

    // Add nearby drivers (you can replace this with your actual driver data)
    getNearbyDrivers(userLocation);
  }

  bool isSearchVisible = false; // Track visibility of the search field

  TextEditingController _searchController = TextEditingController();

  Future<BitmapDescriptor> rotateMarker(
      String assetPath, double rotation) async {
    // Load the image from assets
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    // Decode the image and apply rotation
    img.Image originalImage = img.decodeImage(bytes)!;
    img.Image rotatedImage = img.copyRotate(originalImage, angle: rotation);

    img.Image resizedImage =
        img.copyResize(rotatedImage, width: 40, height: 60);
    // Encode to bytes
    final Uint8List rotatedBytes =
        Uint8List.fromList(img.encodePng(resizedImage));

    // Convert to a BitmapDescriptor
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(rotatedBytes, completer.complete);
    ui.Image image = await completer.future;

    final ByteData? byteData =
        await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // Function to add nearby driver markers
  Future<void> getNearbyDrivers(LatLng userLocation) async {
    // Mock data for nearby drivers (replace with actual API call)
    List<LatLng> driverLocations = [
      LatLng(userLocation.latitude + 0001, userLocation.longitude),
      LatLng(userLocation.latitude + 0.001, userLocation.longitude + 0.1),
      LatLng(userLocation.latitude - 0.01, userLocation.longitude - 0.01),
      LatLng(userLocation.latitude + 0.05, userLocation.longitude + 0.03),
      LatLng(userLocation.latitude - 0.03, userLocation.longitude - 0.02),
      LatLng(userLocation.latitude + 0.08, userLocation.longitude + 0.10),
      LatLng(userLocation.latitude + 0.04, userLocation.longitude - 0.04),
    ];

    final BitmapDescriptor rotatedIcon = await rotateMarker(
      "assets/yellow_bus.png",
      90, // Adjust rotation angle as needed
    );
    setState(() {
      for (var driverLocation in driverLocations) {
        markers.add(
          Marker(
            markerId: MarkerId(
                "driver_${driverLocation.latitude}_${driverLocation.longitude}"),
            position: driverLocation,
            infoWindow: InfoWindow(title: "Near by Bus"),
            icon: rotatedIcon,
            // icon: AssetMapBitmap("assets/yellow_bus.png",height: 40,width: 60 )
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Aspire",
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                      ClipRRect(
                        borderRadius: radius(50),
                        child: Image.asset("assets/logo.jpeg",
                            width: 40, height: 40),
                      ),
                    ],
                  ),
                ),
              ),
              if (isSearchVisible)
                SizedBox(
                  height: 15,
                ),
              Container(
                  height: Get.height * 0.8,
                  child: Stack(
                    children: [
                      GoogleMap(
                        padding: EdgeInsets.only(top: 42),
                        compassEnabled: true,
                        mapToolbarEnabled: false,
                        zoomControlsEnabled: false,
                        myLocationEnabled: false,
                        mapType: MapType.normal,
                        markers: markers,
                        polylines: _polyLines,
                        initialCameraPosition: CameraPosition(
                          target: userLocation, // Default to Karachi coordinates
                          zoom: cameraZoom,
                          tilt: cameraTilt,
                          bearing: cameraBearing,
                        ),
                      ),

                      if (isSearchVisible)
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 4.0, left: 8, right: 8),
                          child: TextFormField(
                            controller: destinationLocation,
                            focusNode: desFocus,

                            autofocus: true,
                            decoration: InputDecoration(
                                hintText: "Search Location",
                                filled: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                )),
                            // decoration:
                            //     searchInputDecoration(hint: language.destinationLocation),
                            onTap: () {
                              // isDrop = false;
                              setState(() {});
                            },
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                // isDrop = true;
                                if (val.length < 2) {
                                  listAddress.clear();
                                  setState(() {});
                                } else {
                                  searchAddressRequest(search: val)
                                      .then((value) {
                                    listAddress = value.predictions!;
                                    setState(() {});
                                  }).catchError((error) {
                                    log(error);
                                  });
                                }
                              } else {
                                listAddress.clear();
                                // isDrop = false;
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      // Google Map Display
                      if (listAddress.isNotEmpty) SizedBox(height: 16),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 50,
                        child: ListView.builder(
                          controller: ScrollController(),
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: listAddress.length,
                          itemBuilder: (context, index) {
                            PredictionModel mData = listAddress[index];
                            return ListTile(
                              // tileColor: Colors.white,
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(Icons.location_on_outlined,
                                  color: Colors.blue),
                              minLeadingWidth: 16,
                              title: Text(mData.description ?? "",
                                  style: primaryTextStyle()),
                              onTap: () async {},
                            );
                          },
                        ),
                      ),
                    ],
                  )),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    listAddress.clear();
                    setState(() {
                      isSearchVisible =
                          !isSearchVisible; // Toggle the visibility of search field
                    });
                  },
                  child: const Text("Find Near By Bus"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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

Future<GoogleMapSearchModel> searchAddressRequest({String? search}) async {
  const String GOOGLE_MAP_API_KEY =
      "AIzaSyCa7hc3Il46hg5nLQeGyLns5PBKGdaGYTA"; // Replace with your actual API key
  const String BASE_URL =
      "https://maps.googleapis.com/maps/api/place/autocomplete/json";

  // Initialize Dio
  dio.Dio d = dio.Dio();

  try {
    // Build the URL with query parameters
    String country = "us"; // Replace with your country code logic
    final response = await d.get(
      BASE_URL,
      queryParameters: {
        "input": search,
        "key": GOOGLE_MAP_API_KEY,
        "components": "country:$country",
      },
    );
    print("response ${response}");

    // Check if the request was successful
    if (response.statusCode == 200) {
      // Parse the JSON response
      return GoogleMapSearchModel.fromJson(response.data);
    } else {
      throw Exception("Failed to fetch data: ${response.statusCode}");
    }
  } catch (e) {
    throw Exception("Dio error: ${e}");
  }
}

enum HttpMethod { GET, POST, DELETE, PUT }
