const admin = require('firebase-admin');

let serviceAccount;

if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  // ✅ Render / production
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
} else {
  // ✅ Local development only
  serviceAccount = require('../serviceAccountKey.json');
}

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
}

const db = admin.firestore();

async function writeFloodStatus(data, districtId) {
  await db.collection('flood_status').doc(districtId).set({
    ...data,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function writeFloodGeometry(geometry, districtId) {
  await db.collection('flood_geometry').doc(districtId).set({
    ...geometry,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function writeRiskState(districtId, data) {
  await db.collection('risk_states').doc(districtId).set({
    districtId,

    centerLat: data.centerLat,
    centerLng: data.centerLng,

    currentRadius: data.currentRadius * 1000, // km → meters
    predictedRadius: null,

    currentRisk: data.currentRisk,
    predictedRisk: null,
    predictionWindow: null,

    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

module.exports = {
  writeFloodStatus,
  writeFloodGeometry,
  writeRiskState,
};
