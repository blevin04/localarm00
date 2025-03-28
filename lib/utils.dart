import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:localarm00/models.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

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
  await Hive.openBox("localarms");
  List position = List.empty(growable: true);
  Location location = new Location();

// bool _serviceEnabled;
PermissionStatus _permissionGranted;
LocationData _locationData;

// _serviceEnabled = await location.serviceEnabled();
// if (!_serviceEnabled) {
//   _serviceEnabled = await location.requestService();
//   if (!_serviceEnabled) {
//     return [];
//   }
// }
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
  List positionset,
  bool isAlarm_,
  bool isPolygon,
)async{
  String state = "";
  // await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //   AndroidFlutterLocalNotificationsPlugin>()!.requestNotificationsPermission();
  //  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //   AndroidFlutterLocalNotificationsPlugin>()!.requestExactAlarmsPermission();
  //  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //   AndroidFlutterLocalNotificationsPlugin>()!.requestFullScreenIntentPermission();
  try {
   await Hive.openBox("localarms");
   Box localarmBox = Hive.box("localarms");
    
   String uid = Uuid().v1();
   localarmModel newLoc = localarmModel(isAlarm: isAlarm_, location: positionset, range: 500, reminder: message,uid: uid,isPolygon: isPolygon);
   if (localarmBox.containsKey("active")) {
     List active = localarmBox.get("active");
     active.add(newLoc.toJyson());
     localarmBox.put("active", active);
   }else{
    localarmBox.put("active", [newLoc.toJyson()]);
   }
   state = "Success";
   print(localarmBox.get("active"));
  } catch (e) {
    state = e.toString();
  }
  return state;
}

Future<String> deactivate([String alarmId = ""])async{
  String res ;
  
  try {
    await Hive.openBox("localarms");
  Box localarms0 = Hive.box("localarms");
  if (alarmId.isEmpty) {
  localarms0.clear();
  }else{
    List loc = localarms0.get("active");
   List focus = loc.where((data){return data["Id"] == alarmId;}).toList();
    if (localarms0.containsKey("inactive")) {
      List inactive0 = localarms0.get("inactive");
      inactive0.addAll(focus);
      localarms0.put("inactive", inactive0);
    }else{
      localarms0.put("inactive", focus);
    }
    loc.remove(focus.single);
  }

  res = "Success";
  } catch (e) {
    res = e.toString();
  }

  return res;
}

Future<String> activate(String locId)async{
  String res;
  try {
    Box locBox0 = Hive.box("localarms");
  List activeB = locBox0.get("active");
  List inactive0 = locBox0.get("inactive");
  List focus = inactive0.where((data){return data["Id"] == locId;}).toList();
  activeB.addAll(focus);
  inactive0.remove(focus.single);
  await locBox0.put("active", activeB);
  await locBox0.put("inactive", inactive0);
  res = "Success";
  } catch (e) {
  res = e.toString();  
  }
  return res;
}

// Future<String>addPolyon(List points)async{
//   await Hive.openBox("localarms");
//   Box polyBox = Hive.box("localarms");
//   if (polyBox.containsKey("polyActive")) {
//     List activeP = polyBox.get("polyActive");
//     PolygonLocalarm newP = PolygonLocalarm(
//       isAlarm: isAlarm, 
//       location: location, 
//       range: range, 
//       reminder: reminder, 
//       uid: uid)
//   }
// }