const { computePrediction } = require('../predictionLogic');

const prediction = computePrediction({
  currentRadius: 4,
  currentRisk: 'MODERATE',
  confidence: 0.8,

  forecastRain6h: 30,
  forecastRain12h: 60,
  forecastRain24h: 90,

  forecastMaxIntensity1h: 22,
});

console.log(prediction);
