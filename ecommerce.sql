-- 1. in this dataset we will find out the key markets for targeted marketing 
-- 2. also we need tyo find out the targeted customers like one time buyer two time buyer or frequent buyer
-- 3. we will check high revenue products which will drive the sales 
-- 4. also we will check the month on month sales to check the high sales products to manage the stocks of that 
-- 5. also wee need to check which products are there with high inventory but less sales to inc marketing of that product to drive sales
-- 6. need to check m-o-m inc in user base to keepcheck on markekting practices
-- Identify the top 3 cities with the highest number of customers to determine key markets
--  for targeted marketing and logistic optimization.

select * from customers1;
desc customers1;
select COUNT(distinct(CUSTOMER_ID)) FROM CUSTOMERS1;
-- change name for customer_id with some charaters in customers1
alter table customers1
rename column ï»¿customer_id to customer_id;
-- change name for order_id with some charaters in orders1
alter table orders1
rename column ï»¿order_id to order_id;
-- change name for order_id with some charaters in orderdetails1
alter table orderdeatils1
rename column ï»¿order_id to order_id;
-- change name for product_id with some charaters in products1
alter table products1
rename column ï»¿product_id to product_id;
-- check for duplicates
select customer_id, count(*) as numbers
from customers1
group by customer_id
having numbers >1;
-- check for duplicates
select order_id, count(*) as numbers_count
from orders1
group by order_id
having numbers_count>1;
-- check for null values
SELECT COUNT(*) FROM orders1 WHERE order_id IS NULL;

-- Find Top3 cities with highest foot fall
select location, count(*) as number_of_customers 
from customers1
group by location 
order by number_of_customers desc
limit 3;
-- output
-- Top3 cities with highest foot fall are Delhi, Chennai,Jaipur

/* Determine the distribution of customers by the number of orders placed. 
This insight will help in segmenting customers into one-time buyers, occasional shoppers, 
and regular customers for tailored marketing strategies.*/

with countcustomer as (
select count(order_id) as NumberOfOrders,customer_id
from orders1
group by customer_id)
select NumberOfOrders, count(*) as customercount
from countcustomer
group by NumberOfOrders
order by NumberOfOrders asc;
-- output
-- THis query indicates that more customers are one time buyers 
-- and customers buys 2 or 3 times from the website customers1ie there are not loyal customers 

/*Identify products where the average purchase quantity per order is 2 but with a high total revenue,
suggesting premium product trends*/
select product_id, avg(quantity) as AvgQuantity, sum(quantity*price_per_unit) as total_revenue
from orderdetails
group by product_id
having AvgQuantity = 2
order by total_revenue desc;
-- ouptut
-- product_id 1 and 8 gives highest revenue with average orders of 2 units

/*For each product category, calculate the unique number of customers purchasing from it.
 This will help understand which categories have wider appeal across the customer base.*/
select p.category, count(distinct o.customer_id) as customerscount
from products1 p
join orderdetails as od
on p.product_id = od.product_id
join orders1 as o 
on od.order_id = o.order_id
group by p.category
order by customerscount desc;
-- output 
-- electronics has max customers the wearabletech and photography being last


/* Analyze the month-on-month percentage change in total sales to identify growth trends.*/
with month_sale as
 (select date_format(o.order_date, "%Y-%m") as Month, sum(quantity*price_per_unit) as Totalsales
from orders1 as o 
join orderdetails as od
on o.order_id = od.order_id
group by date_format(o.order_date, "%Y-%m"))
select Month, Totalsales, (Totalsales-lag(Totalsales) over (order by Month ))*100/lag(Totalsales) over (order by Month ) as PercentChange
from month_sale;
-- output
-- in 4th, 7th and 12th month the percentage increase in sales are more than 100% and 7 month being the peak also observed 
-- whenever sale inc by 100 there is drop in sales for 2 months 


/* Examine how the average order value changes month-on-month.
 Insights can guide pricing and promotional strategies to enhance order value.*/
 
with month_sale as (select date_format(o.order_date, "%Y-%m") as Month, round(avg(total_amount),2) as AvgOrderValue
from orders1 as o 
group by date_format(o.order_date, "%Y-%m"))
select Month, AvgOrderValue, (AvgOrderValue-lag(AvgOrderValue) over (order by Month )) as ChangeInValue
from month_sale
order by changeinvalue desc;

/* Based on sales data, identify products with the fastest turnover rates,
suggesting high demand and the need for frequent restocking.*/

select product_id, COUNT(order_ID) as saleFrequency
from orderdetails
group by product_id
order by saleFrequency desc
limit 5;
-- output 
-- product_id 7,3,4,2,8 are high moving products means needs faster restocking.

/* List products purchased by less than 40% of the customer base, 
indicating potential mismatches between inventory and customer interest.*/

select p.Product_id,p.Name, count(distinct c.customer_id) as Uniquecustomercount
from products1 as p 
join orderdetails od
on p.product_id = od.product_id
join orders1 as o 
on od.order_id = o.order_id
join customers1 as c 
on o.customer_id = c.customer_id
group by p.product_id,name
having Uniquecustomercount < 
                     (select count(customer_id) from customers1)*0.40;
-- output
-- smartphone 6' and wireless earbuds are least popular and their promotional startergy and stocks needs to be checked


/* Evaluate the month-on-month growth rate in the customer base to 
understand the effectiveness of marketing campaigns and market expansion efforts.*/

with firstpurchase as
(select min(date_format(order_date, '%Y-%m')) as FirstPurchaseMonth, count(distinct customer_id) as TotalCustomers
from orders1
group by customer_id
)
select FirstPurchaseMonth, sum(TotalCustomers) as TotalNewCustomers
from firstpurchase
group by FirstPurchaseMonth
order by FirstPurchaseMonth;

-- Identify the months with the highest sales volume, aiding in planning for stock levels, 
-- marketing efforts, and staffing in anticipation of peak demand periods.

select date_format(o.order_date,"%Y-%m") as Month, sum(od.price_per_unit*od.quantity) as Totalsales
from orders1 as o 
join orderdetails as od 
on o.order_id = od.order_id
group by month
order by Totalsales desc;
-- output 
-- september was the month with max sales and feb for min sales