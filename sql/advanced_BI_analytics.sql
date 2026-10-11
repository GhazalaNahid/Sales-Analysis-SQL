use streamcart;

-- CHURN RISK ANALYSIS
with max_order_date as(
select max(order_date) as latest_order_date
from orders),

customer_metrics as(
select customer_id,
max(order_date) as last_order_date,
round(sum(revenue), 2) as lifetime_value 
from vw_sales_details
where return_status = 'Completed'
group by customer_id)

select c.customer_id, c.cusomer_name, cm.lifetime_value,
datediff(m.latest_order_date, cm.last_order_date) as days_since_last_order,
case
when datediff(m.latest_order_date, cm.last_order_date) > 180 then 'High Risk'
when datediff(m.latest_order_date, cm.last_order_date) > 90 then 'Medium Risk'
else 'Low Risk'
end as churn_risk
from customer_metrics cm
join customers c
on cm.customer_id = c.customer_id
cross join max_order_date m
order by days_since_last_order desc;

-- RFM BASE ANALYSIS
with max_order_date as(
select max(order_date) as latest_order_date
from orders),

rfm_base as(
select customer_id, max(order_date) as last_order_date, count(distinct order_id) as frequency, 
round(sum(revenue), 2) as monetary
from vw_sales_details
where return_status = 'Completed'
group by customer_id)

select r.customer_id,
datediff(m.latest_order_date, r.last_order_date) as recency,
r.frequency, r.monetary
from rfm_base r
cross join max_order_date m;

-- RFM SEGMENTATION
with max_order_date as(
select max(order_date) as latest_order_date
from orders),

rfm_base as(
select customer_id, max(order_date) as last_order, 
count(distinct order_id) as frequency,
sum(revenue) as monetary
from vw_sales_details
where return_status = 'Completed'
group by customer_id),

rfm_scores as(
select customer_id,
ntile(4) 
over(
order by datediff((select latest_order_date from max_order_date),last_order) desc) as r_score,
ntile(4)
over(
order by frequency asc) as f_score,
ntile(4)
over(
order by monetary asc) as m_score
from rfm_base)

select customer_id, r_score, f_score, m_score,
concat(r_score, f_score, m_score) as rfm_code,
case 
when r_score = 4 and f_score>= 3 and m_score>= 3 then 'Champion'
when r_score >= 3 and f_score >= 3 then 'Loyal Customer'
when r_score <= 2 and f_score <= 2 then 'At Risk'
else 'Regular Customer'
end as customer_segment
from rfm_scores
order by customer_id;

-- CUSTOMER AQUISTION ANALYSIS
with first_purchase as(
select customer_id,
min(order_date) as first_order
from orders
where return_status = 'Completed'
group by customer_id)

select 
year(first_order) as cohort_year,
month(first_order) as cohort_month,
count(*) as customers
from first_purchase
group by cohort_year, cohort_month
order by cohort_year, cohort_month;

-- COHORT ANALYSIS (MONTHLY)
with customer_cohort as(
select customer_id,
date_format(min(order_date), '%Y-%m') as cohort_month
from orders 
where return_status = 'Completed'
group by customer_id)

select cohort_month,
count(*) as customers
from customer_cohort
group by cohort_month
order by cohort_month;

-- CUSTOMER SPENDING TIERS
with customer_spend as(
select customer_id,
round(sum(revenue), 2) as total_spend
from vw_sales_details
where return_status = 'Completed'
group by customer_id),

tiered_customers as(
select customer_id, total_spend,
ntile(5)
over(
order by total_spend) as spending_tier
from customer_spend)

select customer_id, total_spend, spending_tier,
case 
when spending_tier = 5 then 'VIP'
when spending_tier = 4 then 'Premium'
when spending_tier = 3 then 'Standard'
else 'Low value'
end as customer_value
from tiered_customers;

-- REVENUE MOMENTUM - Month-by-Month(MoM) Revenue Growth
with monthly_revenue as(
select year(order_date) as order_year, month(order_date) as order_month,
sum(revenue) as revenue 
from vw_sales_details where return_status ='Completed'
group by year(order_date), month(order_date))

select order_year, order_month,
revenue,
lag(revenue)
over(order by order_year, order_month) as previous_month_revenue,
round(
100 * (revenue - lag(revenue) over(order by order_year, order_month))
/lag(revenue) over(order by order_year, order_month), 2) as mom_growth_pct
from monthly_revenue;

-- CUSTOMER PURCHASE TREND - Purchase Gap Analysis
with purchase_history as(
select customer_id, order_date,
lag(order_date)
over(
	partition by customer_id
    order by order_date) as previous_order_date
from orders
where return_status = 'Completed')

select customer_id, order_date, previous_order_date,
datediff(order_date, previous_order_date) as days_between_orders
from purchase_history;

-- TOP PRODUCTS BY CATEGORY	
with product_profit as(
select category, product_name, sum(profit) as total_profit
from vw_sales_details 
where return_status = 'Completed'
group by category, product_name)

select * from(
select category, product_name, total_profit,
round(100 * total_profit/sum(total_profit) over(partition by category), 2) 
as category_profit_pct,
dense_rank()
over(partition by category 
order by total_profit desc) as category_rank
from product_profit) x where category_rank <=3;

-- PARETO ANALYSIS
with customer_revenue as(
select customer_id, sum(revenue) as total_revenue
from vw_sales_details
where return_status = 'Completed'
group by customer_id)

select customer_id, total_revenue, 
round(100 * sum(total_revenue) over(order by total_revenue desc) / sum(total_revenue) over(), 2)
as cumulative_revenue_pct
from customer_revenue;

-- RUNNING REVENUE TOTAL
with monthly_revenue as(
select year(order_date) as order_year, month(order_date) as order_month,
sum(revenue) as revenue
from vw_sales_details
where return_status = 'Completed'
group by order_year, order_month)

select order_year, order_month, revenue,
sum(revenue) over(order by order_year, order_month) as cumulative_revenue,
round(100 * sum(revenue) over(order by order_year, order_month)/ sum(revenue) over(), 2) as revenue_pct
from monthly_revenue;

-- 3-MONTH MOVING AVERAGE
with monthly_revenue as(
select year(order_date) as order_year, month(order_date) as order_month,
sum(revenue) as revenue
from vw_sales_details 
where return_status = 'Completed'
group by order_year, order_month)

select order_year, order_month, revenue,
round(sum(revenue) over(
	order by order_year, order_month
    rows between 2 preceding and current row), 2) as moving_avg_3_month
from monthly_revenue;