const { fetchRainfall } = require('../weather');
const { fetchRiverDischarge } = require('../river');
const { computeFloodStatus } = require('../floodLogic');

(async () => {
  const lat = 12.9716;
  const lon = 77.5946;

  const weather = await fetchRainfall(lat, lon);
  const river = await fetchRiverDischarge(lat, lon);

  const flood = computeFloodStatus({
    ...weather,
    ...river,
    previousState: null,
    districtId: 'bangalore',
  });

  console.log({
    weather,
    river,
    flood,
  });
})();
