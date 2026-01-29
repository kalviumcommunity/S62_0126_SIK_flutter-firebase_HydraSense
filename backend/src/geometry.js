function degToRad(deg) {
  return deg * (Math.PI / 180);
}

/**
 * Creates a Firestore-safe flood polygon.
 * Output format:
 * [
 *   { lat: number, lng: number },
 *   ...
 * ]
 */
function createFloodPolygon(lat, lon, radiusKm, points = 64) {
  const earthRadiusKm = 6371;

  const latRad = degToRad(lat);
  const lonRad = degToRad(lon);
  const angularDistance = radiusKm / earthRadiusKm;

  const polygon = [];

  for (let i = 0; i < points; i++) {
    const bearing = (2 * Math.PI * i) / points;

    const newLat = Math.asin(
      Math.sin(latRad) * Math.cos(angularDistance) +
        Math.cos(latRad) *
          Math.sin(angularDistance) *
          Math.cos(bearing)
    );

    const newLon =
      lonRad +
      Math.atan2(
        Math.sin(bearing) *
          Math.sin(angularDistance) *
          Math.cos(latRad),
        Math.cos(angularDistance) -
          Math.sin(latRad) * Math.sin(newLat)
      );

    polygon.push({
      lat: newLat * (180 / Math.PI),
      lng: newLon * (180 / Math.PI),
    });
  }

  return polygon;
}

function computeBoundingBox(lat, lon, radiusKm) {
  const deltaLat = radiusKm / 111;
  const deltaLon = radiusKm / (111 * Math.cos(degToRad(lat)));

  return {
    north: lat + deltaLat,
    south: lat - deltaLat,
    east: lon + deltaLon,
    west: lon - deltaLon,
  };
}

module.exports = {
  createFloodPolygon,
  computeBoundingBox,
};
