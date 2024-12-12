import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
MapType mapType = MapType.hybrid;
bool changeView = false;
ValueNotifier<bool> showSearch = ValueNotifier(false);
ValueNotifier<List<LatLng>> polygons = ValueNotifier([]);
ValueNotifier<bool> newPoint = ValueNotifier(false);
class Homepage extends StatefulWidget {
  const Homepage({super.key});
  // static final Completer<GoogleMapController> _controller =
  //     Completer<GoogleMapController>();

  @override
  State<Homepage> createState() => _HomepageState();
}
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    

  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        // leading: InkWell(
        //   onTap: (){
           
        //   },
        //   child: Padding(
        //     padding: const EdgeInsets.all(10.0),
        //     child: FutureBuilder(
        //       future: getDp(),
        //       initialData:const AssetImage("lib/assets/user_default.png"),
        //       builder: (BuildContext context, AsyncSnapshot snapshot) {
        //         return CircleAvatar(
        //           radius: 20,
        //           backgroundImage: snapshot.data
        //         );
        //       },
        //     ),
        //   )
        //   ),
        title:const Text("Localarm"),
        actions: [
          IconButton(onPressed: (){
            showSearch.value = !showSearch.value;
          }, icon: const Icon(Icons.search)),
          IconButton(onPressed: (){
             Navigator.push(context, (MaterialPageRoute(builder: (context)=>const Profile())));
          }, icon:const Icon(Icons.person_pin))
          ,
          // StatefulBuilder(
          //       builder: (context,modestate) {
          //         return IconButton(onPressed: (){
          //             themechange(context);
          //           if (darkmode)
          //               {MyApp.of(context)!.changeTheme(ThemeMode.light);}
          //             else
          //               {MyApp.of(context)!.changeTheme(ThemeMode.dark);}
          //               modestate(() {
          //                 darkmode = !darkmode;
          //               });
          //         }, icon: Icon(darkmode?Icons.dark_mode: Icons.sunny));
          //       }
          //     )
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
              List activePoly = List.empty(growable: true);
              if (Hive.box("localarms").containsKey("active")) {
                activeLocs =  Hive.box("localarms").get("active");
                activePoly = activeLocs.where((value0){return value0["IsPolygon"] != null && value0["IsPolygon"]==true;}).toList();
                
                activeLocs = activeLocs.where((value){return value["IsPolygon"] == null|| value["IsPolygon"]==false;}).toList();
              }
              return  StatefulBuilder(
                builder: (context,mapState) {
                  //print("new");
                  return GoogleMap(
                    
                    polylines: {
                      Polyline(
                        polylineId:const PolylineId("testpoly"),
                        points: polygons.value
                        )
                    },
                    polygons:Set.from(List.generate(activePoly.length, (index){
                      Map poly = activePoly[index];
                      String polyId = poly["Id"];
                      List polyPoints = poly["Location"];
                      List<LatLng> points0 = List.generate(polyPoints.length, (index){
                        return LatLng(polyPoints[index].first, polyPoints[index].last);
                      });
                      return Polygon(
                        polygonId:PolygonId(polyId),
                        points: points0,
                        fillColor: Colors.transparent,
                        strokeWidth: 6,
                         );
                    })),
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
                    mapType:mapType ,
                    initialCameraPosition: CameraPosition(
                      bearing: 180,
                      tilt: 30,
                      zoom: 19.151926040649414,
                      target: LatLng(latitude,longitude),
                      ),
                      onTap: (position0){
                        if (polygons.value.isNotEmpty) {
                          polygons.value.add(position0);
                          mapState((){});
                        }
                      },
                      onLongPress: (position){
                        showDialog(context: context, builder: (context){
                          return AlertDialog(
                            title:const Text("Add Localarm at Location"),
                            actions: [
                              TextButton(onPressed: (){
                                polygons.value.add(position);
                                newPoint.value = true;
                                Navigator.pop(context);
                                mapState((){});
                              }, child:const Text("Build fence")),
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
          ListenableBuilder(
            listenable: showSearch,
            builder: (context,child) {
              return Visibility(
                visible: showSearch.value,
                child: SearchBar(
                  //elevation: WidgetStatePropertyAll(0),
                  //backgroundColor: WidgetStatePropertyAll(Colors.transparent),
                  leading: Icon(Icons.search),
                  hintText: "eg. office",
                ),
              );
            }
          )
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            
            StatefulBuilder(
              builder: (context,typeState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Visibility(
                      visible: changeView,
                      child: Column(
                      children: [
                        CircleAvatar(
                          child: IconButton(onPressed: (){
                            mapType = MapType.satellite;
                            setState(() {
                              
                            });
                          }, icon:const Icon(FontAwesomeIcons.satellite)),
                        ),
                        const SizedBox(height: 10,),
                        CircleAvatar(
                          child: IconButton(onPressed: (){
                            mapType = MapType.terrain;
                            setState(() {
                              
                            });
                          }, icon:const Icon(Icons.terrain)),
                        ),
                        const SizedBox(height: 10,),
                        CircleAvatar(
                          child: IconButton(onPressed: (){
                            mapType = MapType.normal;
                            setState(() {
                              
                            });
                          }, icon:const Icon(FontAwesomeIcons.cube,color: Colors.black,)),
                        ),
                        const SizedBox(height: 10,),
                      ],
                    )),
                    CircleAvatar(child: IconButton(onPressed: (){
                      typeState((){
                        changeView = !changeView;
                      });
                    }, icon:const Icon(Icons.layers)))
                  ],
                );
              }
            ),
             SizedBox(width: MediaQuery.of(context).size.width/3,),
            ListenableBuilder(
              listenable: newPoint, builder: (context,child){
              return Visibility(
                visible: newPoint.value,
                child: InkWell(
                  onTap: ()async{
                    newPoint.value = false;
                    final List<LatLng> pointlist = polygons.value;
                    polygons.value.clear();
                   await Navigator.push(context, (MaterialPageRoute(builder: (context)=>Newlocalarm(points:pointlist,isPolygon_: true,))));
                    
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding:const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 238, 228, 194),
                
                    ),
                    child:const Text("Done"),
                  ),
                ),
              );
            }),
          ],
        )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
    );
  }
}