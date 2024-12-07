import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:localarm00/utils.dart';

class Newlocalarm extends StatelessWidget {
  final LatLng position;
  final bool isPolygon_;
  final List points;
  const Newlocalarm({super.key,this.position =const LatLng(0, 0),this.isPolygon_=false,this.points = const [] });
static TextEditingController controller =  TextEditingController();
  @override
  Widget build(BuildContext context) {
    bool isAlarm =true;
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text("New Localarm")),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Message",style: TextStyle(fontSize: 17),),
            ),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide:const BorderSide(color: Colors.grey)
                  
                ),
                hintText: "eg. Check out the new court"
              ),
              maxLength: null,
              maxLines: null,
              
            ),
            const Text("Alert type",style: TextStyle(fontWeight: FontWeight.normal,fontSize: 17),),
            StatefulBuilder(
              builder: (BuildContext context, typeState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.alarm),
                        Text("Alarm"),
                        IconButton(onPressed: (){
                          typeState((){
                            isAlarm = true;
                          });
                        }, icon: isAlarm?
                        const Icon(Icons.check_box_outlined):
                        const Icon(Icons.check_box_outline_blank))
                      ],
                    ),
                    Row(children: [
                      const Icon(Icons.notifications),
                      Text("Notification"),
                      IconButton(onPressed: (){
                        typeState((){
                          isAlarm = false;
                        });
                      }, icon: !isAlarm?
                        const Icon(Icons.check_box_outlined):
                        const Icon(Icons.check_box_outline_blank))
                    ],)
                  ],
                );
              },
            ),
            const SizedBox(height: 50,),
            Center(
              child: InkWell(
                onTap: ()async{
                  if (controller.text.isNotEmpty) {
                    List pointsSet;
                    
                    if (isPolygon_) {
                      pointsSet = List.generate(points.length, (index){
                        return [points[index].latitude,points[index].longitude];
                      });
                    }else{
                      pointsSet = [position.latitude,position.longitude];
                    }
                    String state = await setLocalarm(controller.text, pointsSet, isAlarm,isPolygon_);
                    if (state == "Success") {
                      Navigator.pop(context);
                    }
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.blue
                  ),
                  child:const Text("Done",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}