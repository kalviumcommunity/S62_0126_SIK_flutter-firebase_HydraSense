const axios = require('axios');
const { httpsAgent } = require('./httpAgent');

const OPEN_METEO_URL = 'https://api.open-meteo.com/v1/forecast';

async function fetchRainfall(lat, lon) {
  const res = await axios.get(OPEN_METEO_URL, {
    httpsAgent,
    params: {
      latitude: lat,
      longitude: lon,
      hourly: 'rain,precipitation_probability',
      past_hours: 24,
      forecast_hours: 24,
      timezone: 'auto',
    },
  });

  const rain = res.data.hourly?.rain ?? [];
  const prob = res.data.hourly?.precipitation_probability ?? [];

  // --- Accumulation + intensity ---
  let rainfallLast24h = 0;
  let maxRainIntensity1h = 0;

  for (let i = 0; i < 24 && i < rain.length; i++) {
    const r = rain[i] || 0;
    rainfallLast24h += r;
    if (r > maxRainIntensity1h) maxRainIntensity1h = r;
  }

  // --- CURRENT probability (last ~3 hours) ---
  let currentRainProb = 0;
  for (let i = 0; i < 3 && i < prob.length; i++) {
    if (prob[i] > currentRainProb) currentRainProb = prob[i];
  }

  // --- FORECAST probability (next 24h) ---
  let forecastRainProb = 0;
  for (let i = 24; i < 48 && i < prob.length; i++) {
    if (prob[i] > forecastRainProb) forecastRainProb = prob[i];
  }

  // --- Forecast rainfall ---
  let forecastRain6h = 0;
  let forecastRain12h = 0;
  let forecastRain24h = 0;

  for (let i = 24; i < 30 && i < rain.length; i++) forecastRain6h += rain[i] || 0;
  for (let i = 24; i < 36 && i < rain.length; i++) forecastRain12h += rain[i] || 0;
  for (let i = 24; i < 48 && i < rain.length; i++) forecastRain24h += rain[i] || 0;

  return {
    rainfallLast24h,
    maxRainIntensity1h,

    currentRainProb,
    forecastRainProb,

    forecastRain6h,
    forecastRain12h,
    forecastRain24h,
  };
}

module.exports = { fetchRainfall };
