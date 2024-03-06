{{ config(materialized="table") }}

with
    fhv_trip_data as (select * from {{ ref("stg_fhv_trip_data") }}),
    dim_zones as (select * from {{ ref("dim_zones") }} where borough != 'Unknown')
select
    fhv_trip_data.dispatching_base_num,
    fhv_trip_data.pickup_datetime,
    fhv_trip_data.dropoff_datetime,
    fhv_trip_data.pulocationid,
    fhv_trip_data.dolocationid,
    fhv_trip_data.sr_flag,
    fhv_trip_data.affiliated_base_number,
    pickup_zone.borough as pickup_borough,
    pickup_zone.zone as pickup_zone,
    dropoff_zone.borough as dropoff_borough,
    dropoff_zone.zone as dropoff_zone,
from fhv_trip_data
inner join
    dim_zones as pickup_zone on fhv_trip_data.pulocationid = pickup_zone.locationid
inner join
    dim_zones as dropoff_zone on fhv_trip_data.dolocationid = dropoff_zone.locationid
