#!/bin/bash

# Check for custom script
ls /uc4/ | grep UC4_main.R > /dev/null

# check output of the previous command
if [ $? -eq 0 ]
then
    echo -e "Using custom script"
    # overwrite script in container
    cp -f /uc4/UC4_main.R /usr/local/src/uc4/UC4_main.R
else
    echo -e "Running UC4_main.R from container"
fi

# run script
Rscript /usr/local/src/uc4/UC4_main.R