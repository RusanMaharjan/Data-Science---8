/*
	SubQuery
	---------

	SubQuery / Nested Query / Logical Query

	1. Types of SubQueries
		a. Single Row Subquery
			- If inner query provides with single row and single column data.
			- Comparison Operator

		b. Multi Row Subquery
			- If inner query provides with multiple row and single column
			- In (Categorical / Continuous / Discrete), (Any, All (continuous))

		3. Correlated Subquery
			- It can be multi row subquery or independent correlated subquery.
			- It uses exists if inner query provides multiple row and mutiple column output.

	Syntax
	-------
	select * from table_name where col_name = ( -- Outer Query
		select col_name from table_name -- Inner Query
	);
*/

-- Find product details whose price is less than its average price.

select
	avg(list_price)
from production.products;

select * from production.products where list_price < 1520.591401;

select * from production.products where list_price < (
	select avg(list_price) from production.products
);

-- Find second highest list price proudct details.

select * from production.products where list_price = (
	select max(list_price) from production.products where list_price < (
		select max(list_price) from production.products
	)
);

select * from production.products where list_price = (
	select max(list_price) from production.products where list_price < (
		select max(list_price) from production.products where list_price < (
			select max(list_price) from production.products
		)
	)
);

-- Find customer details whose order has been rejected.
select
	CONCAT(sc.first_name, ' ', sc.last_name) as customer_name,
	email, street, city, state, zip_code
from sales.customers sc
join sales.orders so
on sc.customer_id = so.customer_id
where so.order_status = 3;

select
	CONCAT(first_name, ' ', last_name) as customer_name, email, street, city, state, zip_code
from sales.customers where customer_id in (
	select customer_id from sales.orders where order_status = 3
);

-- Find staff details who works in Store Santa Cruz Bikes and who had handled orders in 2018.
select 
	distinct CONCAT(sst.first_name, ' ', sst.last_name) as staff_name,
	sst.email, sst.active
from sales.stores ss
join sales.orders so
on ss.store_id = so.store_id
join sales.staffs sst
on so.staff_id = sst.staff_id
where ss.store_name = 'Santa Cruz Bikes'
	and order_date between '2018-01-01' and '2018-12-31';


select CONCAT(first_name, ' ', last_name) as staff_name, email, active
from sales.staffs where staff_id in (
	select staff_id from sales.orders where store_id in (
		select store_id from sales.stores where store_name = 'Santa Cruz Bikes'
	) and order_date between '2018-01-01' and '2018-12-31'
);

-- Find details of products whose price is less than 209.99 and 249.99. (All)

select * from production.products where list_price < all (
	select list_price from production.products where list_price in (209.99, 249.99)
);

-- Find details of products whose price is less than 209.99 or 249.99. (Any)
select * from production.products where list_price < any (
	select list_price from production.products where list_price in (209.99, 249.99)
);

-- Correlated Subquery

select 
	distinct sc.customer_id, CONCAT(sc.first_name, ' ', sc.last_name) as full_name,
	total_price, product_name, model_year
from (
	select
		so.order_id, so.customer_id, so.order_status, so.order_date,
		((soi.list_price * soi.quantity) * (1 - soi.discount)) as total_price,
		pp.product_name, pp.model_year
	from sales.orders so
	join sales.order_items soi
	on so.order_id = soi.order_id
	join production.products pp
	on soi.product_id = pp.product_id
	where model_year = 2018
		and ((soi.list_price * soi.quantity) * (1 - soi.discount)) < 1000
) as data
join sales.customers sc
on data.customer_id = sc.customer_id;


select customer_id, CONCAT(first_name, ' ', last_name) as full_name
from sales.customers where customer_id in (
	select customer_id from sales.orders where order_id in (
		select order_id from sales.order_items where product_id in (
			select product_id from production.products where model_year = 2018
		) and ((list_price * quantity) * (1 - discount)) < 1000
	)
);

