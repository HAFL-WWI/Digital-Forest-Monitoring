#-------------------------------#
####           INFO          ####
#-------------------------------#
# build with
# docker build -t hbh1/uc4_prototype .

# run with
# docker run -v C:\LOCAL\DIRECTORY:/usr/local/src/uc4 hbh1/uc4_prototype

# the C:\LOCAL\DIRECTORY must contain a subfolder "input" containing the input files for the algorithm

#-------------------------------#
####           SETUP         ####
#-------------------------------#
# use as base image geospatial R image for lidR, raster, ...
FROM rocker/geospatial

# CREATE WORKING DIRECTORY
# this directory needs to be connected as volume
# use -v flag: -v C:\LOCAL\DIRECTORY:/usr/local/src/uc4
RUN mkdir /uc4

# copy sourcecode
# this will include the current directory content in the container
# in case the docker is deployed 
# https://stackoverflow.com/questions/47664107/docker-mount-to-folder-overriding-content
COPY . /usr/local/src/uc4
WORKDIR /usr/local/src/uc4


# install additional required packages
RUN R -e "install.packages('rstac')"
RUN R -e "install.packages('viridis')"

#-------------------------------#
####           MAIN          ####
#-------------------------------#

#CMD ls -la /usr/local/src/uc4 && cp -f /uc4/UC4_main.R /usr/local/src/uc4/UC4_main.R && ls -la /usr/local/src/uc4 && Rscript /usr/local/src/uc4/UC4_main.R
#CMD [ -f "/uc4/UC4_main.R" ] && cp -f /uc4/UC4_main.R /usr/local/src/uc4/UC4_main.R && ls -la /usr/local/src/uc4 && Rscript /usr/local/src/uc4/UC4_main.R

# run mainscript upon container execution
#CMD ["Rscript", "/usr/local/src/uc4/UC4_main.R"]
CMD ["bash", "/usr/local/src/uc4/DockerCMD.sh"]
