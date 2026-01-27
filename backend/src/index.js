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
const DISTRICTS = require('./districts');

const app = express();
const PORT = 3000;

app.get('/', (req, res) => {
  res.send('HydraSense backend - Monitoring ' + DISTRICTS.length + ' districts');
});

app.use(express.json());
app.use('/api', require('./api/userSafety'));


async function runFloodUpdateForDistrict(district) {
  try {
    const weather = await fetchRainfall(district.lat, district.lon);
    const river = await fetchRiverDischarge(district.lat, district.lon);

    const floodStatus = computeFloodStatus({
      ...weather,
      ...river,
    });

    const polygon = createFloodPolygon(
      district.lat,
      district.lon,
      floodStatus.currentRadius
    );

    const bbox = computeBoundingBox(
      district.lat,
      district.lon,
      floodStatus.currentRadius
    );

    console.log(`${district.name} flood status:`, floodStatus.currentRisk);

    // Write analytics
    await writeFloodStatus(floodStatus, district.id);
    
    // Write geometry
    await writeFloodGeometry({
      polygon,
      bbox,
      risk: floodStatus.currentRisk,
      confidence: floodStatus.confidence,
    }, district.id);

    // 🔴 Frontend bridge - THIS IS WHAT YOUR APP READS
    await writeRiskState(district.id, {
      centerLat: district.lat,
      centerLng: district.lon,
      currentRadius: floodStatus.currentRadius,
      currentRisk: floodStatus.currentRisk,
    });
    
  } catch (err) {
    console.error(`Flood update failed for ${district.name}:`, err.message);
  }
}

async function runAllDistricts() {
  console.log(`Updating ${DISTRICTS.length} districts...`);
  
  // Process districts sequentially to avoid API rate limits
  for (const district of DISTRICTS) {
    await runFloodUpdateForDistrict(district);
    await new Promise(resolve => setTimeout(resolve, 1000)); // 1 second delay
  }
  
  console.log('All districts updated');
}

// Run once at startup
runAllDistricts();

// Every 30 minutes
cron.schedule('*/30 * * * *', runAllDistricts);

app.listen(PORT, () => {
  console.log(`Backend listening on port ${PORT}`);
});