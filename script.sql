
select CONCAT(ROUND((sum(t.INDEX_LENGTH) * 100) / (sum(t.DATA_LENGTH) + sum(t.INDEX_LENGTH)), 2), ' %') as "result"
from
(SELECT t.DATA_LENGTH, t.INDEX_LENGTH 
from information_schema.TABLES t 
where TABLE_SCHEMA = 'sakila') t;


explain analyze
select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id and i.inventory_id = r.inventory_id;

-- -> Limit: 200 row(s)  (cost=0..0 rows=0) (actual time=6396..6397 rows=200 loops=1)
--     -> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=6396..6396 rows=200 loops=1)
--         -> Temporary table with deduplication  (cost=0..0 rows=0) (actual time=6396..6396 rows=391 loops=1)
--             -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id,f.title )   (actual time=2993..6191 rows=642000 loops=1)
--                 -> Sort: c.customer_id, f.title  (actual time=2993..3066 rows=642000 loops=1)
--                     -> Stream results  (cost=21.7e+6 rows=16e+6) (actual time=1.81..2007 rows=642000 loops=1)
--                         -> Nested loop inner join  (cost=21.7e+6 rows=16e+6) (actual time=1.74..1660 rows=642000 loops=1)
--                             -> Nested loop inner join  (cost=20.1e+6 rows=16e+6) (actual time=1.65..1456 rows=642000 loops=1)
--                                 -> Nested loop inner join  (cost=18.5e+6 rows=16e+6) (actual time=1.53..1199 rows=642000 loops=1)
--                                     -> Inner hash join (no condition)  (cost=1.58e+6 rows=15.8e+6) (actual time=1.33..57.7 rows=634000 loops=1)
--                                         -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1.65 rows=15813) (actual time=0.385..10.4 rows=634 loops=1)
--                                             -> Table scan on p  (cost=1.65 rows=15813) (actual time=0.334..7.93 rows=16044 loops=1)
--                                         -> Hash
--                                             -> Covering index scan on f using idx_title  (cost=112 rows=1000) (actual time=0.35..0.695 rows=1000 loops=1)
--                                     -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=0.969 rows=1.01) (actual time=0.0011..0.00165 rows=1.01 loops=634000)
--                                 -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=250e-6 rows=1) (actual time=188e-6..247e-6 rows=1 loops=642000)
--                             -> Single-row covering index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=250e-6 rows=1) (actual time=131e-6..156e-6 rows=1 loops=642000)


explain analyze
select concat(c.last_name, ' ', c.first_name), sum(p.amount)
from payment p 
join rental r ON r.rental_id = p.rental_id
join customer c ON p.customer_id = c.customer_id 
where date(p.payment_date) = '2005-07-30'
GROUP BY c.customer_id;

CREATE INDEX idx_payment_date ON payment((date(payment_date)));


-- -> Limit: 200 row(s)  (actual time=3.23..3.26 rows=200 loops=1)
--     -> Table scan on <temporary>  (actual time=3.23..3.25 rows=200 loops=1)
--         -> Aggregate using temporary table  (actual time=3.23..3.23 rows=391 loops=1)
--             -> Nested loop inner join  (cost=580 rows=634) (actual time=0.266..2.72 rows=634 loops=1)
--                 -> Nested loop inner join  (cost=358 rows=634) (actual time=0.261..2.12 rows=634 loops=1)
--                     -> Filter: (p.rental_id is not null)  (cost=136 rows=634) (actual time=0.248..1.59 rows=634 loops=1)
--                         -> Index lookup on p using pay_dates (cast(payment_date as date)='2005-07-30')  (cost=136 rows=634) (actual time=0.247..1.55 rows=634 loops=1)
--                     -> Single-row index lookup on c using PRIMARY (customer_id=p.customer_id)  (cost=0.25 rows=1) (actual time=662e-6..686e-6 rows=1 loops=634)
--                 -> Single-row covering index lookup on r using PRIMARY (rental_id=p.rental_id)  (cost=0.25 rows=1) (actual time=775e-6..799e-6 rows=1 loops=634)
-- 
