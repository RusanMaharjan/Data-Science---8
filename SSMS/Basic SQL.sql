-- to switch database
use BikeStores;

Set Nocount On; -- Will not show number of rows affected message.

Set Statistics Time On;

select 
	customer_id, first_name, last_name, phone, email, street, city, state, zip_code
from sales.customers;

Set Statistics Time Off;


Set Statistics Time On;
select * from sales.customers;
Set Statistics Time Off;

-- Find customer details who lives in state NY.
select
	*
from sales.customers where state = 'NY';

-- String Functions
-- Used to extract letters from text / digits.
-- SubString(), Left(), Right()

-- Substring(col_name, start_value (length), number_of_text_to_extract)
-- Extract first 3 letters of customers first name.

select
	first_name, SUBSTRING(first_name, 2, 3) as first_3
from sales.customers;

--Left(col_name, number_of_text_to_extract), Right(col_name, number_of_text_to_extract)
-- Extract last 4 letters of customers first name.
select
	first_name, SUBSTRING(first_name, 1, 3) as first_3, RIGHT(first_name, 4) as last_4
from sales.customers;

select
	first_name, SUBSTRING(first_name, 2, 30) as first_3
from sales.customers;

-- Concat Function and Concatenation Operator (+)
select
	CONCAT(first_name, ' ', last_name, ' ', zip_code) as customer_name,
	(first_name + ' ' + last_name) as full_name
from sales.customers;

select product_name + '-----' + list_price from production.products;

select concat(product_name, '-----' ,list_price) from production.products;

-- Data limitation
-- Limit -> MySQL / PgSQL
-- Top -> MSSQL Server
-- Offset and Fetch -> MSSQL Server / Oracle

-- Top
select top 5
	customer_id, first_name, last_name, phone, email, street, city, state, zip_code
from sales.customers
order by zip_code desc;

-- Offset and Fetch
-- Offset -> number of rows to skip.
-- fetch -> extract number of rows after skip.
select
	customer_id, first_name, last_name, phone, email, street, city, state, zip_code
from sales.customers
order by zip_code desc
offset 10 rows fetch next 5 rows only;


--1 - first_name(2, 3) - last_name(last 3) - email(5, 4) - street(4, 5) - city(first 3) - state - zip_code (2, 2)

-- UUID (Universal Unique ID)
-- GUID (Global Unique ID)

-- 1-ebr-rks-.burk-3 Tho-Orc-NY-41
select
	CONCAT(
		customer_id, '-', Substring(first_name, 2, 3), '-', right(last_name, 3), '-', substring(email, 5, 4),
		'-', substring(street, 4, 5), left(city, 3), '-', state, '-', substring(zip_code, 2, 2)
	) as cust_unique_id,
	first_name, last_name, phone, email, street, city, state, zip_code
from sales.customers;

-- Handle Null Values
--IsNull
--Coalesce

select
	phone, ISNULL(phone, 'No Phone Number') as filled_number,
	coalesce(phone, 'no data') as coalesce_number
from sales.customers;


-- Date Functions
select * from sales.orders;


select
	order_date,
	-- SQL / Tableau / PowerBI
	YEAR(order_date) as o_year,
	MONTH(order_date) as o_month,
	DAY(order_date) as o_day,

	-- SQL / Tableau
	DATEPART(WEEK, order_date) as week_num,
	CONCAT(YEAR(order_date), '-Q',DATEPART(QUARTER, order_date)) as quarter_num,
	DATEPART(WEEKDAY, order_date) as weekday_num,
	DATENAME(MONTH, order_date) as order_month_name,
	DATENAME(WEEKDAY, order_date) as order_day_name,

	-- SQL / PowerBI
	FORMAT(order_date, 'MMMM') as order_month,
	FORMAT(order_date, 'dddd') as order_day
from sales.orders;


-- Date Analytics Function
select
	order_date, ISNULL(shipped_date, GETDATE()) as shipped_date, required_date,
	DATEDIFF(DAY, order_date, ISNULL(shipped_date, GETDATE())) as day_diff,
	DATEADD(DAY, 2, required_date) as added_required_date
from sales.orders;


/*
	Relational Algebra
	--------------------
	Projection (Pie) -> Filter Data
	Selection (Sigma) -> Column Selection
	Join (x) -> Join

	SQL Execution Flow
	---------------------
	From -> Join -> Where -> Group By -> Having -> Select -> Distinct -> Order By -> Top/Limit/Offset Fetch
*/


select 
	order_id, item_id, product_id, quantity, list_price, discount,
	(((list_price * quantity) * (1 - discount)) * 1.13) as total_price
from sales.order_items
where ((list_price * quantity) * (1 - discount)) > 1000
order by total_price;

/*
	SQL CASE
	----------
	select
		Case
			when condition then value
			when condition then value
			when condition then value
			Else Value
		End
	from table_name;
*/

select 
	order_id, item_id, product_id, quantity, list_price, discount,
	(((list_price * quantity) * (1 - discount)) * 1.13) as total_price,
	CASE
		WHEN (((list_price * quantity) * (1 - discount)) * 1.13) between 0 and 5000 then 'Low Spent'
		When (((list_price * quantity) * (1 - discount)) * 1.13) between 5001 and 15000 then 'Average Spent'
		--When (((list_price * quantity) * (1 - discount)) * 1.13) > 15000 then 'High Spent'
		Else 'High Spent'
	END as price_segment
from sales.order_items
order by total_price;

-- Find order details of customers whose order has been delivered till now 
-- show customer id, order status and how many days required to deliver order
-- and in which quarter of year the order has been delivered.
select distinct order_status from sales.orders;