import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/risk_state.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create user document
  Future<void> createUser(String uid, String email) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Stream user document
  Stream<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  /// Stream single risk state safely
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

  /// Stream all risk states
  Stream<List<RiskState>> streamAllRiskStates() {
    return _db.collection('risk_states').snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map((doc) => RiskState.fromFirestore(doc))
            .toList();
      },
    );
  }
}
