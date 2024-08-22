1. Считаем общее количество покупателей из таблицы customers.
   Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк. 
SELECT 
COUNT(customer_id) as customers_count 
FROM customers
;

   ИТОГ: customers_count 19759