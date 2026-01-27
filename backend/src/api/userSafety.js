const express = require('express');
const router = express.Router();

const { fetchRainfall } = require('../weather');
const { fetchRiverDischarge } = require('../river');
const { computeFloodStatus } = require('../floodLogic');
const DISTRICTS = require('../districts');

// Utility: find nearest district center
function findNearestDistrict(lat, lon) {
  let minDist = Infinity;
  let nearest = null;

  for (const d of DISTRICTS) {
    const dx = lat - d.lat;
    const dy = lon - d.lon;
    const dist = dx * dx + dy * dy;

    if (dist < minDist) {
      minDist = dist;
      nearest = d;
    }
  }

  return nearest;
}

router.post('/check-user-safety', async (req, res) => {
    console.log('📍 Safety check request:', req.body);
  try {
    const { lat, lng } = req.body;

    if (typeof lat !== 'number' || typeof lng !== 'number') {
      return res.status(400).json({ error: 'Invalid coordinates' });
    }

    // Anchor to nearest district (sampling point)
    const district = findNearestDistrict(lat, lng);

    const weather = await fetchRainfall(lat, lng);
    const river = await fetchRiverDischarge(lat, lng);

    const flood = computeFloodStatus({
      ...weather,
      ...river,
    });

    let status = 'SAFE';
    if (flood.currentRisk === 'MODERATE') status = 'MODERATE';
    if (flood.currentRisk === 'HIGH') status = 'DANGER';

    let message = 'You are safe at your current location.';
    if (status === 'MODERATE') {
      message = 'Moderate flood risk detected nearby. Stay alert.';
    }
    if (status === 'DANGER') {
      message = 'High flood risk detected at your location. Move to higher ground.';
    }

    return res.json({
      status,
      message,
      confidence: flood.confidence,
      radius: flood.currentRadius * 1000, // meters
      nearestDistrict: district?.name ?? null,
    });
  } catch (err) {
    console.error('User safety check failed:', err.message);
    res.status(500).json({
      status: 'UNKNOWN',
      message: 'Unable to determine safety at this time.',
      confidence: 0,
    });
  }
});

module.exports = router;
