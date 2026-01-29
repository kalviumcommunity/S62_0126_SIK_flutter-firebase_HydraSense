const CONFIDENCE_THRESHOLD = 0.55;

const SPREAD_ACCUM = 0.015;
const SPREAD_INTENSITY = 0.04;

const DRAIN_DECAY_RATE = 0.25;

function computePrediction({
  currentRadius,
  currentRisk,
  confidence,

  forecastRain6h = 0,
  forecastRain12h = 0,
  forecastRain24h = 0,

  forecastMaxIntensity1h = 0,
}) {
  if (confidence < CONFIDENCE_THRESHOLD) return null;

  let forecastRain = 0;
  let window = null;

  if (forecastRain24h >= 60) {
    forecastRain = forecastRain24h;
    window = 24;
  } else if (forecastRain12h >= 40) {
    forecastRain = forecastRain12h;
    window = 12;
  } else if (forecastRain6h >= 25) {
    forecastRain = forecastRain6h;
    window = 6;
  }

  if (!window) return null;

  const decay = Math.max(0.3, 1 - DRAIN_DECAY_RATE);

  const spread =
    forecastRain * SPREAD_ACCUM * decay +
    forecastMaxIntensity1h * SPREAD_INTENSITY * decay;

  let predictedRisk = currentRisk;
  if (currentRisk === 'LOW') predictedRisk = 'MODERATE';
  else if (currentRisk === 'MODERATE') predictedRisk = 'HIGH';

  return {
    predictedRadius: currentRadius + spread,
    predictedRisk,
    predictionWindow: window,
    predictionExpiresAt: Date.now() + window * 3600 * 1000,
  };
}

module.exports = { computePrediction };
