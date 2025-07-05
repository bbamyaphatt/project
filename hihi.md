### I. Sales Performance & Product Insights:
**Overall Sales Trend**
1. What are our total sales revenue and total quantity sold over time (monthly, quarterly, annually)?
```sql
# by month
SELECT
  STRFTIME('%m', orderdate) AS month,
  sum(quantity*unitprice) AS total_sales_revenue,
  sum(quantity) AS total_qty_sold
FROM orders
JOIN orderdetails
  ON orders.orderid = orderdetails.orderid
GROUP BY month;
```
```sql
# by quarter
SELECT
  STRFTIME('%Y', orderdate) AS year,
  STRFTIME('%m', orderdate) AS month,
  CASE
    WHEN STRFTIME('%m', orderdate) BETWEEN '01' AND '03' THEN 'Q1'
    WHEN STRFTIME('%m', orderdate) BETWEEN '04' AND '06' THEN 'Q2'
    WHEN STRFTIME('%m', orderdate) BETWEEN '07' AND '09' THEN 'Q3'
    WHEN STRFTIME('%m', orderdate) BETWEEN '10' AND '12' THEN 'Q4'
  END AS quarter,
  sum(quantity*unitprice) AS total_sales_revenue,
  sum(quantity) AS total_qty_sold
FROM orders
JOIN orderdetails
  ON orders.orderid = orderdetails.orderid
GROUP BY quarter;
```
```sql
# by year
SELECT
  STRFTIME('%Y', orderdate) AS year,
  sum(quantity*unitprice) AS total_sales_revenue,
  sum(quantity) AS total_qty_sold
FROM orders
JOIN orderdetails
  ON orders.orderid = orderdetails.orderid
GROUP BY year;
```
2. Which months/quarters/years had the highest/lowest sales? Are there any clear seasonal trends?
```sql
# by month
SELECT
  STRFTIME('%m', orderdate) AS month,
  sum(quantity*unitprice) AS total_sales_revenue
FROM orders
JOIN orderdetails
  ON orders.orderid = orderdetails.orderid
GROUP BY month
ORDER BY total_sales_revenue DESC;
```
```sql
# by quarter
SELECT
  CASE
    WHEN STRFTIME('%m', orderdate) BETWEEN '01' AND '03' THEN 'Q1'
    WHEN STRFTIME('%m', orderdate) BETWEEN '04' AND '06' THEN 'Q2'
    WHEN STRFTIME('%m', orderdate) BETWEEN '07' AND '09' THEN 'Q3'
    WHEN STRFTIME('%m', orderdate) BETWEEN '10' AND '12' THEN 'Q4'
  END AS quarter,
  sum(quantity*unitprice) AS total_sales_revenue
FROM orders
JOIN orderdetails
    ON orders.orderid = orderdetails.orderid
GROUP BY quarter
ORDER BY total_sales_revenue DESC;
```
```sql
# by year
SELECT
STRFTIME('%Y', orderdate) AS year,
  sum(quantity*unitprice) AS total_sales_revenue
FROM orders
JOIN orderdetails
  ON orders.orderid = orderdetails.orderid
GROUP BY year
ORDER BY total_sales_revenue DESC;
```
3. What's the average order value? Is it increasing or decreasing?
```sql
SELECT
  STRFTIME('%Y', orderdate) AS year,
  SUM(quantity * unitprice)/COUNT(orders.orderid) AS avg_order_value
FROM orderdetails
JOIN orders
  ON orderdetails.orderid = orders.orderid
GROUP BY year;
```
**Top/Bottom Performers**
1. Which products are our top 10 best-sellers by revenue and quantity?
```sql
# by revenue
SELECT
  productname,
  sum(quantity * products.unitprice) AS total_sales
FROM Products
JOIN OrderDetails
  ON products.productid = orderdetails.productid
GROUP BY productname
ORDER BY total_sales DESC
LIMIT 10;
```
```sql
# by qty
SELECT
  productname,
  sum(quantity) AS total_qty
FROM Products
JOIN OrderDetails
  ON products.productid = orderdetails.productid
GROUP BY productname
ORDER BY total_qty DESC
LIMIT 10;
```
2. Which product categories are generating the most revenue? 
```sql
SELECT
  categoryname,
  sum(quantity * orderdetails.unitprice) AS total_sales
FROM categories
JOIN products
  ON categories.categoryid = products.categoryid
JOIN orderdetails
  ON products.productid = orderdetails.productid
GROUP BY categoryname
ORDER BY total_sales DESC;
```
3. Who are our top 5 employees by sales volume/revenue?
```sql
SELECT
  firstname ||' '|| lastname AS employee_name,
  employees.employeeid AS employee_id,
  sum(quantity * unitprice) AS total_sales_volume
FROM employees
JOIN orders
  ON employees.employeeid = orders.employeeid
JOIN orderdetails
  ON orders.orderid = orderdetails.orderid
GROUP BY employee_id
ORDER BY total_sales_volume DESC
LIMIT 5;
```












