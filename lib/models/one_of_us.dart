import 'package:flutter/cupertino.dart';

class Condition{
  String name;
  IconData icon;
  String description="";
  bool inCondition = true;
  Condition(this.name,this.icon);
}

/*ToDo: need to move to the new List of possible gender to make shure that
organisations can help according to the gender
*/
enum Gender {
  notSpecified,
  female,
  male,
  diverse,
}

class OneOfUs {
  String title = "Eine(r) von uns der Hilfe braucht";
  String notes = "";
  String languages = "de";
  bool helped = false;
  Gender gender = Gender.notSpecified;
  List<Condition> conditions = <Condition>[];
  //ToDo: add Organisations wich helped
  addCondition(Condition _condition){
    conditions.add(_condition);
  }

}