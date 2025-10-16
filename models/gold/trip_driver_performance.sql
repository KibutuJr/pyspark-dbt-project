{{
    config(
        materialized='table'
    )
}}

SELECT
    driver_id,
    COUNT(trip_id) AS total_trips,
    SUM(distance_km) AS total_distance,
    SUM(fare_amount) AS total_earnings,
    ROUND(AVG(fare_amount), 2) AS avg_fare_per_trip,
    ROUND(SUM(fare_amount)/NULLIF(SUM(distance_km), 0), 2) AS revenue_per_km,
    CASE
        WHEN AVG(fare_amount) > 80 THEN 'Top Performer'
        WHEN AVG(fare_amount) BETWEEN 50 AND 80 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_category
FROM {{ ref('trips') }}
GROUP BY driver_id
