const path = require('path');
require('dotenv').config({
  path: path.resolve(__dirname, '../.env'),
});

const express = require('express');
const cron = require('node-cron');

const { fetchRainfall } = require('./weather');
const { fetchRiverDischarge } = require('./river');
const { computeFloodStatus } = require('./floodLogic');
const {
  writeFloodStatus,
  writeFloodGeometry,
  writeRiskState,
} = require('./firestore');
const {
  createFloodPolygon,
  computeBoundingBox,
} = require('./geometry');

const app = express();
const PORT = 3000;

// Fixed center for Phase 6
const CENTER_LAT = 13.0827;
const CENTER_LON = 80.2707;
const DISTRICT_ID = 'chennai';

app.get('/', (req, res) => {
  res.send('HydraSense backend running');
});

async function runFloodUpdate() {
  try {
    const weather = await fetchRainfall(CENTER_LAT, CENTER_LON);
    const river = await fetchRiverDischarge(CENTER_LAT, CENTER_LON);

    const floodStatus = computeFloodStatus({
      ...weather,
      ...river,
    });

    const polygon = createFloodPolygon(
      CENTER_LAT,
      CENTER_LON,
      floodStatus.currentRadius
    );

    const bbox = computeBoundingBox(
      CENTER_LAT,
      CENTER_LON,
      floodStatus.currentRadius
    );

    console.log('Flood status:', floodStatus);

    // Phase 5 (debug / analytics)
    await writeFloodStatus(floodStatus);

    // Phase 6 geometry (Firestore-safe)
    await writeFloodGeometry({
      polygon,
      bbox,
      risk: floodStatus.currentRisk,
      confidence: floodStatus.confidence,
    });

    // 🔴 Frontend bridge (existing Flutter code)
    await writeRiskState(DISTRICT_ID, {
      centerLat: CENTER_LAT,
      centerLng: CENTER_LON,
      currentRadius: floodStatus.currentRadius, // km → meters inside
      currentRisk: floodStatus.currentRisk,
    });
  } catch (err) {
    console.error('Flood update failed:', err.message);
  }
}

// Run once at startup
runFloodUpdate();

// Every 30 minutes
cron.schedule('*/30 * * * *', runFloodUpdate);

app.listen(PORT, () => {
  console.log(`Backend listening on port ${PORT}`);
});
