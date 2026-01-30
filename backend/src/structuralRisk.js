const FLOOD_ZONES = require('./floodProneZones');

function applyStructuralRisk({ severity, districtId }) {
  // Don't apply multiplier for searched locations
  if (districtId === 'SEARCHED_LOCATION' || districtId === 'SEARCHED LOCATION') {
    return severity;
  }
  
  const zone = FLOOD_ZONES.find(z => z.districtId === districtId);
  if (!zone) return severity;

  const multiplier = zone.riskMultiplier ?? 1.2;
  return Math.min(severity * multiplier, 2.5);
}

module.exports = { applyStructuralRisk };