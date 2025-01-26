use pizza_runner;
select * from runner_orders;
/* cleaning of data in runner_orders
1-in distance extract the numerical term and remove 'km'
2-in duration remove minutes,mins and extract only numerical value*/
update runner_orders
set distance = case when (distance is null) or (lower(distance)='null') then ' '
                    when distance like '%km' then trim(both 'km' from distance)
                    else distance end;

set sql_safe_updates=0;

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

select * from customer_orders;
update customer_orders
set exclusions=case when lower(exclusions)='null' or exclusions is null then ' ' else exclusions end;

update customer_orders
set extras=case when lower(extras)='null' or extras is null then ' ' else extras end;

select * from runner_orders;

select * from customer_orders;
create table temp_table as
select *,row_number() over(partition by order_id,customer_id,pizza_id,exclusions,extras,order_time) as rnk
from customer_orders;
delete from customer_orders;
insert into customer_orders
select order_id,customer_id,pizza_id,exclusions,extras,order_time from temp_table
where rnk=1;
drop table temp_table;

