--1. Считаем общее количество покупателей из таблицы customers.
  -- Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк. 
     SELECT COUNT(customer_id) AS customers_count
FROM customers;

--2.1. Первый отчет о десятке лучших продавцов.
    select
    employees.first_name || ' ' || employees.last_name as seller,
    count(employee_id) as operations, --Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк.
    floor(sum(quantity * price)) as income --Используем агрегирующий оператор SUM - SQL функция используется для суммирования строк (количество умножаем на цену товара). Оператор FLOOR - для округления целого числа
from sales
left join customers on sales.customer_id = customers.customer_id
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by 1
order by sum(quantity * price) desc
limit 10;
 --2.2. Второй отчет - информация о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
    select
    employees.first_name || ' ' || employees.last_name as seller,
    FLOOR(AVG(quantity * price)) as average_income --Используем агрегирующий оператор AVG - SQL функция используется для подсчета среднего значения (количество умножаем на цену товара). Оператор ROUND - для округления чисел
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by 1
having AVG(quantity * price) < (select AVG(quantity * price) from sales left join products on sales.product_id = products.product_id) --Используем агрегирующий оператор having для дополнительной группировки после group by
order by 2;
--2.3. Третий отчет - информация о выручке по дням недели.
    select
    employees.first_name || ' ' || employees.last_name as seller,
    --Оператор To_char - преобразование даты в день недели
    to_char(sales.sale_date, 'day') as day_of_week,
    floor(sum(quantity * price)) as income
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
-- Оператор Extract необходим для преобразование текста даты в число
group by extract(isodow from sales.sale_date), 1, 2
order by extract(isodow from sales.sale_date), 2, 1;
   
 --3.1. Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
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
 --3.2. Второй отчет - данные по количеству уникальных покупателей и выручке, которую они принесли.
   select
    --Оператор To_char - преобразование даты в день недели
    to_char(sales.sale_date, 'YYYY-MM') as selling_month,
    count(distinct sales.customer_id) as total_customers, --Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк.
    floor(sum(quantity * price)) as income  --Используем агрегирующий оператор SUM - SQL функция используется для суммирования строк (количество умножаем на цену товара). Оператор ROUND - для округления чисел
from sales
left join customers on sales.customer_id = customers.customer_id
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by 1
order by selling_month asc;
 --3.3. Третий отчет - о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0).
    with TAB as (
    select
        CUSTOMERS.CUSTOMER_ID,
        SALES.SALE_DATE,
        PRODUCTS.PRICE,
        CUSTOMERS.FIRST_NAME || ' ' || CUSTOMERS.LAST_NAME as CUSTOMER,
        EMPLOYEES.FIRST_NAME || ' ' || EMPLOYEES.LAST_NAME as SELLER,
        --используем для нумерования строк
        ROW_NUMBER()
            over (partition by CUSTOMERS.CUSTOMER_ID order by SALES.SALE_DATE)
            as SALE_NUMBER
    from SALES
    left join CUSTOMERS on SALES.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
    left join PRODUCTS on SALES.PRODUCT_ID = PRODUCTS.PRODUCT_ID
    left join EMPLOYEES on SALES.SALES_PERSON_ID = EMPLOYEES.EMPLOYEE_ID
    where PRODUCTS.PRICE = 0)
select
    CUSTOMER,
    SALE_DATE,
    SELLER
from TAB where SALE_NUMBER = 1;


    
  