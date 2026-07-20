-- Data Remediation Actions
-- Execute corrective actions identified during Data Quality Audit.

-- Run only after reviewing audit findings.

set sql_safe_updates = 0;

delete from customers
where 
ifnull(trim(cusomer_name), '') = ''
and ifnull(trim(email), '') = ''
and ifnull(trim(city), '') = ''
and ifnull(trim(country), '') = '';

delete from products
where
ifnull(trim(product_name), '') - ''
and ifnull(trim(category), '') = ''
and ifnull(trim(subcategory), '') = '';

delete from orders
where
ifnull(trim(return_status), '') = ''
and ifnull(trim(selling_channel), '') = '';

delete from subscriptions
where
ifnull(trim(plan_name), '') = ''
and ifnull(trim(pay_method), '') = '';

delete from support_tickets
where
ifnull(trim(priority), '') = ''
and ifnull(trim(category), '') = '';

delete from orders
where 
customer_id is null
and product_id is null
and quantity is null
and unit_price is null
and discount_pct is null;

DELETE FROM subscriptions
WHERE
customer_id IS NULL
AND IFNULL(TRIM(plan_name),'') = ''
AND monthly_fee IS NULL
AND IFNULL(TRIM(pay_method),'') = '';

delete from support_tickets
where
customer_id is null
and created_date is null
and resolved_date is null
and ifnull(trim(priority), '') = ''
and ifnull(trim(category), '') = ''
and csat_score is null;

set sql_safe_updates = 1;