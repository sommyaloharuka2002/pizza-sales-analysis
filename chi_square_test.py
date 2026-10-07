"""
=============================================================================
Portfolio Project: Pizza Sales Data Analysis
Script: Chi-Square Test of Independence (Question 5)
-----------------------------------------------------------------------------
Objective: 
Determine whether customer category preferences (e.g., Veg, Non-Veg) 
significantly depend on the day of the week, or if orders are distributed 
randomly regardless of the day.

Hypothesis:
- Null Hypothesis (H0): Category preferences are independent of the day of the week.
- Alternative Hypothesis (Ha): Category preferences depend on the day of the week.
=============================================================================
"""

import sqlite3
import pandas as pd
from scipy.stats import chi2_contingency

conn = sqlite3.connect('pizza_sales.db')

query = """
    WITH category_totals AS (
    SELECT 
        strftime('%w', o.date) AS days_num,
        CASE strftime('%w', o.date)
            WHEN '0' THEN 'Sunday' 
            WHEN '1' THEN 'Monday'
            WHEN '2' THEN 'Tuesday'
            WHEN '3' THEN 'Wednesday'
            WHEN '4' THEN 'Thursday'
            WHEN '5' THEN 'Friday'
            WHEN '6' THEN 'Saturday'
        END AS days,
        pt.category AS category, 
       COUNT(*) AS order_count 
    FROM order_details od 
    JOIN orders o ON od.order_id = o.order_id 
    JOIN pizzas p ON od.pizza_id = p.pizza_id 
    JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
    GROUP BY strftime('%w', o.date), category
)
SELECT days, category, order_count 
FROM category_totals
ORDER BY days_num;
"""

df = pd.read_sql(query, conn)
conn.close()

contingency_table = df.pivot(index= 'days', columns= 'category', values= 'order_count')

day_order = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday']
contingency_table = contingency_table.reindex(day_order)
contingency_table = contingency_table.fillna(0)

print("---Contingency Table---")
print(contingency_table)
print("\n" + "=" *40 + "\n")

chi2_stat, p_val, dof, expected = chi2_contingency(contingency_table)

print(f"Chi-Square Statistic Test : {chi2_stat:.4f}")
print(f"Degree of Freedom: {dof}")
print(f"P-Value: {p_val}")

alpha = 0.05
if p_val < alpha:
    print("\nResult: Reject the Null Hypothesis")
    print("Conclusion: Category Preferences DO significantly depend on the days of the week")
else:
    print("\nResult: Fail to Reject the Null Hypothesis")   
    print("Conclusion: There is no statistically significant relationship between category preferences and days") 