
# Case Study #2 Pizza Runner






![](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%232-%20Pizza%20Runner/screenshort_used/Logo_image.png?raw=true)

***
Note: All source material is from :https://8weeksqlchallenge.com/

 Customer and Runner Analysis Using MySQL Concepts Objective: To analyze customer orders, runner performance, and ratings using advanced MySQL concepts such as JOIN, CTE, and aggregate functions.
***

## Table of Contents:
1. creation of table and Data insertion
2. Data Cleaning
3. ERD Diagram
4. Case Study Question and Answer

****
### 
![ERD Diagram](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%232-%20Pizza%20Runner/screenshort_used/ERD_Diagram.png?raw=true)

### Dataset Structure:

```sql
create database Pizza_Runner;
use Pizza_Runner;

DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings TEXT
);
INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  select * from pizza_names;
  select * from pizza_toppings;
  select * from pizza_recipes;
  
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);
INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');
  
````
## dataset Cleaning and Transformation

### Table: customer_orders

Looking at the customer_orders table below, we can see that there are

- In the exclusions column, there are missing/ blank spaces ' ' and null values.
- In the extras column, there are missing/ blank spaces ' ' and null values. 

![](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%232-%20Pizza%20Runner/screenshort_used/Screenshot%202025-01-27%20141133.png?raw=true)

### Now I have to clean the data:
- Remove the unnecessary null values in form of text in exclusions and extras column and replace it with space ' '.

```sql
update customer_orders
set exclusions=case when lower(exclusions)='null' or exclusions is null then ' ' else exclusions end;

update customer_orders
set extras=case when lower(extras)='null' or extras is null then ' ' else extras end;
```
This is how a clean table look like
![](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%232-%20Pizza%20Runner/screenshort_used/Screenshot%202025-01-27%20142216.png?raw=true)
****
## Table: runner_orders

### Looking at runner_orders we see that there are

- In the pickup_time there is null in text format.
- distance column contain km and nulls.
- cancellation column contain nulls.
![](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%232-%20Pizza%20Runner/screenshort_used/Screenshot%202025-01-27%20143056.png?raw=true)

Our course of action to clean the table:
- Remove the km and replace null with space ' '.
- Remove the all format of minutes and replace null with ' '.
- In cancellation column replace null with ' '.

``` sql
update runner_orders
set distance = case when (distance is null) or (lower(distance)='null') then ' '
                    when distance like '%km' then trim(both 'km' from distance)
                    else distance end;


update runner_orders
set duration=case when (duration is null) or lower(duration)='null' then ' '
                  when lower(duration) like '%minutes' then trim(both 'minutes' from duration)
                  when lower(duration) like '%mins' then trim(both 'mins' from duration)
                  when lower(duration) like '%minute' then trim(both 'minute' from duration)
                  else duration end
                  ;
update runner_orders
set cancellation=case when cancellation is null or lower(cancellation)='null' or cancellation = '' then ' '
                      else cancellation end; 
update runner_orders
set pickup_time=case when pickup_time is null or lower(pickup_time)='null' then ' ' else
pickup_time end;

```
Our table now look like this-:

![](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%232-%20Pizza%20Runner/screenshort_used/Screenshot%202025-01-27%20143443.png?raw=true)

***
Question and Solution:

## A. Pizza Metrics

### 1. How many pizzas were ordered?
``` sql
select count(pizza_id) as total_pizzas_ordered from customer_orders;
```

#### Answer:
| total_pizzas_ordered |
| -------------------- |
|   14                 |

- Total 14 pizzas were ordered.

### 2. How many unique customer orders were made?
```sql
select count(distinct order_id) as total_unique_customer from customer_orders;
```

#### Answer:
| total_unique_customer|
| -------------------- |
|   10                 |

- There are 10 unique customer orders.

### 3.How many successful orders were delivered by each runner?
```sql
select runner_id,sum(case when cancellation is null or cancellation=' 'then 1 else 0 end)
as total_successful_orders
 from runner_orders
 group by 1;
 ```

 #### Answer:
 | runner_id | total_successful_orders  |
 | --------- | -----------------------  |
 |    1      |      4                   |
 |    2      |      3                   |
 |    3      |      1                   |

 - Runner with runner id 1 has 4 successful delivered orders.
 - Runner with runner id 2 has 3 successful delivered orders.
 - Runner with runner id 3 has 1 successful delivered orders.

 ### 4. How many of each type of pizza was delivered?
 ```sql
  select customer_orders.pizza_id,pizza_names.pizza_name,sum(case when runner_orders.cancellation=' ' then 1 else 0 end)
 as total_number_of_pizza_delivered
 from customer_orders
 inner join runner_orders
 on runner_orders.order_id=customer_orders.order_id
 inner join pizza_names
 on pizza_names.pizza_id=customer_orders.pizza_id
 group by 1,2;
 ```

 #### Answer:
 | pizza_id | pizza_name   | total_number_of_pizza_delivered |
 | -------- | ----------   | ------------------------------- |
 |    1     |  Meatlovers  |      9                          |
 |    2     |  Vegetarian  |      3                          |

 - There are 8 Meatlovers and 3 Vegetarian

 ### 5. How many Vegetarian and Meatlovers were ordered by each customer?**

 ``` sql
  select customer_orders.customer_id,
 sum(case when lower(pizza_name)='meatlovers' then 1 else 0 end) as Meatlovers_ordered,
 sum(case when lower(pizza_name)='vegetarian' then 1 else 0 end) as Vegetarian_ordered
 from customer_orders
 inner join pizza_names
 on pizza_names.pizza_id=customer_orders.pizza_id
 group by 1;
 ```
 #### Answer:
| customer_id | Meatlovers_ordered | Vegetarian_ordered |
| ----------- | ------------------ | ------------------ |
|   101       |    2               |    1               |
|   102       |    2               |    1               |
|   103       |    3               |    1               |
|   104       |    3               |    0               |
|   105       |    0               |    1               |

- Customer 101 ordered 2 meatlovers Pizzas and 1 Vegetarian pizza.
- Customer 102 ordered 2 meatlovers Pizzas and 1 Vegetarian pizza.
- Customer 103 ordered 2 meatlovers Pizzas and 1 Vegetarian pizza.
- Customer 104 ordered 3 meatlovers Pizzas.
- Customer 105 ordered 1 Vegetarian pizza.

### 6.What was the maximum number of pizzas delivered in a single order?
```sql
 with final_table as (
 select *,dense_rank() over(order by total_orders desc) as rnk from (
 select customer_orders.order_id,count(customer_orders.pizza_id) as total_orders
 from customer_orders
 group by 1) as temp_table)
 select order_id,total_orders from final_table
 where rnk=1;
 ```
  ### Answer:
  | order_id | total_orders |
  | -------- | ------------ |
  |   4      |    3         |

  - 3 is the maximum number of pizza delivered in a single order , order id is 4.


### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

``` sql
Select customer_id,sum(case when (trim(exclusions) != '' or trim(extras) != '') then 1 else 0 end) as atleast_1_change,
sum(case when (TRIM(exclusions) = '' AND TRIM(extras) = '') THEN 1 else 0 end) as No_change
from 
    (select customer_orders.* 
     from customer_orders 
     inner join runner_orders on customer_orders.order_id = runner_orders.order_id
     where cancellation = '' or cancellation = ' ') as temp
group by customer_id;
```
| customer_id | atleast_1_change | No_change |
| ----------- | ---------------- | --------- |
|   101       |     0            |   2       |
|   102       |     0            |   3       |
|   103       |     3            |   0       |
|   104       |     2            |   1       |
|   105       |     1            |   0       |

- Customer 101 has 102 likes their pizzas as per standard recipe.
- Customer 102 , 104 and 105 have their own preference for pizza topping.

### 8. How many pizzas were delivered that had both exclusions and extras?
``` sql
select sum(case when trim(exclusions)!='' and trim(extras)!='' then 1 else 0 end)
as pizzas_with_exclusion_and_extras
from customer_orders
inner join 
runner_orders
on runner_orders.order_id=customer_orders.order_id
where trim(cancellation)='';
```

#### Answer:
| pizzas_with_exclusion_and_extras |
| -------------------------------- |
|         1                        |

- Only 1 pizza ordered that had both exclusion and extra topping.

### 9. What was the total volume of pizzas ordered for each hour of the day?
```sql
select time_hour,count(pizza_id) as total_order_in_each_hour from (
select customer_orders.*,hour(time(order_time)) as time_hour
from customer_orders) as temp
group by 1
order by 1;
```
| time_hour | total_order_in_each_hour |
| --------- | ------------------------ |
|   11      |         1                |
|   13      |         3                |
|   18      |         3                |
|   19      |         1                |
|   21      |         3                |
|   23      |         3                |

- Lowest volume of pizzas ordered is at 11(11:00 am) and 19(7::00 pm).
- Highest volume of pizza ordered is at 13(1:00 pm),18(6:00 pm),21(9:00 pm) and 23(11:00 pm).

### 10. What was the volume of orders for each day of the week?
``` sql
select date_format((order_time),'%a') as week_day,count(order_id) as total_order
from customer_orders
group  by 1
order by 1;
```

#### Answer:
| week_day | total_order |
| -------- | ----------- |
| Fri      |   1         |
| Sat      |   5         |
| Thu      |   3         |
| Wed      |   5         |

- Highest volume of order take place in Saturday and wednesday.
- Lowest volume of order take place in Friday.

***
# Runner and Customer Experience

### 1.  How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
``` sql
select floor(datediff(registration_date,'2021-01-01')/7) +1 as week_number,count(runner_id) as number_of_signup
from runners
group by 1;
```

| week_number | number_of_signup |
| ----------- | ---------------- |
|    1        |    2             |
|    2        |    1             |
|    3        |    1             |

- Maximum number of signup happened in 1st week. perhaps due to the discount and advertising.

### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
``` sql
with temp as(select distinct pickup_time,order_time,timestampdiff(minute,order_time,pickup_time) as min_taken
from customer_orders
inner join runner_orders
on runner_orders.order_id=customer_orders.order_id
where lower(pickup_time)!='null')
select round(avg(min_taken),1) as average_time_to_pickup from temp;
```
| average_time_to_pickup |
| ---------------------- |
|      15.6              |

- average time to pickup an order is 15.6 minute.

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
``` sql
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
```
##### Assumption: I am considering the runner pickup the order when the order was picked jut after the order was ready.

| count_orders | average_time_taken |
| ------------ | ------------------ |
|     1        |     12.0           |
|     2        |     18.0           |
|     3        |     29.0           |

- From the result we can say that if the number of order is more then the time taken to prepare will be more.

### 4. Is there any relationship between the number of pizzas and how long the order takes to prepare?
``` sql
select customer_orders.customer_id,round(avg(runner_orders.distance),1) as avg_distance from 
customer_orders inner join
runner_orders
on runner_orders.order_id=customer_orders.order_id
where distance!=0
group by 1;
```

- Assumption: Assuming that distance is calculated from Pizza Runner HQ to customer’s place.

| customer_id | avg_distance |
| ----------- | ------------ |
|  101        |  20          |
|  104        |  16.7        |
|  103        |  23.4        |
|  104        |  10          |
|  105        |  25          |

- Customer 104 stays the nearest to Pizza Runner HQ at average distance of 10km, whereas Customer 105 stays the furthest at 25km.

### 5. What was the difference between the longest and shortest delivery times for all orders?

``` sql
select max(duration)-min(duration) as difference_between_max_and_min_delivery_time
from customer_orders
inner join 
runner_orders
on runner_orders.order_id=customer_orders.order_id
where distance!=0;
```

| difference_between_max_and_min_delivery_time |
| -------------------------------------------- |
|           30                                 |

- The difference between maximum and minimum delivery time is 30 min.

### 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?

```sql
select runner_orders.runner_id,customer_orders.customer_id,customer_orders.order_id,
runner_orders.distance,runner_orders.duration,
round(avg(distance*60/duration),2) as speed
from runner_orders
inner join 
customer_orders
on customer_orders.order_id=runner_orders.order_id
where trim(cancellation)=''
group by 1,2,3,4,5;
```
![](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%232-%20Pizza%20Runner/screenshort_used/Screenshot%202025-01-27%20215227.png?raw=true)

- Runner 1 average speed varies from 37.5 km/h to 60 km/h.
- Runner 2 average speed varies from 35.1 km/h to 60 km/h.
- Runner 3 average speed varies from 40 km/h to 60 km/h.

### 7. What is the successful delivery percentage for each runner?
```sql
SELECT 
    runner_orders.runner_id ,
    round((SELECT COUNT(order_id) 
     FROM runner_orders r2 
     WHERE r2.runner_id = runner_orders.runner_id and trim(r2.cancellation)='') * 100 / COUNT(1),2) AS percentage_success
FROM runner_orders
GROUP BY runner_orders.runner_id;
```

| runner_id | percentage_success |
| --------- | ------------------ |
|    1      |    100.00          |
|    2      |    75.00           |
|    3      |    50.00           |

- The successful delivery of runner with id 1 is 100%.
- The successful delivery of runner with id 2 is 75%.
- The sucessful delivery of runner with id 3 is 50%.

# C. Ingredient Optimisation

### 1. What are the standard ingredients for each pizza?
```sql
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
```

![](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%232-%20Pizza%20Runner/screenshort_used/Screenshot%202025-01-27%20220213.png?raw=true)

### 2. What was the most commonly added extra?
```sql
with recursive extras_inclusion as(
select order_id,trim(substring_index(extras,',',1)) as extras_id,
substring(extras,length(substring_index(extras,',',1))+2) as remaining_extras
from customer_orders
where extras is not null and extras!=''
union all
select eo.order_id,trim(substring_index(eo.remaining_extras,',',1)) as extras_id,
substring(eo.remaining_extras,length(substring_index(eo.remaining_extras,',',1))+2) as remaining_extras 
from extras_inclusion as eo
where eo.remaining_extras!='' and eo.remaining_extras is not null)
,temp_table as(
select extras_id,count(order_id) as total_count from extras_inclusion
where trim(extras_id)!='' and lower(extras_id)!='null' and lower(extras_id) is not NULL
group by 1
order by 2 desc)
select extras_id,total_count,topping_name
from temp_table
inner join 
pizza_toppings on topping_id=extras_id;
```

| extras_id | total_count | topping_name |
| --------- | ----------- | ------------ |
|     1     |     4       |  Bacon       |
|     5     |     1       |  Chicken     |
|     4     |     1       |  Cheese      | 

- Bacon is the most commonly extra added.

### 4. What was the most common exclusion?
```sql
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
```

| exclusion_id | topping_name | total_count |
| ------------ | ------------ | ----------- |
|    4         |  Cheese      |   4         |
|    2         |  BBQ Souce   |   1         |
|    6         |  Mushrooms   |   1         |

- Cheese is the most commom exclusion in the orders.

### 5. Generate an order item for each record in the customers_orders table in the format of one of the following:
 - Meat Lovers
 - Meat Lovers - Exclude Beef
 - Meat Lovers - Extra Bacon
``` sql
select *,case when pizza_id=1 then 'Yes' else 'No' end as meat_lover
,case when pizza_id=1 and exclusions not like '%3,%' then 'No' 
      when pizza_id!=1 then '-'
      when pizza_id=1 and exclusions like '%3,%' then 'Yes'
      else 'Yes'
      end
      as meat_lover_excludes_beef,
case when extras like '%1,%' then 'Yes' else 'No' end as extra_bacon
from customer_orders;
```

![](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%232-%20Pizza%20Runner/screenshort_used/Screenshot%202025-01-27%20221332.png?raw=true)

****
# D.  Pricing and Ratings

#### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
```sql
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
```

| runner_id | total_earning |
| --------- |  ------------ |
|   1       |     70        |
|   2       |     56        |
|   3       |     12        |

- The runner with id=1 earn 70$.
- The runner with id=2 earn 56$.
- The runner with id=3 earn 12$.

#### 2. What if there was an additional $1 charge for any pizza extras?
- Add cheese is $1 extra
```sql
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
select runner_id,total_earning+total_earn as total_earning
from main_pizza_table;
```
| runner_id | total_earning |
| --------- |  ------------ |
|   1       |     70        |
|   2       |     57        |
|   3       |     13        | 

- The runner with id=1 earn 72$.
- The runner with id=2 earn 57$.
- The runner with id=3 earn 13$.

#### 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.

```sql
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
```
| order_id | runner_id | rating |
| -------- | --------- | ------ |
|   1      |    1      |    3   |
|   2      |    1      |    3   |
|   3      |    1      |    2   |
|   3      |    1      |    2   |
|   4      |    2      |    1   |
|   4      |    2      |    1   |
|   4      |    2      |    1   |
|   5      |    3      |    3   |
|   7      |    2      |    3   |
|   8      |    2      |    2   |
|   10     |    1      |    2   |
|   10     |    1      |    2   |

#### 4. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
```sql
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
```
| runner_id | net_income |
| --------- | ---------- |
|     1     |   38.3     |
|     2     |   20.1     |
|     3     |    7       |

- The net income of runner with id=1 is 38.3$.
- The net income of runner with id=2 is 20.1$.
- The net income of runner with id=3 is 7$.














