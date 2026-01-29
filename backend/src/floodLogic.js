const { computeFloodSeverity } = require('./floodSeverity');
const { applyDrainageMemory } = require('./drainageMemory');
const { applyStructuralRisk } = require('./structuralRisk');

const BASE_RADIUS_KM = 3;

function classifyRisk(severity) {
  if (severity < 0.7) return 'LOW';
  if (severity < 1.3) return 'MODERATE';
  return 'HIGH';
}

function computeFloodStatus({
  maxRainIntensity1h,
  rainfallLast24h,
  riverDischarge,
  previousState,
  districtId,
}) {
  const { severity } = computeFloodSeverity({
    maxRainIntensity1h,
    rainfallLast24h,
    riverDischarge,
  });

  let finalSeverity = applyDrainageMemory({
    previousState,
    currentSeverity: severity,
  });

  finalSeverity = applyStructuralRisk({
    severity: finalSeverity,
    districtId,
  });

  return {
    severity: finalSeverity,
    currentRisk: classifyRisk(finalSeverity),
    currentRadius:
      BASE_RADIUS_KM * Math.max(0.8, Math.min(finalSeverity, 2.2)),
    confidence: Math.min(1, finalSeverity / 1.5),
  };
}

module.exports = { computeFloodStatus };
