import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/risk_state.dart';

class RiskFirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<RiskState>> streamAllRiskStates() {
    return _db.collection('risk_states').snapshots().map((snapshot) {
      final list = snapshot.docs
          .map(RiskState.fromFirestore)
          .toList();

      list.sort((a, b) => a.districtId.compareTo(b.districtId));
      return list;
    });
  }

  Stream<RiskState> streamRiskState(String districtId) {
    return _db
        .collection('risk_states')
        .doc(districtId)
        .snapshots()
        .map((doc) {
          if (!doc.exists) {
            throw Exception('RiskState not found');
          }
          return RiskState.fromFirestore(doc);
        });
  }
}