// structuralRisk.js
const FLOOD_ZONES = require('./floodProneZones');

/**
 * Applies structural flood-prone bias.
 * This NEVER downgrades risk.
 * It only elevates risk if the area is historically vulnerable.
 */
function applyStructuralRisk(currentRisk, districtId) {
  const zone = FLOOD_ZONES.find(z => z.districtId === districtId);


  if (!zone) return currentRisk;

if (districtId === 'bangalore') {
    return 'HIGH';
  }

  if (currentRisk === 'LOW') return 'MODERATE';
  if (currentRisk === 'MODERATE') return 'HIGH';

  return currentRisk;
}

module.exports = { applyStructuralRisk };
