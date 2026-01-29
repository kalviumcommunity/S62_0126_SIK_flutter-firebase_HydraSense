function clamp(v, min, max) {
  return Math.max(min, Math.min(max, v));
}

function computeFloodSeverity({
  maxRainIntensity1h = 0,
  rainfallLast24h = 0,
  riverDischarge = 0,
}) {
  const intensityScore = clamp(maxRainIntensity1h / 20, 0, 2);
  const accumulationScore = clamp(rainfallLast24h / 80, 0, 2);
  const riverScore = clamp(riverDischarge / 800, 0, 2);

  const severity =
    0.4 * intensityScore +
    0.3 * accumulationScore +
    0.3 * riverScore;

  return { severity };
}

module.exports = { computeFloodSeverity };
