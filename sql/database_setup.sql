create database streamcart;
use streamcart;

-- tables and constarints creation
create table customers(
	customer_id int primary key,
    cusomer_name varchar(100),
    email varchar(100),
    city varchar(50),
    country varchar(50),
    signup_date date,
    plan_type varchar(50),
    is_active boolean);
    
create table products(
	product_id int primary key,
    product_name varchar(100),
    category varchar(50),
    subcategory varchar(50),
    cost_price decimal(10,2),
    selling_price decimal(10,2),
    launch_date date);
    
create table orders(
	order_id int primary key,
    customer_id int,
    product_id int,
    order_date date,
    quantity int,
    unit_price decimal(10,2),
    discount_pct decimal(5,2),
    return_status varchar(20),
    selling_channel varchar(20),
    foreign key (customer_id) references customers(customer_id),
    foreign key (product_id) references products(product_id));
    
create table subscriptions(
	sub_id int primary key,
    customer_id int,
    plan_name varchar(50),
    start_date date,
    end_date date,
    monthly_fee decimal(10,2),
    pay_method varchar(50),
    foreign key (customer_id) references customers(customer_id));
    
create table support_tickets(
	ticket_id int primary key,
    customer_id int,
    created_date date,
    resolved_date date,
    priority varchar(30),
    category varchar(50),
    csat_score int,
    foreign key (customer_id) references customers(customer_id));
    
    show tables;
    
 -- Index Creation   
create index idx_orders_cx
on orders(customer_id);

create index idx_orders_product
on orders(product_id);

create index idx_subscription_cx
on subscriptions(customer_id);

create index idx_tickets_cx
on support_tickets(customer_id);

-- create views
create view vw_sales_details as
select
	o.order_id,
    o.order_date,
    o.return_status,
    o.selling_channel,
    
    c.customer_id,
    c.cusomer_name,
    c.city,
    c.country,
    c.sign_up_date,
    c.plan_type,
    c.is_active,
    
    p.product_id,
    p.product_name, 
    p.category,
    p.subcategory,
    
	o.quantity,
    o.unit_price,
    o.discount_pct,
    
    round(o.quantity * o.unit_price * (1 - o.discount_pct/100), 2) as revenue,
    
    round((p.selling_price - p.cost_price) * o.quantity, 2) as profit
    
    from orders o
    join customers c
    on o.customer_id = c.customer_id
    join products p
    on o.product_id = p.product_id;
    
create view vw_subscription_summary as
select 
	s.sub_id,
    s.customer_id,
    c.cusomer_name,
    c.city,
    
    s.plan_name,
    s.monthly_fee,
    
    s.pay_method,
    
    s.start_date,
    s.end_date,
    
    datediff(s.end_date, s.start_date) as subscription_days
    
from subscriptions s
join customers c
on s.customer_id = c.customer_id;

create view vw_support_summary as
select
	t.ticket_id,
    t.customer_id,
    
    c.cusomer_name,
    c.city,
    
    t.category,
    t.priority,
    t.csat_score,
    
    t.created_date,
    t.resolved_date,
    
    datediff(t.resolved_date, t.created_date) as resolution_days
    
from support_tickets t
join customers c
on t.customer_id = c.customer_id;

create view vw_churn_risk as
with max_order_date as
(	select max(order_date) as latest_order_date
	from orders),
    
customer_last_order as
(
	select customer_id,
		max(order_date) as last_order_date
        from orders
        cross join max_order_date 
        where return_status = 'Completed'
        group by customer_id
)

select
c.customer_id,
c.cusomer_name,
datediff(m.latest_order_date, clo.last_order_date) as days_since_last_order,
case
when datediff(m.latest_order_date, clo.last_order_date) > 180 then 'High Risk'
when datediff(m.latest_order_date, clo.last_order_date) > 90 then 'Medium Risk'
else 'Low Risk'
end as churn_risk
from customer_last_order clo 
join customers c
on clo.customer_id = c.customer_id
cross join max_order_date m;

select * from vw_support_summary;
