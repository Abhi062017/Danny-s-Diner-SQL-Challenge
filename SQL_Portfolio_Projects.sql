-- 28th Oct 2:30am
-- SQL Portfolio Project | Data Analytics | Danny's Diner SQL Challenge

create schema SQL_Portfolio_Projects;
use SQL_Portfolio_Projects;

show schemas;
show tables;

CREATE TABLE if not exists dd_sales
(
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO dd_sales VALUES
('A', '2021-01-01', '1'),
('A', '2021-01-01', '2'),
('A', '2021-01-07', '2'),
('A', '2021-01-10', '3'),
('A', '2021-01-11', '3'),
('A', '2021-01-11', '3'),
('B', '2021-01-01', '2'),
('B', '2021-01-02', '2'),
('B', '2021-01-04', '1'),
('B', '2021-01-11', '1'),
('B', '2021-01-16', '3'),
('B', '2021-02-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-01', '3'),
('C', '2021-01-07', '3');


CREATE TABLE dd_menu
(
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO dd_menu VALUES
('1', 'sushi', '10'),
('2', 'curry', '15'),
('3', 'ramen', '12');

CREATE TABLE dd_members
(
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO dd_members VALUES
('A', '2021-01-07'),
('B', '2021-01-09');

select * from dd_members;
select * from dd_menu;
select * from dd_sales;

/* --------------------
   Case Study Questions
   --------------------*/

-- 1. What is the total amount each customer spent at the restaurant?

with cte_diner as
(select ms.customer_id, ms.join_date, s.order_date, m.product_id, m.product_name, m.price
from dd_members ms
join dd_sales s on ms.customer_id=s.customer_id
join dd_menu m on s.product_id=m.product_id)

select customer_id, sum(price) total_amount_spent
from cte_diner
group by customer_id
order by customer_id;
 
-- 2. How many days has each customer visited the restaurant?
select customer_id, count(customer_id) no_of_days
from dd_sales
group by customer_id;

-- 3. What was the first item from the menu purchased by each customer?
with cte_q3 as
(select m.product_id, m.product_name, s.customer_id, s.order_date
from dd_menu m
join dd_sales s on m.product_id=s.product_id)

select customer_id, product_name, order_date
from cte_q3
where order_date = (select min(order_date) from cte_q3)
group by customer_id, product_name, order_date
order by customer_id;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
with cte_diner as
(select ms.customer_id, ms.join_date, s.order_date, m.product_id, m.product_name, m.price
from dd_members ms
join dd_sales s on ms.customer_id=s.customer_id
join dd_menu m on s.product_id=m.product_id)

select product_name, count(product_name) total_purchases
from cte_diner
group by product_name
order by count(product_name) desc
limit 1;

-- 5. Which item was the most popular for each customer?
with cte_diner as
(select ms.customer_id, ms.join_date, s.order_date, m.product_id, m.product_name, m.price
from dd_members ms
join dd_sales s on ms.customer_id=s.customer_id
join dd_menu m on s.product_id=m.product_id)

select customer_id, product_name, count(*)
from cte_diner
group by customer_id, product_name
order by count(*) desc;

-- 6. Which item was purchased first by the customer after they became a member?
with cte_diner as
(select ms.customer_id, ms.join_date, s.order_date, m.product_id, m.product_name, m.price
from dd_members ms
join dd_sales s on ms.customer_id=s.customer_id
join dd_menu m on s.product_id=m.product_id)

select customer_id, join_date, order_date, product_name
from cte_diner
where join_date <= order_date
group by customer_id, join_date, order_date, product_name
order by order_date;

-- 7. Which item was purchased just before the customer became a member?
with cte_diner as
(select ms.customer_id, ms.join_date, s.order_date, m.product_id, m.product_name, m.price
from dd_members ms
join dd_sales s on ms.customer_id=s.customer_id
join dd_menu m on s.product_id=m.product_id)

select customer_id, join_date, order_date, product_name
from cte_diner
where join_date > order_date
order by order_date desc;

-- 8. What is the total items and amount spent for each member before they became a member?
with cte_diner as
(select ms.customer_id, ms.join_date, s.order_date, m.product_id, m.product_name, m.price
from dd_members ms
join dd_sales s on ms.customer_id=s.customer_id
join dd_menu m on s.product_id=m.product_id)

select customer_id, sum(price), count(product_name)
from cte_diner
where join_date > order_date
group by customer_id
order by customer_id;

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte_diner as
(select ms.customer_id, ms.join_date, s.order_date, m.product_id, m.product_name, m.price
from dd_members ms
join dd_sales s on ms.customer_id=s.customer_id
join dd_menu m on s.product_id=m.product_id),

cte_lp as
(select customer_id, price, product_name,
case when product_name = 'curry' or product_name = 'ramen' then price*10
else price*20
end as loyalty_points
from cte_diner
order by customer_id)

select customer_id, sum(loyalty_points)
from cte_lp
group by customer_id
order by customer_id;


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
with cte_diner as
(select ms.customer_id, ms.join_date, s.order_date, m.product_id, m.product_name, m.price
from dd_members ms
join dd_sales s on ms.customer_id=s.customer_id
join dd_menu m on s.product_id=m.product_id),

cte_lp as
(select customer_id, order_date, price, product_name,
case when product_name in ('curry' , 'ramen', 'sushi') then price*2
end as loyalty_points
from cte_diner
where order_date between join_date and date_add(join_date interval 7 day) -- Note to self : This is not working. 
order by customer_id)

select customer_id, order_date, sum(loyalty_points)
from cte_lp
group by customer_id, order_date
having month(order_date) = '01'
order by customer_id;