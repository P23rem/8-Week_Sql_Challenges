
# Case Study #1 - Danny's Diner


![Logo](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%231-%20Danny%20Diner/Pictures_used_for_readme_file/danny_diner_logo.png?raw=true)


## Content

- Business Task

- Entity Relationship Diagram

- Question and Solution

All the dataset and information regarding the case study has been sourced from the following link : [here](https://8weeksqlchallenge.com/case-study-1/)


## Task

Danny wants to use data to answer some question about his customer like how much money they have spent and also the most purchased item etc.


## Entity Relationship Diagram

![ERD Diagram](https://github.com/P23rem/8-Week_Sql_Challenges/blob/main/Case%20Study%20%231-%20Danny%20Diner/Pictures_used_for_readme_file/Screenshot%202025-01-25%20001037.png?raw=true)


## Question and Solution

**1. What is the total amount each customer spent at the restaurant?**

```sql
select sales.customer_id,sum(menu.price) as total_amount_spend
from sales
inner join 
menu
on menu.product_id=sales.product_id
group by sales.customer_id
order by 2 desc;
```

#### Answer:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | 76          |
| B           | 74          |
| C           | 36          |

- Customer A spent $76.
- Customer B spent $74.
- Customer C spent $36.
***

**2. How many days has each customer visited the restaurant?**

```sql
select customer_id,count(distinct order_date) as total_visit
from sales
group by customer_id;
```
#### Answer:
| customer_id | total_visit |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |

- Customer A visited 4 times.
- Customer B visited 6 times.
- Customer C visited 2 times.
 
 ***
 

 **3. What was the first item from the menu purchased by each customer?**

 ```sql
 with temp_table as(
select sales.customer_id,sales.product_id,menu.product_name,sales.order_date
from sales
inner join 
menu on 
menu.product_id=sales.product_id)
select distinct customer_id,product_id,product_name from (
select *,dense_rank() over(partition by customer_id order by order_date asc) as rnk
from temp_table) as temp2_table
where rnk=1;
```
- Assumption-  i have consider that the products which are ordered in same date is ordered together

## Answer:
| customer_id | product_id | product_name |
| ----------- | ---------- | ------------ |
|    A        |    1       |    sushi     |
|    A        |    2       |    curry     |
|    B        |    2       |    curry     |
|    C        |    3       |    ramen     |

- A ordered sushi and curry first.
- B ordered curry first.
- C ordered ramen first.



**4. What is the most purchased item on the menu and how many times was it purchased by all customers?**

```sql
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
```
### Answer:
| product_id | product_name | total_order |
| ---------- | ------------ | ----------- |
|   3        |  ramen       |   8         |

- Most purchases item on menu is ramen which is purchased 8 times.

****
**5.Which item was the most popular for each customer?**


```sql
with temp1_table as(
select temp.*,dense_rank() over(partition by temp.customer_id order by total_order desc) as rnk
from (
select sales.customer_id,sales.product_id,count(customer_id) as total_order
from sales
group by 1,2) as temp)
select temp1_table.customer_id,temp1_table.product_id,temp1_table.total_order,menu.product_name
from temp1_table
inner join menu
on menu.product_id=temp1_table.product_id
where temp1_table.rnk=1
order by temp1_table.customer_id;
```
## Answer:

| customer_id | product_id | total_order | product_name |
| ----------- | ---------- | ----------- | ------------ |
|     A       |      3     |      3      |    ramen     |
|     B       |      2     |      2      |    curry     |
|     B       |      1     |      2      |    sushi     |
|     B       |      3     |      2      |    ramen     |
|     C       |      3     |      3      |    ramen     |

- The most purchased item for customer A is ramen.
- Customer B has ordered ramen,curry and sushi equal number of times.
- Ramen is mostly ordered by Customer C.
***

**6.Which item was purchased first by the customer after they became a member?**

```sql 
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
```

## Answer
| customer_id | product_id | product_name |
| ----------- | ---------- | ------------ |
|    A        |    3       |    ramen     |
|    B        |    1       |    sushi     |

- Customer A ordered ramen first after becoming a member.
- Customer B ordered sushi first after becoming a member. 
- Customer C is yet to become a member.
***


**7.Which item was purchased just before the customer became a member?**
 

``` sql
with temp_table as(select temp.*,dense_rank() over(partition by customer_id order by order_date desc) as rnk from (
select sales.* from sales
inner join members
on members.customer_id=sales.customer_id
and sales.order_date<members.join_date) as temp)
select temp_table.customer_id,temp_table.product_id,menu.product_name
from temp_table
inner join 
menu on 
menu.product_id=temp_table.product_id
where rnk=1
order by customer_id;
```

## Answer:
| customer_id | product_id | product_name |
| ----------- | ---------- | ------------ |
|    A        |    1       |    sushi     |
|    B        |    1       |    sushi     |

- A ordered curry right before becoming a member.
- B ordered sushi right before becoming a member.
- C is not a member yet.
***

**8.What is the total items and amount spent for each member before they became a member?**

```sql 
select sales.customer_id,sum(menu.price) as total_spent
from sales
inner join 
menu on 
menu.product_id=sales.product_id
inner join members on 
members.customer_id=sales.customer_id
where sales.order_date < all(select join_date from members where members.customer_id=sales.customer_id)
group by 1;
```

# Answer:
| customer_id | total_spent |
| ----------- | ----------- |
|   A         |  25         |
|   B         |  40         |

- Customer A spent 25$.
- Customer B spent 40$.

***
**9.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?**

```sql
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
```

## Answer:
| customer_id | total_point |
| ----------- | ----------- |
|    A        |   1020      |
|    B        |   320       |

- The total point earned by customer A is 1020.
- The total point earned by customer B is 320.
***

## Bonus Question 

**Join All The Things**

* Recreate the table with: customer_id, order_date, product_name, price, member (Y/N)

* Rank All The Things 

* Danny also requires further information about the ```ranking``` of customer products, but he purposely does not need the ranking for non-member purchases so he expects null ```ranking``` values for the records when customers are not yet part of the loyalty program.

```sql 
WITH temp AS (
    SELECT 
        sales.customer_id,
        sales.product_id,
        sales.order_date,
        menu.product_name,
        CASE
            WHEN members.join_date <= sales.order_date THEN 'Y'
            ELSE 'N'
        END AS Members
    FROM sales
    LEFT JOIN members ON members.customer_id = sales.customer_id
    LEFT JOIN menu ON menu.product_id = sales.product_id
)
SELECT 
    *, 
    CASE 
        WHEN Members = 'Y' THEN 
            DENSE_RANK() OVER (PARTITION BY customer_id, Members ORDER BY order_date)
        ELSE 
            NULL 
    END AS ranking
FROM temp; 
```

## Answer:

#### Answer: 
| customer_id | order_date | product_name |  Members | ranking | 
| ----------- | ---------- | -------------| -------- | ------- |
| A           | 2021-01-01 | sushi        | N        | NULL    |
| A           | 2021-01-01 | curry        | N        | NULL    |
| A           | 2021-01-07 | curry        | Y        | 1       |
| A           | 2021-01-10 | ramen        | Y        | 2       | 
| A           | 2021-01-11 | ramen        | Y        | 3       | 
| A           | 2021-01-11 | ramen        | Y        | 3       |
| B           | 2021-01-01 | curry        | N        | NULL    |
| B           | 2021-01-02 | curry        | N        | NULL    |
| B           | 2021-01-04 | sushi        | N        | NULL    |
| B           | 2021-01-11 | sushi        | Y        | 1       |
| B           | 2021-01-16 | ramen        | Y        | 2       |
| B           | 2021-02-01 | ramen        | Y        | 3       |
| C           | 2021-01-01 | ramen        | N        | NULL    |
| C           | 2021-01-01 | ramen        | N        | NULL    |
| C           | 2021-01-07 | ramen        | N        | NULL    |







