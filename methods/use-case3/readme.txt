Ablauf / Skripte:

1) GEE > "\\bfh.ch\data\LFE\Users\eaa2\Digital-Forest-Monitoring\methods\use-case3\ndvi_anomaly_gee_script_new.txt"

2) Postprocessing R > "\\bfh.ch\data\LFE\Users\eaa2\Digital-Forest-Monitoring\methods\use-case3\ndvi_anomaly_gee_postprocessing.R"

3) Manuelles Postprocessing > Expand Model in Arcmap > "\\bfh.ch\data\LFE\HAFL\WWI-Sentinel-2\Use-Cases\Use-Case3\Toolbox.tbx"
Die Outputs müssen als Letztes noch erneut auf die Waldmaske zugeschnitten werden (R oder Arcmap).

4) Reklassierung für die Bereitstellung als WMS Dienst > "\\bfh.ch\data\LFE\Users\eaa2\Digital-Forest-Monitoring\methods\use-case3\reclassify_for_wms.R"


new style file (july 2021) > "\\bfh.ch\data\LFE\Users\eaa2\Digital-Forest-Monitoring\methods\use-case3\ndvi_anomaly_incl_filter_new.qml"
