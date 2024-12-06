

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:localarm00/models.dart';
import 'package:location/location.dart';

showsnackbar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(content)));
}

void showcircularProgressIndicator(BuildContext context)async{
  return await showDialog(context: context,
   builder: (context){
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Center(child: CircularProgressIndicator(),),
        );
      });
}

Future<List> getPosition()async{
  List position = List.empty(growable: true);
  Location location = new Location();

bool _serviceEnabled;
PermissionStatus _permissionGranted;
LocationData _locationData;

_serviceEnabled = await location.serviceEnabled();
if (!_serviceEnabled) {
  _serviceEnabled = await location.requestService();
  if (!_serviceEnabled) {
    return [];
  }
}

_permissionGranted = await location.hasPermission();
if (_permissionGranted == PermissionStatus.denied) {
  _permissionGranted = await location.requestPermission();
  if (_permissionGranted != PermissionStatus.granted) {
    return [];
  }
}

_locationData = await location.getLocation();
position.add(_locationData.latitude);
position.add(_locationData.longitude);
  return position;
}

Future<ImageProvider>getDp()async{
  ImageProvider dp ;
  try {
    await Hive.openBox("UserData");
    if (Hive.box("UserData").containsKey("Dp")) {
      dp = FileImage(File(Hive.box("UserData").get("Dp")));
    }else{
      dp =const  AssetImage("lib/assets/user_default.png");
    }
  } catch (e) {
    dp =const AssetImage("lib/assets/user_default.png");
  }
  return dp;
}

Future<String> setLocalarm(
  String message,
  LatLng positionset,
  bool isAlarm_,

)async{
  String state = "";
  try {
   await Hive.openBox("localarms");
   Box localarmBox = Hive.box("localarms");
   List position0 = [positionset.latitude,positionset.longitude]; 
   localarmModel newLoc = localarmModel(isAlarm: isAlarm_, location: position0, range: 500, reminder: message);
   if (localarmBox.containsKey("active")) {
     List active = localarmBox.get("active");
     active.add(newLoc.toJyson());
     localarmBox.put("active", active);
   }else{
    localarmBox.put("active", [newLoc.toJyson()]);
   }
   state = "Success";
  } catch (e) {
    state = e.toString();
  }



  return state;
}