Processing Steps for Calculating NDVI Max Differences (updated Oct 2022)
=======================================================================
The following steps are to be reproduced every year, as soon as the first of September passed.
The steps are executed on two to three plattforms:
- A: Google Earth Engine (account required)
- B: Local computer or server with GIS (for inspection and reprojection) and R (if no R-Server is used).
- C: (**optional**) R-Server (for faster/remote computation of R-scripts) 

In our example, for B/C we will be servers connected to the BFH-network drive `P:\LFE\HAFL\WWI-Sentinel-2\Use-Cases\Use-Case1`, respectively `//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1` (as seen from bfh.science, where our R-Server is hosted). ***On each step, make sure to adjust paths within involved scripts accordingly!***

Follow these steps:

1. Execute **ndvi_max_gee_script.js** in Google Earth Engine (account required). Change `.filterDate('2022-06-01', '2022-09-01')` to the required time frame. If a ndvi_max-composite is already present for the previous year (check on network under the path provided above in our case), you'll only need to calculate the current year, otherwise you'll need to execute this twice. You may manually need to start the task that saves the resulting file to your google drive (this may take quite a while).

2. Download the resulting file(s) from Google Drive and store it/them to your processing folder. In our example, this will be `P:\LFE\HAFL\WWI-Sentinel-2\Use-Cases\Use-Case1\NDVI_max_2022`, respectively `//mnt/smb.hdd.rbd/HAFL/WWI-Sentinel-2/Use-Cases/Use-Case1/NDVI_max_2022` (as seen from bfh.science).

3. Run Postprocessing-Script (mosaic & clip to forest mask) in R: **ndvi_max_gee_postprocess.R** (requires function mosaic.R)

4. Calculate difference raster with **calc_diff.R**. To reduce storage size, results (between -1 and +1) will be multiplied by 10000 and stored as Int16 raster.

5. Reproject Difference-Raster to EPSG 3857 with **reproject_diffs.R** (requires function project.R). Different methods for reprojection were tested and "bilinear" was found to work best.

6. Finalize and vectorize with **polygonize_change_surfaces.R**. This script also generates rasters for the WMS Service (i.e. `values > thrvalue` are set to `NA`)

7. Manually reproject with QGIS or software of your choice, since `writeOGR` doesn't correctly save the CRS in some versions of R. Assign CRS = EPSG:3857 for each Layer and export.

Eventually you will have three outputs:
- Raster for WMS Service (values > threshold are set to NA), reprojected to EPSG:3857
- Raster for WCS Service with original values, reprojected to EPSG:3857
- Shapefile with areas of change, reprojected to EPSG:3857


Archiv
----------
The archive contains old scripts based on R only (without GEE).