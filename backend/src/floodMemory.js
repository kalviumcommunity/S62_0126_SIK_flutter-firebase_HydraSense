const FLOOD_PERSISTENCE_HOURS = 72;
const DECAY_HALF_LIFE_HOURS = 24;

function hoursBetween(a, b) {
  return (a - b) / (1000 * 60 * 60);
}

function decayRisk(risk, hoursElapsed) {
  if (hoursElapsed < DECAY_HALF_LIFE_HOURS) return risk;

  if (risk === 'HIGH') return 'MODERATE';
  if (risk === 'MODERATE') return 'LOW';

  return risk;
}

function applyFloodMemory({
  previousState,
  currentRisk,
  now = Date.now(),
}) {
  if (!previousState) return currentRisk;

  const lastFloodedAt = previousState.lastFloodedAt;
  const prevRisk = previousState.currentRisk;

  if (lastFloodedAt) {
    const floodedHours = hoursBetween(
      now,
      lastFloodedAt.toMillis()
    );

    // 🔴 HARD SAFETY FLOOR
    if (floodedHours < FLOOD_PERSISTENCE_HOURS) {
      if (currentRisk === 'LOW') return 'MODERATE';
      return currentRisk;
    }
  }

  if (!previousState.updatedAt) return currentRisk;

  const elapsed = hoursBetween(
    now,
    previousState.updatedAt.toMillis()
  );

  const decayed = decayRisk(prevRisk, elapsed);

  const priority = ['LOW', 'MODERATE', 'HIGH'];

  return priority.indexOf(decayed) >
    priority.indexOf(currentRisk)
    ? decayed
    : currentRisk;
}

module.exports = { applyFloodMemory };
