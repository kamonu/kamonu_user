import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kamonu_user/models/OneOfUs.dart';
import 'package:kamonu_user/models/ReportOneOfUs.dart';

class KamonuMarker extends Marker {
  ReportOneOfUs oneOfUsReport;
  KamonuMarker(MarkerId markerId, this.oneOfUsReport): super(
     markerId: markerId,
  );
}