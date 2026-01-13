import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/risk_state.dart';


class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(String uid, String email) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<DocumentSnapshot> getUser(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Stream<RiskState> getRiskState(String districtId) {
    return _db
        .collection('risk_states')
        .doc(districtId)
        .snapshots()
        .map((doc) => RiskState.fromFirestore(doc));
  }
}
