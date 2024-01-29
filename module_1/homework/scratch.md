# Q1

```
docker run --help | grep -i 'automatically remove'
    --rm                     Automatically remove the container when it exits
```


# Q2

create a Dockerfile:
```
FROM python:3.9

ENTRYPOINT ["bash"]
```

build image: `docker build -t module-1:homework`
run image: `docker run -it module-1:homework` 

get version of `wheel`

```
root@fb1f9ad2923a:/# pip list
Package    Version
---------- -------
pip        23.0.1
setuptools 58.1.0
wheel      0.42.0
```


# Q3

ran Postgres and pgAdmin containers in network:

```
docker run -it -e POSTGRES_USER="root" -e POSTGRES_PASSWORD="root" -e POSTGRES_DB="ny_taxi" -v $(pwd)/ny_taxi_postgres_data:/var/lib/postgresql/data -p 5432:5432 --network=pg-network --name pg-database postgres:16

docker run -it -e PGADMIN_DEFAULT_EMAIL="admin@admin.com" -e PGADMIN_DEFAULT_PASSWORD="root" -p 8080:80 --network=pg-network --name pg-admin dpage/pgadmin4
```

ran custom taxi_ingest container with green trip data:

```
docker run -it --network=pg-network \
    taxi_ingest:v001 \
        --user=root \
        --pswd=root \
        --host=pg-database \
        --port=5432 \
        --db=ny_taxi \
        --tbl_name=green_taxi_trips \
        --url="https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-09.csv.gz"
```

get counts of trips on 2019-09-18:

```
SELECT COUNT(*) 
FROM green_taxi_trips 
WHERE DATE(lpep_pickup_datetime) = '2019-09-18'
	AND DATE(lpep_pickup_datetime) = '2019-09-18';

15767
```


# Q4

get pickup day with longest trip:

```
SELECT lpep_pickup_datetime, trip_distance
FROM green_taxi_trips
ORDER BY trip_distance DESC;

2019-09-26
```

# Q5

load taxi zone lookup data to postgres

```
import pandas as pd
from sqlalchemy import create_engine

df = pd.read_csv('taxi_zone_lookup.csv')

user='root'
pswd='root'
host='localhost'
port='5432'
db='ny_taxi'
tbl_name='taxi_zone_lookup'

conn_str = 'postgresql://{}:{}@{}:{}/{}'.format(user, pswd, host, port, db)
engine = create_engine(conn_str)
df.to_sql(name=tbl_name, con=engine, if_exists='replace')
```

get Three biggest pick up Boroughs on 2019-09-18, ignoring Unknown boroughs

```
SELECT tzl."Borough", SUM(gtt.total_amount) AS total_amount_sum
FROM green_taxi_trips gtt
INNER JOIN taxi_zone_lookup tzl
	ON gtt."PULocationID" = tzl."LocationID"
WHERE DATE(lpep_pickup_datetime) = '2019-09-18'
	AND tzl."Borough" <> 'Unknown'
GROUP BY tzl."Borough"
ORDER BY total_amount_sum DESC; 

"Borough"	"total_amount_sum"
"Brooklyn"	96333.23999999897
"Manhattan"	92271.30000000075
"Queens"	78671.70999999957
"Bronx"	32830.08999999989
"Staten Island"	342.59
```


# Q6

```
SELECT tzl."Zone", gtt.tip_amount
FROM green_taxi_trips gtt
INNER JOIN taxi_zone_lookup tzl
	ON gtt."DOLocationID" = tzl."LocationID"
WHERE EXTRACT(YEAR FROM lpep_pickup_datetime) = '2019'
	AND EXTRACT(MONTH FROM lpep_pickup_datetime) = '09'
	AND gtt."PULocationID" = 7
ORDER BY gtt.tip_amount DESC
LIMIT 1; 

"Zone"	"tip_amount"
"JFK Airport"	62.31
```

# Q7