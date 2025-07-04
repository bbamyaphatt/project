# Ecommerce Consumer Behavior Analysis Data
got this dataset from: [Ecommerce Consumer Behavior Analysis Data](https://www.kaggle.com/datasets/salahuddinahmedshuvo/ecommerce-consumer-behavior-analysis-data)

## Install package
```r
install.packages('tidyverse')
install.packages('dplyr')
library(readr)
library(dplyr)

# read file
df <- read_csv('Ecommerce_Consumer_Behavior_Analysis_Data.csv')

# data str
str(df)
```
First of all, we need to upload the file to our work directory before using `read_csv()` and don't forget to assign a variable. 
Then I checked the data structure, there're 1,000 row and columns. The columns are following:

1. **Customer_ID**: Unique identifier for each customer.
2. **Age**: Customer's age (integer).
3. **Gender**: Customer's gender (categorical: Male, Female, Non-binary, Other).
4. **Income_Level**: Customer's income level (categorical: Low, Middle, High).
5. **Marital_Status**: Customer's marital status (categorical: Single, Married, Divorced, Widowed).
6. **Education_Level**: Highest level of education completed (categorical: High School, Bachelor's, Master's, Doctorate).
7. **Occupation**: Customer's occupation (categorical: Various job titles).
8. **Location**: Customer's location (city, region, or country).
9. **Purchase_Category**: Category of purchased products (e.g., Electronics, Clothing, Groceries).
10. **Purchase_Amount**: Amount spent during the purchase (decimal).
11. **Frequency_of_Purchase**: Number of purchases made per month (integer).
12. **Purchase_Channel**: The purchase method (categorical: Online, In-Store, Mixed).
13. **Brand_Loyalty**: Loyalty to brands (1-5 scale).
14. **Product_Rating**: Rating given by the customer to a purchased product (1-5 scale).
15. **Time_Spent_on_Product_Research**: Time spent researching a product (integer, hours or minutes).
16. **Social_Media_Influence**: Influence of social media on purchasing decision (categorical: High, Medium, Low, None).
17. **Discount_Sensitivity**: Sensitivity to discounts (categorical: Very Sensitive, Somewhat Sensitive, Not Sensitive).
18. **Return_Rate**: Percentage of products returned (decimal).
19. **Customer_Satisfaction**: Overall satisfaction with the purchase (1-10 scale).
20. **Engagement_with_Ads**: Engagement level with advertisements (categorical: High, Medium, Low, None).
21. **Device_Used_for_Shopping**: Device used for shopping (categorical: Smartphone, Desktop, Tablet).
22. **Payment_Method**: Method of payment used for the purchase (categorical: Credit Card, Debit Card, PayPal, Cash, Other).
23. **Time_of_Purchase**: Timestamp of when the purchase was made (date/time).
24. **Discount_Used**: Whether the customer used a discount (Boolean: True/False).
25. **Customer_Loyalty_Program_Member**: Whether the customer is part of a loyalty program (Boolean: True/False).
26. **Purchase_Intent**: The intent behind the purchase (categorical: Impulsive, Planned, Need-based, Wants-based).
27. **Shipping_Preference**: Shipping preference (categorical: Standard, Express, No Preference).
28. **Payment_Frequency**: Frequency of payment (categorical: One-time, Subscription, Installments).
29. **Time_to_Decision**: Time taken from consideration to actual purchase (in days).
    
```r
# check missing value
sum(is.na(df))

# data transformation 
# change colnames
colnames(df) <- tolower(colnames(df))
```
I checked if there're missing values in any columns. The result of `sum()` is 0, which means there're no missing value in this dataset.
Before diving into the insight, I changed the columns name into lowercase for readability. 

Now we're ready to go to the question part

## Key Question
**1. How does customer spending vary across different income level segments,
   and is there a statistically significant relationship between income level and the discount used?**
   ```r
   library(stringr)
   
   # remove $
   df$purchase_amount <- df$purchase_amount %>%
    str_remove_all("\\$") %>%
    str_trim() %>%
    as.numeric
   ```
The datatype of `purchase_amount` column in the original .csv data is text and contain `$`, which cannot be used for calculation.
So I removed the `$` and all possible white space by using function in `library(stringr)`, and coverted datatype from `chr` into `num`.
```r
# purchase mean by income level
avg_purchase <- df %>%
  select(income_level, purchase_amount) %>%
  group_by(income_level) %>%
  summarise(avg_purchase = mean(purchase_amount))
```
The first part of question asking about the purchase amount between 2 groups, high and middle income.
The result of 2 groups are quite similar, the average purchase amount of high income group is $276, while the middle group's is $275.

The second part is asking about discount used between those 2 groups.
```r
# create crosstab
crosstab <- table(df$income_level, df$discount_used)

# chisq test
chisq_result <- chisq.test(crosstab)
```
To determine if income levels are associated with the use of discounts, we will perform a chi-square test. But in case of using `chisq.test()`,
we need to create crosstab first to find the observed frequency. The crosstab results show that, 
among the high income group, 255 people use discounts while 260 do not. Among the middle income group, 266 people use discounts while 219 do not.

We set the assumptions:
- H0: There is NO significant association between the two variables.
- H1: there is significant association between the two variables.
  
According to the chi-square test, the p-value is 0.1046 (> 0.5), which means there'is no statistically significant difference between two groups -- so we fail to reject H0.

Based on the statistical results from our current data, a universal discount strategy appears effective, 
as there's no statistically significant need to tailor discounts to specific income levels.

**2. What is the average purchase amount for each product category, and which categories demonstrate the highest and lowest average transaction values?**
```r
library(ggplot2)
library(forcats)

# find average amount for each product category
avg_purchase_cate <- df %>%
  mutate(purchase_category = as.factor(purchase_category)) %>%
  select(purchase_category, purchase_amount) %>%
  group_by(purchase_category) %>%
  summarise(avg_purchase_cate = mean(purchase_amount)) %>%
  mutate(purchase_category = fct_reorder(purchase_category, avg_purchase_cate, .desc=TRUE)) %>%
  arrange(desc(avg_purchase_cate)) 

# create chart
ggplot(data = avg_purchase_cate,
       aes(x = purchase_category, 
           y = avg_purchase_cate, 
           fill = purchase_category)) +
geom_bar(stat = "identity") +
labs(title = "Average Purchase Amount by Category",
       x = "Purchase Category",
       y = "Average Purchase Amount") +
theme_minimal() +
theme(axis.text.x = element_text(angle = 45, hjust = 1))
```
I installed `ggplot2` for visualization with `ggplot`, and `forcats` to reorder charts by their height using `fct_reorder`.
After calculating the average purchase amount for each product category, I generated a bar chart to facilitate easier comprehension.

![Consumer behavior](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Average%20purchase%20amount%20by%20category.jpeg)

According to the bar chart, the Software & Apps category has the highest purchase amount, at $316, while Arts & Crafts has the lowest, at $221.


**3. Which product category has the highest total sales volume? What is the proportion of total sales contributed by each category, and how does marital status influence purchasing within these top categories?**
```r
# convert datatype
df$marital_status = as.factor(df$marital_status)

total_sales_cate <- df %>%
  select(purchase_category, purchase_amount, marital_status) %>%
  group_by(purchase_category, marital_status) %>%
  summarize(total_sales = sum(purchase_amount), .groups = "drop") %>%
  group_by(purchase_category) %>%
  mutate(cate_total_sales = sum(total_sales)) %>%
  ungroup() %>%
  mutate(purchase_category = fct_reorder(purchase_category, cate_total_sales, .desc=TRUE)) %>%
  arrange(desc(total_sales))
```

To answer this question, a stacked bar chart is suitable as it allows for visualizing the total sales volume per product category while also showing the breakdown by marital status. The first `group_by(purchase_category, marital_status)` operation calculates the `total_sales` for each unique combination of product category and marital status. This tells R to sum the purchase amounts for each segment e.g. 'Software & Apps' purchased by 'Married' individuals, 'Software & Apps' purchased by 'Single' individuals, and so-on. Then, the `.groups = "drop"` removes the grouping, preparing the data for the next step. Following this, the data is grouped again, but only by `purchase_category`, to calculate the `cate_total_sales`, which represents the sum of all sales within each product category. Finally, the categories are reordered by their `cate_total_sales` in descending order to easily identify the highest-selling categories.

```r
totl_sales_by_cate <- ggplot(data = total_sales_cate,
       aes(x = purchase_category, 
           y = total_sales,
           fill = marital_status)) +
  geom_bar(stat = "identity") +
  labs(title = "Total Sales by Category",
       x = "Purchase Category",
       y = "Total Sales") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  scale_fill_manual(values = c('lightblue',
                               'lightgreen',
                               'gold',
                               'salmon'))
```
![Total sales by category](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Total%20sales%20by%20category.jpeg)

The chart indicates that 'Jewelry & Accessories' has the highest total sales, followed by 'Sports & Outdoors', 'Electronics' and 'Software & Apps'. On the other hand, 'Arts & Crafts' appears to have the lowest total sales among the categories presented. Looking at sales by marital status, we see that:
- **Widowed customers** purchase a lot of things, especially big items like 'Jewelry & Accessories', 'Electronics', and 'Home Appliances'. They also spend a lot on 'Toys & Games' and 'Health Care'.
- **Single customers** purchase a lot of 'Software & Apps', 'Books', and 'Health Supplements' – things for personal growth. They also purchase 'Mobile Accessories' and 'Animal Feed'.
- **Married customers** tend to purchase 'Sports & Outdoors' gear, 'Electronics', and 'Food & Beverages', suggesting purchases often family activities and household things.
- **Divorced customers** purchase the least overall, but they show up more in 'Jewelry & Accessories', 'Toys & Games', and 'Mobile Accessories'.

The propotion of 'Jewelry & Accessories', which is the highest total sales, is 5.50%
``` r
# proportion
top_total_sales <- df %>%
  select(purchase_category, purchase_amount) %>%
  group_by(purchase_category) %>%
  summarise(top_total_amount = sum(purchase_amount)) %>%
  arrange(desc(top_total_amount)) %>%
  head(1)

total_sales <- sum(df$purchase_amount)

jewel_proportion <- (top_total_sales$top_total_amount/total_sales)*100
```
**4. Which Top 3 locations contribute the highest total purchase amount?**
```r
sales_by_location <- df %>%
  select(location, purchase_amount) %>%
  group_by(location) %>%
  summarise(total_sales_location = sum(purchase_amount) %>%
  arrange(desc(total_sales_location)) %>%
  head(3)
```
The result shows that Göteborg had the most sales, bringing in $1,161. Next is Oslo, with sales of $1,022.
Last is Punta Gorda, with $820 in sales. Based on this, we should consider about running special deals to get more customers to buy from the shop.

**5. What are the most frequently used payment methods overall, and how do their distributions differ between 'Online' and 'In-Store' purchase channels?**
```r
plot_payment <- df %>%
  select(purchase_channel, payment_method) %>%
  group_by(payment_method, purchase_channel) %>%
  summarise(count = n(), .groups = "drop") %>%
  group_by(payment_method) %>%
  mutate(payment_total_count = sum(count)) %>%
  ungroup() %>%
  mutate(payment_method = fct_reorder(payment_method, payment_total_count, .desc = TRUE))

payment_met <- ggplot(data = plot_payment,
       aes(x = payment_method,
           y = payment_total_count,
           fill = purchase_channel)) +
  geom_bar(stat = "identity") +
  labs(title = "Distribution of Payment Method between Online and In-store",
       x = "Payment Method",
       y = "Count of Purchase Channel") +
  theme_minimal() +
  scale_fill_manual(values = c('lightblue',
                               'lightgreen',
                               'gold'))
```

![Most used payment method](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/Distribution%20of%20payment%20method.jpeg)

'PayPal' is indeed the most frequently used payment method, with the highest total count across all purchase channels. This is followed by 'Other' methods, 'Debit Card', 'Credit Card', and 'Cash' being the least popular. 

Across all payment methods, the distribution of purchase channels remains similar in proportion, so promotions should be tailored to each specific payment method rather than being a one-size-fits-all approach across all channels.

**6. Is there a statistically significant correlation between being a customer loyalty program member and frequency of purchase?**
```r
# convert datatype
df$customer_loyalty_program_member <- as.factor(df$customer_loyalty_program_member)

# t test freq and membership
t_test_freq <- t.test(frequency_of_purchase ~ customer_loyalty_program_member, data = df)
```
To determine if there's a statistically significant difference in the frequency of purchase between customers who are members of the loyalty program and those who are not, a t-test was performed.

The assumptions for the t-test were:
- H0: There is no significant difference in the frequency of purchase between loyalty program members and non-members.
- H1: There is a significant difference in the frequency of purchase between loyalty program members and non-members.

The p-value obtained from the t-test is 0.6017. Since this p-value is greater than 0.5, we fail to reject H0. This indicates that the frequency of purchase does not statistically imply whether a customer is registered for the loyalty program.
```r
# cal of freq
des_freq <- df %>%
  group_by(customer_loyalty_program_member) %>%
  summarise(avg_freq = mean(frequency_of_purchase),
            median_freq = median(frequency_of_purchase),
            SD_freq = sd(frequency_of_purchase))
```

While the t-test tells us if a significant difference exists, it doesn't quantify the magnitude of this difference. Therefore, we calculated descriptive statistics for the purchase frequency for both groups:
- For non-members: The average frequency of purchase is 7.00, the median is 7, and the standard deviation is 3.13.
- For members: The average frequency of purchase is 6.89, the median is 7, and the standard deviation is 3.17.
  
These very close results for the mean, median, and standard deviation further confirm that there is no statistically significant difference in purchase frequency between customers who are loyalty program members and those who are not.


## Conclusion
To increase sales, we can summarize the insights from the six key questions as follows:
- We should provide universal promotions to customers of all income levels, as there's no need to tailor them to specific groups. This is because both middle and high-income levels show very close average purchase amounts, and the use of discounts is not significantly different among them.
- In terms of product categories, we should focus on high-performing categories like 'Jewelry & Accessories' and 'Software & Apps', while also considering strategies to boost lower-performing ones like 'Arts & Crafts'.
Regarding marital status, we should tailor promotions to specific statuses. For example, we could offer family-centric deals to 'Married' customers, such as sports and household products, while providing personal growth deals to 'Single' customers.
- Leverage location-based promotions in top sales cities like Göteborg, Oslo, and Punta Gorda to drive more purchases.
- Since 'PayPal' is the most used payment method, we should tailor specific promotions for PayPal users. Additionally, consider offering special deals for other specific payment methods that have a high number of users.
- Finally, as loyalty program membership doesn't significantly correlate with purchase frequency, consider focusing on other benefits of the loyalty program beyond increasing transaction volume. For example, offer discounts or gift vouchers upon reaching a cumulative total purchase amount of $XX.
