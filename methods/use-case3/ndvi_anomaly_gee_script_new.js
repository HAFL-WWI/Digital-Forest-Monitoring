//////////////////////////////////////////////////////////////
// Analysis of Sentinel-2 images for drought stress detection > z-score
//
// Script prepared by Alexandra Erbach, BFH-HAFL
/////////////////////////////////////////////////////////////

// IMAGE COLLECTIONS
var s2Sr = ee.ImageCollection('COPERNICUS/S2');
var s2Clouds = ee.ImageCollection('COPERNICUS/S2_CLOUD_PROBABILITY');

//LOCATION

// Switzerland
Map.setCenter(8.83, 47.62, 7)
var swiss = ee.Geometry.Rectangle(5.4, 45.5, 11, 48.1);
var aoi = swiss;

// Boncourt
//Map.setCenter(7.02, 47.49, 14);
//var aoi = ee.Geometry.Rectangle(6.97324, 47.50835, 7.21612, 47.38846);

// Walensee
//Map.setCenter(9.10816, 47.13483, 14)
//var aoi = ee.Geometry.Rectangle(8.93667, 47.20197, 9.35101, 47.06807);


// PARAMS
var reference_year_from = 2015;
var reference_year_to = 2017;
var monitoring_year_from = 2018;
var monitoring_year_to = 2018;
var month_from = 8;
var month_to = 9;
var MAX_CLOUD_PROBABILITY = 10;

/////////////////////////////////////////////////////////////
// GENERAL FUNCTIONS

// function to mask clouds based on cloud probability layer
function maskClouds(img) {
  var clouds = ee.Image(img.get('cloud_mask')).select('probability');
  var isNotCloud = clouds.lt(MAX_CLOUD_PROBABILITY);
  return img.updateMask(isNotCloud);
}

// The masks for the 10m bands sometimes do not exclude bad data at
// scene edges, so we apply masks from the 20m and 60m bands as well.
// Example asset that needs this operation:
// COPERNICUS/S2_CLOUD_PROBABILITY/20190301T000239_20190301T000238_T55GDP
function maskEdges(s2_img) {
  return s2_img.updateMask(
      s2_img.select('B8A').mask().updateMask(s2_img.select('B9').mask()));
}

// Function to calculate and add a VI band
var addNDVI = function(image) {
  return image.addBands(image.normalizedDifference(['B8', 'B4']).rename('NDVI'));
};

// Function to add a date band
var addDate = function(image){
  var doy = ee.Date(image.get('system:time_start')).format('D');
  var num = ee.Number.parse(doy);
  var banddate = image.select('B8').multiply(0).eq(0).multiply(num).uint16().rename('date');
  return image.addBands(banddate);
};

// Function to subtract raster layer from stack and return absolute deviation
var diff = function(ras,bn){
  var wrap = function(image){
    return (image.select(bn).subtract(ras)).abs().rename('diff');
  };
  return wrap;
};

/////////////////////////////////////////////////////////////
// REFERENCE PERIOD
// Filter input collections by desired data range and region.
var criteria_ref = ee.Filter.and(
    ee.Filter.bounds(aoi), ee.Filter.calendarRange(reference_year_from,reference_year_to,'year'), ee.Filter.calendarRange(month_from,month_to,'month'));
var s2Sr_ref = s2Sr.filter(criteria_ref).map(maskEdges);
var s2Clouds_ref = s2Clouds.filter(criteria_ref);

// Join S2 SR with cloud probability dataset to add cloud mask.
var s2SrWithCloudMask_ref = ee.Join.saveFirst('cloud_mask').apply({
  primary: s2Sr_ref,
  secondary: s2Clouds_ref,
  condition:
      ee.Filter.equals({leftField: 'system:index', rightField: 'system:index'})
});

// Mask clouds and add NDVI band
var ref = ee.ImageCollection(s2SrWithCloudMask_ref)
  .map(maskClouds)
  .map(addNDVI);
  //.map(addDate);

// Calculate NDVI median
var ref_ndvi_med = ref.select(['NDVI']).reduce(ee.Reducer.median());

// Calculate NDVI median absolute deviation (MAD)
var ref_abs_diff = ref.map(diff(ref_ndvi_med,'NDVI'));
var ref_ndvi_mad = ref_abs_diff.select('diff').reduce(ee.Reducer.median());

// Count valid pixels (several valid pixels for one and the same date count as one)
var valid_ref = ref.select(['date']).reduce(ee.Reducer.countDistinct());


/////////////////////////////////////////////////////////////
// MONITORING PERIOD

// Filter input collections by desired data range and region.
var criteria_mon = ee.Filter.and(
    ee.Filter.bounds(aoi), ee.Filter.calendarRange(monitoring_year_from,monitoring_year_to,'year'), ee.Filter.calendarRange(month_from,month_to,'month'));
var s2Sr_mon = s2Sr.filter(criteria_mon).map(maskEdges);
var s2Clouds_mon = s2Clouds.filter(criteria_mon);

// Join S2 SR with cloud probability dataset to add cloud mask.
var s2SrWithCloudMask_mon = ee.Join.saveFirst('cloud_mask').apply({
  primary: s2Sr_mon,
  secondary: s2Clouds_mon,
  condition:
      ee.Filter.equals({leftField: 'system:index', rightField: 'system:index'})
});

// Mask clouds and add NDVI band
var mon = ee.ImageCollection(s2SrWithCloudMask_mon)
  .map(maskClouds)
  .map(addNDVI)
  .map(addDate);

// Calculate NDVI median
var mon_ndvi_med = mon.select(['NDVI']).reduce(ee.Reducer.median());

// Count valid pixels (several valid pixels for one and the same date count as one)
var valid_mon = mon.select(['date']).reduce(ee.Reducer.countDistinct()).int16();

/////////////////////////////////////////////////////////////
// Z-SCORE

// calculate modified z-score
var z_score = (mon_ndvi_med.subtract(ref_ndvi_med)).multiply(0.6745).divide(ref_ndvi_mad).multiply(100).round().int16();

// display NDVIs
//var ndvi_params = {min: 0, max: 1, palette: ['blue', 'white', 'green']};
//Map.addLayer(ref_ndvi_med, ndvi_params, 'ndvi reference', false);  
//Map.addLayer(mon_ndvi_med, ndvi_params, 'ndvi monitoring', false);

// display z-score
//var z_params = {min: -500, max: 500, palette: ['red', 'yellow', 'green']};
//Map.addLayer(z_score, z_params, 'z score', true);  


/////////////////////////////////////////////////////////////
// EXPORT
// stack z-score and validity raster
var stacked = z_score.addBands(valid_mon).rename(['zsc','no_valid']);

// Export image
Export.image.toDrive({
  image: stacked,
  description: 'z_score_08-09_2018',
  scale: 10,
  maxPixels: 2000000000,
  region: aoi,
  crs: 'EPSG:2056'
});


