     SELECT COUNT(customer_id) AS customers_count
FROM customers;

    select
    employees.first_name || ' ' || employees.last_name as seller,
    count(employee_id) as operations,
    floor(sum(quantity * price)) as income
from sales
left join customers on sales.customer_id = customers.customer_id
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by 1
order by sum(quantity * price) desc
limit 10;

select
    employees.first_name || ' ' || employees.last_name as seller,
    floor(avg(quantity * price)) as average_income
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by 1
having avg(quantity * price) < (select avg(quantity * price) from sales left join products on sales.product_id = products.product_id) --Используем агрегирующий оператор having для дополнительной группировки после group by
order by 2;

    select
    employees.first_name || ' ' || employees.last_name as seller,
    to_char(sales.sale_date, 'day') as day_of_week,
    floor(sum(quantity * price)) as income
from sales
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by extract(isodow from sales.sale_date), 1, 2
order by extract(isodow from sales.sale_date), 2, 1;
   
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

    select
    to_char(sales.sale_date, 'YYYY-MM') as selling_month,
    count(distinct sales.customer_id) as total_customers,
    floor(sum(quantity * price)) as income
from sales
left join customers on sales.customer_id = customers.customer_id
left join products on sales.product_id = products.product_id
left join employees on sales.sales_person_id = employees.employee_id
group by 1
order by selling_month asc;
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


