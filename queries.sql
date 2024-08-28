1. Считаем общее количество покупателей из таблицы customers.
   Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк. 
     SELECT 
     COUNT(customer_id) as customers_count 
     FROM customers;

2.1. Первый отчет о десятке лучших продавцов.
    select
          employees.first_name||' '||employees.last_name as seller,
    count(employee_id) as operations, --Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк.
    FLOOR(SUM(quantity * price)) as income --Используем агрегирующий оператор SUM - SQL функция используется для суммирования строк (количество умножаем на цену товара). Оператор FLOOR - для округления целого числа
    from sales
         LEFT join customers on customers.customer_id = sales.customer_id
         LEFT join products  on products.product_id = sales.product_id
         LEFT join employees on employees.employee_id = sales.sales_person_id
    group by 1
    order by SUM(quantity * price) DESC
    limit 10;
 2.2. Второй отчет - информация о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
    select
          employees.first_name||' '||employees.last_name as seller,
    FLOOR(AVG(quantity * price)) as average_income --Используем агрегирующий оператор AVG - SQL функция используется для подсчета среднего значения (количество умножаем на цену товара). Оператор ROUND - для округления чисел
    from sales
         LEFT join products on products.product_id = sales.product_id
         LEFT join employees on employees.employee_id = sales.sales_person_id
    group by 1
    having AVG(quantity * price) < (select AVG(quantity * price) from sales LEFT join products on products.product_id = sales.product_id) --Используем агрегирующий оператор having для дополнительной группировки после group by
    order by 2;
 2.3. Третий отчет - информация о выручке по дням недели.
    select
          employees.first_name||' '||employees.last_name as seller,
          to_char(sales.sale_date, 'day') as day_of_week, --Оператор To_char - преобразование даты в день недели
    FLOOR(SUM(quantity * price)) as income
    from sales
    LEFT join products on products.product_id = sales.product_id
    LEFT join employees on employees.employee_id = sales.sales_person_id
    group by EXTRACT(isodow from sales.sale_date), 1, 2 -- Оператор Extract необходим для преобразование текста даты в число
    order by EXTRACT(isodow from sales.sale_date), 2, 1;
   
 3.1. Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
    select
     case --оператор позволяет осуществить проверку условий и возвратить в зависимости от выполнения того или иного условия тот или иной результат.
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    COUNT(*) as age_count --Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк.
    from customers
    group by age_category
    order by age_category;
 3.2. Второй отчет - данные по количеству уникальных покупателей и выручке, которую они принесли.
   select
   to_char(sales.sale_date, 'YYYY-MM') as date,  --Оператор To_char - преобразование даты в день недели
   count(distinct sales.customer_id) as total_customers, --Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк.
   FLOOR(SUM(quantity * price)) as income  --Используем агрегирующий оператор SUM - SQL функция используется для суммирования строк (количество умножаем на цену товара). Оператор ROUND - для округления чисел
   from sales
   LEFT join customers on customers.customer_id = sales.customer_id
   LEFT join products on products.product_id = sales.product_id
   LEFT join employees on employees.employee_id = sales.sales_person_id
   group by 1 
  order by date asc;
 3.3. Третий отчет - о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0).
    with TAB as (select
      customers.customer_id,
      customers.first_name||' '||customers.last_name as customer,
      sales.sale_date,
      products.price,
      employees.first_name||' '||employees.last_name as seller,
      ROW_NUMBER() OVER (PARTITION BY customers.customer_id order by sales.sale_date) AS sale_number --используем для нумерования строк
      from sales
      LEFT join customers on customers.customer_id = sales.customer_id
      LEFT join products on products.product_id = sales.product_id
      LEFT join employees on employees.employee_id = sales.sales_person_id
      where products.price = 0)
  select customer, sale_date, seller
  from TAB where sale_number = 1;
