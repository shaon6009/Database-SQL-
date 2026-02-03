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

select distinct country from combine_data;
select distinct extreme_weather_events from combine_data;
select distinct climate_classification from combine_data;
select distinct climate_zone from combine_data;