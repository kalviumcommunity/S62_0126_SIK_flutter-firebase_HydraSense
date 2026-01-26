const axios = require('axios');

const OPEN_METEO_URL = 'https://api.open-meteo.com/v1/forecast';

async function fetchRainfall(lat, lon) {
  const res = await axios.get(OPEN_METEO_URL, {
    params: {
      latitude: lat,
      longitude: lon,
      hourly: 'rain,precipitation_probability',
      past_hours: 24,
      forecast_hours: 24,
    },
  });

  const rain = res.data.hourly?.rain || [];
  const prob = res.data.hourly?.precipitation_probability || [];

  let rainfallLast24h = 0;
  for (let i = 0; i < 24 && i < rain.length; i++) {
    rainfallLast24h += rain[i] || 0;
  }

  let maxRainProb = 0;
  for (let i = 0; i < prob.length; i++) {
    if (prob[i] > maxRainProb) maxRainProb = prob[i];
  }

  return {
    rainfallLast24h, // mm
    maxRainProb,     // %
  };
}

module.exports = { fetchRainfall };
