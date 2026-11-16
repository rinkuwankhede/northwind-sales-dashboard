select * from categories;
SELECT 'shippers' AS table_name, COUNT(*) AS total_rows FROM shippers
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'order_details', COUNT(*) FROM order_details
UNION ALL SELECT 'orders', COUNT(*) FROM orders;

--1. Total revenue, total orders, average order value
select * from order_details limit 5;

select round(sum(revenue)::numeric,2) as total_revenue,
       count(distinct orderid) as total_orders,
       round((sum(revenue)/count(distinct orderid))::numeric,2) as avg_order_value
from order_details;

--2. Revenue by year and month 
select * from orders;
select * from order_details;

select orders.orderyear ,orders.ordermonth,round(sum(order_details.revenue)::numeric, 2) as total_revenue
from orders join order_details on orders.orderid = order_details.orderid
group by orders.orderyear,orders.ordermonth
order by orders.orderyear,orders.ordermonth;

--3. month-over-month growth.
---The only new thing is the “Last month” column. SQL has a tool called lag. It just looks at the row above and brings that number down.
--- use CTE - Common table expression 

with monthly as(
select orders.orderyear,orders.ordermonth,
sum(order_details.revenue)as total_revenue,
lag(sum(order_details.revenue)) over (order by orders.orderyear,orders.ordermonth) as last_month_revenue
from orders
join order_details on orders.orderid = order_details.orderid
group by orders.orderyear, orders.ordermonth
)
select orderyear,ordermonth,
round(total_revenue::numeric,2) as total_revenue,
round(last_month_revenue::numeric,2) as last_month_revenue,
round(((total_revenue-last_month_revenue)/last_month_revenue * 100)::numeric,2)as growth_precent
from monthly 
order by orderyear, ordermonth;

--4. Top 10 products by revenue
select * from products;
select * from order_details;

select products.productname ,
round(sum(order_details.revenue)::numeric,2) as total_revenue
from products join order_details on products.productid = order_details.productid
group by products.productname
order by total_revenue desc
limit 10;


--5. Revenue by category
select * from categories;
select * from order_details;
select * from products;

select categories.categoryname,
round(sum(order_details.revenue)::numeric,2) as total_revenue
from order_details
join products on order_details.productid = products.productid
join categories on products.categoryid = categories.categoryid
group by categories.categoryname
order by total_revenue desc;


--6. Revenue from discontinued products
select * from products;
select * from order_details;

select products.productname ,
round(sum(order_details.revenue)::numeric,2) as total_revenue
from products join order_details on products.productid = order_details.productid
where products.discontinued = '1'
group by products.productname
order by total_revenue desc;


--7. Top 10 customers by revenue
select * from customers;
select * from order_details;
select *  from orders;

select customers.companyname,
round(sum(order_details.revenue)::numeric,2) as total_revenue
from orders join order_details on orders.orderid = order_details.orderid
join customers on orders.customerid = customers.customerid
group by customers.companyname
order by total_revenue desc
limit 10;


--8. Revenue by country
select * from customers;
select * from order_details;
select * from orders;

select customers.country,
round(sum(order_details.revenue)::numeric,2) as total_revenue
from customers join orders on customers.customerid = orders.customerid
join order_details on order_details.orderid = orders.orderid
group by customers.country 
order by total_revenue desc;


--9. Customers who never ordered 
select * from customers;
select * from orders;

select customers.customerid,customers.companyname,customers.country
from customers left join orders on customers.customerid = orders.customerid 
where orders.orderid is null;

--10. Average shipping cost by shipper
select * from shippers;
select * from orders;

select shippers.companyname , 
round(avg(orders.shippingcost)::numeric,2) as Avg_shipping_cost
from shippers join orders on shippers.shipperid = orders.shipperid
group by shippers.companyname 
order by Avg_shipping_cost desc;

--11. Late orders by shipper
select * from orders;
select * from shippers;

select shippers.companyname , count(*) as late_orders
from shippers join orders on shippers.shipperid = orders.shipperid
where orders.islate = 'true'
group by shippers.companyname
order by late_orders desc;














