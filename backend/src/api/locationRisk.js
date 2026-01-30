const admin = require('firebase-admin');
const { haversineKm } = require('../utils/distance');
const { fetchRainfall } = require('../weather');
const { computeFloodStatus } = require('../floodLogic');

const db = admin.firestore();

function riskRank(risk) {
  if (risk === 'HIGH') return 3;
  if (risk === 'MODERATE') return 2;
  return 1;
}

module.exports = async function checkLocationRisk(req, res) {
  try {
    const { lat, lng, radiusKm = 50 } = req.body;

    if (lat == null || lng == null) {
      return res.status(400).json({ error: 'lat/lng required' });
    }

    const snap = await db.collection('risk_states').get();

    let best = null;
    const now = Date.now();

    snap.forEach(doc => {
      const d = doc.data();

      const dist = haversineKm(
        lat,
        lng,
        d.centerLat,
        d.centerLng
      );

      if (dist > radiusKm) return;

      const insideCurrent = dist * 1000 <= d.currentRadius;
      const insidePrediction =
        d.predictedRadius &&
        d.predictionExpiresAt?.toMillis() > now &&
        dist * 1000 <= d.predictedRadius;

      if (!insideCurrent && !insidePrediction) return;

      const effectiveRisk =
        insidePrediction && d.predictedRisk
          ? d.predictedRisk
          : d.currentRisk;

      if (
        !best ||
        riskRank(effectiveRisk) > riskRank(best.effectiveRisk)
      ) {
        best = {
          districtId: d.districtId,
          effectiveRisk,
          currentRisk: d.currentRisk,
          predictedRisk: d.predictedRisk,
          predictionWindow: d.predictionWindow,
          confidence: d.confidence,
          currentRadius: d.currentRadius,
        };
      }
    });

    const weather = await fetchRainfall(lat, lng);

    const flood = computeFloodStatus({
      maxRainIntensity1h: weather.maxRainIntensity1h,
      rainfallLast24h: weather.rainfallLast24h,
      riverDischarge: null,
      previousState: null,
      districtId: 'SEARCH',
    });

    return res.json({
      isInDanger: flood.currentRisk === 'HIGH',
      status: flood.currentRisk,

      nearestDistrict: best?.districtId ?? null,

      currentRisk: flood.currentRisk,
      currentRadius: flood.currentRadius * 1000, // km → meters
      confidence: flood.confidence,

      metrics: {
        rainfallLast24h: weather.rainfallLast24h,
        maxRainIntensity1h: weather.maxRainIntensity1h,

        currentRainProb: weather.currentRainProb,
        forecastRainProb: weather.forecastRainProb,

        forecastRain6h: weather.forecastRain6h,
        forecastRain12h: weather.forecastRain12h,
        forecastRain24h: weather.forecastRain24h,
      },
    });
  } catch (e) {
    console.error(e);
    res.status(500).json({ error: 'Risk check failed' });
  }
};
