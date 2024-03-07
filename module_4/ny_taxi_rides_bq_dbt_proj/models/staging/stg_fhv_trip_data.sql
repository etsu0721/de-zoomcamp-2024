{{ config(materialized='view') }}

with source as (
    select * 
    from {{ source('staging', 'fhv_trip_data') }}
    where extract(year from pickup_datetime) = 2019
),
renamed as (
    select
        dispatching_base_num,
        pickup_datetime,
        dropoff_datetime,
        pulocationid,
        dolocationid,
        sr_flag,
        affiliated_base_number
    from source
)
select * from renamed
