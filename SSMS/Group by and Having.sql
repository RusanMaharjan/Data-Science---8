/*
	Group By
	----------
	Aggregate Function -> Sum, Avg, Count, Min, Max

	Aggregate Column -> If any aggregation function is used with column.
	Non-Aggregate Column -> If column is specified as normal column.

	Rule
	----------
	1. If any non-aggreagte column is specified with aggregate column then non-aggregate column must be defined in 
	group by clause.

	2. Non Aggreagate columns can only be specify in group by clause.

	Having
	-------
	Where -> Filter Data
	Having -> Filter Data

	1. Having is used to filter aggregate data column and columns which has been specified in group by clause.

	where
	-----
	1. Where only filters columns which are available in table.

*/


--df.groupby('State')['customer_id'].count()

-- Find total customer by each state, City, zip code.
select
	State, City, zip_code, COUNT(customer_id) as total_customers
from sales.customers
group by State, City, zip_code;


select
	State, City, COUNT(customer_id) as total_customers
from sales.customers
group by State, City
having state = 'NY';


-- Find total orders in each order status.
select
	CASE
		When order_status = 1 then 'Pending'
		When order_status = 2 then 'Processing'
		When order_status = 3 then 'Rejected'
		When order_status = 4 then 'Completed'
	End as order_label,
	COUNT(order_id) as total_orders
from sales.orders
group by CASE
		When order_status = 1 then 'Pending'
		When order_status = 2 then 'Processing'
		When order_status = 3 then 'Rejected'
		When order_status = 4 then 'Completed'
	End;


select
	CASE
		When order_status = 1 then 'Pending'
		When order_status = 2 then 'Processing'
		When order_status = 3 then 'Rejected'
		When order_status = 4 then 'Completed'
	End as order_label,
	COUNT(order_id) as total_orders
from sales.orders
group by order_status;


-- Using Sum Case or Sum Count
select
	SUM(Case when order_status = 1 then 1 else 0 end) as Pending,
	SUM(Case when order_status = 2 then 1 else 0 end) as Processing,
	SUM(Case when order_status = 3 then 1 else 0 end) as Rejected,
	SUM(Case when order_status = 4 then 1 else 0 end) as Completed
from sales.orders;

select
	count(Case when order_status = 1 then 1 end) as Pending,
	count(Case when order_status = 2 then 1 end) as Processing,
	count(Case when order_status = 3 then 1 end) as Rejected,
	count(Case when order_status = 4 then 1 end) as Completed
from sales.orders;

/*
	3. Order Volume by Seasonal Quarters 
	Write a query using the orders table to analyze order 
	volumes based on when they were placed. Use a CASE expression to group the order_date values 
	into 'First Half' (months January through June) and 'Second Half' (months July through December). 
	Use a WHERE clause to only look at orders from the year 2018, and use a HAVING clause to 
	only show halves that processed more than 200 orders.
*/

select
	Case
		When order_date >= '2018-01-01' and order_date <='2018-06-30' then 'First Half'
		When order_date >= '2018-07-01' and order_date <='2018-12-31' then 'Second Half'
	End as date_label,
	COUNT(order_id) as total_orders
from sales.orders
where YEAR(order_date) = 2018
group by 
	Case
		When order_date >= '2018-01-01' and order_date <='2018-06-30' then 'First Half'
		When order_date >= '2018-07-01' and order_date <='2018-12-31' then 'Second Half'
	End
having COUNT(order_id) > 200;