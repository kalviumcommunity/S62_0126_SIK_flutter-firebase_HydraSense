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

  Stream<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Stream<RiskState?> streamRiskState(String districtId) {
    return _db
        .collection('risk_states')
        .doc(districtId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      return RiskState.fromFirestore(doc);
    });
  }

  Stream<List<RiskState>> streamAllRiskStates() {
    return _db.collection('risk_states').snapshots().map(
          (snapshot) =>
              snapshot.docs.map(RiskState.fromFirestore).toList(),
        );
  }
}
