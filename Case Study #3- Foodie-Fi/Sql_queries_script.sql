use Foodie_Fi;
select * from plans;
select * from subscriptions;

/*Customer Journey*/
select customer_id,subscriptions.plan_id,start_date,plan_name,price
from subscriptions
inner join 
plans
on subscriptions.plan_id=plans.plan_id
where customer_id in (2,11,13,15,16,18,19)
order by customer_id;
/*
- "The customer with customer ID 2 started a trial subscription on 2020-09-20 and then converted the plan to Pro Annual, which cost him/her $199.00.".
- "The customer with customer ID 11 started a trial plan on 2020-11-19 and then decided not to take any plan, ultimately churning the subscription on 2020-11-26."
- The customer with customer ID 13 started a trial plan on 2020-12-15 and then  upgraded to basic monthly plan on 2020-12-22 and later he/her decided to take the pro monthly plan.
- The customer with customer ID 15 started a trial plan on 2020-03017 and then upgraded to pro monthly but later decided to churn the subscription plan on 2020-04-29.
- The customer with customer ID 16 started a trial plan on 2020-05-31 and then upgraded to basic monthly and then to pro annual plan on 2020-10-21.
- The customer with customer ID 18 started a trial plan on 2020-07-13 and then upgraded to pro monthly plan on 2020-06-22.
- The customer with customer ID 19 started a trial plan on 2020-06-22 and upgraded to pro monthly and later decide to upgrade it to pro annual plan on 2020-08-29.*/

/*1.How many customers has Foodie-Fi ever had?*/
select count(distinct customer_id) as total_customer
from subscriptions;

/*What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value*/
select month(start_date) as months,count(customer_id) as distribution_of_trial_plan
from subscriptions
inner join 
plans
on plans.plan_id=subscriptions.plan_id
where lower(plans.plan_name)='trial'
group by 1
order by 1;

/*What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name*/
select plans.plan_id,plans.plan_name,count(customer_id) as total_count
from subscriptions
inner join 
plans
on plans.plan_id=subscriptions.plan_id
where year(start_date)>2020
group by 1,2
order by 3 desc;

/*What is the customer count and percentage of customers who have churned rounded to 1 decimal place?*/
with temp as(
select *,row_number() over(partition by customer_id order by start_date) as rnk_order
from subscriptions
order by customer_id)
select count(customer_id) as total_customer,round(count(customer_id)*100/(select count(distinct customer_id) from subscriptions),1) as
percentage_of_customer_who_churned
from temp as temp2
where rnk_order=(select max(rnk_order) from temp where temp.customer_id=temp2.customer_id)
and plan_id=4;

/*How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?*/
select count(customer_id) as total_count,round(count(customer_id)*100/(select count(distinct customer_id) from subscriptions),0) as percentage_of_directly_churned_people
from (
select *,lead(plan_id) over(partition by customer_id order by start_date) as next_plan
from subscriptions) as temp
where plan_id=0 and next_plan=4;

/*What is the number and percentage of customer plans after their initial free trial?*/
select next_plan,count(customer_id) as total_count,round(count(customer_id)*100/(select count(distinct customer_id) from subscriptions),1)
as percent_conversion from (
select *,lead(plan_id) over(partition by customer_id order by start_date) as next_plan
from subscriptions) as temp
where next_plan is not null and
plan_id=0
group by 1;

/*What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?*/
select plan_id,count(customer_id) as total_count,round(count(customer_id)*100/(select count(distinct customer_id) from subscriptions),1)
as percent_conversion from (
select *,lead(start_date) over(partition by customer_id order by start_date) as next_start
from subscriptions 
where start_date<='2020-12-31') as temp
where next_start is null
group by 1;

/*How many customers have upgraded to an annual plan in 2020?*/
select count(customer_id) as total_customer
from (
select customer_id from subscriptions inner join plans on 
plans.plan_id=subscriptions.plan_id 
where lower(plan_name)='pro annual'
and start_date<='2020-12-31')
as temp;

/*How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?*/
select round(avg(datediff(temp.start_date,(select start_date from subscriptions where customer_id=temp.customer_id and plan_id=0 limit 1))),0) as average_days
from subscriptions as temp
where plan_id=3;

/*Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)*/
with recursive temp as(
select 1 as month_number
union all
select month_number+1
from temp
where month_number<12),temp2 as(
select month_number,month_number*floor(365/(12))-30 as lower_value,month_number*floor(365/12) as higher_value
from temp),table_of_cust_having_annual_plan as(
select customer_id,start_date 
from subscriptions
where plan_id=3),
table_of_cust_with_joining_date as(
select customer_id,start_date as joining_date
from subscriptions 
where plan_id=0),table_final as(
select a.customer_id,datediff(start_date,joining_date) as number_of_days
from table_of_cust_having_annual_plan as a
inner join 
table_of_cust_with_joining_date as b 
on a.customer_id=b.customer_id),final_table_with_bins as(
select customer_id,number_of_days,ceil(number_of_days/30) as order_of_bin
from table_final)
select concat(lower_value,'-',higher_value),count(customer_id) as total_customer
from final_table_with_bins
inner join 
temp2
on temp2.month_number=final_table_with_bins.order_of_bin
group by 1;

/*How many customers downgraded from a pro monthly to a basic monthly plan in 2020?*/
with temp as(
select customer_id,start_date,plan_id,lead(start_date) over(partition by customer_id order by start_date) as last_subscription_date 
from subscriptions),temp2 as(
select customer_id,start_date
from subscriptions
where plan_id=2 and year(start_date)<=2020),temp3 as(
select customer_id
from temp
where last_subscription_date is null and plan_id=3 and start_date<=2020)
select count(temp3.customer_id) as total_count
from temp3
inner join temp2
on temp2.customer_id=temp3.customer_id;

/*join all the table*/
CREATE TABLE payments_2020 (
    payment_id int primary key auto_increment,
    customer_id int not null,
    plan_id int not null,
    plan_name varchar(50) not null,
    payment_date date not null,
    amount decimal(10,2) not null,
    payment_order int not null
);
CREATE TABLE payments_2020 (
    customer_id INT NOT NULL,
    plan_id INT NOT NULL,
    plan_name VARCHAR(50) NOT NULL,
    payment_date DATE NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    payment_order INT NOT NULL
);
insert into payments_2020(customer_id,plan_id,plan_name,payment_date,amount,payment_order)
with recursive first_join as(
select customer_id,s.plan_id,plan_name,start_date,lead(start_date) over(partition by customer_id order by start_date,s.plan_id) as next_date
,price from subscriptions as s
inner join 
plans on plans.plan_id=s.plan_id),second_join as(
select customer_id,plan_id,plan_name,start_date,price,
case when next_date is null or next_date>'2020-12-31' then '2020-12-31' else next_date end as next_date1
from first_join
where plan_id not in (0,4)),third_join as
(select customer_id,plan_id,plan_name,start_date,price,next_date1 from second_join
union all 
select customer_id,plan_id,plan_name,date_add(start_date, interval 1 month) as start_date
,price,next_date1
from third_join
where start_date<next_date1 and plan_id!=3)
select customer_id,plan_id,plan_name,start_date,price,row_number() over(partition by customer_id order by start_date,plan_id) from third_join
where year(start_date)<=2020
order by customer_id,start_date;
select * from payments_2020
order by customer_id,payment_date;

/*How would you calculate the rate of growth for Foodie-Fi?*/
select round(sum(new_customer_2021)*100/sum(2020_customer_number),1) as growth_rate from(
select null as new_customer_2021,count(distinct customer_id) as 2020_customer_number
from subscriptions
where start_date<='2020-12-31'
union all
select count(distinct customer_id) as current_customer_2021,null as 2020_customer_number
from subscriptions
where year(start_date)=2021) as temp;

/*Calculating the growth rate based on increase in revenue over time.*/
select round(((total_revenue_in_2021-total_revenue_in_2020)*100)/total_revenue_in_2020,1) from 
(select sum(plans.price) as total_revenue_in_2020
from subscriptions 
inner join plans
on plans.plan_id=subscriptions.plan_id
where start_date<'2020-12-31') as temp1
inner join
(select sum(plans.price) as total_revenue_in_2021
from subscriptions 
inner join plans
on plans.plan_id=subscriptions.plan_id
where year(start_date)=2021) as temp2
on 1=1;
/*4. If the Foodie-Fi team were to create an exit survey shown to customers who wish to cancel their subscription, what questions would you include*/
/*
in the survey?

If Foodie-Fi were to create an exit survey shown to customers who wish to cancel their subscription, some questions that could be included in the survey are:

Why are you cancelling your subscription?
How satisfied were you with the content offered on Foodie-Fi?
Was the price of the subscription a deciding factor in your cancellation?
How was your experience with the Foodie-Fi platforms? Was it user-friendly?
Did you encounter any technical issues while using Foodie-Fi?
Did you find the content recomendation relevant and personalized to your interests?
Did you experience any issues with customer support during your subscription?
Would you consider re-subscribing to Foodie-Fi in the future?
How likely are you to recommend Foodie-Fi to a friend or family member?
Is there anything that Foodie-Fi could have done differently to prevent your cancellation?*/



