{% macro revenue_category(fare_amount) %}
    CASE
        WHEN {{ fare_amount }} >= 100 THEN 'High Value'
        WHEN {{ fare_amount }} BETWEEN 50 AND 99 THEN 'Medium Value'
        ELSE 'Low Value'
    END
{% endmacro %}


