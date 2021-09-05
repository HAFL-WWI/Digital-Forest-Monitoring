
LiDAR Detektion von forstlichen Verjüngungsflächen (Prototyp UC4)
=================================================================

Diese Anwendung nutzt LiDAR Daten, um in Waldgebieten das Vorkommen verschiedener Vegetationsschichten zu detektieren. Der Prototyp ist hier als eigenständiges Docker-Image veröffentlicht.

**Input**: Area of Interest Perimeter (als .kml oder .shp file)

**Output**: ein Geotiff Raster (.tif) pro folgender Vegetationsschichten:

| Vegetationsschicht/"Höhenklasse"			| Höhe  			|
|----------------       |---------------    |
| Vegetationshöhe 1		| 0-1 m
| Vegetationshöhe 2		| 1-2 m
| Vegetationshöhe 3		| 2-5 m
| Vegetationshöhe 4		| 5-12 m
| Vegetationshöhe 5		| 12-24 m
| Vegetationshöhe 6		| 24+ m

Zudem werden Vegetationshöhenmodell und Terrainmodell generiert.


Methode
-----------------------------------
Der Prototyp lädt automatisch die benötigten LiDAR Daten von [swisssurface3D](https://www.swisstopo.admin.ch/de/geodata/height/surface3d.html#341_1554992541029) als Basis für die Berechnungen und extrahiert den für die Fläche relevanten Teil der Punktwolke.
Die Punktwolke wird normalisiert auf Basis der in der Punktwolke enthaltenen Bodenpunkte.
Anschließend wird ein Raster mit der absolute Punktdichte der Fläche berechnet, dass als Basis dient um dann pro Vegetationsschichte die relative Punktdichte und die mit Schwellwert ermittelte "Abdeckung" der Vegetationsschicht zu berechnen.


Benutzung
-----------------------------------
Um die Anwendung einzusetzen muss [Docker Desktop](https://docs.docker.com/desktop/) installiert sein. Eine ausführliche Installationsanleitung findet sich [hier für Windows](https://docs.docker.com/docker-for-windows/install/) und [hier für Mac](https://docs.docker.com/docker-for-mac/install/).

Nachdem Docker Desktop installiert ist, kann docker über ein beliebiges Terminal aufgerufen werden, z.B. das die standardmäßig installierte Windows Kommandozeile (command prompt, im Startmenü nach "cmd" suchen), Windows Powershell oder integrierte Konsolen von Programmierumgebungen (RStudio, pyCharm, eclipse, ...).
Mit dem folgenden Befehl wird der Container heruntergeladen und ausgeführt:

    docker run -v C:\Beliebiger\Pfad\zu\einem\Ordner:/uc4_wd hbh1/uc4_prototype

Dazu muss der Pfad ```C:\Beliebiger\Pfad\zu\einem\Ordner``` zu einem existierenden Ordner zeigen, in dem sich ein Ordner "input" befindet. Z.B.:

    C:\Users\my_username\Projects\UC4_LiDAR
    
mit dem Unterordner ```input``` der eine .shp Datei (mit den dazugehörigen .dbf, .shx) oder .kml Datei enthält, die zu berechnenden Regionen enthält:

    C:\Users\my_username\Projects\UC4_LiDAR\input
    C:\Users\my_username\Projects\UC4_LiDAR\input\example.dbf
    C:\Users\my_username\Projects\UC4_LiDAR\input\example.shp
    C:\Users\my_username\Projects\UC4_LiDAR\input\example.shx

Oder:

    C:\Users\my_username\Projects\UC4_LiDAR\input\example.kml


Die Anwendung erstellt einen Ordner 

    C:\Users\my_username\Projects\UC4_LiDAR\output

in dem die Ergebnisse der Berechnungen zu finden sind. Dazu wird ein Unterordner mit dem Zeitstempel angelegt (z.B. ```C:\Users\my_username\Projects\UC4_LiDAR\output\2021-07-30_115639\```, in dem folgende Ausgabeprodukte pro Fläche zu finden sind:

#### Abdeckung der Vegetationsschicht
Ein binäres Raster (0 oder 1); die «Abdeckung» der Klasse. Die Vegetationsschicht gilt als "vorhanden", wenn die relative Punktdichte höher als ein Schwellwert ist (siehe Methode). Pro Vegetationsschicht wird ein Raster ausgegeben:
    
    example_1_1cov0-1.tif
	example_1_2cov1-2.tif
	example_1_3cov2-5.tif
	example_1_4cov5-12.tif
	example_1_5cov12-24.tif
	example_1_6cov24-99.tif
	
Die Namensgebung erfolgt dabei wie folgt:
	
	[name-shp-file]_[ID-der-Fläche]_[Index_Vegetationsschicht]cov[untere Grenze]-[obere Grenze Vegetationsschicht].tif
	
#### Relative Punktdichte der Vegetationsschicht
Ein Raster mit Werten von 0 bis 1; die relative Punktdichte (absolute Punktdichte der Klasse dividiert durch die absolute Punktdichte der Zelle). 

	example_1_1dens_rel0-1.tif
	example_1_2dens_rel1-2.tif
	... (folgt derselben Namensgebung wie oben)
	
#### Relative Punktdichte der Vegetationsschicht
Ein Raster mit Werten von 0 bis [Maximale Punktdichte]; die absolute Punktdichte in der Klasse.

	example_1_1dens0-1.tif
	example_1_2dens1-2.tif
	... (folgt derselben Namensgebung wie oben)
	
Da der Wertebereich der Punktdichte je Vegetationsschicht abhängig von der gesamten Punktdichte der betrachteten Zelle ist, kann dieser Wert eigentlich nur in Kombination mit der absoluten Punktdichte der Zelle interpretiert werden (deshalb oben die relative Punktdichte). Die absoluten Punktdichtewerte pro Zelle sind in der Datei: **example_1_densitygrid.tif** zu finden (hier visualisiert: **example_1_densitygrid.pdf**).
 
#### Visualisierung
Die oben genannten Raster sind für jede Vegetationsschicht visualisiert.

	example_1_1plot0-1.pdf
	example_1_2plot1-2.pdf
	... (folgt derselben Namensgebung wie oben)
	
 
#### Nebenprodukte
Folgende Dateien werden als "Nebenprodukte" mit ausgegeben:

	# die Punktwolke der Fläche
    example_1.las
    # ein normalisierte Punktwolke der Fläche
    example_1_n.las
    # ein Vegetationshöhenmodell der Fläche
    example_1_chm_pitfree.tif
    # ein Terrainmodell der Fläche
	example_1_dtm.tif



Bekannte Probleme und Limitierungen
-----------------------------------
Aktuell greift die Anwendungen per STAC auf die offen zur Verfügung gestellten swisssurface3D Daten zurück.

Die folgenden Limitierungen sind bekannt und werden in den nächsten Entwicklungsschritten aufgehoben:
- eigene LiDAR Daten können noch nicht verwendet werden.
- Polygone, die über swisssurface3D Kachelgrenzen hinaus verlaufen, werden nicht unterstützt (Kachelgrenzen siehe [hier](https://s.geo.admin.ch/9222883f46)). Um solche Perimeter abzudecken, müssen zwei Polygone erstellt werden, die jeweils komplett innerhalb einer Kachel liegen.