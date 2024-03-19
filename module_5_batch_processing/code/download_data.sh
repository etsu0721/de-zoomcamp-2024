#!/bin/sh

# Stop execution if command exits with a non-zero code
set -e

# Get taxi type and year as command line args
TAXI_TYPE=$1 # yellow
YEAR=$2 # 2020

URL_PREFIX="https://github.com/DataTalksClub/nyc-tlc-data/releases/download"

MONTH=1
while [ "${MONTH}" -le 12 ]; do
    # Format month as 01,02,...,11,12
    FMONTH=$(printf "%02d" "${MONTH}")
    URL="${URL_PREFIX}/${TAXI_TYPE}/${TAXI_TYPE}_tripdata_${YEAR}-${FMONTH}.csv.gz"
    LOCAL_PREFIX="data/raw/${TAXI_TYPE}/${YEAR}/${FMONTH}"
    LOCAL_FILE="${TAXI_TYPE}_tripdata_${YEAR}_${FMONTH}.csv.gz"
    LOCAL_PATH="${LOCAL_PREFIX}/${LOCAL_FILE}"
    HTTP_RESPONSE=$(curl --head --write-out '%{http_code}' --silent \
        --output /dev/null \
        -L "${URL}")
    
    # Only create directories and download data if data file is found
    if [ "${HTTP_RESPONSE}" = "200" ]
    then
        echo "Downloading ${URL} to ${LOCAL_PREFIX}"
        curl --create-dirs --output "${LOCAL_PATH}" -L "${URL}"
    fi
    MONTH=$((MONTH + 1))
done
