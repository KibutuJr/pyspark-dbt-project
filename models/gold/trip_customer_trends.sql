{{
    config(
        materialized='table'
    )
}}

SELECT
    customer_id,
    COUNT(trip_id) AS total_trips,
    SUM(fare_amount) AS total_spent,
    AVG(fare_amount) AS avg_spent_per_trip,
    MIN(trip_start_time) AS first_trip,
    MAX(trip_start_time) AS last_trip,
    DATEDIFF(MAX(trip_start_time), MIN(trip_start_time)) AS days_active,
    CASE
        WHEN COUNT(trip_id) >= 20 THEN 'Loyal'
        WHEN COUNT(trip_id) BETWEEN 10 AND 19 THEN 'Regular'
        ELSE 'Occasional'
    END AS customer_category
FROM {{ ref('trips') }}
GROUP BY customer_id
