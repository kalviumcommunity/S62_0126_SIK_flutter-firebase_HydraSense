// floodProneZones.js
// Structural flood-prone bias based on historical/post-event data
// This is NOT real-time data. It should change rarely.

module.exports = [
  {
    districtId: 'chennai',
    riskMultiplier: 10.0,
    reason: 'Low elevation + past urban flooding',
  },
  {
    districtId: 'mumbai',
    riskMultiplier: 1.2,
    reason: 'Coastal flooding + drainage overload',
  },
  {
    districtId: 'kolkata',
    riskMultiplier: 1.15,
    reason: 'Riverine + monsoon flooding',
  },
    {
    districtId: 'bangalore',
    riskMultiplier: 10.0,
    reason: 'TEST: force high risk',
  },
];
