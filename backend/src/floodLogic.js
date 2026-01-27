function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

const BASE_RADIUS_KM = 3;              // historical flood radius
const RAIN_24H_THRESHOLD = 60;         // mm
const RIVER_DANGER_DISCHARGE = 800;    // m³/s
const PROBABILITY_THRESHOLD = 70;      // %

function computeFloodStatus({
  rainfallLast24h = 0,
  maxRainProb = 0,
  riverDischarge = 0,
}) {
  // ---- Normalize inputs ----
  const rainFactor = clamp(
    rainfallLast24h / RAIN_24H_THRESHOLD,
    0,
    2
  );

  const riverFactor = clamp(
    riverDischarge / RIVER_DANGER_DISCHARGE,
    0,
    2
  );

  // Weak predictive boost
  const probabilityFactor =
    maxRainProb >= PROBABILITY_THRESHOLD ? 0.2 : 0;

  // ---- Weighted fusion (stronger than max()) ----
  const combinedFactor =
    0.6 * riverFactor +
    0.3 * rainFactor +
    probabilityFactor;

  const dominantFactor = clamp(combinedFactor, 1, 2);

  const currentRadius = BASE_RADIUS_KM * dominantFactor;

  // ---- Risk (severity, not geometry) ----
  let currentRisk = 'LOW';

  if (riverFactor > 1.2) currentRisk = 'MODERATE';
  if (riverFactor > 1.6) currentRisk = 'HIGH';

  if (rainFactor > 1.4 && riverFactor > 1.0)
    currentRisk = 'HIGH';

  // ---- Confidence (for alerts & UI later) ----
  const confidence = clamp(
    (rainFactor + riverFactor) / 2,
    0,
    1
  );

  return {
    // outputs
    currentRadius,
    currentRisk,
    confidence,

    // raw + normalized signals (debug / audit)
    rainfallLast24h,
    maxRainProb,
    riverDischarge,

    signals: {
      rainFactor,
      riverFactor,
      probabilityFactor,
    },
  };
}

function computePrediction(floodStatus, forecastRainfall = 0) {
  const { currentRisk, rainfallLast24h, maxRainProb, riverDischarge } = floodStatus;
  
  // Simple prediction: if heavy rain forecasted and river is high
  const willWorsen = forecastRainfall > 30 || maxRainProb > 80;
  
  if (!willWorsen) {
    return {
      predictedRisk: null,
      predictedRadius: null,
      predictionWindow: null,
    };
  }

  let predictedRisk = currentRisk;
  if (currentRisk === 'LOW' && (forecastRainfall > 50 || maxRainProb > 90)) {
    predictedRisk = 'MODERATE';
  } else if (currentRisk === 'MODERATE' && forecastRainfall > 70) {
    predictedRisk = 'HIGH';
  }

  // Increase radius by 30% if prediction is worse
  const predictedRadius = floodStatus.currentRadius * (predictedRisk === 'HIGH' ? 1.3 : 1.15);

  return {
    predictedRisk,
    predictedRadius,
    predictionWindow: 6, // hours
  };
}

module.exports = { 
  computeFloodStatus, 
  computePrediction
};

