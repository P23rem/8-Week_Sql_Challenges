use danny_diner;
/*Each of the following case study questions can be answered using a single SQL statement:*/
/*What is the total amount each customer spent at the restaurant?*/
select sales.customer_id,sum(menu.price) as total_amount_spend
from sales
inner join 
menu
on menu.product_id=sales.product_id
group by sales.customer_id
order by 2 desc;

/*How many days has each customer visited the restaurant?*/
select customer_id,count(distinct order_date) as total_visit
from sales
group by customer_id;

/*What was the first item from the menu purchased by each customer?*/
with temp_table as(
select sales.customer_id,sales.product_id,menu.product_name,sales.order_date
from sales
inner join 
menu on 
menu.product_id=sales.product_id)
select customer_id,product_id,product_name from (
select *,dense_rank() over(partition by customer_id order by order_date asc) as rnk
from temp_table) as temp2_table
where rnk=1;
/* i have consider that the products which are ordered in same date is ordered together*/

/*What is the most purchased item on the menu and how many times was it purchased by all customers?*/
with temp_table as(
select temp.*,dense_rank() over(order by total_order desc) as rnk,
menu.product_name from (
select sales.product_id,count(customer_id) as total_order
from sales
group by 1) as temp
inner join menu
on menu.product_id=temp.product_id)
select product_id,product_name,total_order from temp_table
where rnk=1;

/*Which item was the most popular for each customer?*/
with temp1_table as(
select temp.*,dense_rank() over(partition by temp.customer_id order by total_order desc) as rnk
from (
select sales.customer_id,sales.product_id,count(customer_id) as total_order
from sales
group by 1,2) as temp)
select temp1_table.*,menu.product_name
from temp1_table
inner join menu
on menu.product_id=temp1_table.product_id
where temp1_table.rnk=1
order by temp1_table.customer_id;

/*Which item was purchased first by the customer after they became a member?*/
with temp_table as(select temp.*,dense_rank() over(partition by customer_id order by order_date) as rnk from (
select sales.* from sales
inner join members
on members.customer_id=sales.customer_id
and sales.order_date>members.join_date) as temp)
select temp_table.customer_id,temp_table.product_id,menu.product_name
from temp_table
inner join 
menu on 
menu.product_id=temp_table.product_id
where rnk=1
order by customer_id;

/*Which item was purchased just before the customer became a member?*/
with temp_table as(select temp.*,dense_rank() over(partition by customer_id order by order_date desc) as rnk from (
select sales.* from sales
inner join members
on members.customer_id=sales.customer_id
and sales.order_date<=members.join_date) as temp)
select temp_table.customer_id,temp_table.product_id,menu.product_name
from temp_table
inner join 
menu on 
menu.product_id=temp_table.product_id
where rnk=1
order by customer_id;

/*What is the total items and amount spent for each member before they became a member?*/
select sales.customer_id,sum(menu.price) as total_spent
from sales
inner join 
menu on 
menu.product_id=sales.product_id
where sales.order_date<all(select join_date from members where members.customer_id=sales.customer_id)
group by 1;

/*If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?*/
select sales.customer_id,sum(case when lower(menu.product_name)='sushi' then 20*menu.price else 10*menu.price end) as total_point
from sales
inner join menu on 
menu.product_id=sales.product_id
group by 1
order by 2 desc;

/*In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?*/
with temp_table as(
select sales.customer_id,order_date,sales.product_id,datediff(sales.order_date,members.join_date) as interval_days
from sales
inner join members
on members.customer_id=sales.customer_id
where members.join_date<=sales.order_date)
select customer_id,sum(case 
                           when lower(menu.product_name)='sushi' then 20*menu.price 
                           when interval_days<=6 then 20*menu.price 
                           else 10*menu.price end) as total_point
                           from temp_table inner join menu
                           on menu.product_id=temp_table.product_id
                           where month(order_date)<2
                           group by 1;
/*Join All The Things*/
with temp as (
select sales.customer_id,sales.product_id,sales.order_date,
menu.product_name,case
                     when members.join_date<=sales.order_date then 'Y' else 'N' end
                     as Members
from sales
left join members on members.customer_id=sales.customer_id
left join menu on menu.product_id=sales.product_id)
select *,case when 
				  Members='Y' then dense_rank() over(partition by customer_id,Members order by order_date)
                  else null end as ranking
                  from temp;
                           
                           