# A/B Test Analysis: Click-Through Rate Performance
A/B testing is comparing two versions of the same thing to see which performs better. 
For instance, this method can determine which video version gains more views or which caption leads to a higher Click-Through Rate (CTR). 
For this analysis, I am using an A/B Testing Dataset from [Kaggle](https://www.kaggle.com/datasets/amirmotefaker/ab-testing-dataset/data).


### Import library
First of all, we need to install the libraries.
```py
import pandas as pd
import numpy as np
import scipy.stats as stats
```
### Load data
Then, I uploaded both control and test group into work directory.
```py
control_group = pd.read_csv('AB Testing/control_group.csv', sep = ';')
test_group = pd.read_csv('AB Testing/test_group.csv', sep = ';')
```
Since these csv files are separated by semicolon, not a comma, we have to add parameter `sep = ';'`.
### Data cleaning and processing
Let's check the data overview using `.info()`.
```py
control_group.info()
test_group.info()
```
Both the control and test groups have a data structure consisting of 30 rows and 10 columns, which include:
- **Campaign Name (object):** The name of the campaign
- **Date (object):** Date of the record
- **Spend:** Amount spent on the campaign in dollars
- **of Impressions:** Number of impressions the ad crossed through the campaign
- **Reach (float64):** The number of unique impressions received in the ad
- **of Website Clicks (float64):** Number of website clicks received through the ads
- **of Searches (float64):** Number of users who performed searches on the website
- **of View Content (float64):** Number of users who viewed content and products on the website
- **of Add to Cart (float64):** Number of users who added products to the cart
- **of Purchase (float64):** Number of purchases

The `.info()` result shows that the date data type is `object`, which is incorrect for a date type. Regarding completeness, the test group is complete, with no missing values (NaNs). However, the control group is missing one record in each of the following columns: 
Impressions, Reach, Website Clicks, Searches, View Content, Add to Cart, and Purchase, totaling seven missing values.

Let's convert the date type from `object` to `datetime64[ns]` first. 
Since the date value isn't in ISO 8601 (YYYY-MM-DD) format, we need to add the parameter `format = '%d.%m.%Y'`.
```py
# convert date type
control_group['Date'] = pd.to_datetime(control_group['Date'], format = '%d.%m.%Y')
test_group['Date'] = pd.to_datetime(test_group['Date'], format = '%d.%m.%Y')
```
The date type turned to `datetime64[ns]`.

Next, I plotted box plots to see if the data is normally or skewed distributed, 
so I can decide whether the mean or median should be used for imputation. 
I selected three columns to observe the trend: mpressions, Reach and Website Clicks.
```py
control_group[['# of Impressions','Reach','# of Website Clicks']].plot(kind='box');
```
![Box plot](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/box%20plot.png)

We can see that all three box plots are skewed. 
Impressions and Reach have a right skew, while Website Clicks has a left skew. 
Therefore, I will choose the median to perform the imputation.

```py
# filter NaNs columns

filter_nan_cols = [
    '# of Impressions',
    'Reach',
    '# of Website Clicks',
    '# of Searches',
    '# of View Content',
    '# of Add to Cart',
    '# of Purchase']

for col in filter_nan_cols:
    if control_group[col].isna().any():
        median_control_col = control_group[col].median()
        control_group[col].fillna(value = median_control_col, inplace = True)
        print(f"NaN in {col} replaced by {median_control_col}")
    else:
        print(f"No NaN in {col}")
```
I first filtered the columns that contain missing values and then used a `for` loop to fill them. 
If the loop finds a missing value in any of these columns, it calculates the median for that specific column using `.median()`. 
Subsequently, that missing value is filled with the calculated median. 
The `inplace = True` parameter instructs Python to apply these new values directly to the original DataFrame.

### Metric and hypothesis
The metric I used to perform this A/B test is the **Click-Through Rate (CTR)**. The control version has a general product description in its caption, whereas the test version incorporates urgency and scarcity with phrases like 'Limited Time Offer - Shop Now!'. 

The hypothesis is:
- Null hypothesis (H0): The CTR of the control group is equal to the CTR of the test group.
- Alternative hypothesis (H1): The CTR of the control group is not equal to the CTR of the test group.

### Perform A/B Test
```py
# create ab_test function
def ab_test(total_control_click, total_control_impression,
            total_test_click, total_test_impression,
            signigicant_level = 0.05):
    
    # calculate conversion rate
    control_conv_rate = total_control_click / total_control_impression
    test_conv_rate = total_test_click / total_test_impression

    # calculate absolute and relative diff
    absolute_diff = test_conv_rate - control_conv_rate
    relative_diff = absolute_diff / control_conv_rate

    # calculate pooled proportion
    pooled_prop = (total_control_click + total_test_click) / (total_control_impression + total_test_impression)

    # calculate pooled standard error
    pooled_se = np.sqrt(pooled_prop * (1-pooled_prop) * (1/total_control_impression + 1/total_test_impression))

    # calculate z-score
    z_score = absolute_diff / pooled_se

    # calculate p-value (two-tailed)
    p_value = 2 * (1 - stats.norm.cdf(abs(z_score)))

    # calculate individual se for ci
    control_se_for_ci = np.sqrt(control_conv_rate * (1 - control_conv_rate) / total_control_impression)
    test_se_for_ci = np.sqrt(test_conv_rate * (1-test_conv_rate) / total_test_impression)

    # calculate unpooled for ci
    unpooled_se = np.sqrt(control_se_for_ci**2 + test_se_for_ci**2)

    # calculate confident interval
    z_critical = stats.norm.ppf(1 - signigicant_level / 2)
    margin_error = z_critical * unpooled_se
    upper_ci = absolute_diff + margin_error
    lower_ci = absolute_diff - margin_error

    # determine if result is significant
    is_sig = p_value < signigicant_level

    return {
        'control conversion rate': control_conv_rate,
        'test conversion rate': test_conv_rate,
        'absolute diff': absolute_diff,
        'relative diff': relative_diff * 100,
        'z-score': z_score,
        'p-value': p_value,
        'lower ci': lower_ci,
        'upper ci': upper_ci,
        'is significant': is_sig
    }
```
Let's explain the above function:

```py
def ab_test(total_control_click, total_control_impression,
            total_test_click, total_test_impression,
            signigicant_level = 0.05):
```

The function aims to compare Click-Through Rates (CTRs) between two groups, using their total clicks and impressions. 
The signigicant_level is set to 0.05, representing a 95% confidence level.

```py
    # calculate conversion rate
    control_conv_rate = total_control_click / total_control_impression
    test_conv_rate = total_test_click / total_test_impression

    # calculate absolute and relative diff
    absolute_diff = test_conv_rate - control_conv_rate
    relative_diff = absolute_diff / control_conv_rate
```

First, we calculate each group's individual CTR using the formula `clicks / impressions`. 
These rates are essential for later determining the absolute difference, which means how much one CTR directly differs from the other, and the relative difference, which means
the percentage change of the test group's CTR compared to the control.

```py
    # calculate pooled proportion
    pooled_prop = (total_control_click + total_test_click) / (total_control_impression + total_test_impression)

    # calculate pooled standard error
    pooled_se = np.sqrt(pooled_prop * (1-pooled_prop) * (1/total_control_impression + 1/total_test_impression))
```

When conducting a hypothesis test for the difference between two proportions, we assume that the H0 (the CTRs of both groups are equal) is true. If they are equal, it implies the data originate from the same underlying population. Therefore, we pool the CTRs from the test and control groups and calculate the pooled standard error (`pooled_se`) to see how much the observed difference between the control and test CTRs might vary due to random chance.

```py
 # calculate z-score
    z_score = absolute_diff / pooled_se

    # calculate p-value (two-tailed)
    p_value = 2 * (1 - stats.norm.cdf(abs(z_score)))
```

We use a Z-score to measure the difference in CTRs. 
It shows how far our result is from zero (no difference), using a standard statistical method for comparing rates.

Next, we find the p-value using a two-tailed test. This is because we want to detect if the test CTR is significantly different from the control CTR in either direction, higher or lower

```py
   # calculate individual se for ci
    control_se_for_ci = np.sqrt(control_conv_rate * (1 - control_conv_rate) / total_control_impression)
    test_se_for_ci = np.sqrt(test_conv_rate * (1-test_conv_rate) / total_test_impression)

    # calculate unpooled for ci
    unpooled_se = np.sqrt(control_se_for_ci**2 + test_se_for_ci**2)

    # calculate confident interval
    z_critical = stats.norm.ppf(1 - signigicant_level / 2)
    margin_error = z_critical * unpooled_se
    upper_ci = absolute_diff + margin_error
    lower_ci = absolute_diff - margin_error
```

Finally, we calculate the Confidence Interval (CI).

For the CI, we use the unpooled standard error (`unpooled_se`). We don't pool the data here because, unlike hypothesis testing, we're not assuming the CTRs are equal. Instead, we're trying to estimate the actual true difference between the two groups. The unpooled standard error correctly uses each group's individual observed CTR to reflect this.

We then multiply this `unpooled_se` by the `z_critical` value to get the margin of error. Adding and subtracting this `margin_error` from the observed `absolute_diff` gives us the upper and lower bounds of the CI. This range shows where the true difference between the two population CTRs most likely lies.

(ps. The analysis code was adapted from [A Complete Guide to A/B Testing in Python](https://www.kdnuggets.com/a-complete-guide-to-a-b-testing-in-python))

Now, the function is ready to use. Let's find all the requied parameters. 
```py
# find total click and impression
# control
total_control_click = control_group['# of Website Clicks'].sum()
total_control_impression = control_group['# of Impressions'].sum()

# test
total_test_click = test_group['# of Website Clicks'].sum()
total_test_impression = test_group['# of Impressions'].sum()

print(f"total control click: {total_control_click}\n"
      f"total control impression: {total_control_impression}\n"
      f"total test click: {total_test_click}\n"
      f"total test impression: {total_test_impression}")
```
We got the required parameters:
- total control click: 159527.0
- total control impression: 3290663.0
- total test click: 180970
- total test impression: 2237544

Finally, we added all the number in the `ab_test()` function.
```py
ab_test(159527, 3290663, 180970, 2237544, signigicant_level=0.05)
```
The results are below:
![A/B testing result](https://raw.githubusercontent.com/bbamyaphatt/project/main/images/AB%20Testing%20Result.png)
- The **control conversion rate is 0.048**, while the **test conversion rate is 0.081**. The **absolute difference** between these is **0.032 percentage points**.
Considering this, the test conversion rate shows a strong positive impact compared to the control, with a **relative difference of 66.83%**.
- The **Z-score is 155.53**, which is **extremely high**. This indicates that the observed difference between the control and test conversion rates is more than 155 standard errors away from zero.
- **A P-value of 0.0** is expected with such a high Z-score. This shows that a p-value less than 0.05 means the difference between these two groups is statistically significant and unlikely due to random chance.
- The **95% confidence interval** for the absolute difference is **[0.0319 - 0.0328]**. This means we are 95% confident that the true difference in conversion rates between the populations lies within this range.
Since the entire interval is above zero, it indicates that the test group performed significantly better than the control group. The fact that the interval does not include zero further confirms that this difference is not due to random chance.
- Both the p-value and the confidence interval directly align and provide strong evidence to reject the null hypothesis (H0)
  
### Conclusion
From the above results, we can draw a conclusion that using the new CTA version can significantly increase CTRs. 
The absolute difference between the two groups is 0.032 percentage points, representing a relative difference of 66.83%. 
A P-value of 0.0 and a 95% confidence interval lying in the range [0.0319 - 0.0328], not including zero, indicate that this is not due to random chance.

Increasing CTRs doesn't solely rely on the method of writing captions, but also involves factors like CTA, layout, headlines, quality of images and videos, and more. 
We can statistically test these by performing A/B methods to find which approaches are most beneficial for the business.
