Processing Steps for Calculating NDVI Max Differences
=======================================================================
***(updated Jan 2024)***
The procedure described below is to be executed every year, as soon as the first of September passed.

### Requierment
* Up to date versions of 
  - [_**R**_](https://cran.r-project.org/index.html) (>= 4.3.0)
  - [_**RStudio Desktop**_](https://posit.co/downloads/) (>= 2023.6.0.421)
  - [_**RTools4.3**_](https://cran.r-project.org/bin/windows/Rtools/rtools43/rtools.html) (if _**R**_ >= 4.4.X the according _**RTools**_ version)
  
&emsp; &emsp; &nbsp; installed on a local computer (so far the only used operation system was Windows 10)

* _**Google Earth Engine**_ account
* _**Google Drive**_ account
* _**R**_-package [`rgee`](https://r-spatial.github.io/rgee/) (>= 1.1.7) and its its non-_R_-dependencies
* Other _**R**_-packages, which in contrast are easy to install and get working.
These packages are documented in the code either by `library(pkg_XYZ)` or by
`pkg_XYZ::some_function()`.

* Reading and writing rights in directory  
`P:/HAFL/7 WWI/74a FF WG/742a Aktuell/R.011551-52-WFOM-01_Fernerkundungstools_Forstliche_Praxis/Methoden/Use-Cases`

### Which directory is to use when?
Note that the a. m. directory so far only serves as storage for the output
deriving form the redesigned workflow of Use Case 1 ( _**R**_-scripts mentioned
below under _Procedure_ ). Formerly the Use-Case-1-output was saved in
`P:/LFE/HAFL/WWI-Sentinel-2/Use-Cases`.
Don't use that directory to save the the outcome of the redesigned workflow. Thus
no results from the erstwhile method get overwritten / lost. 

### Procedure

Once you have fulfilled the a. m. requirement proceed as follows:

1. Log in on your gmail account associated with _**Google Earth Engine**_.
2. Check if your _**Google Drive**_ account has enough free capacity for at least
another 2 GB of new data (once the whole procedure is completed you can delete
the intermediate GeoTIFF stored in _**Google Drive**_). 
3. Go to directory `.../Digital-Forest-Monitoring` and start _**RStudio**_ by
clicking on a _.Rproj_ file (most likely _**Digital-Forest-Monitoring.Rproj**_).
4. Within _**RStudio**_'s _File_ pane navigate to `.../Digital-Forest-Monitoring/methods/use-case1`,
where you find the three _**R**_-scripts involved in the resigned workflow:
   - _**$\_$us1_main_including_GEE.R**_
   - _**ee_S2_max_ndvi.R**_
   - _**ee_map_max_ndvi_rgb.R**_
5. Open _**$\_$us1_main_including_GEE.R**_, which contains the main code (scouring
also _**ee_S2_max_ndvi.R**_ and _**ee_map_max_ndvi_rgb.R**_). You can't send the
main-script's code in one flush to the console and except everything will work
fine. Up to and including section _**PARAMETERS**_ there's some interactivity
involved. Twice you're prompted for input
   - your gmail / _**Google Earth Engine**_ account (something like EE.USER@gmail.com)
   in section _**GEE / rgee SET UP**_
   - the current year (= year for which you wish to calculate the NDVI max
   difference) in section _**PARAMETERS**_

&emsp; &emsp; &nbsp; Moreover in section _**GEE / rgee SET UP**_ you have to pay close attention: Read the comments and run the code line by line!

&emsp; &emsp; &nbsp; At the end of the _**PATHS**_ section existence of relative and absolved paths is checked. Recheck the check!

6. Having finished section _**PATHS**_ you should be able execute the rest of the
code in one go. This will take time (experiences made so far about 1^1^$/$~2~ to 2 hours)!

During the whole (redesigned) workflow there's no need for any manual transfer
of data. The pipeline  
&emsp; &emsp; &nbsp; _**Google Earth Engine**_  $\Longrightarrow$ _**Google Drive**_ $\Longrightarrow$ local drive (`P:/...`)  
works without any human intervention!

Eventually you will have outputs of the following type:

* _**ndvi_diff_20CC_20PP_Int16.tif**_: Raster with original values, in original projection EPSG:2056 $\Rightarrow$ for **WCS Service**
* _**ndvi_diff_20CC_20PP_Int16_EPSG3857_NA-600.tif**_: Raster thresholded (values > threshold are set to NA), reprojected to EPSG:3857 $\Rightarrow$ for **WMS Service**
* _**ndvi_diff_20CC_20PP_Int16_EPSG3857_NA-600.gpkg**_: Vector file  with areas of change, reprojected to EPSG:3857 $\Rightarrow$ for **WFS Service**

_**20CC**_ stands for a current year, while _**20PP**_ stands for the particular previous year.

These three files are saved in directory
`P:/HAFL/7 WWI/74a FF WG/742a Aktuell/R.011551-52-WFOM-01_Fernerkundungstools_Forstliche_Praxis/Methoden/Use-Cases/Use-Case1`

This directory will also be equipped with _**ndvi_diff_20CC_20PP_tab_run_times.RData**_,
which contains a single `data.frame` / table documenting the overall run time of
the whole procedure as well as run times of different steps along the workflow.

### Note on development

* The workflow of Use Case 1 was redesigned in autumn 2023 aiming at
  - compatibility with recent version of _**R**_ / _**Rstudio**_
  - automating the workflow as much as possible by integrating _**Google Earth Engine**_
  and data transfer with `rgee`
  - avoiding non-_R_-dependencies as much as possible
  - no further use of [outdated _**R**_-packages](https://geocompx.org/post/2023/rgdal-retirement/) (`raster`)
  - no need for _**R**_-server
* The redesign has archived these goals. And detailed quality checks within
five test areas (overall 1400 km^2^) have only shown minor differences to results
obtained with the formerly applied method.
* Somewhat parallel to the ongoing redesign discussion arouse around the institutional
framework, within which the future maintenance and development of Use Case 1 ought
to take place.
* As long as this discussion hasn't settle no further development related to Use
Case 1 will be done at the HAFL / WWI.

Archiv
----------
The archive contains older scripts

* based on _**R**_ only / without  _**Google Earth Engine**_ (_**calc_ndvi_max.R**_, _**ndvi_max_switzerland.R**_)
* based on combination of _**R**_ and  _**Google Earth Engine**_ (everything else)
