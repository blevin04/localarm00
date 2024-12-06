import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:localarm00/models.dart';
import 'package:localarm00/utils.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
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
            const Text("Active Localarms"),
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
                return ListView.builder(
                  itemCount: active.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    Map localarm = active[index];
                    bool isAlarm = localarm["IsAlarm"];
                    String message0 = localarm["Reminder"];

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
                                  onChanged: (val){}
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