import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localarm00/main.dart';
import 'package:localarm00/newLocalarm.dart';
import 'package:localarm00/profile.dart';
import 'package:localarm00/utils.dart';

bool darkmode = false;
void themechange(BuildContext context) async {
  await Hive.box("theme").clear();
  if (darkmode) {
    await Hive.box("theme").put("theme", 1);
  } else {
    await Hive.box("theme").put("theme", 0);
  }
  // print(Hive.box("theme").get("theme"));
}

class Homepage extends StatelessWidget {
  const Homepage({super.key});
  static final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: (){
            Navigator.push(context, (MaterialPageRoute(builder: (context)=>const Profile())));
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder(
              future: getDp(),
              initialData:const AssetImage("lib/assets/user_default.png"),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                return CircleAvatar(
                  radius: 20,
                  backgroundImage: snapshot.data
                );
              },
            ),
          )
          ),
        title:const Text("Localarm"),
        actions: [
          StatefulBuilder(
                builder: (context,modestate) {
                  return IconButton(onPressed: (){
                      themechange(context);
                    if (darkmode)
                        {MyApp.of(context)!.changeTheme(ThemeMode.light);}
                      else
                        {MyApp.of(context)!.changeTheme(ThemeMode.dark);}
                        modestate(() {
                          darkmode = !darkmode;
                        });
                  }, icon: Icon(darkmode?Icons.dark_mode: Icons.sunny));
                }
              )
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder(
            future: getPosition(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(),);
              }
              double latitude = snapshot.data.first;
              double longitude = snapshot.data.last;
              List activeLocs = List.empty(growable: true);
              if (Hive.box("localarms").containsKey("active")) {
                activeLocs =  Hive.box("localarms").get("active");
              }
              return  ListenableBuilder(
                listenable: Hive.box("localarms").listenable(),
                builder: (context,child) {
                  return GoogleMap(
                    circles: Set.from(List.generate(activeLocs.length, (index){
                      Map loc = activeLocs[index];
                      bool isalarm = loc["IsAlarm"];
                      return Circle(
                        consumeTapEvents: true,
                        circleId: CircleId(loc["Id"]),
                        center: LatLng(loc["Location"].first, loc["Location"].last),
                        radius: 10,
                        fillColor: const Color.fromARGB(10, 158, 158, 158),
                        onTap: (){
                          showDialog(context: context, builder: (builder){
                            return AlertDialog(
                              title: Text(isalarm?"Alarm":"Notification"),
                              content: Text(loc["Reminder"]),
                              
                            );
                          });
                        }
                        );
                    })),
                    myLocationEnabled: true,
                    initialCameraPosition: CameraPosition(
                      bearing: 180,
                      tilt: 30,
                      zoom: 19.151926040649414,
                      target: LatLng(latitude,longitude),
                      ),
                      onLongPress: (position){
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title:const Text("Add Localarm at Location"),
                            actions: [
                              TextButton(onPressed: (){
                                Navigator.pop(context);
                                Navigator.push(context, (MaterialPageRoute(builder: (context)=>Newlocalarm(position: position,))));
                              }, 
                              child:const Text("Continue")),
                              TextButton(onPressed: (){
                                Navigator.pop(context);
                              }, child:const Text("Cancel"))
                            ],
                          );
                        });
                      },
                    );
                }
              );
            },
          ),
          Padding(
            padding:EdgeInsets.only(left: 50.0,right: 50,top: 8),
            child: SearchBar(
              //elevation: WidgetStatePropertyAll(0),
              //backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              
            ),
          )
        ],
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 50.0),
      //   child: IconButton(
      //     onPressed: (){
      //       Navigator.push(context, (MaterialPageRoute(builder: (builder))))
      //     }, 
      //     icon:const Icon(Icons.add_circle_sharp,size: 40,color: Colors.blue,)
      //     ),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}