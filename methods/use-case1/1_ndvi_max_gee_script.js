//////////////////////////////////////////////////////////////
// Calculate NDVI max composite for Switzerland using GEE.
//
// GEE -> Google Earth Engine -> https://code.earthengine.google.com/38acfd5a95ddca198e7f2b134e1e4664
//
// by Dominique Weber, Hannes Horneber, BFH-HAFL
/////////////////////////////////////////////////////////////

Map.setCenter(8.83, 47.62, 7)
var swiss = ee.Geometry.Rectangle(5.4, 45.5, 11, 48.1);
var aoi = swiss;

// Sentine-2 imagery --> S2 (for L1C), S2_SR (for L2A)
// data after 25.01.2022 is incompatible due to the processing baseline update 04.00
// use S2_HARMONIZED (L1C) or S2_SR_HARMONIZED (L2A), which remove the baseline offset
var S2 = ee.ImageCollection('COPERNICUS/S2_HARMONIZED')
  .filterDate('2023-06-01', '2023-09-01')
  .filterBounds(aoi);

// add layers
var addNDVI = function(image) {
  return image.addBands(image.normalizedDifference(['B8', 'B4']).rename('NDVI'));
};

// add ndvi
var S2 = S2.map(addNDVI);

// build ndvi max composite
var greenest = S2.qualityMosaic('NDVI');

// display
Map.addLayer(greenest.select('NDVI'), {min: 0, max: 1, palette: ['red', 'blue', 'green']}, 'NDVI max');
//Map.addLayer(greenest, {bands: ['B4', 'B3', 'B2'], max: 1500}, 'Greenest pixel composite');

// Export
var ndvi_max = greenest.select('NDVI');
Export.image.toDrive({
  image: ndvi_max,
  description: 'ndvi_max',
  scale: 10,
  maxPixels: 2000000000,
  region: aoi,
  crs: 'EPSG:2056'
});
