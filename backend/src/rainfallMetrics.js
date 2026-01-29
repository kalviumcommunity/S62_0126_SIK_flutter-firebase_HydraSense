function computeRainfallMetrics(rain = []) {
  let rainfallLast24h = 0;
  let maxRainIntensity1h = 0;

  for (let i = 0; i < rain.length && i < 24; i++) {
    const r = rain[i] || 0;
    rainfallLast24h += r;
    if (r > maxRainIntensity1h) maxRainIntensity1h = r;
  }

  return {
    rainfallLast24h,
    maxRainIntensity1h,
  };
}

module.exports = { computeRainfallMetrics };
