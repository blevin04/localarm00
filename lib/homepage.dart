import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localarm00/utils.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});
  
  static final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: FutureBuilder(
        future: getPosition(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(),);
          }
          double latitude = snapshot.data.first;
          double longitude = snapshot.data.last;
          return  GoogleMap(
            initialCameraPosition: CameraPosition(
              bearing: 180,
              tilt: 59.440717697143555,
              zoom: 19.151926040649414,
              target: LatLng(latitude,longitude),
              )
            );
        },
      ),
      floatingActionButton: IconButton(onPressed: (){}, icon:const Icon(Icons.add)),
    );
  }
}