-- Fetch the full name and hiring date of all Employees who work as Sales Representatives.
 select 
 concat(firstname, ' ' , lastname) as full_name ,
 hiredate 
 from `Cochin.employees`
 where title = 'Sales Representative'

-- Which of the products in our inventory need to be reordered? 
-- Note: Used the fields UnitsInStock and ReorderLevel, where UnitsInStock is less than the ReorderLevel, ignoring the fields UnitsOnOrder and Discontinued.
select 
productid
from `Cochin.products`
where unitsinstock < reorderlevel
order by productid

-- Find and display the details of customers who have placed more than 5 orders.
select*
from `Cochin.customers` c 
where customerid in (
select
customerid
from `Cochin.orders`
group by customerid 
having count(orderid) > 5 
)

-- An employee of ours (Margaret Peacock, EmployeeID 4) has the record of completing most orders. However, there are some customers who've never placed an order with her. Show such customers.

select
distinct(o.customerid ) , c.contactname
from `Cochin.orders` o 
join `Cochin.customers` c 
on o.customerid = c.customerid
where o.customerid not in (
select distinct(customerid)
from `Cochin.orders`
where employeeid = 4 )


-- Retrieve the top 5 best-selling products on the basis of the quantity ordered. 

select
od.productid, p.productname , sum(od.quantity) as total_quantity
from `Cochin.orders_details` od
join `Cochin.products` p 
on od.productid = p.productid
group by od.productid , p.productname
order by total_quantity desc 
limit 5 

-- Analyze the monthly order count for the year 1997.
select 
extract(month from orderdate) as month , 
count(orderid) as order_count
from `Cochin.orders`
where extract(year from orderdate) = 1997
group by 1
order by 1 asc

-- Calculate the difference in sales revenue for each month compared to the previous month.
with monthlysales as (
select 
extract(month from o.orderdate) as month ,
extract(year from o.orderdate) as year ,
round(sum(od.unitprice*od.quantity - od.discount*(od.unitprice*od.quantity)),2) as sales_revenue 
from `Cochin.orders_details` od 
join `Cochin.orders` o 
on od.orderid = o.orderid
group by 1,2
order by 2,1 asc)

select 
month , year , sales_revenue , 
round(sales_revenue - lag(sales_revenue) OVER (ORDER BY year, month) , 2) AS sales_difference
from monthlysales
order by year , month

-- Calculate the percentage of total sales revenue for each product.
with total_product_sales as 
(
select
productid , 
round(sum(unitprice*quantity - discount*(unitprice*quantity)),2) as total_product_revenue , 
from `Cochin.orders_details`
group by productid
)
select * , 
round(sum(total_product_revenue) over() , 2) as total_revenue , 
round((total_product_revenue *100)/ round(sum(total_product_revenue) over() , 2),2 ) product_sales_percentage 
from total_product_sales
