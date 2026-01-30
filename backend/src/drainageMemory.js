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

  // Handle null/undefined previousState
  if (!previousState) {
    return severity;
  }

  // SAFELY check lastFloodedAt
  if (previousState.lastFloodedAt) {
    let lastFloodedMillis;
    
    // Handle both Firestore Timestamp and plain number
    if (previousState.lastFloodedAt.toMillis) {
      lastFloodedMillis = previousState.lastFloodedAt.toMillis();
    } else if (typeof previousState.lastFloodedAt === 'number') {
      lastFloodedMillis = previousState.lastFloodedAt;
    } else if (previousState.lastFloodedAt._seconds) {
      // Firestore timestamp from toDate()
      lastFloodedMillis = previousState.lastFloodedAt._seconds * 1000;
    }
    
    if (lastFloodedMillis) {
      const floodedHours = hoursBetween(now, lastFloodedMillis);
      if (floodedHours < FLOOD_PERSISTENCE_HOURS) {
        severity = Math.max(severity, 0.8);
      }
    }
  }

  // SAFELY check severity and updatedAt
  if (previousState.severity && previousState.updatedAt) {
    let updatedMillis;
    
    if (previousState.updatedAt.toMillis) {
      updatedMillis = previousState.updatedAt.toMillis();
    } else if (typeof previousState.updatedAt === 'number') {
      updatedMillis = previousState.updatedAt;
    } else if (previousState.updatedAt._seconds) {
      updatedMillis = previousState.updatedAt._seconds * 1000;
    }
    
    if (updatedMillis) {
      const elapsed = hoursBetween(now, updatedMillis);
      const decay = Math.exp(-Math.log(2) * elapsed / DRAIN_HALF_LIFE_HOURS);
      severity = Math.max(severity, previousState.severity * decay);
    }
  }

  return severity;
}

module.exports = { applyDrainageMemory };