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
WITH user_funnel AS (
    SELECT 
        u.id AS user_id,
        u.source,
        COUNT(CASE WHEN a.event_name = 'trial_activated' THEN 1 END) AS activated_trial,
        COUNT(CASE WHEN t.payment_status = 'completed' THEN 1 END) AS paid
    FROM users u
    LEFT JOIN activity a ON u.id = a.user_id
    LEFT JOIN transactions t ON u.id = t.user_id
    GROUP BY u.id, u.source
)
SELECT 
    source,
    COUNT(user_id) AS total_users,
    -- Conversion to Trial (%)
    ROUND(SUM(CASE WHEN activated_trial > 0 THEN 1 ELSE 0 END)::numeric / COUNT(user_id) * 100, 2) AS cr_to_trial,
    -- Conversion from Trial to Paid (%)
    ROUND(SUM(CASE WHEN paid > 0 THEN 1 ELSE 0 END)::numeric / NULLIF(SUM(CASE WHEN activated_trial > 0 THEN 1 ELSE 0 END), 0) * 100, 2) AS cr_trial_to_paid
FROM user_funnel
GROUP BY source
ORDER BY total_users DESC;
```

### Funnel Results

<img width="872" height="111" alt="image" src="https://github.com/user-attachments/assets/0a6a2be0-ce21-4510-a898-bcf85936de5e" />

### Key Insights

- Organic traffic converts perfectly.
- Instagram sends moderate‑quality leads but converts all trial users.
- Facebook delivers **zero** trial activations.

## Retention Analysis (Python)
### Code (key parts)
```python
cohort_pivot = df.groupby(['cohort_week', 'week_number'])
retention = cohort_pivot.div(cohort_pivot.iloc[:,0], axis=0)
sns.heatmap(retention, annot=True, fmt=".0%", cmap="Blues")
```

### Retention Heatmap

![Retention Heatmap](retention_heatmap_weekly.png)

### Key Insights
- Largest drop occurs between **Week 0 and Week 1** (dropping to ~35–41%).
- Later cohorts follow nearly identical curves, indicating stable long‑term behavior.
- Retention decays steadily, stabilizing around **11–12% by Week 4**.
- Cohort **Week 22** shows an noticeable retention dip at Week 2 (18.2%), suggesting possible technical issues or poor acquisition traffic during that period.

## Unit Economics
### Code (key parts)
```python
LTV = AOV * lifespan_months
ROMI = ((LTV - CAC) / CAC) * 100
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
FitLife cannot scale efficiently without improving conversion or reducing CAC. Retention improvements directly increase LTV and unlock sustainable growth.

## A/B Test — New Paywall Design
### Hypothesis
A redesigned Paywall will increase trial‑to‑paid conversion.

### Results
| Group    | Conversion | Buyers  |
|----------|------------|---------|
| Control  | 1.50%      | 18,000  |
| Variant  | 1.87%      | 22,440  |

- **Uplift**: +24.7%
- **p-value**: < 0.05 (statistically significant)

## Business Impact
Annual traffic: **1,200,000 users**:

| Metric                | Value        |
|-----------------------|--------------|
| Additional buyers     | +4,440       |
| Incremental revenue   | +$186,258    |

### Conclusion
The redesigned Paywall significantly improves conversion and should be rolled out globally.

## Executive Insights
- High‑volume channels deliver weak trial activation, indicating inefficient spend.
- Android users convert worse, suggesting UX/Paywall issues.
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
This project demonstrates the full workflow of a product data analyst:

**SQL → Python → Cohorts → Unit Economics → A/B Testing → Business Impact.**
