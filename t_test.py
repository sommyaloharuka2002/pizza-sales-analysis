"""
Script: Two-Sample T-Test (Question 1 - Peak Basket Analysis)
Objective: Compare order quantities between Lunch (12-14) and Dinner (17-20).
Hypotheses:
- H0: Mean order quantities for lunch and dinner are equal.
- Ha: Mean order quantities are significantly different.
"""

import sqlite3
import pandas as pd
from scipy.stats import ttest_ind

conn = sqlite3.connect('pizza_sales.db')

t_query = """
SELECT 
    o.order_id,
    SUM(od.quantity) AS order_quantity,
    CASE 
        WHEN strftime('%H', o.time) BETWEEN '12' AND '14' THEN 'Lunch'
        WHEN strftime('%H', o.time) BETWEEN '17' AND '20' THEN 'Dinner'
    END AS meal_time
FROM order_details od 
JOIN orders o ON od.order_id = o.order_id
WHERE strftime('%H', o.time) BETWEEN '12' AND '14' 
   OR strftime('%H', o.time) BETWEEN '17' AND '20'
GROUP BY o.order_id;
"""

df_t = pd.read_sql(t_query, conn)
conn.close()

lunch_baskets = df_t[df_t['meal_time'] == 'Lunch']['order_quantity']
dinner_baskets = df_t[df_t['meal_time'] == 'Dinner']['order_quantity']

t_stat, p_val_t = ttest_ind(lunch_baskets, dinner_baskets)

print(f"T-Test Statistisc Test : {t_stat:.4f}")
print(f"P-Value: {p_val_t}")

alpha = 0.05
if p_val_t < alpha:
    print("\nResult: Reject the Null Hypothesis")
    print("Conclusion: There is a statistically significant difference in average order sizes between lunch and dinner.")
else:
    print("\nResult: Fail to Reject the Null Hypothesis")   
    print("Conclusion: There is no statistically significant difference in average order sizes; lunch and dinner baskets are comparable.") 