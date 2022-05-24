import 'package:cloud_firestore/cloud_firestore.dart'; 

class CommonUtils {
  static DateTime convertFBTimeStamp2DateTime(Timestamp tiemstamp) {
    if (tiemstamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(tiemstamp.seconds * 1000);
    }
    return null;
  }
}
