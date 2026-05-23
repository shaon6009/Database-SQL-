-- create database GSCRA;

use gscra;

select * from supply_risk;


select distinct Weather_Condition from supply_risk;
select distinct transport_mode from supply_risk;
select distinct origin_port from supply_risk;
select distinct destination_port from supply_risk;
select distinct Product_Category from supply_risk;

SELECT ROUND(MIN(distance_km), 2) AS MINIMUM_DISTANCE, 
ROUND(MAX(distance_km), 2) AS MAXIMUM_DISTANCE FROM supply_risk;

SELECT ROUND(MIN(Fuel_Price_Index), 2) AS MINIMUM_DISTANCE, 
ROUND(MAX(Fuel_Price_Index), 2) AS MAXIMUM_DISTANCE FROM supply_risk;

-- Rolling 30-Day Disruption Rate by Lane
WITH daily AS (SELECT origin_port, destination_port, date, AVG(disruption_occurred * 1.0) 
OVER(PARTITION BY origin_port, destination_port ORDER BY date ROWS BETWEEN 30 PRECEDING AND CURRENT ROW) 
AS rolling_30d_disruption_rate FROM supply_risk)
SELECT * FROM daily 
WHERE rolling_30d_disruption_rate IS NOT NULL;