# Домашнее задание к занятию "`Работа с данными (DDL/DML)`" - `Мамонтов Александр`


### Задание 1.

Напишите запрос к учебной базе данных, который вернёт процентное отношение общего размера всех индексов к общему размеру всех таблиц.

    select CONCAT(ROUND((sum(t.INDEX_LENGTH) * 100) / (sum(t.DATA_LENGTH) + sum(t.INDEX_LENGTH)), 2), ' %') as "result"
    from
    (SELECT t.DATA_LENGTH, t.INDEX_LENGTH 
    from information_schema.TABLES t 
    where TABLE_SCHEMA = 'sakila') t

### Задание 2. 

Выполните explain analyze следующего запроса:

    select distinct concat(c.last_name, ' ', c.first_name), sum(p.amount) over (partition by c.customer_id, f.title)
    from payment p, rental r, customer c, inventory i, film f
    where date(p.payment_date) = '2005-07-30' and p.payment_date = r.rental_date and r.customer_id = c.customer_id and i.inventory_id = r.inventory_id

# перечислите узкие места

![Скриншот-1](https://github.com/Zzeting/relationbd-hw-3/blob/main/img/1.PNG)

Узкие места:
- отсутствие join
- оконная функция
- distinct

# оптимизируйте запрос: внесите корректировки по использованию операторов, при необходимости добавьте индексы

    CREATE INDEX idx_payment_d ON payment(payment_date)

    explain analyze
    select concat(c.last_name, ' ', c.first_name), sum(p.amount)
    from payment p 
    join rental r ON r.rental_id = p.rental_id
    join customer c ON p.customer_id = c.customer_id 
    where date(p.payment_date) >= '2005-07-30' and date(p.payment_date) < DATE_ADD('2005-07-30', INTERVAL 1 DAY)
    GROUP BY c.customer_id 

    
![Скриншот-2](https://github.com/Zzeting/relationbd-hw-3/blob/main/img/2.PNG)


### Задание 3. 

Самостоятельно изучите, какие типы индексов используются в PostgreSQL. Перечислите те индексы, которые используются в PostgreSQL, а в MySQL — нет.

Приведите ответ в свободной форме.

Индекс по частичному соответствию (Partial Index): в PostgreSQL вы можете создать индекс только для строк, которые удовлетворяют определенному условию. Это позволяет сократить размер индекса и улучшить производительность запросов, которые используют этот индекс.

Индекс сортировки NULL (NULLS FIRST / NULLS LAST Index): в PostgreSQL вы можете указать, как будут сортироваться NULL значения в индексе. Это полезно, когда вам нужно отсортировать данные в определенном порядке, например, сначала NULL значения, а затем не-NULL значения.

Индекс функции (Functional Index): в PostgreSQL вы можете создать индекс на основе выражения или функции, а не только на столбце. Это позволяет вам создавать индексы для вычисляемых значений или применять функции к столбцам во время поиска.

Индекс на массив (Array Index): в PostgreSQL вы можете создать индекс на столбец с типом данных массива. Это позволяет эффективно искать значения в массиве и улучшить производительность запросов, связанных с массивами.

