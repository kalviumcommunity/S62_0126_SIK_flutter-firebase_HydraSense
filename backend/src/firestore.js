const admin = require('firebase-admin');

let serviceAccount;

if (process.env.FIREBASE_SERVICE_ACCOUNT) {
  serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT);
} else {
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
  const prediction = data.prediction ?? null;

  await db.collection('risk_states').doc(districtId).set({
    districtId,

    centerLat: data.centerLat,
    centerLng: data.centerLng,

    currentRadius: data.currentRadius * 1000, // km → meters
    currentRisk: data.currentRisk,
    confidence: data.confidence ?? null,

    predictedRadius: prediction?.predictedRadius
      ? prediction.predictedRadius * 1000 // km → meters
      : null,

    predictedRisk: prediction?.predictedRisk ?? null,

    predictionWindow: prediction?.predictionWindow ?? null,

    predictionExpiresAt: prediction?.predictionExpiresAt
      ? admin.firestore.Timestamp.fromMillis(
          prediction.predictionExpiresAt
        )
      : null,

    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

module.exports = {
  writeFloodStatus,
  writeFloodGeometry,
  writeRiskState,
};
