const axios = require('axios');
const { httpsAgent } = require('./httpAgent');

const OPEN_METEO_URL = 'https://api.open-meteo.com/v1/forecast';

async function fetchRainfall(lat, lon) {
  const res = await axios.get(OPEN_METEO_URL, {
    httpsAgent, // 🔴 FIX
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

  let forecastRain6h = 0;
  let forecastRain12h = 0;
  let forecastRain24h = 0;

  for (let i = 24; i < 30 && i < rain.length; i++) forecastRain6h += rain[i] || 0;
  for (let i = 24; i < 36 && i < rain.length; i++) forecastRain12h += rain[i] || 0;
  for (let i = 24; i < 48 && i < rain.length; i++) forecastRain24h += rain[i] || 0;


  return {
    rainfallLast24h,
    maxRainProb,
    forecastRain6h,
    forecastRain12h,
    forecastRain24h
  };
}

module.exports = { fetchRainfall };
