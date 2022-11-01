Processing Steps for Calculating NDVI Anomalies (Vitality Indicators)
=======================================================================
***(updated Oct 2022)***

1. run `1_ndvi_anomaly_gee_script.js` on Google Earth Engine (GEE). Create dirs for your respective dates (e.g. NDVI_Anomaly_2022_08-09) and save the result in the subfolder *gee_output* (should be two files, named something like z_score_08-09_2022-0000000000-0000000000.tif)

2. run postprocessing in R with `2_ndvi_anomaly_gee_postprocessing.R`

3. Do manual postprocessing, using the ArcMap Toolbox (Expand cloud mask to cater for cloud shadows/fuzzy edges). For batch processing, save the output of the previous script (found in each subfolder) to a shared folder (e.g. 2_temp_for_expand). Set the output folder to a new folder (e.g. 3_expand_output).

4. run reclassification (mask certain values, set NA value, compression) for WMS in R with `3_reclassify_for_WMS.R`

As of July 2021, there is a new style file (july 2021): `Style\ndvi_anomaly_incl_filter_new.qml`
