-- create database wallmart;

use wallmart;
select * from wsales;

-- add the time_of_day column
update wsales
set time_of_day = case 
when try_cast([time] as time) >= '00:00:00' and try_cast([time] as time) < '12:00:00' then 'morning'
when try_cast([time] as time) >= '12:00:00' and try_cast([time] as time) < '16:00:00' then 'afternoon'
else 'evening' end;

-- add day_name column
alter table wsales add day_name varchar(20);
update wsales set day_name = datename(weekday, date);
select date, day_name from wsales;

-- add month_name column
alter table wsales add month_name varchar(20);
update wsales set month_name = datename(month, date);


-- ---------------------------- Generic ------------------------------


-- How many unique cities does the data have?
select distinct city from wsales;

-- In which city is each branch?
select distinct city, branch from wsales;


-- ---------------------------- Product -------------------------------


-- How many unique product lines does the data have?
select distinct product_line from wsales;

-- What is the most selling product line
select sum(quantity) , product_line from wsales group by product_line order by sum(quantity) desc;

-- What is the total revenue by month
select month_name as m, sum(total) as t from wsales
group by month_name order by t;

-- What month had the largest COGS?
select month_name as m, sum(cogs) as c from wsales
group by month_name order by c desc;

-- What product line had the largest revenue?
select product_line, sum(total) as total_revenue
from wsales order by total_revenue desc;

-- What is the city with the largest revenue?
select branch, city, sum(total) as t from wsales group by city, branch order by t;

-- What product line had the largest VAT?
select product_line, avg(tax_5) as AVG_TAX  from wsales group by product_line order by AVG_TAX desc;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales
select avg(quantity) as avg_qnty from wsales;
select product_line , case when avg(quantity) > 6 then 'good' else 'bad' end as remark
from wsales group by Product_line;

-- Which branch sold more products than average product sold?
select branch, sum(quantity) as qunty from wsales group by branch
having sum(quantity) > (select avg(quantity) from wsales);

-- What is the most common product line by gender
select gender, product_line, count(gender) as total_gender_cnt from wsales group by gender, Product_line
order by total_gender_cnt desc;

-- What is the average rating of each product line
select product_line, round(avg(rating),2) as AVG_RATING from wsales group by product_line order by AVG_RATING;


-- -------------------------- Customers -------------------------------


-- How many unique customer types does the data have?
select distinct  customer_type from wsales;

-- How many unique payment methods does the data have?
select distinct payment from wsales;

-- What is the most common customer type?
select customer_type , count(*) as count from wsales group by customer_type;

-- Which customer type buys the most?
select customer_type, round(sum(total),2) as total_buy, sum(quantity) as total_quantity from wsales 
group by customer_type;

-- What is the gender of most of the customers?
select gender, count(*) as count_gender from wsales group by gender;

-- What is the gender distribution per branch?
select branch, gender, count(*) as total from wsales  group by branch, Gender;

-- Which time of the day do customers give most ratings?
select time_of_day , round(avg(rating),1)/2 as avg_rating, branch, count(invoice_id) as total_customer 
from wsales group by time_of_day, branch;

-- Which day of the week has the best average ratings per branch?
select day_name, round(avg(rating),1)/2 as avg_rating, branch, count(invoice_id) as total_customer 
from wsales group by DAY_NAME, branch;


-- ---------------------------- Sales ---------------------------------


-- Number of sales made in each time of the day per weekday 
select time_of_day, round(sum(Total),2) as total_slaes from wsales where DAY_NAME= 'Sunday' group by time_of_day;

-- Which of the customer types brings the most revenue?
select Customer_type, round(sum(Total),2) as total_slaes from wsales group by Customer_type;

-- which city has the largest tax/vat percent?
select
    city,
    round(avg(tax_5), 2) as avg_tax_pct
from wsales
group by city
order by avg_tax_pct desc;

-- which customer type pays the most in vat?
select
    customer_type,
    avg(Tax_5) as total_tax
from wsales
group by customer_type
order by total_tax;