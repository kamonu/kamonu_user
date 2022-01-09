import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kamonu_user/models/OneOfUs.dart';

class KamonuMarker extends Marker {
  OneOfUs oneOfUs;
  KamonuMarker(MarkerId markerId, this.oneOfUs,): super(
     markerId: markerId,
  );
}