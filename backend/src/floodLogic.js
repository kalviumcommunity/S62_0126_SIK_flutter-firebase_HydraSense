function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

const BASE_RADIUS_KM = 3;
const RAIN_24H_THRESHOLD = 60;
const RIVER_DANGER_DISCHARGE = 800;
const PROBABILITY_THRESHOLD = 70;

function computeFloodStatus({
  rainfallLast24h = 0,
  maxRainProb = 0,
  riverDischarge = 0,
}) {
  const rainFactor = clamp(rainfallLast24h / RAIN_24H_THRESHOLD, 0, 2);
  const riverFactor = clamp(riverDischarge / RIVER_DANGER_DISCHARGE, 0, 2);
  const probabilityFactor = maxRainProb >= PROBABILITY_THRESHOLD ? 0.2 : 0;

  const combinedFactor =
    0.6 * riverFactor +
    0.3 * rainFactor +
    probabilityFactor;

  const dominantFactor = clamp(combinedFactor, 1, 2);
  const currentRadius = BASE_RADIUS_KM * dominantFactor;

  let currentRisk = 'LOW';
  if (riverFactor > 1.2) currentRisk = 'MODERATE';
  if (riverFactor > 1.6) currentRisk = 'HIGH';
  if (rainFactor > 1.4 && riverFactor > 1.0) currentRisk = 'HIGH';

  const confidence = clamp((rainFactor + riverFactor) / 2, 0, 1);


  return {
    currentRadius,
    currentRisk,
    confidence,
    rainfallLast24h,
    maxRainProb,
    riverDischarge,
  };
}

module.exports = { computeFloodStatus };
