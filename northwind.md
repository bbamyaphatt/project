### Sales Performance
1. What are our top 5 best-selling products by quantity and revenue over all time
```sql
SELECT
  productname AS product_name,
  SUM(quantity * orderdetails.unitprice * (1-discount)) AS total_revenue
FROM products
JOIN orderdetails
  ON products.productid = orderdetails.productid
GROUP BY productname
ORDER BY total_revenue DESC
LIMIT 5;
```
![Best-selling products](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Top%205%20Best%20Selling%20Products.png)
2. Can we see the total sales revenue per month for the last two years available in the dataset?
```sql
SELECT DISTINCT(STRFTIME('%Y', orderdate)) AS year
FROM orders
ORDER BY year;
```
```sql
SELECT
  STRFTIME('%Y', orderdate) AS year,
  STRFTIME('%m', orderdate) AS month,
  SUM(quantity * orderdetails.unitprice * (1-discount)) AS total_revenue_per_month
FROM orderdetails
JOIN orders
  ON orderdetails.orderid = orders.orderid
WHERE STRFTIME('%Y', orderdate) IN ('2022', '2023')
GROUP BY year, month
ORDER BY year;
```
![Total Sales 2022-2023](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Total%20Sales%202022-2023.png)
3. Which countries or regions generate the most sales revenue?
```sql
SELECT
  COALESCE(country, 'Unknown') AS country_clean,
  SUM(quantity * orderdetails.unitprice * (1-discount)) AS total_revenue
FROM customers
JOIN orders
  ON customers.customerid = orders.customerid
JOIN orderdetails
  ON orders.orderid = orderdetails.orderid
GROUP BY country
ORDER BY total_revenue DESC
LIMIT 1;
```
USA 62601564.8405
### Customer Insights
1. Who are our top 10 customers by total order value in 2023?
```sql
SELECT
	customers.customerid AS customer_id,
	companyname AS company_name,
  SUM(quantity * unitprice * (1-discount)) AS total_purchase
FROM customers 
JOIN orders
	ON customers.customerid = orders.customerid
JOIN orderdetails 
	ON orders.orderid = orderdetails.orderid
GROUP BY customer_id
ORDER BY total_purchase DESC
LIMIT 10;
```
![Top 10 customers 2023](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Top%2010%20customers%202023.png)

### Employee Performance
1. Which employee generated the most sales revenue in any single year?
```sql
WITH emp_total_revenue AS(
  SELECT
    STRFTIME('%Y', orderdate) AS year,
    employees.employeeid AS employee_id,
    firstname ||' '|| lastname AS employee_name,
    SUM(quantity * unitprice * (1-discount)) AS total_revenue
  FROM employees
  JOIN orders
    ON employees.employeeid = orders.employeeid
  JOIN orderdetails
    ON orders.orderid = orderdetails.orderid
  GROUP BY
    year,
    employee_id,
    employee_name
),
rank_emp AS(
  SELECT
    year,
    employee_id,
    employee_name,
    total_revenue,
    ROW_NUMBER() OVER (PARTITION BY year ORDER BY total_revenue DESC) AS rank
  FROM emp_total_revenue
)

SELECT
  year,
  employee_id,
  employee_name,
  total_revenue
FROM rank_emp
WHERE rank = 1
GROUP BY year;
```
![Employee Generated The Most Revenue](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Emplyee%20Generated%20The%20Most%20Revenue.png)

### Product and Category Analysis
1. Which product categories are performing the best in terms of sales?
```sql
SELECT
  categories.categoryid AS category_id,
  categoryname AS category_name,
  SUM(quantity * orderdetails.unitprice * (1-discount)) AS total_revenue
FROM categories
JOIN products
  ON categories.categoryid = products.categoryid
JOIN orderdetails
  ON products.productid = orderdetails.productid
GROUP BY category_name
ORDER BY total_revenue DESC
```
![Top 10 Product Categories](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Top%2010%20Product%20Categories.png)

2. Are there any products with unusually low sales in last year that we should investigate?
```sql
SELECT
  categories.categoryid AS category_id,
  categoryname AS category_name,
  products.productid AS product_id,
  productname AS product_name,
  suppliers.supplierid AS supplier_id,
  companyname AS supplier_company,
  SUM(quantity * orderdetails.unitprice * (1-discount)) AS total_revenue
FROM categories
JOIN products
  ON categories.categoryid = products.categoryid
JOIN orderdetails
  ON products.productid = orderdetails.productid
JOIN orders
  ON orderdetails.orderid = orders.orderid
JOIN suppliers
  ON products.supplierid = suppliers.supplierid
WHERE STRFTIME('%Y', orderdate) = '2013'
GROUP BY category_id, category_name, product_id, product_name, supplier_id, supplier_company
ORDER BY total_revenue
LIMIT 5;
```
![Low Sales Product](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Low%20Sales%20Products%20in%202023.png)





