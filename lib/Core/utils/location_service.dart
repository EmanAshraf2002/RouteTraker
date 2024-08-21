import 'package:location/location.dart';

class LocationServices{

  Location location=Location();


  Future<void> checkAndRequestLocationService() async{
    var isServiceEnabled=await location.serviceEnabled();
    if(!isServiceEnabled){
      isServiceEnabled=await location.requestService();
        if(!isServiceEnabled){
          throw LocationServiceException();
      }
    }
  }


  Future<void> checkAndRequestPermission() async{
    var permissionStatus=await location.hasPermission();
    if(permissionStatus == PermissionStatus.deniedForever){
      throw LocationPermissionException();
    }
    if(permissionStatus == PermissionStatus.denied){
      permissionStatus=await location.requestPermission();
      if(permissionStatus !=PermissionStatus.granted){
        throw LocationPermissionException();
      }
    }
  }

  void getRealTimeLocationData(void Function(LocationData)? onData) async{
    await checkAndRequestLocationService();
    await checkAndRequestPermission();
    location.onLocationChanged.listen(onData);
  }

  Future<LocationData> getLocation() async{
    await checkAndRequestLocationService();
    await checkAndRequestPermission();
    return await location.getLocation();
  }
}

class LocationServiceException implements Exception{}
class LocationPermissionException implements Exception{}