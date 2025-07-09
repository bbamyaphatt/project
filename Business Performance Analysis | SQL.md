# Business Performance Analysis
I use the Northwind dataset for this project and developing my SQL skill. The Northwind-SQLite3 dataset is a re-engineered version of the classic Microsoft Access 2000 Northwind database, converted to SQLite3 by [Northwind-SQLite3](https://github.com/jpwhite3/northwind-SQLite3?tab=readme-ov-file). The Northwind dataset is a simulated business scenario database. It tracks all the sales activity for "Northwind Traders," a made-up company that buys and sells specialty foods globally.  It contains information about Customer, Products, Categories, Orders, Orderdetails, Employees, Suppliers and Shippers.

## Key Questions
### Sales Performance
1. What are our top 5 best-selling products by revenue over all time
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
This chart highlights the top five products by all-time revenue, showcasing their impressive sales performance:
1) Côte de Blaye (Beverages): Leading the pack with a remarkable $53,265,895.23 in revenue.
2) Thüringer Rostbratwurst (Meat/Poultry): Coming in second at $24,623,469.23.
3) Mishi Kobe Niku (Meat/Poultry): Following closely behind with $19,423,037.50.
4) Sir Rodney's Marmalade (Confections): Securing the fourth spot at $16,653,807.36.
5) Carnarvon Tigers (Seafood): Rounding out the top five with $12,604,671.88.

These products clearly demonstrate top performance within their respective categories and are highly popular among customers.

2. Can we see the total sales revenue per month for the last two years available in the dataset?
```sql
SELECT DISTINCT(STRFTIME('%Y', orderdate)) AS year
FROM orders
ORDER BY year;
```
I first checked the dataset's timeframe and found it contains records from 2012 to 2023. This means the last two years in the dataset are 2022 and 2023.
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
Total revenue in 2022 was $39,742,066.18, slightly more than 2023's $33,054,490 (as 2023's data only goes up to October).

Both years show that May (the 5th month) had the highest revenue, reaching $3,719,270.11 in 2022 and $3,896,544.35 in 2023. This could be because May marks the start of summer, leading to more outdoor activities and related purchases. Interestingly, no discounts were applied in May, suggesting this high performance isn't due to promotions. Given this trend, offering promotions in May next year, like "spend $XX, get XX free" or a discount, could attract even more customers during this already popular period.

Conversely, February (the 2nd month) was the lowest season for both 2022 and 2023. This might be due to people saving money after New Year's celebrations in January. For this low period, promotions like "clearance sales" could be effective without needing a large budget.

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
The USA has generated the highest total sales over time, reaching $62,601,564.84. This strong performance suggests that we should consider expanding our operations there.

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
![Top 10 customers 2023](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Top%2010%20Customers%20in%202023.png)
The customer generating the most revenue is B's Beverages, with an outstanding $6.1 million in sales. They've purchased a wide range of product categories, including Beverages, Meat/Poultry, Confections, and Dairy Products.

Following closely is Hungry Coyote Import Store, reaching $5.6 million, with similar purchasing patterns across those same categories.

Next in line are several customers in the $5.5 million range: Rancho Grande, Gourmet Lanchonetes, Ana Trujillo Emparedados y helados, and Ricardo Adocicados. Folies Gourmandes is also in this group.

Finally, Let's Stop N Shop, LILA-Supermercado, and Princesa Isabel Vinhos fall within the $5.4 million range.

It's noteworthy that most of these top revenue-generating customers primarily purchase Beverages, which aligns strongly with our observation that Beverages is our overall best-performing product category.

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

This chart identifies the top revenue-generating employee for each year in the dataset. Two employees consistently led sales for three years each:
Laura Callahan, who's the top earner in 2015, 2016, and 2018 and Nancy Davolio, who's Top earner in 2013, 2017, and 2020.
Following closely, Margaret Peacock generated the most revenue for two years (2019 and 2021). The remaining top performers each led for one year: Andrew Fuller (2012), Robert King (2022), and Steven Buchanan (2023).

These employees demonstrate exceptional dedication to the business and should be recognized. I recommend implementing an ongoing reward program, such as offering additional holiday time or in-store discount coupons, to acknowledge and further encourage their outstanding contributions annually.

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

Looking at the chart, Beverages are the top revenue earner by far, bringing in over $92 million. Confections ($66 million) and Meat/Poultry ($64 million) are also strong performers. In the middle range, we have Dairy Products ($58 million), Condiments ($55 million), and Seafood ($49 million). While still substantial, Produce ($32 million) and Grains/Cereals ($28 million) generated the least revenue among the top 10 categories. Since the high-performing categories achieve strong sales without relying on discounts, I suggest focusing promotions on the lower-performing products to boost their sales volume.

2. Are there any products with unusually low sales in last year that we should investigate?
```sql
SELECT
  categoryname AS category_name,
  productname AS product_name,
  SUM(quantity * orderdetails.unitprice * (1-discount)) AS total_revenue
FROM categories
JOIN products
  ON categories.categoryid = products.categoryid
JOIN orderdetails
  ON products.productid = orderdetails.productid
JOIN orders
  ON orderdetails.orderid = orders.orderid
WHERE STRFTIME('%Y', orderdate) = '2013'
GROUP BY category_name, product_name
LIMIT 5;
```
![Low Sales Product](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Low%20Sales%20Products%20in%202023.png)

Looking at the lowest revenue products for 2023 so far, Geitost (from Dairy Products) is at the bottom with just $41,855. Next up is Guaraná Fantástica (Beverages) at $77,211, followed by Konbu (Seafood) at $101,172, Filo Mix (Grains/Cereals) at $123,830, and Tourtière (Meat/Poultry) at $132,557.85.

One possible reason for these lower numbers is simply that 2023 isn't over yet; we still have two months of sales data to come in. However, we also need to investigate factors like product freshness or expiration dates. It's crucial to ensure our stock follows a 'first-in, first-out' system and that quality is maintained right from the supplier.

Perhaps we should also consider surveying customers or creating a questionnaire to gauge the popularity of these specific products. Their feedback could help us decide if we should continue offering them.



