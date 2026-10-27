/*
	- Non Argumented Functions
	Row_Number()
		- Gives unique identifier number for each row of table.
		- Find and removes duplicate values

	Rank()
	Dense_Rank()
		- Rank Data on basis of selected column in order by and partition by

	- Argumented Functions
	NTile()
		- Divides data into multiple partition

	Lead()
		- Next Value

	Lag()
		- Previous Value

	Sum()
	Avg()

	-- Syntax
	select
		col1, col2, col3, win_func() Over(partition by col_name order by col_name)
	from table_name;

*/

select * from FDD.dbo.[Fraud Detection Dataset];


select
	Transaction_ID, User_ID, Transaction_Amount, Transaction_Type, Time_of_Transaction, Device_Used,
	Location, Previous_Fraudulent_Transactions, Account_Age, Number_of_Transactions_Last_24H,
	Payment_Method, Fraudulent,
	Row_Number() Over(partition by Time_of_Transaction order by Transaction_ID) as rn
from FDD.dbo.[Fraud Detection Dataset];

-- Finding Duplicate Data
select
	Transaction_ID, User_ID, Transaction_Amount, Transaction_Type, Time_of_Transaction, Device_Used,
	Location, Previous_Fraudulent_Transactions, Account_Age, Number_of_Transactions_Last_24H,
	Payment_Method, Fraudulent,
	Row_Number() Over(partition by Transaction_ID order by Transaction_ID) as rn
from FDD.dbo.[Fraud Detection Dataset];

-- Removing Duplicate Data
with duplicate_fraud_data as (
	select
		Transaction_ID, User_ID, Transaction_Amount, Transaction_Type, Time_of_Transaction, Device_Used,
		Location, Previous_Fraudulent_Transactions, Account_Age, Number_of_Transactions_Last_24H,
		Payment_Method, Fraudulent,
		Row_Number() Over(partition by Transaction_ID order by Transaction_ID) as rn
	from FDD.dbo.[Fraud Detection Dataset]
)
delete from duplicate_fraud_data where rn > 1;


-- Rank
select
	product_id, product_name, brand_id, category_id, model_year, list_price,
	Rank() Over(partition by model_year order by list_price desc) as rank_num
from production.products;

-- Dense Rank
select * from (
	select
		product_id, product_name, brand_id, category_id, model_year, list_price,
		DENSE_RANK() Over(partition by model_year order by list_price desc) as dense_rank_num
	from production.products
) as data
where dense_rank_num = 2;


-- NTile
select
	product_id, product_name, brand_id, category_id, model_year, list_price,
	NTILE(3) Over(order by list_price) as ntile_num
from production.products;

-- LEAD and LAG
select
	product_id, product_name, brand_id, category_id, model_year, list_price,
	Lead(product_name, 1) Over(order by list_price) as next_product,
	LAG(product_name, 1) Over(order by list_price) as prev_product
from production.products;

-- Running Sum and Moving Average
select
	product_id, product_name, brand_id, category_id, model_year, list_price,
	SUM(list_price) Over(partition by model_year order by list_price) as running_sum,
	AVG(list_price) Over(partition by model_year order by list_price) as moving_avg
from production.products;

/*
	Monthly Running Total Revenue: Calculate the running total of sales revenue month
	over-month for the fiscal year 2017. 
*/

select
	soi.order_id, year(order_date) as order_year, list_price, discount, FORMAT(so.order_date, 'MMMM') as order_month,
	SUM(list_price) OVER(Order by list_price) as running_revenue
from sales.order_items soi
join sales.orders so
on soi.order_id = so.order_id
where YEAR(order_date) = 2017;


with MoM_revenue as (
	select
		DATEFROMPARTS(year(order_date), MONTH(order_date), 1) as month_start,
		sum((soi.quantity * soi.list_price) * (1 - soi.discount)) as revenue
	from sales.order_items soi
	join sales.orders so
	on soi.order_id = so.order_id
	where YEAR(order_Date) = 2017
	group by DATEFROMPARTS(year(order_date), MONTH(order_date), 1)
)
select
	FORMAT(month_start, 'MMMM') as month_name,
	SUM(revenue) Over(order by revenue) as revenue_total
from MoM_revenue
order by month_start;













