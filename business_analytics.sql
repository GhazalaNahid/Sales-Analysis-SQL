use streamcart;

-- REVENUE ANALYTICS
-- Revenue Trend Analysis
select
year(order_date) as order_year,
month(order_date) as order_month,
round(sum(revenue), 2) as revenue
from vw_sales_details
where return_status = 'Completed'
group by order_year, order_month
order by order_year, order_month;

-- Revenue by Category
select
category,
round(sum(revenue), 2) as revenue
from vw_sales_details
where return_status = 'Completed'
group by category
order by revenue desc;

-- Revenue by Channel
select
selling_channel,
round(sum(revenue), 2) as revenue
from vw_sales_details
where return_status = 'Completed'
group by selling_channel
order by revenue desc;

-- Revenue by City
select
city,
round(sum(revenue), 2) as revenue
from vw_sales_details
where return_status = 'Completed'
group by city
order by revenue desc;

-- PROFITABILITY ANALYTICS
-- Profit Trend Analysis
select
year(order_date) as order_year,
month(order_date) as order_month,
round(sum(profit), 2) as profit
from vw_sales_details
where return_status = 'Completed'
group by order_year, order_month
order by order_year, order_month;

-- Most Profitable Categories
select
category,
round(sum(profit), 2) as profit
from vw_sales_details 
where return_status = 'Completed'
group by category
order by profit desc;

-- Profit Margin by Category
select
category,
round(sum(profit), 2) as profit,
round(100 * sum(profit)/sum(revenue), 2) as margin_pct
from vw_sales_details
where return_status = 'Completed'
group by category
order by margin_pct desc;

-- CUSTOMER ANALYTICS
-- Highest Value Customers
select
customer_id,
cusomer_name,
round(sum(revenue), 2) as revenue
from vw_sales_details
where return_status = 'Completed'
group by customer_id, cusomer_name
order by revenue desc
limit 5;

-- Customer Lifetime Value Ranking
select customer_id, cusomer_name,
round(sum(revenue), 2) as clv,
rank() over(
order by sum(revenue) desc) as customer_rank
from vw_sales_details
where return_status= 'Completed'
group by customer_id, cusomer_name
limit 10;

-- Customer Order Frequency
select customer_id, cusomer_name,
count(distinct order_id) as total_orders
from vw_sales_details
where return_status = 'Completed'
group by customer_id, cusomer_name
order by total_orders desc;

-- Customer Segmentation
select customer_id, cusomer_name,
round(sum(revenue), 2) as total_spend,
case
	when sum(revenue) >= 50000 then 'High Value'
    when sum(revenue) >=30000 then 'Medium Value'
else 'Low Value'
end as customer_segment
from vw_sales_details
where return_status = 'Completed'
group by customer_id, cusomer_name;

-- SUBSCRIPTION ANALYTICS
-- Revenue by Plan
select plan_name, count(*) as subcsribers,
round(sum(monthly_fee), 2) as revenue
from subscriptions
group by plan_name
order by revenue desc; 

-- Plan Distribution
select plan_name, count(*) as subscribers,
round(100 * count(*)/sum(count(*)) over(), 2) as subscriber_pct
from subscriptions
group by plan_name;

-- Payment Method Analysis
select pay_method, count(*) as subscribers,
round(avg(monthly_fee), 2) as avg_fee
from subscriptions
group by pay_method
order by subscribers desc;

-- SUPPORT ANALYTICS
-- Ticket Volume by Category
select category,
count(*) as ticket_volume
from support_tickets
group by category
order by ticket_volume desc;

-- CSAT by Category
select category,
round(avg(csat_score), 2) as avg_csat
from support_tickets
group by category
order by avg_csat desc;

-- Average Resolution Time
select priority,
round(avg(datediff(resolved_date, created_date)), 2) as avg_resolution_days
from support_tickets
group by priority
order by avg_resolution_days desc;

-- SLA BREACH ANALYSIS
select priority, count(*) as total_tickets,
sum(
case
when priority = 'Critical' and datediff(resolved_date, created_date) > 1 then 1  
when priority = 'High' and datediff(resolved_date, created_date) > 3 then 1
when priority = 'Medium' and datediff(resolved_date, created_date) > 7 then 1
else 0
end) as breached_tickets
from support_tickets
group by priority;

-- DISCOUNT ANALYTICS
-- Revenue by Discount Band
select 
case 
when discount_pct = 0 then 'No discount'
when discount_pct <= 10 then '0-10%'
when discount_pct <= 20 then '10-20%'
else '20%+'
end as discount_band,
round(sum(revenue), 2) as revenue
from vw_sales_details
where return_status = 'Completed'
group by discount_band
order by revenue desc;

-- Average Discount by Channel
select selling_channel,
round(avg(discount_pct), 2) as avg_discount
from vw_sales_details
where return_status = 'Completed'
group by selling_channel
order by avg_discount desc;

-- CUSTOMER AQUISITION ANALYTICS
-- Monthly Signup Trend
select 
year(sign_up_date) as signup_year,
month(sign_up_date) as signup_month,
count(*) as new_customers
from customers
group by signup_year, signup_month
order by signup_year, signup_month;

-- Active vs Inactive Customers
select is_active,
count(*) as customers
from customers
group by is_active;

-- Plan Type Adoption
select plan_type,
count(*) as customers
from customers
group by plan_type
order by customers desc;