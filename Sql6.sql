# 1 Problem 1 : Game Play Analysis II (https://leetcode.com/problems/game-play-analysis-ii/)

# Solution1
with cte as
(
    select player_id, device_id, row_number() over(partition by player_id order by event_date) as ranks
    from Activity
)
select player_id, device_id 
from cte
where ranks = 1

# Solution2
with cte as
(
    select player_id, device_id, rank() over(partition by player_id order by event_date) as ranks
    from Activity
)
select player_id, device_id 
from cte
where ranks = 1

# Solution3
with cte as
(
    select player_id, device_id, dense_rank() over(partition by player_id order by event_date) as ranks
    from Activity
)
select player_id, device_id 
from cte
where ranks = 1

# Solution4
select a.player_id, a.device_id
from Activity a
where a.event_date in
    (
        select min(b.event_date)
        from Activity b
        where a.player_id = b.player_id
    )

# Solution5
select distinct(player_id), 
first_value(device_id) over(partition by player_id order by event_date ) as device_id
from Activity

# Solution6
select distinct(player_id), 
last_value(device_id) over(partition by player_id order by event_date desc range between unbounded preceding and unbounded following) as device_id
from Activity

# Solution7
select a1.player_id, a1.device_id
from Activity a1
where (a1.player_id, event_date) in 
    (
        select a2.player_id, min(event_date)
        from Activity a2
        group by a2.player_id
    )

# Solution8
with cte as
(
    select a.player_id, min(a.event_date) as event_date
    from Activity a
    group by a.player_id
)
select a1.player_id, a1.device_id
from Activity a1
join cte c
on a1.player_id = c.player_id
and a1.event_date = c.event_date

# 2 Problem 2 : Game Play Analysis III (https://leetcode.com/problems/game-play-analysis-iii/)

# Solution1
select player_id, event_date, 
    sum(games_played) over(partition by player_id order by event_date) as games_played_so_far
from Activity

# Solution2
select a1.player_id, a1.event_date,
    (
        select ifnull(sum(a2.games_played), 0)
        from Activity a2 
        where a1.player_id = a2.player_id 
        and a2.event_date <= a1.event_date
    ) as games_played_so_far 
from Activity a1

# 3 Problem 3 : Shortest Distance in a Plane (https://leetcode.com/problems/shortest-distance-in-a-plane/)

# Solution1
select round(sqrt(min(power(p2.x - p1.x, 2) + power(p2.y - p1.y, 2))), 2) as shortest
from Point2D p1
join Point2D p2  
on p1.x != p2.x or p1.y != p2.y

# Solution2
select round(sqrt(min(power(p2.x - p1.x, 2) + power(p2.y - p1.y, 2))), 2) as shortest
from Point2D p1
join Point2D p2  
on p1.x <= p2.x and p1.y < p2.y
or p1.x <= p2.x and p1.y > p2.y
or p1.x > p2.x and p1.y = p2.y

# 4 Problem 4 : Combine Two Tables (https://leetcode.com/problems/combine-two-tables/)

#Solution1
select p.firstName, p.lastName, a.city, a.state
from Person p
left join Address a
on p.personId = a.personId

# Solution2
select p.firstName, p.lastName, a.city, a.state
from Address a
right join Person p
on p.personId = a.personId

# 5 Problem 5 : Customers with Strictly Increasing Purchases (https://leetcode.com/problems/customers-with-strictly-increasing-purchases/)

# Solution
with cte as
(
    select customer_id, Year(order_date) as order_date, sum(price) as total_price
    from Orders
    group by customer_id, Year(order_date)
    order by customer_id, Year(order_date)
)
select c1.customer_id
from cte c1
left join cte c2
on c1.customer_id = c2.customer_id
and c1.order_date + 1 = c2.order_date 
and c1.total_price < c2.total_price
group by c1.customer_id
having count(*) - count(c2.customer_id) = 1