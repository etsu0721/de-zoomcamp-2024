# Data Warehouses and BigQuery

## Homework

### Setup

For this homework we will be using the 2022 Green Taxi Trip Record Parquet Files from the New York City Taxi Data found here:
https://www.nyc.gov/site/tlc/about/tlc-trip-record-data.page

If you are using orchestration such as Mage, Airflow or Prefect do not load the data into Big Query using the orchestrator.
Stop with loading the files into a bucket.

Create an external table using the Green Taxi Trip Records Data for 2022.
Create a table in BQ using the Green Taxi Trip Records for 2022 (do not partition or cluster this table).

```
-- Create an external table using the Green Taxi Trip Records Data for 2022.
CREATE OR REPLACE EXTERNAL TABLE `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi_external`
OPTIONS (
  format = 'PARQUET',
  uris = ['gs://de_zoomcamp_mage_18469/2022_nyc_green_taxi_data/29281b36b7af4990b9aa67c0f070de4f-0.parquet']
);

-- Create a non partitioned table from external table
CREATE OR REPLACE TABLE `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi` AS
SELECT * FROM `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi_external`;
```


### Question 1
```
SELECT COUNT(*) FROM `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi`;
```
**840,402**


### Question 2
**0 B** data processed by query on external table:
```
SELECT COUNT(DISTINCT PULocationID) FROM `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi_external`;
```

**6.41 MB** processed by query on materialized table:
```
SELECT COUNT(DISTINCT PULocationID) FROM `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi`;
```


### Question 3
```
SELECT COUNT(*) 
FROM `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi` 
WHERE fare_amount = 0;
```
**1,622**


### Question 4
**Partition by lpep_pickup_datetime and Cluster on PUlocationID**

Since our query will always filter on lpep_pickup_datetime, we want to partition on lpep_pickup_datetime so to reduce the amount of data our query will need to process. Clustering on PUlocationID will give results ordered by PUlocationID within the partitions which is what we want from our query.

```
-- Create a partitioned and clustered table from external table
CREATE OR REPLACE TABLE `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi_partitioned_clustered`
PARTITION BY DATE(lpep_pickup_datetime)
CLUSTER BY PULocationID AS
SELECT * FROM `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi_external`;
```


### Question 5
Query materialized table:
```
-- Retrieve distinct PULocationIDs between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive), 
SELECT DISTINCT PULocationID 
FROM `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi` 
WHERE TIMESTAMP_TRUNC(lpep_pickup_datetime, DAY) 
  BETWEEN TIMESTAMP("2022-06-01") and TIMESTAMP("2022-06-30");
```
**12.82 MB**

Query partitioned and clustered table:
```
-- Retrieve distinct PULocationIDs between lpep_pickup_datetime 06/01/2022 and 06/30/2022 (inclusive), 
SELECT DISTINCT PULocationID 
FROM `striking-audio-412822.2022_nyc_green_taxi.2022_nyc_green_taxi_partitioned_clustered` 
WHERE TIMESTAMP_TRUNC(lpep_pickup_datetime, DAY) 
  BETWEEN TIMESTAMP("2022-06-01") and TIMESTAMP("2022-06-30");
```
**1.12 MB**

### Question 6
External table data is stored in GCP Bucket, not BigQuery

### Question 7
False


### Question 8
It's estimated that 0 B will be read when running a `SELECT count(*)` query on the materialized table, not sure why.