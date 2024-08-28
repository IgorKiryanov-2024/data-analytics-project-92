---1. Считаем общее количество покупателей из таблицы customers.
  -- Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк. 
SELECT COUNT(customer_id) AS customers_count
FROM customers;

--2.1. Первый отчет о десятке лучших продавцов.
--Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк.
--Используем агрегирующий оператор SUM - SQL функция используется для суммирования строк (количество умножаем на цену товара). Оператор FLOOR - для округления целого числа
select
    employees.first_name || ' ' || employees.last_name as seller,
    count(employees.employee_id) as operations,
    floor(sum(sales.quantity * products.price)) as income
from sales
left join customers on sales.customer_id = customers.customer_id
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by seller
order by sum(sales.quantity * products.price) desc
limit 10;
 --2.2. Второй отчет - информация о продавцах, чья средняя выручка за сделку меньше средней выручки за сделку по всем продавцам.
--Используем агрегирующий оператор AVG - SQL функция используется для подсчета среднего значения (количество умножаем на цену товара). Оператор FLOOR - для округления чисел
--Используем агрегирующий оператор having для дополнительной группировки после group by
select
    employees.first_name || ' ' || employees.last_name as seller,
    FLOOR(AVG(sales.quantity * products.price)) as average_income
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by seller
having
    AVG(sales.quantity * products.price) < (
        select AVG(sales.quantity * products.price)
        from sales left
        join products on sales.product_id = products.product_id
    )
order by average_income;

--2.3. Третий отчет - информация о выручке по дням недели.
--Оператор To_char - преобразование даты в день недели
-- Оператор Extract необходим для преобразование текста даты в число
select
    employees.first_name || ' ' || employees.last_name as seller,
    to_char(sales.sale_date, 'day') as day_of_week,
    floor(sum(sales.quantity * products.price)) as income
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by extract('isodow' from sales.sale_date), seller, day_of_week
order by extract('isodow' from sales.sale_date), seller;
   
 --3.1. Первый отчет - количество покупателей в разных возрастных группах: 16-25, 26-40 и 40+.
--оператор case позволяет осуществить проверку условий и возвратить в зависимости от выполнения того или иного условия тот или иной результат.
--Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк.
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    COUNT(*) as age_count
from customers
group by age_category
order by age_category;
 --3.2. Второй отчет - данные по количеству уникальных покупателей и выручке, которую они принесли.
 --Оператор To_char - преобразование даты в день недели
--Используем агрегирующий оператор COUNT - SQL функция используется для подсчета количества строк.
--Используем агрегирующий оператор SUM - SQL функция используется для суммирования строк (количество умножаем на цену товара). Оператор FLOOR - для округления чисел
select
    to_char(sales.sale_date, 'YYYY-MM') as selling_month,
    count(distinct sales.customer_id) as total_customers,
    floor(sum(sales.quantity * products.price)) as income
from sales
left join customers on sales.customer_id = customers.customer_id
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by selling_month
order by selling_month asc;
 --3.3. Третий отчет - о покупателях, первая покупка которых была в ходе проведения акций (акционные товары отпускали со стоимостью равной 0).
 --ROW_NUMBER() используем для нумерования строк
with TAB as (
    select
        CUSTOMERS.CUSTOMER_ID,
        SALES.SALE_DATE,
        PRODUCTS.PRICE,
        CUSTOMERS.FIRST_NAME || ' ' || CUSTOMERS.LAST_NAME as CUSTOMER,
        EMPLOYEES.FIRST_NAME || ' ' || EMPLOYEES.LAST_NAME as SELLER,
        ROW_NUMBER()
            over (partition by CUSTOMERS.CUSTOMER_ID order by SALES.SALE_DATE)
            as SALE_NUMBER
    from SALES
    left join CUSTOMERS on SALES.CUSTOMER_ID = CUSTOMERS.CUSTOMER_ID
    left join PRODUCTS on SALES.PRODUCT_ID = PRODUCTS.PRODUCT_ID
    left join EMPLOYEES on SALES.SALES_PERSON_ID = EMPLOYEES.EMPLOYEE_ID
    where PRODUCTS.PRICE = 0
)

select
    CUSTOMER,
    SALE_DATE,
    SELLER
from TAB where SALE_NUMBER = 1;
