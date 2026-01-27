const admin = require('firebase-admin');

if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: process.env.FIREBASE_PROJECT_ID,
  });
}

const db = admin.firestore();

async function writeFloodStatus(data, districtId) {  // Added districtId
  await db.collection('flood_status').doc(districtId).set({
    ...data,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function writeFloodGeometry(geometry, districtId) {  // Added districtId
  await db.collection('flood_geometry').doc(districtId).set({
    ...geometry,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function writeRiskState(districtId, data) {
  await db.collection('risk_states').doc(districtId).set({
    districtId: districtId,  // Make sure this is set

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