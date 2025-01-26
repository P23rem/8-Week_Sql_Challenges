use pizza_runner;
/*A. Pizza Metrices*/

/*1.How many pizzas were ordered?*/
select count(pizza_id) as total_pizzas_ordered from customer_orders;

/*2. How many unique customer orders were made?*/
select count(distinct order_id) as total_unique_customer from customer_orders;

/*How many successful orders were delivered by each runner?*/
select runner_id,sum(case when cancellation is null or cancellation=' 'then 1 else 0 end)
as total_successful_orders
 from runner_orders
 group by 1;
 select * from runner_orders;
 
 /*How many of each type of pizza was delivered?*/
 select customer_orders.pizza_id,pizza_names.pizza_name,sum(case when runner_orders.cancellation=' ' then 1 else 0 end)
 as total_number_of_pizza_delivered
 from customer_orders
 inner join runner_orders
 on runner_orders.order_id=customer_orders.order_id
 inner join pizza_names
 on pizza_names.pizza_id=customer_orders.pizza_id
 group by 1,2;
 
 /*How many Vegetarian and Meatlovers were ordered by each customer?*/
 select customer_orders.customer_id,
 sum(case when lower(pizza_name)='meatlovers' then 1 else 0 end) as Meatlovers_ordered,
 sum(case when lower(pizza_name)='vegetarian' then 1 else 0 end) as Vegetarian_ordered
 from customer_orders
 inner join pizza_names
 on pizza_names.pizza_id=customer_orders.pizza_id
 group by 1;
 
 /*What was the maximum number of pizzas delivered in a single order?*/
 with final_table as (
 select *,dense_rank() over(order by total_orders desc) as rnk from (
 select customer_orders.order_id,count(customer_orders.pizza_id) as total_orders
 from customer_orders
 group by 1) as temp_table)
 select order_id,total_orders from final_table
 where rnk=1;
 
 /*For each customer, how many delivered pizzas had at least 1 change and how many had no changes?*/
 SELECT 
    customer_id,
    SUM(
        CASE 
            WHEN (TRIM(exclusions) != '' OR TRIM(extras) != '') THEN 1 
            ELSE 0 
        END
    ) AS atleast_1_change,
    SUM(
        CASE 
            WHEN (TRIM(exclusions) = '' AND TRIM(extras) = '') THEN 1 
            ELSE 0 
        END
    ) AS No_change
FROM 
    (SELECT customer_orders.* 
     FROM customer_orders 
     INNER JOIN runner_orders ON customer_orders.order_id = runner_orders.order_id
     WHERE cancellation = '' OR cancellation = ' ') AS temp
GROUP BY customer_id;

/*How many pizzas were delivered that had both exclusions and extras?*/
select sum(case when trim(exclusions)!='' and trim(extras)!='' then 1 else 0 end)
as pizzas_with_exclusion_and_extras
from customer_orders
inner join 
runner_orders
on runner_orders.order_id=customer_orders.order_id
where trim(cancellation)='';

/*What was the total volume of pizzas ordered for each hour of the day?*/
select time_hour,count(pizza_id) as total_order_in_each_hour from (
select customer_orders.*,hour(time(order_time)) as time_hour
from customer_orders) as temp
group by 1
order by 1;

/*What was the volume of orders for each day of the week?*/
select date_format((order_time),'%a') as week_day,count(order_id) as total_order
from customer_orders
group  by 1
order by 1;

/*How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)*/
select floor(datediff(registration_date,'2021-01-01')/7) +1 as week_number,count(runner_id) as number_of_signup
from runners
group by 1;

/*What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?*/
with temp as(select distinct pickup_time,order_time,timestampdiff(minute,order_time,pickup_time) as min_taken
from customer_orders
inner join runner_orders
on runner_orders.order_id=customer_orders.order_id
where lower(pickup_time)!='null')
select round(avg(min_taken),1) as average_time_to_pickup from temp;

/*Is there any relationship between the number of pizzas and how long the order takes to prepare?*/

with temp as (
select customer_orders.order_id,customer_orders.order_time,count(customer_orders.order_id) as count_orders
,timestampdiff(minute,order_time,pickup_time) as minutes_to_prepare 
from customer_orders
inner join 
runner_orders
on runner_orders.order_id=customer_orders.order_id
where runner_orders.distance!=0
group by 1,2,4)
select count_orders,round(avg(minutes_to_prepare),1) as average_time_taken
from temp
group by 1;

/*What was the average distance travelled for each customer?*/
select customer_orders.customer_id,round(avg(runner_orders.distance),1) from 
customer_orders inner join
runner_orders
on runner_orders.order_id=customer_orders.order_id
where distance!=0
group by 1;
/*(Assuming that distance is calculated from Pizza Runner HQ to customer’s place)*/


/*What was the difference between the longest and shortest delivery times for all orders?*/

select max(duration)-min(duration) as difference_between_max_and_min_delivery_time
from customer_orders
inner join 
runner_orders
on runner_orders.order_id=customer_orders.order_id
where distance!=0;

/*What was the average speed for each runner for each delivery and do you notice any trend for these values?*/
select runner_orders.runner_id,customer_orders.customer_id,customer_orders.order_id,
runner_orders.distance,runner_orders.duration,
round(distance*60/duration,2) as speed
from runner_orders
inner join 
customer_orders
on customer_orders.order_id=runner_orders.order_id
where trim(cancellation)='';

/*What is the successful delivery percentage for each runner?*/
SELECT 
    runner_orders.runner_id AS temp_id,
    round((SELECT COUNT(order_id) 
     FROM runner_orders r2 
     WHERE r2.runner_id = runner_orders.runner_id and trim(r2.cancellation)='') * 100 / COUNT(1),2) AS percentage_success
FROM runner_orders
GROUP BY runner_orders.runner_id;

with recursive split_ingredient as(
select pizza_id,
trim(substring_index(toppings,',',1)) as topping_id,
substring(toppings,length(substring_index(toppings,',',1))+2) as remaining_toppings
from pizza_recipes
where toppings is not null
union All
select pizza_id,
trim(substring_index(remaining_toppings,',',1)) as topping_id,
substr(remaining_toppings,length(substring_index(remaining_toppings,',',1))+2) as remaining_toppings
from split_ingredient
where remaining_toppings!='')
select pizza_id,group_concat(topping_name separator ',') as ingredient_name from split_ingredient
inner join pizza_toppings
on pizza_toppings.topping_id=split_ingredient.topping_id
group by 1;

/*What was the most commonly added extra?*/
with recursive extras_exclusion as(
select order_id,trim(substring_index(extras,',',1)) as extras_id,
substring(extras,length(substring_index(extras,',',1))+2) as remaining_extras
from customer_orders
where extras is not null and extras!=''
union all
select eo.order_id,trim(substring_index(eo.remaining_extras,',',1)) as extras_id,
substring(eo.remaining_extras,length(substring_index(eo.remaining_extras,',',1))+2) as remaining_extras 
from extras_exclusion as eo
where eo.remaining_extras!='' and eo.remaining_extras is not null)
,temp_table as(
select extras_id,count(order_id) as total_count from extras_exclusion
where trim(extras_id)!='' and lower(extras_id)!='null' and lower(extras_id) is not NULL
group by 1
order by 2 desc)
select extras_id,total_count,topping_name
from temp_table
inner join 
pizza_toppings on topping_id=extras_id;

/*What was the most common exclusion?*/
with recursive common_exclusion as (
select order_id,
trim(substring_index(exclusions,',',1)) as exclusion_id,
substr(exclusions,length(substring_index(exclusions,',',1))+2) as remaining_exclusions
from customer_orders
where trim(exclusions)!='' and exclusions is not null
union all
select order_id,
trim(substring_index(remaining_exclusions,',',1)) as exclusion_id,
substr(remaining_exclusions,length(substring_index(remaining_exclusions,',',1))+2) as remaing_exclusion
from common_exclusion
where trim(remaining_exclusions)!='' and remaining_exclusions is not null
)
select exclusion_id,topping_name,count(order_id) as total_count
from common_exclusion
inner join pizza_toppings
on topping_id=exclusion_id
group by 1,2
order by 3 desc;

/*mean lovers*/
select *,case when pizza_id=1 then 'Yes' else 'No' end as meat_lover
,case when pizza_id=1 and exclusions not like '%3,%' then 'No' 
      when pizza_id!=1 then '-'
      when pizza_id=1 and exclusions like '%3,%' then 'Yes'
      else 'Yes'
      end
      as meat_lover_excludes_beef,
case when extras like '%1,%' then 'Yes' else 'No' end as extra_bacon
from customer_orders;

/*Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients*/








/*If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?*/
with temp as(select runner_orders.runner_id,runner_orders.order_id,pizza_id
from runner_orders
inner join 
customer_orders
on customer_orders.order_id=runner_orders.order_id
where trim(cancellation)='' or cancellation is null or (lower(cancellation)='null') 
)

select runner_id,sum(case when pizza_id=1 then 12 else 10 end) as total_earning
from temp
group  by 1;

/*What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra*/
with temp as(
select runner_id,customer_orders.pizza_id,extras
from runner_orders
inner join 
customer_orders
on customer_orders.order_id=runner_orders.order_id
where trim(cancellation)='' or cancellation is null or (lower(cancellation)='null')),main_pizza_table as(
select runner_id,sum(case when pizza_id=1 then 12 else 10 end) as total_earning,
sum(case when trim(extras)='' then 0 else
              case when length(extras)-length(replace(extras,',',''))=0 then 1
              else length(extras)-length(replace(extras,',',''))+1 end
              end) as total_earn
from temp
group  by 1)
select runner_id,total_earning+total_earn
from main_pizza_table;


/*The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5*/
create table runner_rating_order(order_id int,runner_id int,rating int);
insert into runner_rating_order
with temp as(
select runner_orders.order_id,runner_orders.runner_id,pickup_time,distance,duration,timestampdiff(minute,order_time,pickup_time) as time_taken
from runner_orders
inner join 
customer_orders
on customer_orders.order_id=runner_orders.order_id
where trim(distance)<>''),temp2 as(
select order_id,runner_id,case when time_taken>(select avg(time_taken) from temp)+0.5*(select stddev_samp(time_taken) from temp) then 1
								when time_taken<(select avg(time_taken) from temp)-0.5*(select stddev_samp(time_taken) from temp) then 3
                                else 2 end as rating
                                from temp)
                                select * from temp2;


/*If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?*/
with temp as(select runner_orders.runner_id,runner_orders.order_id,pizza_id
from runner_orders
inner join 
customer_orders
on customer_orders.order_id=runner_orders.order_id
where trim(cancellation)='' or cancellation is null or (lower(cancellation)='null') 
), temp2 as (select runner_id,sum(distance*0.5) as total_expenditure from runner_orders
where trim(distance)!='' or trim(distance) is not null
group by runner_id),temp3 as
(select runner_id,sum(case when pizza_id=1 then 12 else 10 end) as total_earning
from temp
group  by 1)
select temp2.runner_id,round(total_earning-total_expenditure,1) as net_income
from temp2
inner join temp3
on temp2.runner_id=temp3.runner_id;

                                        
