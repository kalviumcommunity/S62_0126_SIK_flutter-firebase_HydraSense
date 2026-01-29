const { fetchRainfall } = require('../weather');
const { fetchRiverDischarge } = require('../river');

(async () => {
  const lat = 12.9716;
  const lon = 77.5946;

  const weather = await fetchRainfall(lat, lon);
  const river = await fetchRiverDischarge(lat, lon);

  console.log('WEATHER:', weather);
  console.log('RIVER:', river);
})();
