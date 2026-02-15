create database int_sales;

use int_sales;

select * into[combine_data]
from(select * from[sales_Canada] union all
select * from[sales_China] union all
select * from[sales_India] union all
select * from[sales_Nigeria] union all
select * from[sales_UK] union all
select * from[sales_US]) as combine_data;


select * from combine_data;

--Updating “Quantity Purchased”
update combine_data set Quantity_Purchased= '3' where Transaction_ID= '596875d9-4ad0-4188-86fc-930a0283d228';

-- Updating “Price Per Unit”
update combine_data set Price_per_Unit= (select avg(Price_per_Unit) from combine_data where Price_per_Unit is not null)
where Transaction_ID= '596875d9-4ad0-4188-86fc-930a0283d228';

-- Checking for duplicate values
select Transaction_ID, count(*) as total_Tranaction_id
from combine_data group by Transaction_ID having count(*) >1 ;

-- Adding “Total Amount” column
alter table combine_data add Total_Amount Numeric(10,2);
update combine_data set Total_Amount = (Price_per_Unit * Quantity_Purchased)-Discount_Applied;

-- Adding “Profit” column
alter table combine_data add Profit numeric(10,2);
update combine_data set profit= Total_Amount - (Cost_Price+ Quantity_Purchased);
-- alter table combine_data drop column proifit;

--Sales Revenue & Profit by Country (Combined Query)
select country , sum(total_amount) as total_revenauem,
sum(profit) as total_profit from combine_data where date between '2025-02-10' AND '2025-02-14' group by country;

-- Top 5 Best-Selling Products (During the Period)
SELECT TOP 10 Product_Name, SUM(Quantity_Purchased) AS Total_Units_Sold
FROM combine_data WHERE Date BETWEEN '2025-02-10' AND '2025-02-14'
GROUP BY Product_Name ORDER BY Total_Units_Sold DESC;

--Best Sales Representatives (During the Period)
select top 5 sales_rep, sum(total_amount) as total_sales
from combine_data where date between '2025-02-10' and '2025-02-14'
group by sales_rep order by total_sales desc;

-- Which store locations generated the highest sales?
select top 5 store_location, sum(total_amount) as total_sales, sum(profit) as total_profit
from combine_data where date between '2025-02-10' and '2025-02-14'
group by store_location order by total_sales desc;

-- What are the key sales and profit insights for the selected period?
select min(total_amount) as min_sales, max(total_amount) as max_sales, avg(total_amount) as avg_sales, sum(total_amount) as total_sales,
min(profit) as min_profit, max(profit) as max_profit, avg(profit) as avg_profit, sum(profit) as total_profit
from combine_data
where date between '2025-02-10' and '2025-02-14';
