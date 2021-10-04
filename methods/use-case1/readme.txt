==============================================================================================================================
Prozessschritte Berechnung NDVI Max Differenzen (Stand Oktober 2021):
==============================================================================================================================

1.) Für die jeweiligen Jahre ndvi_max_gee_script in der Google Earth Engine ausführen

2.) Files vom Google Drive herunterladen und auf Server abspeichern

3.) Postprocessing (mosaic & clip to forest mask) mit R > ndvi_max_gee_postprocess.R (Zugriff auf Funktion mosaic.R)

4.) Differenz Raster berechnen > calc_diff.R
    Die Differenzen werden dabei mit 10000 multipliziert und als Int16 Raster gespeichert.

5.) Differenz-Raster umprojizieren nach EPSG 3857 > reproject_diffs.R (Zugriff auf Funktion project.R)
    Es wurden verschiedene Projizierungs-Methoden getestet und "bilinear" als beste Lösung identifiziert.

6.) Vektorisierung > polygonize_change_surfaces.R
    In diesem Skript werden zudem auch die Raster für den WMS Service generiert und exportiert (d.h. values > thrvalue auf NA)

7.) Manuelle reprojection, da writeOGR das nicht korrekt schreibt leider 
    > im GIS KBS (crs = 3857) für jeden Vektorlayer korrekt definieren und dann exportieren (geht am einfachsten mit QGIS)

=======

Am Ende gibt es drei Outputs:
- Raster für WMS Service (alle Werte > Schwellwert auf NA gesetzt), reprojiziert auf EPSG 3857
- Raster für WCS Service mit Originalwerten, reprojiziert auf EPSG 3857
- Shapefile mit Veränderungsflächen, reprojiziert auf EPSG 3857

=======

Im Archiv befinden sich die ehemaligen, nur auf R basierten Skripte (ohne GEE).
