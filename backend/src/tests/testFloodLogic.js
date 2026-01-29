const { computeFloodStatus } = require('../floodLogic');

const flood = computeFloodStatus({
  maxRainIntensity1h: 28,
  rainfallLast24h: 90,
  riverDischarge: 500,
  previousState: null,
  districtId: 'bangalore',
});

console.log(flood);
