import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localarm00/utils.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: FutureBuilder(
                future: getDp(),
                initialData:const AssetImage("lib/assets/user_default.png"),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return CircleAvatar(
                    backgroundImage: snapshot.data,
                  );
                },
              ),
              title:const Text("Profile"),
            ),
           const Padding(
              padding:  EdgeInsets.all(8.0),
              child:  Text("Active Localarms",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
            ),
            FutureBuilder(
              future: Hive.openBox("localarms"),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(),);
                }
                Box localarms = Hive.box("localarms");
                List active = List.empty(growable: true);
                if (localarms.containsKey("active")) {
                  active.addAll(localarms.get("active"));
                  // print(active);
                }
                if (active.isEmpty) {
                  return const Center(child: Text("No active localarms at the moment"),);
                }
                return ListView.builder(
                  itemCount: active.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    Map localarm = active[index];
                    bool isAlarm = localarm["IsAlarm"];
                    String message0 = localarm["Reminder"];
                    String alarmId0 = localarm["Id"];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(isAlarm?"Alarm:":"Notification",style:const TextStyle(fontSize: 17),),
                                IconButton(onPressed: (){}, icon:const Icon(Icons.location_pin))
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Text(message0,),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(onPressed: (){}, 
                                child:const Row(children: [
                                  Text("Edit"),
                                  Icon(Icons.arrow_right_alt)
                                ],)),
                                Switch(
                                  value: true, 
                                  onChanged: (val)async{
                                   String state = await deactivate(alarmId0);
                                   if (state == "Success") {
                                     setState(() {
                                       
                                     });
                                   }
                                  }
                                  )
                            ],)
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const Padding(
              padding:EdgeInsets.all(8.0),
              child: Text("Inactive localarms",style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
            ),
            FutureBuilder(
              future: Hive.openBox("localarms"),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                Box locBox = Hive.box("localarms");
                List inactiveLocs = List.empty(growable: true);
                if (locBox.containsKey("inactive")) {
                  inactiveLocs.addAll(locBox.get("inactive"));
                }
                if (inactiveLocs.isEmpty) {
                  return const Center(child: Text("No inactive localarms at the moment"),);
                }
                return ListView.builder(
                  itemCount: inactiveLocs.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    Map localarm = inactiveLocs[index];
                    bool isAlarm = localarm["IsAlarm"];
                    String message0 = localarm["Reminder"];
                    String alarmId0 = localarm["Id"];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(isAlarm?"Alarm:":"Notification",style:const TextStyle(fontSize: 17),),
                                IconButton(onPressed: (){}, icon:const Icon(Icons.location_pin))
                              ],
                            ),
                            const SizedBox(height: 10,),
                            Text(message0,),
                            const SizedBox(height: 10,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton(onPressed: (){}, 
                                child:const Row(children: [
                                  Text("Edit"),
                                  Icon(Icons.arrow_right_alt)
                                ],)),
                                Switch(
                                  value: false, 
                                  onChanged: (val)async{
                                   String state = await activate(alarmId0);
                                   if (state == "Success") {
                                     setState(() {
                                     });
                                   }
                                  }
                                  )
                            ],)
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}