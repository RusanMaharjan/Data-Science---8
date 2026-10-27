/*
	CTE (Common Table Expressions)
	-------------------------------
	- Temporary Data Table

	with cte_name as (
		analysis query...
	)
	select / insert / update / delete
*/


select * from (
	select 
		ss.store_name, COUNT(sst.staff_id) as total_staff
	from sales.stores ss
	join sales.orders so
	on ss.store_id = so.store_id
	join sales.staffs sst
	on so.staff_id = sst.staff_id
	group by ss.store_name
) as data;


with store_staff as ( -- create temporary data table
	select 
		ss.store_name, COUNT(sst.staff_id) as total_staff
	from sales.stores ss
	join sales.orders so
	on ss.store_id = so.store_id
	join sales.staffs sst
	on so.staff_id = sst.staff_id
	group by ss.store_name
)
select * from store_staff;


with product_order as (
	select
		so.order_id, so.customer_id, so.order_status, so.order_date,
		((soi.list_price * soi.quantity) * (1 - soi.discount)) as total_price,
		pp.product_name, pp.model_year, pp.product_id
	from sales.orders so
	join sales.order_items soi
	on so.order_id = soi.order_id
	join production.products pp
	on soi.product_id = pp.product_id
	where model_year = 2018
		and ((soi.list_price * soi.quantity) * (1 - soi.discount)) < 1000
),
customer_product as (
	select 
		sc.customer_id, CONCAT(first_name, ' ', last_name) as full_name, 
		total_price, product_name, model_year, product_id
	from product_order po
	join sales.customers sc
	on po.customer_id = sc.customer_id
)
select
	full_name, COUNT(product_id) as total_products
from customer_product
group by full_name;

