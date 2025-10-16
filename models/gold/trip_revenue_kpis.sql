{{ 
    config(
        materialized='table'
    )
}}

{% set metrics = [
    {'name': 'total_fare', 'expr': 'SUM(fare_amount)'},
    {'name': 'avg_fare', 'expr': 'AVG(fare_amount)'},
    {'name': 'trip_count', 'expr': 'COUNT(trip_id)'},
    {'name': 'total_distance', 'expr': 'SUM(distance_km)'}
] %}

SELECT
    DATE_TRUNC('day', trip_start_time) AS trip_date,
    vehicle_id,
    {% for m in metrics %}
        {{ m.expr }} AS {{ m.name }}
        {% if not loop.last %},{% endif %}
    {% endfor %},
    {{ revenue_category('AVG(fare_amount)') }} AS revenue_category
FROM {{ ref('trips') }}
GROUP BY 1, 2
