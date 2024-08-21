import 'dart:convert';

import 'package:route_tracking/Featuers/models/place_autocomplete_model/place_autocomplete_model.dart';
import 'package:http/http.dart' as http;
import 'package:route_tracking/Featuers/models/place_details_model/place_details_model..dart';
 
class PlacesService{
  final String baseUrl='https://maps.googleapis.com/maps/api/place';
  final String Apikey='AIzaSyByqZ7MDePaHTPUmSv2MiLc7jd21W6vvIQ';

  Future<List<PlaceModel>> getPredictions({required String input,required String sessiontoken}) async{
    var response=
    await http.get(Uri.parse('$baseUrl/autocomplete/json?key=$Apikey&input=$input&sessiontoken=$sessiontoken'));

    if(response.statusCode==200){
      var data=jsonDecode(response.body)['predictions'];
      List<PlaceModel> places=[];
      for(var item in data){
        places.add(PlaceModel.fromJson(item));
      }
      return places;
    }
    else {
      throw Exception();
      }
  }


  Future<PlaceDetailsModel> getPlaceDetails({required String placeId}) async{
    var response=
    await http.get(Uri.parse('$baseUrl/details/json?key=$Apikey&place_id=$placeId'));

    if(response.statusCode==200){
      var data=jsonDecode(response.body)['result'];
        return PlaceDetailsModel.fromJson(data);
      }
    else {
      throw Exception();
     }
  }
}