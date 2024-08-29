--1.Считаем общее количество покупателей из таблицы customers.
-- Используем COUNT-используется для подсчета количества строк. 
select count(customer_id) as customers_count
from customers;
--2.1.Первый отчет о десятке лучших продавцов.
--Используем COUNT-спользуется для подсчета количества строк.
--Используем SUM - используется для суммирования строк
--Оператор FLOOR - для округления целого числа
select
    employees.first_name || ' ' || employees.last_name as seller,
    count(employees.employee_id) as operations,
    floor(sum(sales.quantity * products.price)) as income
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by seller
order by sum(sales.quantity * products.price) desc
limit 10;
--2.2.Второй отчет
--Используем AVG-используется для подсчета среднего значения
--Оператор FLOOR-для округления чисел
--Используем having для дополнительной группировки
select
    employees.first_name || ' ' || employees.last_name as seller,
    floor(avg(sales.quantity * products.price)) as average_income
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by seller
having
    avg(sales.quantity * products.price) < (
        select avg(sales.quantity * products.price)
        from sales left
        join products on sales.product_id = products.product_id
    )
order by average_income;
--2.3.Третий отчет-информация о выручке по дням недели.
--Оператор To_char-преобразование даты в день недели
--Оператор Extract необходим для преобразование текста даты в число
select
    employees.first_name || ' ' || employees.last_name as seller,
    to_char(sales.sale_date, 'day') as day_of_week,
    floor(sum(sales.quantity * products.price)) as income
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by extract('isodow' from sales.sale_date), seller, day_of_week
order by extract('isodow' from sales.sale_date), seller;
--3.1.Первый отчет-количество покупателей в разных возрастных группах
--оператор case позволяет осуществить проверку условий и возвратить.
--Используем COUNT-используется для подсчета количества строк.
select
    case
        when age between 16 and 25 then '16-25'
        when age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    count(*) as age_count
from customers
group by age_category
order by age_category;
--3.2.Второй отчет-данные по количеству уникальных покупателей и выручке
--Оператор To_char-преобразование даты в день недели
--Используем COUNT-используется для подсчета количества строк.
--Используем SUM-используется для суммирования строк
--Оператор FLOOR-для округления чисел
select
    to_char(sales.sale_date, 'YYYY-MM') as selling_month,
    count(distinct sales.customer_id) as total_customers,
    floor(sum(sales.quantity * products.price)) as income
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by selling_month
order by selling_month asc;
--3.3.Третий отчет o ходе проведения акций.
--ROW_NUMBER() используем для нумерования строк
with tab as (
    select
        customers.customer_id,
        sales.sale_date,
        products.price,
        customers.first_name || ' ' || customers.last_name as customer,
        employees.first_name || ' ' || employees.last_name as seller,
        row_number()
            over (partition by customers.customer_id order by sales.sale_date)
        as sale_number
    from sales
    left join customers on sales.customer_id = customers.customer_id
    left join products on sales.product_id = products.product_id
    left join employees on sales.sales_person_id = employees.employee_id
    where products.price = 0
)

select
    customer,
    sale_date,
    seller
from tab where sale_number = 1;
