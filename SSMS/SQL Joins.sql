/*
	SQL Join
	---------
	1. Inner Join -> Common data between tables.
	2. Left Join -> All records from left table and common record from right table remaining data shows null.
	3. Right Join -> All records from right table and common record from left table remaining data shows null.
	4. Outer Join -> Combination of all 3 joins
	5. Self Join -> Actually an inner join but joins own table.
	6. Cross Join -> Base of all joins
	7. Natural Join

	Syntax
	--------
	select
		t1.col1, t1.col2, t2.col3, t1.date
	from table1 t1
	join table2 t2
	on t2.fk = t1.pk;

	ambigious column name: date
*/
select
	sc.customer_id, sc.first_name, sc.last_name, sc.email, sc.state, 
	so.order_date, so.order_status
from sales.customers sc
inner join sales.orders so
on sc.customer_id = so.customer_id;

select
	concat(sc.first_name, ' ', sc.last_name) as customer_name,
	count(so.order_id) as total_orders
from sales.customers sc
inner join sales.orders so
on sc.customer_id = so.customer_id
group by concat(sc.first_name, ' ', sc.last_name);


-- Find detail of customer orders and order items.
select
	CONCAT(sc.first_name, ' ', sc.last_name) as customer_name,
	so.order_date, so.order_status,
	((soi.list_price * soi.quantity) * (1 - soi.discount)) as total_price
from sales.customers sc
join sales.orders so
on sc.customer_id = so.customer_id
join sales.order_items soi
on so.order_id = soi.order_id;

/*
	Write a query to display customer name their total products and 
	total amount they have spent on those orders.
*/
select
	CONCAT(sc.first_name, ' ', sc.last_name) as customer_name,
	COUNT(soi.product_id) as total_products,
	sum((soi.list_price * soi.quantity) * (1 - soi.discount)) as total_spent
from sales.customers sc
join sales.orders so
on sc.customer_id = so.customer_id
join sales.order_items soi
on so.order_id = soi.order_id
group by CONCAT(sc.first_name, ' ', sc.last_name);

select
	CONCAT(ss.first_name, ' ', ss.last_name) as staff_name,
	COUNT(so.order_id) as total_orders,
	COUNT(distinct sc.customer_id) as total_customers
from sales.customers sc
join sales.orders so
on sc.customer_id = so.customer_id
join sales.staffs ss
on so.staff_id = ss.staff_id
group by CONCAT(ss.first_name, ' ', ss.last_name);


-- Self Join
select * from sales.staffs;

select
	CONCAT(s1.first_name, ' ', s1.last_name) as manager_name,
	COUNT(s2.staff_id) as total_staff
from sales.staffs s1
inner join sales.staffs s2
on s1.staff_id = s2.manager_id
group by CONCAT(s1.first_name, ' ', s1.last_name);


select
	CONCAT(s1.first_name, ' ', s1.last_name) as manager_name,
	CONCAT(s2.first_name, ' ', s2.last_name) as staff_name
from sales.staffs s1
inner join sales.staffs s2
on s1.staff_id = s2.manager_id;


select
	CONCAT(s1.first_name, ' ', s1.last_name) as manager_name,
	COUNT(distinct s2.staff_id) as total_staff,
	COUNT(distinct sc.customer_id) as total_customers
from sales.staffs s1
inner join sales.staffs s2
on s1.staff_id = s2.manager_id
inner join sales.orders so
on s1.staff_id = so.staff_id
inner join sales.customers sc
on so.customer_id = sc.customer_id
group by CONCAT(s1.first_name, ' ', s1.last_name);

-- Left Join
select
	*
from sales.customers sc
left join sales.orders so
on sc.customer_id = so.customer_id;


select
	*
from sales.staffs s1
left join sales.staffs s2
on s1.staff_id = s2.manager_id;


select
	*
from sales.staffs s1
right join sales.staffs s2
on s1.staff_id = s2.manager_id;


select
	*
from sales.staffs s1
full outer join sales.staffs s2
on s1.staff_id = s2.manager_id;

-- Natural Join
select
	sc.first_name, sc.last_name, so.order_status, so.order_date, soi.list_price, soi.discount, soi.quantity
from sales.customers sc, sales.orders so, sales.order_items soi
where sc.customer_id = so.customer_id
	and so.order_id = soi.order_id;