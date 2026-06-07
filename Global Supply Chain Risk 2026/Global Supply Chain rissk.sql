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

--Running Total of At-Risk Weight per Month
select *, sum(weight_MT) over(partition by Year(date), month(date) order by date) as monthly_rnning_at_risk_weigt
from supply_risk where Geopolitical_Risk_Score > 7;

--Lead Time Anomaly Detection (IQR Method)
with stats as(select *, 
PERCENTILE_CONT(0.25) within group(order by lead_time_days) over(partition by origin_port, destination_port, transport_mode) as q1,
percentile_cont(0.75) within group(order by lead_time_days) over(partition by origin_port, destination_port, transport_mode) as q3
from supply_risk)
select *, case when lead_time_days < q1-1.5*(q3-q1) or lead_time_days > q3+1.5*(q3-q1)
then 1 else 0 end as IS_LEAD_TIME_OUTLAIR from stats;

-- Rank Shipments by Combined Risk (Fuel + Geopolitical)
select *, rank() over(partition by product_category order by fuel_price_index* geopolitical_risk_score) as Combine_risk_rank 
from supply_risk;

--First Disrupted Shipment per Month per Route
with ranked as ( select *, ROW_NUMBER() over(partition by origin_port, destination_port, year(date), mont(date) order by date) as rn
from supply_risk where Disruption_Occurred=1)
select * from ranked where rn=1;

--  Month-over-Month Disruption % Change
WITH monthly AS (
SELECT Origin_Port, Destination_Port, YEAR(Date) AS yr, MONTH(Date) AS mo, AVG(Disruption_Occurred * 1.0) AS disruption_rate
FROM supply_risk GROUP BY Origin_Port, Destination_Port, YEAR(Date), MONTH(Date)
)
SELECT *, 
LAG(disruption_rate) OVER (PARTITION BY Origin_Port, Destination_Port ORDER BY yr, mo) AS prev_rate,
((disruption_rate - LAG(disruption_rate) OVER (PARTITION BY Origin_Port, Destination_Port ORDER BY yr, mo)) / 
NULLIF(LAG(disruption_rate) OVER (PARTITION BY Origin_Port, Destination_Port ORDER BY yr, mo), 0)) * 100 AS pct_change
FROM monthly;

--Consecutive Disruptions (Islands)
with grp as (
    select *, 
           row_number() over(partition by origin_port, destination_port order by date) - 
           row_number() over(partition by origin_port, destination_port, disruption_occurred order by date) as grp_id 
    from supply_risk
)
select origin_port, destination_port, count(*) as streak_length 
from grp
where disruption_occurred = 1 
group by origin_port, destination_port, grp_id
order by streak_length desc;

-- Pivot Table: Disruption Count by Weather Condition
select transport_mode, 
ISNULL([Clear], 0) AS Clear, ISNULL([Storm], 0) AS Storm,
ISNULL([Rain], 0) AS Rain, ISNULL([Fog], 0) AS Fog,
ISNULL([Hurricane], 0) AS Hurricane
from(select transport_mode, weather_condition, CAST(disruption_occurred AS INT) as disruption_occurred from supply_risk) src
PIVOT (SUM(disruption_occurred) FOR weather_condition IN ([Clear],[Storm],[Rain],[Fog],[Hurricane])) pvt;

--Top 3 Most Reliable Carriers per Lane
with ranked as(select * , ROW_NUMBER() over(partition by origin_port, destination_port
order by carrier_reliability_score desc) as rn from supply_risk) select * from ranked where rn<=3;



