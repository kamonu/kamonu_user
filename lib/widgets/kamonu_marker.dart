import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kamonu_user/models/report_one_of_us.dart';

class KamonuMarker extends Marker {
  ReportOneOfUs oneOfUsReport;
  KamonuMarker(MarkerId markerId, this.oneOfUsReport): super(
     markerId: markerId,
  );
}