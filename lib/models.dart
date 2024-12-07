
class localarmModel {
  final List location;
  final String reminder;
  final bool isAlarm;
  final double range;
  final String uid;
  final bool isPolygon;
  localarmModel({
    required this.isAlarm,
    required this.location,
    required this.range,
    required this.reminder,
    required this.uid,
    required this.isPolygon,
  }) ;

  Map<String,dynamic> toJyson()=>{
    "Location":location,
    "Reminder":reminder,
    "IsAlarm":isAlarm,
    "Range":range,
    "Id":uid,
    "IsPolygon":isPolygon,
  };
}

class PolygonLocalarm {
  final List location;
  final String reminder;
  final bool isAlarm;
  final double range;
  final String uid;

  PolygonLocalarm({
    required this.isAlarm,
    required this.location,
    required this.range,
    required this.reminder,
    required this.uid,
  });
   Map<String,dynamic> toJyson()=>{
    "Location":location,
    "Reminder":reminder,
    "IsAlarm":isAlarm,
    "Range":range,
    "Id":uid,
  };
}