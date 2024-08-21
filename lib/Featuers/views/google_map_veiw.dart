import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_tracking/Core/utils/google_maps_places_service.dart';
import 'package:route_tracking/Core/utils/routes_service.dart';
import 'package:route_tracking/Featuers/models/location_info/lat_lng.dart';
import 'package:route_tracking/Featuers/models/location_info/location.dart';
import 'package:route_tracking/Featuers/models/location_info/location_info.dart';
import 'package:route_tracking/Featuers/models/routes_model/routes_model.dart';
import 'package:route_tracking/Featuers/widgets/custom_list_view.dart';
import 'package:uuid/uuid.dart';

import '../../Core/utils/location_service.dart';
import '../models/place_autocomplete_model/place_autocomplete_model.dart';
import '../widgets/custom_text_field.dart';

class GoogleMapVeiw extends StatefulWidget{
  @override
  State<GoogleMapVeiw> createState() => _GoogleMapVeiwState();
}

class _GoogleMapVeiwState extends State<GoogleMapVeiw> {
  late PlacesService placesService;
  late TextEditingController textEditingController;
  late CameraPosition initialCameraPosition;
  late LocationServices locationServices;
  late GoogleMapController googleMapController;
  Set<Marker> markers={};
  Set<Polyline> polylines={};
  List<PlaceModel> places=[];
  late Uuid uuid;
  late RoutesService routesService;
  late LatLng currentLocation;
  late LatLng destination;
  String? sessionToken;
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    uuid=const Uuid();
    routesService=RoutesService();
    placesService=PlacesService();
    locationServices =LocationServices();
    initialCameraPosition=const CameraPosition(target: LatLng(0, 0));
    textEditingController=TextEditingController();
    fetchPredictions();
  }

  void fetchPredictions() {
    sessionToken??=uuid.v4();
    textEditingController.addListener(() {
      if(debounce?.isActive??false){
        debounce?.cancel();
      }
      debounce=Timer(const Duration(milliseconds: 200), () async{
        if(textEditingController.text.isNotEmpty) {
          var result = await placesService.getPredictions(
              input: textEditingController.text, sessiontoken:sessionToken! );
          places.clear();
          places.addAll(result);
          setState(() {});
        }
        else{
          places.clear();
          setState(() {});
        }
      });

    });
  }
  @override
  void dispose() {
    textEditingController.dispose();
    debounce?.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    print(uuid.v4());
    return Stack(
      children:[
        GoogleMap(
        markers: markers,
        polylines: polylines,
        onMapCreated: (controller){
          googleMapController=controller;
          updateCurrentLocation();
        },
        zoomControlsEnabled: false,
        initialCameraPosition: initialCameraPosition,

      ),
        Positioned(
          top: 16,right: 16,left: 16,
            child:  Column(
              children: [
                CustomTextField(textEditingController: textEditingController,),
                const SizedBox(height: 16,),
                CustomListView(onPlaceSelected: (placeDetailsModel) async{
                  textEditingController.clear();
                  places.clear();
                  sessionToken=null;
                  setState(() {});
                  destination=LatLng(
                      placeDetailsModel.geometry!.location!.lat!,
                      placeDetailsModel.geometry!.location!.lng!,
                  );
                  var points=await getRouteData();
                  displayRoute(points);
                  },
                  places: places, googleMapPlacesService: placesService,
                ),

              ],
            )
        ),
      ]
    );
  }

  void updateCurrentLocation() async{
    try {
      var locationData= await locationServices.getLocation();
      currentLocation=LatLng(locationData.latitude!,locationData.longitude!);
      Marker currentMarkerLocation= Marker(markerId:const MarkerId('my location') ,
          position: currentLocation);

      var myCurrentCameraPosition=
      CameraPosition(target: currentLocation,
      zoom: 16);
      googleMapController.animateCamera(CameraUpdate.newCameraPosition(myCurrentCameraPosition));
      markers.add(currentMarkerLocation);
      setState(() {});
    } on LocationServiceException catch(e){

    }
    on LocationPermissionException catch (e) {
      // TODO
    }catch (e) {

    }
  }

 Future<List<LatLng>> getRouteData() async{
    LocationInfoModel origin=LocationInfoModel(
        location:LocationModel(
          latLng: LatLngModel(
            latitude:currentLocation.latitude,
            longitude: currentLocation.longitude,
          )
        )
    );
    LocationInfoModel destination1=LocationInfoModel(
        location:LocationModel(
            latLng: LatLngModel(
              latitude:destination.latitude,
              longitude: destination.longitude,
            )
        )
    );
    RoutesModel routes=
    await routesService.fetchRoute(origin: origin, destination: destination1);
    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> points =getDecodedRoute(polylinePoints, routes);
    return points;
  }

 List<LatLng> getDecodedRoute(PolylinePoints polylinePoints, RoutesModel routes) {
   List<PointLatLng> result =
   polylinePoints.decodePolyline(routes.routes!.first.polyline!.encodedPolyline!);

   List<LatLng> points=result.map((e) => LatLng(e.latitude, e.longitude)).toList();
   return points;
 }

  void displayRoute(List<LatLng> points) {

    Polyline route=Polyline(polylineId:const PolylineId('route'),
        points:points,
        color: Colors.blue, width: 5,
    );
    polylines.add(route);

    LatLngBounds bounds=getLatLngBounds(points);
    googleMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds,16));
    setState(() {

    });
  }

  LatLngBounds getLatLngBounds(List<LatLng> points) {
  var southWestLatitude=points.first.latitude;
  var southWestLongitude=points.first.longitude;
  var northEastLatitude=points.first.latitude;
  var northEastLongitude=points.first.longitude;

  for(var point in points){
    southWestLatitude=min(southWestLatitude, point.latitude);
    southWestLongitude=min(southWestLongitude, point.longitude);
    northEastLatitude=max(northEastLatitude, point.latitude);
    northEastLongitude=max(northEastLongitude, point.longitude);
  }
  return LatLngBounds(
      southwest: LatLng(southWestLatitude,southWestLongitude),
      northeast:LatLng( northEastLatitude,northEastLongitude)  );
  }
}



