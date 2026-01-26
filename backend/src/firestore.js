const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID,
  });
}

const db = admin.firestore();

async function writeFloodStatus(data) {
  await db.collection('flood_status').doc('chennai').set({
    ...data,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function writeFloodGeometry(geometry) {
  await db.collection('flood_geometry').doc('chennai').set({
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
