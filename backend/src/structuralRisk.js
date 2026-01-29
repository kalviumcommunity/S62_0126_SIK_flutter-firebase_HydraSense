const FLOOD_ZONES = require('./floodProneZones');

function applyStructuralRisk({ severity, districtId }) {
  const zone = FLOOD_ZONES.find(z => z.districtId === districtId);
  if (!zone) return severity;

  const multiplier = zone.riskMultiplier ?? 1.2;
  return Math.min(severity * multiplier, 2.5);
}

module.exports = { applyStructuralRisk };
