const axios = require('axios');

const FLOOD_API_URL = 'https://flood-api.open-meteo.com/v1/flood';

async function fetchRiverDischarge(lat, lon) {
  const res = await axios.get(FLOOD_API_URL, {
    params: {
      latitude: lat,
      longitude: lon,
      daily: 'river_discharge',
      forecast_days: 1,
    },
  });

  const riverDischarge =
    res.data.daily?.river_discharge?.[0] ?? 0;

  return {
    riverDischarge, // m³/s
  };
}

module.exports = { fetchRiverDischarge };
