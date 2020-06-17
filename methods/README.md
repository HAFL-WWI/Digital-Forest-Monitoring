# Digital-Forest-Monitoring

### Forest monitoring remote sensing methods.
Contact: Dominique Weber and Alexandra Erbach (BFH-HAFL)

## Data sources

* Sentinel-2 satellite imagery provided by the [ESA](https://sentinel.esa.int/web/sentinel/missions/sentinel-2)
* Forest mask based [swisstopo TLM](https://www.swisstopo.admin.ch/de/wissen-fakten/topografisches-landschaftsmodell.html)

## Methods

### Use-Case 1

Annual forest change maps based on NDVI greenest pixel composites. Implementation in [R](https://www.r-project.org/) using the [BFH instastructure](https://web.bfh.science/) (data and server) and also within the [Google Earth Engine](https://earthengine.google.com).

### Use-Case 2

Near real-time damage indication maps for natural disturbances based on fully pre-processed NBR difference maps for a specific time range. Implementation in [R](https://www.r-project.org/) using the [BFH instastructure](https://web.bfh.science/) (data and server).

### Use-Case 3

Assessment of forest vitality with bi-monthly NDVI anomalies. Implementation within the [Google Earth Engine](https://earthengine.google.com).
