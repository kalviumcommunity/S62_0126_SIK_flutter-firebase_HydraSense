const FLOOD_PERSISTENCE_HOURS = 72;
const DRAIN_HALF_LIFE_HOURS = 24;

function hoursBetween(now, then) {
  return (now - then) / (1000 * 60 * 60);
}

function applyDrainageMemory({
  previousState,
  currentSeverity,
  now = Date.now(),
}) {
  let severity = currentSeverity;

  if (previousState?.lastFloodedAt) {
    const floodedHours = hoursBetween(
      now,
      previousState.lastFloodedAt.toMillis()
    );

    if (floodedHours < FLOOD_PERSISTENCE_HOURS) {
      severity = Math.max(severity, 0.8);
    }
  }

  if (previousState?.severity && previousState?.updatedAt) {
    const elapsed = hoursBetween(
      now,
      previousState.updatedAt.toMillis()
    );

    const decay =
      Math.exp(-Math.log(2) * elapsed / DRAIN_HALF_LIFE_HOURS);

    severity = Math.max(severity, previousState.severity * decay);
  }

  return severity;
}

module.exports = { applyDrainageMemory };
