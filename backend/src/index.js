const path = require('path');
require('dotenv').config({
  path: path.resolve(__dirname, '../.env'),
});

const express = require('express');
const cron = require('node-cron');

const { fetchRainfall } = require('./weather');
const { fetchRiverDischarge } = require('./river');
const { computeFloodStatus } = require('./floodLogic');
const { computePrediction } = require('./predictionLogic');
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

    const prediction = computePrediction({
      currentRadius: floodStatus.currentRadius,
      currentRisk: floodStatus.currentRisk,
      confidence: floodStatus.confidence,
      forecastRain6h: weather.forecastRain6h,
      forecastRain12h: weather.forecastRain12h,
      forecastRain24h: weather.forecastRain24h,
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

    console.log(
      `${district.name}: ${floodStatus.currentRisk}` +
      (prediction ? ` → ${prediction.predictedRisk} (${prediction.predictionWindow}h)` : '')
    );

    await writeFloodStatus(floodStatus, district.id);

    await writeFloodGeometry(
      {
        polygon,
        bbox,
        risk: floodStatus.currentRisk,
        confidence: floodStatus.confidence,
      },
      district.id
    );

    await writeRiskState(district.id, {
      centerLat: district.lat,
      centerLng: district.lon,
      currentRadius: floodStatus.currentRadius,
      currentRisk: floodStatus.currentRisk,
      confidence: floodStatus.confidence,
      prediction,
    });

  } catch (err) {
    console.error(`Flood update failed for ${district.name}:`, err.message);
  }
}

async function runAllDistricts() {
  for (const district of DISTRICTS) {
    await runFloodUpdateForDistrict(district);
    await new Promise(resolve => setTimeout(resolve, 1000));
  }
}

runAllDistricts();
cron.schedule('*/30 * * * *', runAllDistricts);

app.listen(PORT, () => {
  console.log(`Backend listening on port ${PORT}`);
});
