/*
	- View

	- Indexing
		- Used to make data searching and filtering fast.

	- Synonyms

	- Basic Stored Procedure
*/

-- Index
Create index idx_order_date on sales.orders(order_date);

-- View
Create view Monthly_Revenue_Report as
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
	select top 12
		FORMAT(month_start, 'MMMM') as month_name,
		SUM(revenue) Over(order by revenue) as revenue_total
	from MoM_revenue
	order by month_start;


select * from Monthly_Revenue_Report;

-- Synonyms
Create synonym mrr for Monthly_Revenue_Report;

select * from mrr;


-- Stored Procedure
-- @ -> Input Function -> input('Enter')
Create or Alter Procedure usp_Monthly_Revenue_Report (
	@Month_Name Varchar(11)
)
as
BEGIN
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
	select top 12
		FORMAT(month_start, 'MMMM') as month_name,
		SUM(revenue) Over(order by revenue) as revenue_total
	from MoM_revenue
	where FORMAT(month_start, 'MMMM') = @Month_Name
	order by month_start;
END;

exec usp_Monthly_Revenue_Report @Month_Name = 'February';



-- Write a Stored Procedure to filter product data with model year and list price.

Create or Alter Procedure usp_filter_product(
	@model_year int,
	@list_price Decimal(10, 2) = 9999999.99
)
as
BEGIN
	select * from production.products
	where model_year = @model_year
		and list_price < @list_price
END;

Exec usp_filter_product @model_year = 2017, @list_price = 200;


-- Procedure with Transactional SQL
-- Register a Customer with unique email.

Create or Alter Procedure usp_customer_registration(
	@first_name varchar(30),
	@last_name varchar(30),
	@phone varchar(25),
	@email varchar(40),
	@response_message varchar(100) output
)
AS
BEGIN
	IF Exists (select 1 from sales.customers where email = @email)
	BEGIN
		set @response_message = 'Email already exists in database. Use another email.'
		RETURN -- used to end program
	END

	Insert into sales.customers (first_name, last_name, phone, email)
	values (@first_name, @last_name, @phone, @email);

	set @response_message = CONCAT('Customer registered successfully with email ',@email,'.')
END;

Declare @output_message varchar(100)
exec usp_customer_registration @first_name = 'Hari', @last_name = 'Bahadur', @phone='1234567890', @email='hari123@gmail.com',
								@response_message = @output_message output;
select @output_message as message;


select * from sales.customers where email = 'hari123@gmail.com';

-- Show order status message by searching for order id.
Create or Alter Procedure usp_findOrderStatus(
	@order_id int,
	@Response_Message varchar(100) output
)
AS
BEGIN
	IF Not Exists (select 1 from sales.orders where order_id = @order_id)
	BEGIN
		SET @Response_Message = 'Order id does not exists in database. Provide existing order id.'
		RETURN
	END

	Declare @order_status int
	Declare @shipped_date date

	select
		@order_status = order_status,
		@shipped_date = shipped_date
	from sales.orders where order_id = @order_id;

	IF @shipped_date is not null
	BEGIN
		SET @Response_Message = CONCAT('Order with order id ',@order_id,' has already deliverd.')
	END

	ELSE IF @order_status = 1
	BEGIN
		SET @Response_Message = CONCAT('Order Id ',@order_id,' is in pending.')
	END

	ELSE IF @order_status = 2
	BEGIN
		SET @Response_Message = CONCAT('Order Id ',@order_id,' is in processing.')
	END

	ELSE
	BEGIN
		SET @Response_Message = CONCAT('Order Id ',@order_id,' has been rejected.')
	END
END;

Declare @output_message varchar(100)

exec usp_findOrderStatus @order_id=1481, @Response_Message = @output_message output;

select @output_message as message;


select order_id from sales.orders where order_status = 1;










