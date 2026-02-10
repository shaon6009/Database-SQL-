create database climate_change;


use climate_change;
go

SELECT * INTO [combine_data]
FROM (
    SELECT * FROM [australia]
    UNION ALL
    SELECT * FROM [brazil]
    UNION ALL
    SELECT * FROM [canada]
    UNION ALL
    SELECT * FROM [germany]
    UNION ALL
    SELECT * FROM [india]
    UNION ALL
    SELECT * FROM [south_africa]
    UNION ALL
    SELECT * FROM [usa]
) AS combined_results;





select * from combine_data;
select * from india;

select distinct country from combine_data;
select distinct extreme_weather_events from combine_data;
select distinct climate_classification from combine_data;
select distinct climate_zone from combine_data;

select distinct climate_zone from india; 

select distinct climate_zone from combine_data where Country='inda';

select * from combine_data
where record_id is null

update combine_data set City= 'Totonto' where Record_ID= 'cnd_227';
select * from combine_data where Record_ID='cnd_227';

-- Monthly Temperature Trends
select DATENAME(month, date) as month_name, 
avg(temperature_c) as Avg_Temperature from combine_data group by DATENAME(month, date), month(date) order by month(date);

-- average temperature by country
select country, avg(temperature_C) as avg_temp from combine_data 
group by country order by avg_temp desc;

-- Extreme Weather Events by Month
select datename(month, date) as month_name, count(*) as event_count from combine_data 
where extreme_weather_events != 'none' group by datename(month, date), month(date) order by month(date);

-- Country-wise Extreme Weather
select country, count(*) as event_count from combine_data
where Extreme_Weather_Events != 'none' group by Country order by country;

-- Extreme Weather Events by Temperature Range
SELECT CASE 
WHEN temperature_c < 10 THEN '1. Very Cold (<10°C)'
WHEN temperature_c BETWEEN 10 AND 15 THEN '2. Cold (10-15°C)'
WHEN temperature_c BETWEEN 15 AND 20 THEN '3. Moderate (15-20°C)'
WHEN temperature_c BETWEEN 20 AND 25 THEN '4. Warm (20-25°C)'
ELSE '5. Hot (>25°C)'
END AS temperature_range, extreme_weather_events,COUNT(*) AS event_count
FROM combine_data
WHERE extreme_weather_events != 'none'
GROUP BY CASE 
WHEN temperature_c < 10 THEN '1. Very Cold (<10°C)'
WHEN temperature_c BETWEEN 10 AND 15 THEN '2. Cold (10-15°C)'
WHEN temperature_c BETWEEN 15 AND 20 THEN '3. Moderate (15-20°C)'
WHEN temperature_c BETWEEN 20 AND 25 THEN '4. Warm (20-25°C)'
ELSE '5. Hot (>25°C)'
END, extreme_weather_events
ORDER BY temperature_range, event_count DESC;

-- which cities are experiencing extreme weather events this week and what are their economic and population impacts?
select country, city, extreme_weather_events, count(*) as event_count, 
round(avg(temperature_c), 1) as avg_temp, 
sum(population_exposure) as total_pop, 
sum(economic_impact_estimate) as total_impact, 
round(avg(infrastructure_vulnerability_score), 0) as avg_vuln
from combine_data where date between '2025-03-03' and '2025-03-07' and extreme_weather_events != 'none'
group by country, city, extreme_weather_events order by total_impact desc;

-- what are the top 5 cities with the highest air quality concerns and their associate risks?
select top 5 country, city, round(avg(air_quality_index_aqi), 0) as avg_aqi, count(*) as high_aqi_days, 
sum(population_exposure) as total_pop, round(avg(temperature_c), 1) as avg_temp 
from combine_data where date between '2025-03-03' and '2025-03-07'
group by country, city having avg(air_quality_index_aqi) > 100 order by avg_aqi;

-- Which biome types are most risk from extreme weather events this week?
select biome_type, count(*) as total_rec, count(distinct country + city) as loc_count,
count(case when extreme_weather_events != 'none' then 1 end) as event_count,
string_agg(extreme_weather_events, ', ') within group (order by extreme_weather_events) as all_events,
round(avg(temperature_c), 1) as avg_temp, sum(economic_impact_estimate) as total_impact from combine_data 
where date between '2025-03-03' and '2025-03-07' group by biome_type;

select biome_type, count(*) as total_rec, count(distinct country + city) as loc_count,
count(case when extreme_weather_events != 'none' then 1 end) as event_count,
string_agg(extreme_weather_events, ', ') within group (order by extreme_weather_events) as all_events,
round(avg(temperature_c), 1) as avg_temp, sum(economic_impact_estimate) as total_impact from combine_data 
where date between '2025-03-03' and '2025-03-07' and extreme_weather_events != 'none' group by biome_type;
