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

module.exports = { computeFloodStatus };
