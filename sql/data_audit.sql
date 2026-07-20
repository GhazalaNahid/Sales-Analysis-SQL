-- Data Profiling and Data Quality Audit

use streamcart;

-- understanding the data
describe customers;
describe orders;
describe products;
describe subscriptions;
describe support_tickets;

select count(*) as total_customers from customers; 
select count(*) as total_orders from orders; 
select count(*) as total_products from products; 
select count(*) as total_subscriptions from subscriptions; 
select count(*) as total_tickets from support_tickets; 

-- sample data review
select * from customers limit 10;
select * from products limit 10;
select * from orders limit 10;
select * from subscriptions limit 10;
select * from support_tickets limit 10;

-- COMPLETENESS CHECK
-- customers
select count(*) as total_rows,
sum(case when customer_id is null then 1 else 0 end) as customer_id_nulls,
sum(case when cusomer_name is null then 1 else 0 end) as customer_name_nulls,
sum(case when email is null then 1 else 0 end) as email_nulls,
sum(case when city is null then 1 else 0 end) as city_nulls,
sum(case when country is null then 1 else 0 end) as country_nulls,
sum(case when sign_up_date is null then 1 else 0 end) as date_nulls,
sum(case when plan_type is null then 1 else 0 end) as plan_type_nulls,
sum(case when is_active is null then 1 else 0 end) as active_nulls
from customers;

-- products
select count(*) as total_rows,
sum(case when product_id is null then 1 else 0 end) as product_id_nulls,
sum(case when product_name is null then 1 else 0 end) as product_name_nulls,
sum(case when category is null then 1 else 0 end) as category_nulls,
sum(case when subcategory is null then 1 else 0 end) as subcategory_nulls,
sum(case when cost_price is null then 1 else 0 end) as cost_price_nulls,
sum(case when selling_price is null then 1 else 0 end) as selling_price_nulls,
sum(case when launch_date is null then 1 else 0 end) as launch_date_nulls
from products;

-- orders
select count(*) as total_rows,
sum(case when order_id is null then 1 else 0 end) as order_id_nulls,
sum(case when customer_id is null then 1 else 0 end) as customer_id_nulls,
sum(case when product_id is null then 1 else 0 end) as product_id_nulls,
sum(case when order_date is null then 1 else 0 end) as order_date_nulls,
sum(case when quantity is null then 1 else 0 end) as quantity_nulls,
sum(case when unit_price is null then 1 else 0 end) as unit_price_nulls,
sum(case when discount_pct is null then 1 else 0 end) as discount_pct_nulls,
sum(case when return_status is null then 1 else 0 end) as return_status_nulls,
sum(case when selling_channel is null then 1 else 0 end) as selling_channel_nulls
from orders;

-- subscriptions
select count(*) as total_rows,
sum(case when sub_id is null then 1 else 0 end) as sub_id_nulls,
sum(case when customer_id is null then 1 else 0 end) as customer_id_nulls,
sum(case when plan_name is null then 1 else 0 end) as plan_name_nulls,
sum(case when start_date is null then 1 else 0 end) as start_date_nulls,
sum(case when end_date is null then 1 else 0 end) as end_date_nulls,
sum(case when monthly_fee is null then 1 else 0 end) as monthly_fee_nulls,
sum(case when pay_method is null then 1 else 0 end) as pay_method_nulls
from subscriptions;

-- support tickets
select count(*) as total_rows,
sum(case when ticket_id is null then 1 else 0 end) as ticket_id_nulls,
sum(case when customer_id is null then 1 else 0 end) as customer_id_nulls,
sum(case when created_date is null then 1 else 0 end) as created_date_nulls,
sum(case when resolved_date is null then 1 else 0 end) as resolved_date_nulls,
sum(case when priority is null then 1 else 0 end) as priority_nulls,
sum(case when category is null then 1 else 0 end) as category_nulls,
sum(case when csat_score is null then 1 else 0 end) as csat_score_nulls
from support_tickets;

-- blank value check
-- identify blank or whitespace-only values that can impact reporting/filtering/KPI
select 'customers.cusomer_name' as field_name, count(*) as blank_count
from customers where trim(ifnull(cusomer_name, '')) = ''
union all
select 'customers.email', count(*)
from customers where trim(ifnull(email, '')) = ''
union all
select 'customers.city', count(*)
from customers where trim(ifnull(city, '')) = ''
union all 
select 'customers.country', count(*)
from customers where trim(ifnull(country, '')) = ''
union all 
select 'customers.plan_type', count(*)
from customers where trim(ifnull(plan_type, '')) = ''
union all
select 'products.product_name', count(*)
from products where trim(ifnull(product_name, '')) = ''
union all
select 'products.category', count(*)
from products where trim(ifnull(category, '')) = ''
union all
select 'products.subcategory', count(*)
from products where trim(ifnull(subcategory, '')) = ''
union all
select 'orders.return_status', count(*)
from orders where trim(ifnull(return_status, '')) = ''
union all
select 'orders.selling_channel', count(*)
from orders where trim(ifnull(selling_channel, '')) = ''
union all
select 'subscriptions.plan_name', count(*)
from subscriptions where trim(ifnull(plan_name, '')) = ''
union all
select 'subscriptions.pay_method', count(*)
from subscriptions where trim(ifnull(pay_method, '')) = ''
union all
select 'support_tickets.category', count(*)
from support_tickets where trim(ifnull(category, '')) = '';

select * from customers where cusomer_name = '';
select * from customers where city = '';
select * from products where product_name = '';
select * from products where category = '';
select * from orders where selling_channel = '';
select * from subscriptions where plan_name = '';
select * from subscriptions where pay_method = '';
select * from support_tickets where category = '';

-- distinct value audit
select distinct city from customers; 
select distinct sign_up_date from customers; 
select distinct category from products; 
select distinct launch_date from products; 
select distinct return_status from orders; 
select distinct selling_channel from orders; 
select distinct plan_name from subscriptions; 
select distinct csat_score from support_tickets; 

SELECT city, COUNT(*) AS customer_count
FROM customers
GROUP BY city
ORDER BY customer_count DESC;

-- Duplicate record check
 select customer_id, count(*) as duplicate_records
 from customers
 group by customer_id
 having count(*) > 1;
 
 select product_id, count(*) as duplicate_count
 from products
 group by product_id
 having count(*) > 1;
 
 select order_id, count(*) as duplicate_count
 from orders
 group by order_id
 having count(*) > 1;
 
 select sub_id, count(*) as dupli_count
 from subscriptions
 group by sub_id
 having count(*) > 1;
 
 select ticket_id, count(*) as dupli_count
 from support_tickets
 group by ticket_id
 having count(*) > 1;
 
 -- invalid data checks
 -- negative unit price
 select * from orders
 where unit_price <= 0;

-- negative quantity 
 select * from orders
 where quantity <= 0;
 
 -- invalid discount
 select * from orders
 where discount_pct > 100
 or discount_pct < 0;
 
 -- invalid product cost
 select * from products
 where cost_price <= 0;
 
 -- invalid selling price
 select * from products
 where selling_price <= 0;
 
-- invalid subscription fee
select * from subscriptions
 where monthly_fee <= 0;
 
-- subscription ending before start
select * from subscriptions
where end_date < start_date;

-- invalid csat
select * from support_tickets
 where csat_score > 5
 or csat_score < 0;
 
 -- referential integrity check
 -- order without customers
 select * 
 from orders o left join customers c
 on o.customer_id = c.customer_id
 where c.customer_id is null;
 
 -- orders without products
 select *
 from orders o left join products p
 on o.product_id = p.product_id
 where p.product_id is null;
 
 -- subscriptions without customers
 select *
 from subscriptions s left join customers c
 on s.customer_id = c.customer_id
 where c.customer_id is null;
 
 -- tickets without customers
 select * 
 from support_tickets t left join customers c
 on t.customer_id = c.customer_id
 where c.customer_id is null;
 
-- Business Rule Validation 
-- Orders before Customer Signup
select * 
from orders o
join customers c
on o.customer_id = c.customer_id
where  c.sign_up_date < o.order_date;

-- Future orders check
select * 
from orders 
where order_date > curdate();

-- Future Signup check
select * from customers
where sign_up_date > curdate();

-- Future Tickets check
select * from support_tickets
where created_date > curdate();

-- FLAG ISSUE 
-- FLAGS CASES WHERE ORDER DATE OCCURS BEFORE SIGN UP DATE
select
o.*,
c.sign_up_date,
case
	when o.order_date < c.sign_up_date then 'Review Required'
    else 'Valid'
end as validation_status
from orders o 
join customers c 
on o.customer_id = c.customer_id;

-- DATASET SUMMARY
select 'customers' as table_name, count(*) as total_records
from customers
union all
select 'products', count(*) from products
union all
select 'orders', count(*) from orders
union all
select 'subscriptions', count(*) from subscriptions
union all
select 'support_tickets', count(*) from support_tickets;

-- AUDIT SUMMARY
select 'Orders before Signup' as issue,
count(*) as affected_records
from orders o
join customers c
on o.customer_id = c.customer_id
where o.order_date < c.sign_up_date
union all
select 'Products below Cost', count(*)
from products
where selling_price < cost_price
union all
select 'Subscriptions Ending before Start', count(*)
from subscriptions
where end_date < start_date
union all
select 'Tickets Resolved before Creation', count(*)
from support_tickets
where resolved_date < created_date
union all
select 'Future Orders', count(*)
from orders
where order_date > curdate()
union all
select 'Future Signup Dates', count(*)
from customers
where sign_up_date > curdate();