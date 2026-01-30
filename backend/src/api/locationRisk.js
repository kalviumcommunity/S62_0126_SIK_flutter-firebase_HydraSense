const admin = require('firebase-admin');
const { haversineKm } = require('../utils/distance');
const { fetchRainfall } = require('../weather');
const { fetchRiverDischarge } = require('../river');
const { computeFloodStatus } = require('../floodLogic');
const { computePrediction } = require('../predictionLogic');

const db = admin.firestore();

function riskRank(risk) {
  if (risk === 'HIGH') return 3;
  if (risk === 'MODERATE') return 2;
  return 1;
}

async function calculateMetricsForCoordinate(lat, lng) {
  try {
    console.log('📍 CALCULATING real-time metrics for:', { lat, lng });
    
    // 1. Fetch real-time weather data for THIS coordinate
    const weather = await fetchRainfall(lat, lng);
    const river = await fetchRiverDischarge(lat, lng);
    
    // 2. Compute flood status for THIS coordinate
    const floodStatus = computeFloodStatus({
      ...weather,
      ...river,
      previousState: null, // No previous state for arbitrary coordinate
      districtId: 'SEARCHED_LOCATION',
    });
    
    // 3. Compute prediction if applicable
    const prediction = computePrediction({
      currentRadius: floodStatus.currentRadius,
      currentRisk: floodStatus.currentRisk,
      confidence: floodStatus.confidence,
      forecastRain6h: weather.forecastRain6h,
      forecastRain12h: weather.forecastRain12h,
      forecastRain24h: weather.forecastRain24h,
      forecastMaxIntensity1h: weather.maxRainIntensity1h,
    });
    
    console.log('✅ Calculated metrics:', {
      risk: floodStatus.currentRisk,
      radiusKm: floodStatus.currentRadius,
      confidence: floodStatus.confidence,
      hasPrediction: !!prediction,
    });
    
    return {
      isCalculated: true,
      metrics: {
        rainfallLast24h: weather.rainfallLast24h,
        maxRainIntensity1h: weather.maxRainIntensity1h,
        currentRainProb: weather.currentRainProb,
        forecastRainProb: weather.forecastRainProb,
        forecastRain6h: weather.forecastRain6h,
        forecastRain12h: weather.forecastRain12h,
        forecastRain24h: weather.forecastRain24h,
        riverDischarge: river.riverDischarge,
      },
      floodStatus: floodStatus,
      prediction: prediction,
    };
  } catch (error) {
    console.error('❌ Failed to calculate metrics for coordinate:', error.message);
    return { isCalculated: false, error: error.message };
  }
}

module.exports = async function checkLocationRisk(req, res) {
  try {
    const { lat, lng, radiusKm = 25 } = req.body;

    if (lat == null || lng == null) {
      return res.status(400).json({ error: 'lat/lng required' });
    }

    console.log('\n📍📍📍 CHECK-LOCATION-RISK REQUEST:', { lat, lng, radiusKm });

    // FIRST: Always calculate real-time metrics for this exact coordinate
    const calculatedMetrics = await calculateMetricsForCoordinate(lat, lng);
    
    if (calculatedMetrics.isCalculated) {
      // Return calculated metrics for this exact location
      const riskData = calculatedMetrics.floodStatus;
      const prediction = calculatedMetrics.prediction;
      
      const response = {
        isInDanger: riskData.currentRisk === 'HIGH',
        status: riskData.currentRisk,
        nearestDistrict: 'SEARCHED LOCATION', // Use fixed name
        currentRisk: riskData.currentRisk,
        predictedRisk: prediction?.predictedRisk ?? null,
        predictionWindow: prediction?.predictionWindow ?? null,
        confidence: riskData.confidence ?? 0,
        currentRadius: riskData.currentRadius * 1000, // Convert km to meters
        metrics: calculatedMetrics.metrics,
      };
      
      console.log('✅✅✅ SENDING CALCULATED RESPONSE:', {
        district: response.nearestDistrict,
        risk: response.currentRisk,
        radiusMeters: response.currentRadius,
      });
      
      return res.json(response);
    }
    
    // FALLBACK: If calculation fails, use nearest Firestore district (existing logic)
    console.log('⚠️ Using fallback to nearest district (calculation failed)');
    
    const snap = await db.collection('risk_states').get();
    let best = null;
    let nearest = null;
    let nearestDist = Infinity;
    const now = Date.now();

    snap.forEach(doc => {
      const d = doc.data();
      const dist = haversineKm(lat, lng, d.centerLat, d.centerLng);

      if (dist < nearestDist) {
        nearestDist = dist;
        nearest = d;
      }

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

      if (!best || riskRank(effectiveRisk) > riskRank(best.effectiveRisk)) {
        best = {
          districtId: d.districtId,
          effectiveRisk,
          currentRisk: d.currentRisk,
          predictedRisk: d.predictedRisk,
          predictionWindow: d.predictionWindow,
          confidence: d.confidence,
          currentRadius: d.currentRadius,
          metrics: d.metrics ?? null,
        };
      }
    });

    if (!best && nearest) {
      console.log('📌 Using nearest district:', nearest.districtId);
      return res.json({
        isInDanger: false,
        status: 'SAFE',
        nearestDistrict: nearest.districtId,
        currentRisk: nearest.currentRisk,
        predictedRisk: nearest.predictedRisk ?? null,
        predictionWindow: nearest.predictionWindow ?? null,
        confidence: nearest.confidence ?? 0,
        currentRadius: nearest.currentRadius,
        metrics: nearest.metrics ?? null,
      });
    }

    if (!best) {
      console.log('📌 No districts found');
      return res.json({
        isInDanger: false,
        status: 'SAFE',
        message: 'No flood risk detected nearby',
      });
    }

    console.log('📌 Using best matching district:', best.districtId);
    return res.json({
      isInDanger: best.effectiveRisk === 'HIGH',
      status: best.effectiveRisk,
      nearestDistrict: best.districtId,
      currentRisk: best.currentRisk,
      predictedRisk: best.predictedRisk,
      predictionWindow: best.predictionWindow,
      confidence: best.confidence ?? 0,
      currentRadius: best.currentRadius,
      metrics: best.metrics,
    });
    
  } catch (e) {
    console.error('❌❌❌ CHECK LOCATION ERROR:', e);
    res.status(500).json({ error: 'Risk check failed' });
  }
};