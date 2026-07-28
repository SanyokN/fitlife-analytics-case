# End‑to‑end Data Analytics Case Study: SQL, Python, A/B Testing, Unit Economics
## Project Overview
**FitLife** is a subscription‑based fitness app with a 7‑day trial followed by a $9.99 monthly plan. Rising CAC, low trial‑to‑paid conversion, and early retention decay indicate inefficiencies across acquisition and lifecycle funnels. This project evaluates funnel performance, retention patterns, unit economics, and a statistically powered A/B test of a redesigned Paywall.

## Tools & Metrics
### SQL (PostgreSQL)
- Funnel analysis
- Cohort retention
- Weekly activity metrics
### Python: Pandas, NumPy, Seaborn, Matplotlib, Statsmodels
- Exploratory analysis
- Visualization
- Statistical testing
### Jupyter Notebook
- Interactive workflow
- Data exploration
### Key Metrics
- CR_to_trial
- CR_trial_to_paid
- Retention
- LTV
- CAC
- ROMI

### Note on Dataset Size
The SQL dataset is synthetic and intentionally small to demonstrate funnel logic, table structure, and analytical queries.
All business impact calculations (including A/B uplift and revenue estimation) are scaled to FitLife’s **real annual traffic of 1,200,000 users**, reflecting the actual product environment.

## Funnel Analysis (SQL)
The analysis is based on three core tables:

- **users** — user profiles, acquisition source, registration date, device
- **activity** — user events including trial activation and weekly activity
- **transactions** — payment records and statuses

Using these tables, I calculated:

- Total users per acquisition channel
- Trial activation rate (**CR_to_trial**)
- Trial‑to‑paid conversion rate (**CR_trial_to_paid**)
- Paying users
- Weekly cohort size
- Weekly active users
- Weekly retention rate

### SQL Query
```sql
SELECT
    channel,
    COUNT(*) AS users,
    SUM(CASE WHEN trial_start IS NOT NULL THEN 1 END) AS trial_users,
    SUM(CASE WHEN is_paying = TRUE THEN 1 END) AS paying_users,
    ROUND(trial_users * 100.0 / users, 2) AS cr_to_trial,
    ROUND(paying_users * 100.0 / trial_users, 2) AS cr_trial_to_paid
FROM users
GROUP BY channel;
```

### Funnel Results

<img width="872" height="111" alt="image" src="https://github.com/user-attachments/assets/0a6a2be0-ce21-4510-a898-bcf85936de5e" />

The funnel reveals:

- Organic delivers perfect performance (100% trial activation and 100% trial‑to‑paid) — every user completes the entire funnel without drop‑off
- Instagram provides moderate lead quality (50% trial activation), but converts all trial users into paying customers (100%)
- Facebook shows complete funnel failure (0% trial activation and 0% trial‑to‑paid) — the channel generates no engaged or paying users

## Retention Visualization (Python)
To extend the weekly retention signals from the SQL analysis, the data was aggregated into **monthly cohorts** to highlight long‑term engagement patterns.

### Code
```python
# Cohort pivot
cohort_pivot = df.groupby(['cohort_month', 'month_number'])['user_id'] \
                 .nunique() \
                 .unstack()

# Normalize retention
retention = cohort_pivot.div(cohort_pivot.iloc[:, 0], axis=0)

# Heatmap
sns.heatmap(retention, annot=True, fmt=".0%", cmap="Blues")
```
### Visualization

![Retention Heatmap](retention_heatmap_percent.png)

### Key Insights
- **Retention declines consistently across all cohorts**, with the steepest drop occurring between month 0 and month 1
- **Later cohorts (Apr–Jun) follow nearly identical retention curves**, indicating stable user behavior over time
- **Long‑term retention stabilizes around 45–55%**, suggesting a predictable baseline of recurring users

## Unit Economics
### Code
```python
LTV = AOV * lifespan_months
ROMI = (LTV - CAC) / CAC
```

### Key metrics

| Metric        | Value        |
|---------------|--------------|
| AOV           | $9.99        |
| Lifespan      | 4.2 months   |
| LTV           | $41.95       |
| CAC           | varies       |
| LTV/CAC       | ≈ 1.4×       |
| ROMI          | negative for several channels |

### Key Insights
FitLife cannot scale acquisition efficiently without improving conversion or reducing CAC. Retention improvements would directly increase LTV and unlock sustainable growth.

## A/B Test — New Paywall Design
### Hypothesis
A redesigned Paywall highlighting the annual discount will increase trial‑to‑paid conversion by reducing decision friction.

### Experiment Setup
- Baseline CR: **1.5%**
- MDE: **+20% relative**
- Power: **80%**
- Significance level: **5%**
- Required sample size: **~23,500 users per group**

### Results
| Group    | Conversion | Buyers  |
|----------|------------|---------|
| Control  | 1.50%      | 18,000  |
| Variant  | 1.87%      | 22,440  |

### Statistical Significance
| Metric   | Value   |
|----------|---------|
| Uplift   | +24%    |
| p-value  | < 0.05  |

### Conclusion
The new Paywall significantly improves conversion and should be rolled out to all users.

## Business Impact
With annual traffic of **1,200,000 users**:

| Metric                | Value        |
|-----------------------|--------------|
| Control buyers        | 18,000       |
| Variant buyers        | 22,440       |
| Additional buyers     | +4,440       |
| Incremental revenue   | +$186,258    |

The redesigned Paywall provides a clear and measurable financial benefit.

### Executive Insights
- High‑volume channels deliver low trial activation, indicating inefficient marketing spend.
- Trial‑to‑paid conversion is significantly lower on Android, suggesting UX or Paywall issues.
- Monthly retention shows structural decay after Month 1, needing onboarding improvements.
- Unit economics are borderline sustainable (LTV/CAC ≈ 1.4×), limiting growth potential.
- The new Paywall increases conversion by +24% (statistically significant).
- Rolling out the new Paywall yields an estimated **+$186k** in annual incremental revenue.

## Recommendations
- Roll out the new Paywall globally
- Improve onboarding flow and early‑week engagement
- Reallocate budget from low‑performing channels
- Strengthen mid‑lifecycle retention mechanics (pushes, challenges, content)

## Repository Structure

```bash
fitlife-analytics/
├── data/
│   ├── users.csv
│   ├── activity.csv
│   └── transactions.csv
│
├── sql/
│   ├── funnel_analysis.sql
│   ├── retention_weekly.sql
│   └── cohort_monthly.sql
│
├── python/
│   ├── retention_heatmap.ipynb
│   ├── ab_test_analysis.ipynb
│   └── unit_economics.ipynb
│
├── visuals/
│   ├── funnel_results.png
│   ├── retention_heatmap.png
│   └── paywall_ab_test.png
│
├── docs/
│   └── README.md
│
└── requirements.txt
```

## Summary
This end‑to‑end analytics project demonstrates:

- SQL data extraction
- Funnel and cohort analysis
- Python visualization
- Unit economics modeling
- A/B testing with statistical validation
- Business impact estimation

It showcases the full workflow of a product data analyst and provides a realistic example of how data drives product decisions.
