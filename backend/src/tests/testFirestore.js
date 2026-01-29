const { writeRiskState } = require('../firestore');

(async () => {
  await writeRiskState('test-district', {
    centerLat: 12.97,
    centerLng: 77.59,
    currentRadius: 4,
    currentRisk: 'MODERATE',
    confidence: 0.75,
    prediction: null,
    metrics: {
      rainfallLast24h: 80,
      maxRainIntensity1h: 25,
      currentRainProb: 65,
      forecastRainProb: 80,
      forecastRain6h: 20,
      forecastRain12h: 40,
      forecastRain24h: 70,
      riverDischarge: 600,
    },
  });

  console.log('Firestore write OK');
})();
