// ignore_for_file: must_be_immutable

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DashBoardScreen extends StatefulWidget {
  @override
  DashBoardScreenState createState() => DashBoardScreenState();
  String? cancelReason;
  DashBoardScreen({this.cancelReason});
}

class DashBoardScreenState extends State<DashBoardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // LatLng? sourceLocation;

  // List<TexIModel> list = getBookList();
  List<Marker> markers = [];
  Set<Polyline> _polyLines = Set<Polyline>();
  List<LatLng> polylineCoordinates = [];
  late PolylinePoints polylinePoints;
  // OnRideRequest? servicesListData;

  double cameraZoom = 17.0, cameraTilt = 0;

  double cameraBearing = 30;
  int onTapIndex = 0;

  int selectIndex = 0;
  // String sourceLocationTitle = '';

  late StreamSubscription<ServiceStatus> serviceStatusStream;

  LocationPermission? permissionData;

  // late BitmapDescriptor riderIcon;
  late BitmapDescriptor driverIcon;
  List<NearByDriverListModel>? nearDriverModel;

  @override
  void initState() {
    super.initState();
    locationPermission();
   
  }

  void init() async {
    // getCurrentUserLocation();

    riderIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), SourceIcon);
    driverIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 2.5), MultipleDriver);
    // await getAppSettingsData();

    polylinePoints = PolylinePoints();
  }

  Future<void> getCurrentUserLocation() async {
    if (permissionData != LocationPermission.denied) {
      if (sourceLocation != null) {
        polylineSource =
            LatLng(sourceLocation!.latitude, sourceLocation!.longitude);
        addMarker();
        startLocationTracking();
        await getNearByDriver();
        return;
      }
      final geoPosition = await Geolocator.getCurrentPosition(
              timeLimit: Duration(seconds: 30),
              desiredAccuracy: LocationAccuracy.high)
          .catchError((error) {
        launchScreen(navigatorKey.currentState!.overlay!.context,
            LocationPermissionScreen());
        // Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
      });
      sourceLocation = LatLng(geoPosition.latitude, geoPosition.longitude);
      List<Placemark>? placemarks = await placemarkFromCoordinates(
          geoPosition.latitude, geoPosition.longitude);
      await getNearByDriver();

      //set Country
      sharedPref.setString(COUNTRY,
          placemarks[0].isoCountryCode.validate(value: defaultCountry));

      Placemark place = placemarks[0];
      sourceLocationTitle =
          "${place.name != null ? place.name : place.subThoroughfare}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}, ${place.country}";
      polylineSource = LatLng(geoPosition.latitude, geoPosition.longitude);
      addMarker();
      startLocationTracking();

      setState(() {});
    } else {
      launchScreen(navigatorKey.currentState!.overlay!.context,
          LocationPermissionScreen());
      // Navigator.push(context, MaterialPageRoute(builder: (_) => LocationPermissionScreen()));
    }
  }

  Future<void> locationPermission() async {
    serviceStatusStream =
        Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        launchScreen(navigatorKey.currentState!.overlay!.context,
            LocationPermissionScreen());
      } else if (status == ServiceStatus.enabled) {
        getCurrentUserLocation();
        if (locationScreenKey.currentContext != null) {
          if (Navigator.canPop(navigatorKey.currentState!.overlay!.context)) {
            Navigator.pop(navigatorKey.currentState!.overlay!.context);
          }
        }
      }
    }, onError: (error) {
    
    });
  }

  addMarker() {
    markers.add(
      Marker(
        markerId: MarkerId('Order Detail'),
        position: sourceLocation!,
        draggable: true,
        infoWindow: InfoWindow(title: sourceLocationTitle, snippet: ''),
        icon: riderIcon,
      ),
    );
  }

  Future<void> startLocationTracking() async {
    Map req = {
      "latitude": sourceLocation!.latitude.toString(),
      "longitude": sourceLocation!.longitude.toString(),
    };
    await updateStatus(req).then((value) {}).catchError((error) {
      log(error);
    });
  }

  Future<void> getNearByDriver() async {
    await getNearByDriverList(latLng: sourceLocation).then((value) async {
      print('${value}');
      value.data!.forEach((element) {
        markers.add(
          Marker(
            markerId: MarkerId('Driver${element.id}'),
            position: LatLng(double.parse(element.latitude!.toString()),
                double.parse(element.longitude!.toString())),
            infoWindow: InfoWindow(
                title: '${element.firstName} ${element.lastName}', snippet: ''),
            icon: driverIcon,
          ),
        );
      });
      setState(() {});
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    LiveStream().on(CHANGE_LANGUAGE, (p0) {
      setState(() {});
    });
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarIconBrightness: Brightness.light,
            statusBarColor: Colors.black38,
            statusBarBrightness: Brightness.dark),
        toolbarHeight: 0,
        // leading: BackButton(color: context.iconColor),
        // title: Text(language.signUp, style: boldTextStyle()),
      ),
      resizeToAvoidBottomInset: false,
      key: _scaffoldKey,
      drawer: DrawerComponent(),
      body: Stack(
        children: [
          if (sharedPref.getDouble(LATITUDE) != null &&
              sharedPref.getDouble(LONGITUDE) != null)
            GoogleMap(
              padding: EdgeInsets.only(top: context.statusBarHeight + 4 + 24),
              compassEnabled: true,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              myLocationEnabled: false,
              mapType: MapType.normal,
              // myLocationEnabled: false,
              markers: markers.map((e) => e).toSet(),
              polylines: _polyLines,
              initialCameraPosition: CameraPosition(
                target: sourceLocation ??
                    LatLng(sharedPref.getDouble(LATITUDE)!,
                        sharedPref.getDouble(LONGITUDE)!),
                zoom: cameraZoom,
                tilt: cameraTilt,
                bearing: cameraBearing,
              ),
            ),
          Positioned(
            top: context.statusBarHeight + 4,
            right: 14,
            left: 14,
            child: topWidget(),
          ),
          SlidingUpPanel(
            padding: EdgeInsets.all(16),
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(defaultRadius),
                topRight: Radius.circular(defaultRadius)),
            backdropTapClosesPanel: true,
            minHeight: 140,
            maxHeight: 140,
            panel: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(bottom: 12),
                    height: 5,
                    width: 70,
                    decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(defaultRadius)),
                  ),
                ),
                Text(language.whatWouldYouLikeToGo.capitalizeFirstLetter(),
                    style: primaryTextStyle()),
                SizedBox(height: 12),
                AppTextField(
                  autoFocus: false,
                  readOnly: true,
                  onTap: () async {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(defaultRadius),
                            topRight: Radius.circular(defaultRadius)),
                      ),
                      context: context,
                      builder: (_) {
                        return SearchLocationComponent(
                            title: sourceLocationTitle);
                      },
                    );
                  },
                  textFieldType: TextFieldType.EMAIL,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    focusColor: primaryColor,
                    prefixIcon: Icon(Feather.search),
                    filled: false,
                    isDense: true,
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: dividerColor)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: dividerColor)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: Colors.black)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: dividerColor)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(defaultRadius),
                        borderSide: BorderSide(color: Colors.red)),
                    alignLabelWithHint: true,
                    hintText: language.enterYourDestination,
                  ),
                ),
                SizedBox(height: 12),
              ],
            ),
          ),
          Visibility(
            visible: appStore.isLoading,
            child: loaderWidget(),
          ),
        ],
      ),
    );
  }

  Widget topWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        inkWellWidget(
          onTap: () {
            _scaffoldKey.currentState!.openDrawer();
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2), spreadRadius: 1),
              ],
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: Icon(Icons.drag_handle),
          ),
        ),
        inkWellWidget(
          onTap: () {
            launchScreen(context, NotificationScreen(),
                pageRouteAnimation: PageRouteAnimation.Slide);
          },
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2), spreadRadius: 1),
              ],
              borderRadius: BorderRadius.circular(defaultRadius),
            ),
            child: Icon(Ionicons.notifications_outline),
          ),
        ),
      ],
    );
  }

  void _triggerCanceledPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(
                "${language.rideCanceledByDriver}",
                maxLines: 2,
                style: boldTextStyle(),
              )),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.clear),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${language.cancelledReason}",
                style: secondaryTextStyle(),
              ),
              Text(
                widget.cancelReason.validate(),
                style: primaryTextStyle(),
              ),
            ],
          ),
        );
      },
    );
  }
}
