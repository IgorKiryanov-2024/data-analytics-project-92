1. Считаем общее количество покупателей из таблицы customers.
   Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк. 
     SELECT 
     COUNT(customer_id) as customers_count 
     FROM customers;

2.1. Первый отчет о десятке лучших продавцов.
    select
          employees.first_name||' '||employees.last_name as seller,
    count(employee_id) as operations, --Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк.
    ROUND(SUM(quantity * price),0) as income --Используем агрегирующий оператор SUM - SQL функция используется для суммирования строк (количество умножаем на цену товара). Оператор ROUND - для округления чисел
    from sales
         LEFT join customers on customers.customer_id = sales.customer_id
         LEFT join products  on products.product_id = sales.product_id
         LEFT join employees on employees.employee_id = sales.sales_person_id
    group by 1
    order by SUM(quantity * price) DESC
    limit 10;
 2.2. Второй отчет содержит информацию о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам. Таблица отсортирована по выручке по возрастанию.
    select
          employees.first_name||' '||employees.last_name as seller,
    ROUND(AVG(quantity * price),0) as average_income --Используем агрегирующий оператор AVG - SQL функция используется для подсчета среднего значения (количество умножаем на цену товара). Оператор ROUND - для округления чисел
    from sales
         LEFT join products on products.product_id = sales.product_id
         LEFT join employees on employees.employee_id = sales.sales_person_id
    group by 1
    having AVG(quantity * price) < (select AVG(quantity * price) from sales LEFT join products on products.product_id = sales.product_id) --Используем агрегирующий оператор having для дополнительной группировки после group by
    order by 2;
 2.3. Третий отчет содержит информацию о выручке по дням недели.
    select
          employees.first_name||' '||employees.last_name as seller,
          to_char(sales.sale_date, 'day') as day_of_week, --Оператор To_char - преобразование даты в день недели
    ROUND(SUM(quantity * price),0) as income
    from sales
    LEFT join products on products.product_id = sales.product_id
    LEFT join employees on employees.employee_id = sales.sales_person_id
    group by EXTRACT(isodow from sales.sale_date), 1, 2 -- Оператор Extract необходим для преобразование текста даты в число
    order by EXTRACT(isodow from sales.sale_date), 2, 1;
