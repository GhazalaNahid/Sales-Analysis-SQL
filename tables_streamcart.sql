create database streamcart;
use streamcart;

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