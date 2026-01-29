const { computeFloodSeverity } = require('../floodSeverity');

const result = computeFloodSeverity({
  maxRainIntensity1h: 28,
  rainfallLast24h: 90,
  riverDischarge: 500,
});

console.log(result);
