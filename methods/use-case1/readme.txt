==============================================================================================================================
Prozessschritte Berechnung NDVI Max Differenzen:
==============================================================================================================================

1.) Für die jeweiligen Jahre ndvi_max_gee_script in der Google Earth Engine ausführen

2.) Files vom Google Drive herunterladen und auf Server abspeichern

3.) Postprocessing (mosaic & clip to forest mask) mit R > ndvi_max_gee_postprocess.R (Zugriff auf Funktion mosaic.R)

4.) Differenz Raster berechnen > calc_diff.R

5.) Differenz-Raster umprojizieren nach EPSG 3857 > reproject_diffs.R (Zugriff auf Funktion project.R)

6.) Vektorisierung > polygonize_change_surfaces.R

7.) Manuelle reprojection, da writeOGR das nicht korrekt schreibt leider > im GIS KBS (crs = 3857) für jeden Vektorlayer korrekt definieren und dann exportieren (geht am einfachsten mit QGIS)
=======

Im Archiv befinden sich die ehemaligen, nur auf R basierten Skripte (ohne GEE).