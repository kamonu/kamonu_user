import 'package:kamonu_user/models/status.dart';

import 'one_of_us.dart';

class OneOfUsReport {
  OneOfUs oneOfUs;
  int timestamp;
  List<Status> status =[];

  OneOfUsReport(this.oneOfUs,this.timestamp);
}