
-- Functions of this code:
    -- For every person, we get the latest check in date and the class they were at that time
    -- When multiple people have same first name, then we use last name. Otherwise we use first name
    -- We add a label to indicate whether we used first or last name as the main 'tagged' name

-- ASSUMPTION: 
    -- No 2 people can have same first and last name

select name, name_source,class,check_in_date from (
select distinct t1.name,
t1.name_source,
t1.class,
t1.check_in_date,
-- For every person, we get latest info from scan
row_number() over (partition by name order by check_in_date desc) as row_number
from

(
select
case when first_name in 
-- we use last name when multiple people have same first name
(select first_name from (
select first_name, count(*) as c_cnt from 
(select distinct first_name, last_name
from OCIC_DATA.compute_node_hardware_info)
group by first_name
having count(*) > 1)) then last_name
else first_name end as name,

-- same logic as above to add labels for name type
case when first_name in (select first_name from (
select first_name, count(*) as c_cnt from 
(select distinct first_name, last_name
from OCIC_DATA.compute_node_hardware_info)
group by first_name
having count(*) > 1)) then 'Last Name'
else 'First Name' end as name_source,

class,
check_in_date

from log -- table where data is stored
) t1)
where row_number = 1