const CONFIDENCE_THRESHOLD = 0.55;
const SPREAD_COEFFICIENT = 0.015; // km per mm
const DRAIN_DECAY_RATE = 0.25;    // infrastructure loss
const MAX_WINDOW_HOURS = 24;

function computePrediction({
  currentRadius,
  currentRisk,
  confidence,
  forecastRain6h,
  forecastRain12h,
  forecastRain24h,
}) {
  if (confidence < CONFIDENCE_THRESHOLD) {
    return null;
  }

  let forecastRain = 0;
  let window = null;

  if (forecastRain24h > 60) {
    forecastRain = forecastRain24h;
    window = 24;
  } else if (forecastRain12h > 40) {
    forecastRain = forecastRain12h;
    window = 12;
  } else if (forecastRain6h > 25) {
    forecastRain = forecastRain6h;
    window = 6;
  }

  if (!window) return null;

  const decayFactor = Math.max(0.3, 1 - DRAIN_DECAY_RATE);

  const spreadKm =
    forecastRain * SPREAD_COEFFICIENT * decayFactor;

  const predictedRadius =
    Math.max(currentRadius, currentRadius + spreadKm);

  let predictedRisk = currentRisk;
  if (currentRisk === 'LOW') predictedRisk = 'MODERATE';
  else if (currentRisk === 'MODERATE') predictedRisk = 'HIGH';

  return {
    predictedRadius,
    predictedRisk,
    predictionWindow: window,
    predictionExpiresAt: Date.now() + window * 60 * 60 * 1000,
  };
}

module.exports = { computePrediction };
