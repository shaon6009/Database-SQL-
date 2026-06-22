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

--  Running Median of Lead Time
with ordered_shipments as (select shipment_id, transport_mode, date, lead_time_days,
row_number() over(partition by transport_mode order by date) as row_num from supply_risk
)
select a.shipment_id, a.date, a.lead_time_days,(select max(median_val) from (
select percentile_cont(0.5) within group (order by b.lead_time_days) over() as median_val
from ordered_shipments b
where b.transport_mode = a.transport_mode and b.row_num <= a.row_num) t) as Running_median_lead_time
from ordered_shipments a
order by a.transport_mode, a.date;

--  Cumulative Distance per Carrier (Reset on Disruption)
WITH pre_summary AS (SELECT *, 
SUM(CAST(Disruption_Occurred AS INT)) OVER (ORDER BY Date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS disruption_group
FROM supply_risk
)
SELECT *, SUM(Distance_km) OVER (
PARTITION BY Carrier_Reliability_Score, disruption_group ORDER BY Date
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_distance
FROM pre_summary;

-- YOY Disruption Increase by Month
with yoy as(select year(date) as yr, month(date) as mo, avg(cast(disruption_occurred as float)) as disruption_rate
from supply_risk group by year(date), month(date))
select yr, mo, disruption_rate, lag(disruption_rate,12) over(order by yr,mo) as prev_year_rate,
disruption_rate - lag(disruption_rate,12) over (order by yr,mo) as yoy_change from yoy;

-- Weighted Risk Score per Shipment
SELECT *,( (Fuel_Price_Index - MIN(Fuel_Price_Index) OVER ()) * 1.0 / 
NULLIF(MAX(Fuel_Price_Index) OVER () - MIN(Fuel_Price_Index) OVER (), 0) * 0.25
+ (Geopolitical_Risk_Score - MIN(Geopolitical_Risk_Score) OVER ()) * 1.0 / 
NULLIF(MAX(Geopolitical_Risk_Score) OVER () - MIN(Geopolitical_Risk_Score) OVER (), 0) * 0.35
+ (1.0 - Carrier_Reliability_Score) * 0.2
+ (CASE WHEN Weather_Condition = 'Hurricane' THEN 1.0 ELSE 0.0 END) * 0.1
+ (Lead_Time_Days - MIN(Lead_Time_Days) OVER ()) * 1.0 / 
NULLIF(MAX(Lead_Time_Days) OVER () - MIN(Lead_Time_Days) OVER (), 0) * 0.1) AS weighted_risk_score
FROM supply_risk;

-- Recursive CTE: Find Indirect Routes
with routes as(select origin_port, destination_port from supply_risk
union
SELECT a.Origin_Port, b.Destination_Port FROM supply_risk a JOIN supply_risk b ON a.Destination_Port = b.Origin_Port) 
select * from routes;

-- Fill Missing Dates per Lane
WITH dates AS (SELECT Origin_Port, Destination_Port, Date,
LEAD(Date) OVER (PARTITION BY Origin_Port, Destination_Port ORDER BY Date) AS next_date FROM supply_risk
)
SELECT Origin_Port, Destination_Port, DATEADD(day, t.n, dates.Date) AS missing_date FROM dates
CROSS APPLY (SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n 
FROM (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) a(n) 
CROSS JOIN (VALUES (0),(0),(0),(0),(0),(0),(0),(0),(0),(0)) b(n)) t
WHERE next_date IS NOT NULL AND t.n < DATEDIFF(day, dates.Date, dates.next_date);

-- Mode of Transport per Product Category
with freq as(select product_category, Transport_Mode, row_number() over(partition by product_category
order by count(*) desc) as rn from supply_risk group by Product_Category, Transport_Mode) 
select * from freq where rn=1;

-- Shipments with Above-Average Lead Time for that Week
WITH weekly_averages AS (
SELECT *, AVG(Lead_Time_Days) OVER (PARTITION BY Origin_Port, Destination_Port, DATEPART(week, Date)) 
AS weekly_avg_lead_time FROM supply_risk)
SELECT *, CASE WHEN Lead_Time_Days > weekly_avg_lead_time THEN 1 ELSE 0 END AS above_weekly_avg
FROM weekly_averages;

--  Self-Join: Paired Disruptions on Same Day
SELECT a.Shipment_ID, b.Shipment_ID, a.Date, a.Origin_Port FROM supply_risk a
JOIN supply_risk b ON a.Date = b.Date AND a.Origin_Port = b.Origin_Port AND a.Shipment_ID < b.Shipment_ID
WHERE a.Disruption_Occurred = 1 AND b.Disruption_Occurred = 1;

--  Dynamic Pivot: Monthly Disruption Count by Product
DECLARE @cols AS NVARCHAR(MAX), @query AS NVARCHAR(MAX);
SELECT @cols = STRING_AGG(QUOTENAME(ym), ',') FROM (SELECT DISTINCT FORMAT(Date, 'yyyy-MM') AS ym FROM Supply_risk) t;

SET @query = 'SELECT Product_Category, ' + @cols + ' 
FROM (SELECT Product_Category, FORMAT(Date, ''yyyy-MM'') AS ym, 
CAST(Disruption_Occurred AS INT) AS Disruption_Occurred FROM Supply_risk) src 
PIVOT (SUM(Disruption_Occurred) FOR ym IN (' + @cols + ')) pvt';
EXEC sp_executesql @query;

--  Lead Time vs Fuel Price Correlation per Mode
-- select transport_mode, corr(lead_time_days, fuel_price_index) as lead_fuel_corelation from supply_risk group by Transport_Mode;

SELECT Transport_Mode,
(COUNT(*) * SUM(Lead_Time_Days * Fuel_Price_Index) - SUM(Lead_Time_Days) * SUM(Fuel_Price_Index)) /
(SQRT(COUNT(*) * SUM(Lead_Time_Days * Lead_Time_Days) - SQUARE(SUM(Lead_Time_Days))) *
SQRT(COUNT(*) * SUM(Fuel_Price_Index * Fuel_Price_Index) - SQUARE(SUM(Fuel_Price_Index)))) AS lead_fuel_correlation
FROM supply_risk
GROUP BY Transport_Mode;

--  High-Frequency Routes (Top 10% by Shipment Count)
WITH freq AS (
SELECT Origin_Port, Destination_Port, COUNT(*) AS cnt, PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY COUNT(*)) OVER () AS p90
    FROM supply_risk GROUP BY Origin_Port, Destination_Port)
SELECT * FROM freq WHERE cnt > p90;

--Month-End Lead Time Snapshot
WITH ranked AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Origin_Port, Destination_Port, YEAR(Date), 
	MONTH(Date) ORDER BY Date DESC) AS rn FROM supply_risk
)
SELECT * FROM ranked WHERE rn = 1;

-- Weight Moving Average by Product (7-day)
SELECT *, AVG(Weight_MT) OVER (PARTITION BY Product_Category
ORDER BY Date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS ma7_weight
FROM supply_risk;

-- Top 5 Most Unreliable Routes (Highest Disruption %)
SELECT Origin_Port, Destination_Port, AVG(Disruption_Occurred * 1.0) AS disruption_rate,
COUNT(*) AS total_shipments FROM supply_risk
GROUP BY Origin_Port, Destination_Port HAVING COUNT(*) >= 10
ORDER BY disruption_rate DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- Lead Time Difference from Previous Shipment per Lane
SELECT date,destination_port, origin_port, disruption_occurred, Lead_Time_Days - LAG(Lead_Time_Days) OVER (PARTITION BY Origin_Port, Destination_Port
ORDER BY Date) AS lead_time_change__days__ FROM supply_risk;

-- Compare Actual Lead Time vs Route Average
SELECT date,destination_port, origin_port, disruption_occurred, Lead_Time_Days, 
AVG(Lead_Time_Days) OVER (PARTITION BY Origin_Port, Destination_Port) AS route_avg_lt,
Lead_Time_Days - AVG(Lead_Time_Days) OVER (PARTITION BY Origin_Port, Destination_Port) AS deviation
FROM supply_risk;

-- Probability of Disruption Given Weather + High Fuel
with stats as (
select *,count(case when weather_condition='hurricane' and fuel_price_index>3 then 1 end) over() as both_high
from supply_risk
)
select distinct count(case when disruption_occurred=0 and weather_condition='storm' and fuel_price_index>3 then 1 end) over()*1.0/
nullif(both_high,0) as prob_disruption_given_both
from stats;

--  Earliest and Latest Disruption per Week per Lane
WITH weekly AS (SELECT Origin_Port, Destination_Port,
DATEPART(year, Date) AS yr, DATEPART(week, Date) AS wk,
MIN(CASE WHEN Disruption_Occurred = 1 THEN Date END) AS first_disruption,
MAX(CASE WHEN Disruption_Occurred = 1 THEN Date END) AS last_disruption
FROM supply_risk
GROUP BY Origin_Port, Destination_Port, DATEPART(year, Date), DATEPART(week, Date))
SELECT * FROM weekly WHERE first_disruption IS NOT NULL;
