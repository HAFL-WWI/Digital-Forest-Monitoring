import proj4 from "proj4";
/* projection definitions for an easier reference in functions */
proj4.defs(
  "EPSG:21781",
  "+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +k_0=1 +x_0=600000 +y_0=200000 +ellps=bessel +towgs84=674.4,15.1,405.3,0,0,0,0 +units=m +no_defs"
);
proj4.defs(
  "EPSG:2056",
  "+proj=somerc +lat_0=46.95240555555556 +lon_0=7.439583333333333 +k_0=1 +x_0=2600000 +y_0=1200000 +ellps=bessel +towgs84=674.374,15.056,405.346,0,0,0,0 +units=m +no_defs"
);

export const registerProjections = register => {
  register(proj4);
};

/*
 * Converts point coordinates from one projection to another
 * @param {object} params
 * @param {string} params.sourceProj - the EPSG Code of the current coordinate system
 * @param {string} params.destProj - the EPSG Code of the projection the point should be converted
 * @param {array} params.coordinates - the coordinates to convert
 * @returns {array} converted coordinates
 */
export const convertPointCoordinates = ({
  sourceProj,
  destProj,
  coordinates
} = {}) => {
  // we have to switch the coordinates in case its wgs84
  const normalisedCoords =
    sourceProj === "EPSG:4326"
      ? [parseFloat(coordinates[1]), parseFloat(coordinates[0])]
      : [Math.round(coordinates[0]), Math.round(coordinates[1])];
  return proj4(sourceProj, destProj, normalisedCoords);
};
