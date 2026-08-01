# FitLife Analytics — End‑to‑End Data Analytics Case Study
### SQL • Python • Cohorts • Unit Economics • A/B Testing
This case study analyzes FitLife’s funnel performance, retention behavior, unit economics, and A/B test results to identify growth bottlenecks and quantify the impact of a redesigned Paywall.

## Project Overview
FitLife is a subscription‑based fitness app offering a **7‑day trial** followed by a **$9.99 monthly plan**.
The analysis focuses on:

- Funnel conversion by acquisition channel
- Weekly and monthly retention patterns
- LTV, CAC efficiency, and ROMI
- A/B test of a redesigned Paywall
- Business impact and strategic recommendations

The dataset is synthetic for SQL logic but scaled to FitLife’s real annual traffic of **1,200,000 users**.

## Tools & Metrics
- **SQL (PostgreSQL)** — funnel analysis, weekly retention, monthly cohorts
- **Python (Pandas, Seaborn, Statsmodels)** — cohort visualization, statistical testing

**Key Metrics**:

CR_to_trial • CR_trial_to_paid • Retention • LTV • CAC • ROMI

## Funnel Analysis (SQL)
### SQL Query
```sql
WITH trial_users AS (
    SELECT user_id
    FROM activity
    WHERE event_name = 'trial_activated'
    GROUP BY user_id
),
paying_users AS (
    SELECT user_id
    FROM transactions
    WHERE payment_status = 'completed'
    GROUP BY user_id
)
SELECT
    u.source,
    COUNT(u.id) AS total_users,
    COUNT(t.user_id) AS trial_users,
    ROUND(COUNT(t.user_id)::numeric / COUNT(u.id) * 100, 2) AS cr_to_trial,
    COUNT(p.user_id) AS paying_users,
    ROUND(COUNT(p.user_id)::numeric / NULLIF(COUNT(t.user_id), 0) * 100, 2) AS cr_trial_to_paid
FROM users u
LEFT JOIN trial_users t ON u.id = t.user_id
LEFT JOIN paying_users p ON t.id = p.user_id
GROUP BY u.source
ORDER BY total_users DESC;
```

### Funnel Results
<img width="1022" height="135" alt="image" src="https://github.com/user-attachments/assets/d1b4c781-46f1-4c07-b1d9-a050f34b21ed" />

### Key Insights

* **Organic** is the top-performing acquisition channel, leading in trial conversion rate (**13.43%**).
* **Instagram** delivers the highest-quality leads, achieving the top trial-to-paid conversion rate (**15.91%**).
* **TikTok** generated 300 users but showed a **0%** trial-to-paid conversion rate (`cr_trial_to_paid = 0`).

## Retention Analysis (Python)
### Code (key parts)
```python
# Retention Heatmap Generation (Key Snippet)
plt.figure(figsize=(10, 5), dpi=300)
sns.set_theme(style="white")

# 1. Plot Heatmap using Seaborn
ax = sns.heatmap(
    cohort_pivot, 
    annot=True, 
    fmt=".1f", 
    cmap="Blues", 
    vmin=0, 
    vmax=100,
    linewidths=1, 
    linecolor='white',
    cbar_kws={'label': '% Retention'},
    annot_kws={"size": 11, "weight": "bold"}
)

# 2. Append '%' symbol to heatmap cell values
for text in ax.texts:
    val = text.get_text()
    if val != 'nan':
        text.set_text(f"{val}%")

# Styling & Export
plt.title('Weekly Retention Rate (%) by User Cohorts', fontsize=14, fontweight='bold', pad=20)
plt.savefig('visuals/retention_heatmap.png', dpi=300, bbox_inches='tight')
```

### Retention Heatmap

![Retention Heatmap](retention_heatmap_weekly.png)

### Key Insights
- The steepest drop occurs immediately after onboarding, with **Week 1 Retention dropping to ~32–41%** across cohorts (a ~60% user churn in the first 7 days).
- Later cohorts follow nearly identical curves, indicating stable long‑term behavior.
- Retention decays steadily, stabilizing around **11–12% by Week 4**.
- Cohort **Week 22** shows an noticeable retention dip at Week 2 (18.2%), suggesting possible technical issues or poor acquisition traffic during that period. 

## Unit Economics
### Code (key parts)
```python
# LTV assuming 100% Gross Margin (pure marginal revenue per subscriber)
LTV = AOV * lifespan_months

# Unit ROMI based on LTV per acquired customer
romi_pct = ((LTV - CAC) / CAC) * 100
```

### Key metrics

| Metric        | Value        |
|---------------|--------------|
| CR1 (Overall Conversion) | 1.5% |
| AOV           | $9.99        |
| Lifespan      | 4.2 months   |
| LTV           | $41.95 (Gross Margin = 100% assumed)      |
| CAC           | $30.0       |
| LTV/CAC       | ≈ 1.4×       |
| ROMI          | +39.8% |

**Note on LTV**: Calculated as AOV * Lifespan * Gross Margin. Gross Margin is assumed to be **100%** (pure marginal revenue per user) for unit economics modeling.

### Key Insights
FitLife cannot scale efficiently without improving conversion or reducing CAC. Retention improvements directly increase LTV and unlock sustainable growth.

## A/B Test — New Paywall Design
### Hypothesis
A redesigned Paywall will increase trial‑to‑paid conversion.

### Results
| Group    | Sample Size (N) | Conversion | Buyers  |
|----------|-|------------|---------|
| Control  | 24,100 | 1.50%      | 362  |
| Variant  | 24,350 | 1.87%      | 455  |

- **Uplift**: +24.7%
- **p-value**: 0.00096 (statistically significant)

## Business Impact

By extrapolating the observed uplift (+24.7%) to our annual traffic of 1.2M users, we project an additional **+4,440 incremental subscribers** per year.

| Metric | Value |
| :--- | :--- |
| Annual Traffic | 1,200,000 users |
| Baseline Buyers (Control) | 18,000 |
| Projected Buyers (Variant B) | 22,440 |
| **Incremental Subscribers** | **+4,440** |
| **Additional Annual Revenue** | **+$186,258** |

> **Note on Revenue Calculation:** Calculated as `4,440 incremental buyers × $41.95 LTV`.

### Conclusion
The redesigned Paywall significantly improves conversion and should be rolled out globally.

## Executive Insights
- High‑volume channels deliver weak trial activation, indicating inefficient spend.
- Retention decays sharply after Week 1, indicating onboarding gaps.
- LTV/CAC ≈ 1.4×, indicating limited scalability.
- The new Paywall delivers a 24% uplift in conversion, resulting in approximately $186k in additional annual revenue.

## Recommendations
- Roll out the new Paywall.
- Improve onboarding and early‑week engagement.
- Shift budget away from low‑performing channels.
- Strengthen mid‑lifecycle retention (pushes, challenges, content).

## Repository Structure

```bash
fitlife-analytics/
├── data/
│   ├── users.csv
│   ├── activity.csv
│   └── transactions.csv
├── sql/
│   ├── funnel_analysis.sql
│   ├── retention_weekly.sql
│   └── cohort_monthly.sql
├── python/
│   ├── retention_heatmap.ipynb
│   ├── ab_test_analysis.ipynb
│   └── unit_economics.ipynb
├── visuals/
│   ├── funnel_results.png
│   ├── retention_heatmap.png
│   └── paywall_ab_test.png
├── docs/
│   └── 
├── .gitignore
├── README.md                  
└── requirements.txt
```

## Summary
This project demonstrates the full workflow of a product data analyst:

**SQL → Python → Cohorts → Unit Economics → A/B Testing → Business Impact.**
