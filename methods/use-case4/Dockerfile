# build with
# docker build -t r_uc4 .

# use geospatial R image for lidR, raster, ...
FROM rocker/geospatial

# create working directory
# this needs to be connected as volume
# use: docker run r_uc4_test -v C:\Users\hbh1\Projects\H02_Wissenstransfer_Fernerkundung\UC4_LiDAR\docker_conn:/uc4_wd
RUN mkdir /uc4_wd

# create app directory
# 
COPY . /usr/local/src/uc4
WORKDIR /usr/local/src/uc4

# install additional required packages
RUN R -e "install.packages('rstac')"
RUN R -e "install.packages('viridis')"

# run mainscript upon container execution
CMD ["Rscript", "/usr/local/src/uc4/UC4_main.R"]