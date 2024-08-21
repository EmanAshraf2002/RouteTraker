import 'package:flutter/material.dart';
import 'package:route_tracking/Core/utils/google_maps_places_service.dart';
import 'package:route_tracking/Featuers/models/place_details_model/place_details_model..dart';

import '../models/place_autocomplete_model/place_autocomplete_model.dart';

class CustomListView extends StatelessWidget {
  const CustomListView({
    super.key,
    required this.places, required this.googleMapPlacesService,
    required this.onPlaceSelected,
  });

  final List<PlaceModel> places;
  final Function(PlaceDetailsModel) onPlaceSelected;
  final PlacesService googleMapPlacesService;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListView.separated(
          itemBuilder: (context,index){
            return ListTile(
              title: Text(places[index].description!),
              trailing: IconButton(onPressed:() async{
               var placeDetails=
               await googleMapPlacesService.getPlaceDetails(placeId:places[index].placeId.toString());
               onPlaceSelected(placeDetails);
              },
                icon:const Icon(Icons.arrow_circle_right_outlined),),

            );
          },
          separatorBuilder: (context,index){
            return const Divider(
              height: 0,
            );
          },
          itemCount:places.length
      ),
    );
  }
}