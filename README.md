# FitLife Analytics — End‑to‑End Data Analytics Case Study
### SQL • Python • Cohorts • Unit Economics • A/B Testing
This case study analyzes FitLife’s funnel performance, retention behavior, unit economics, and A/B test results to identify growth bottlenecks and quantify the impact of a redesigned Paywall.

## Project Overview
FitLife is a subscription‑based fitness app offering a **7‑day trial** followed by a **$9.99 monthly plan**.
The analysis focuses on:

- End-to-end funnel conversion by acquisition channel
- Weekly and monthly retention patterns
- LTV, CAC efficiency, and ROMI
- A/B test of a redesigned Paywall
- Business impact and strategic recommendations

The dataset is synthetic for SQL logic but scaled to FitLife’s real annual traffic of **1,200,000 users**.

## Tools & Metrics
- **SQL (PostgreSQL)** — funnel analysis, weekly retention, monthly cohorts
- **Python (Pandas, Seaborn, Statsmodels)** — cohort visualization, statistical testing

### Key Funnel Metrics Definitions

* **UA (User Acquisition):** Total volume of incoming traffic/downloads.
* **Trial Activation Rate ($\text{CR}_{\text{trial}}$):** Percentage of acquired users who activate a 7-day free trial.
* **Trial-to-Paid Conversion ($\text{CR}_{\text{trial}\to\text{paid}}$):** Percentage of trial users who complete their first subscription payment (Paywall efficiency).
* **Overall Conversion Rate ($\text{CR}_1$):** Blended end-to-end conversion rate from initial visit to paying subscriber.
  $$\text{CR}_1 = \text{Trial Activation Rate} \times \text{Trial-to-Paid CR}$$

## Funnel Analysis (SQL)
### SQL Query
```sql
-- Calculate funnel conversion rates (Registration -> Trial -> Paid) by traffic source
SELECT 
    u.source,
    COUNT(DISTINCT u.id) AS total_users,
    COUNT(DISTINCT CASE WHEN a.event_name = 'trial_activated' THEN u.id END) AS trials,
    COUNT(DISTINCT CASE WHEN t.payment_status = 'completed' THEN u.id END) AS paid,
    ROUND(
        COUNT(DISTINCT CASE WHEN a.event_name = 'trial_activated' THEN u.id END) * 100.0 
        / COUNT(DISTINCT u.id), 2
    ) AS cr_to_trial,
    ROUND(
        COUNT(DISTINCT CASE WHEN t.payment_status = 'completed' THEN u.id END) * 100.0 
        / NULLIF(COUNT(DISTINCT CASE WHEN a.event_name = 'trial_activated' THEN u.id END), 0), 2
    ) AS cr_trial_to_paid
FROM users u
LEFT JOIN activity a 
    ON u.id = a.user_id 
   AND a.event_name = 'trial_activated'
LEFT JOIN transactions t 
    ON u.id = t.user_id 
   AND t.payment_status = 'completed'
GROUP BY u.source
ORDER BY total_users DESC;
```

### Funnel Results
<img width="932" height="135" alt="funnel_results" src="https://github.com/user-attachments/assets/d2c92a25-422b-4556-845e-08e88c361b9d" />

&nbsp;

> **Key Takeaway:** 
> While **TikTok** shows critical issues in *Trial Activation* (1.67%), **Instagram** shows the strongest *Trial-to-Paid CR* (15.91%). The aggregated blended baseline **Overall CR1** across all channels is **1.53%**.

### Key Insights

* **Organic** is the top-performing acquisition channel, leading in trial activation rate (**13.43%**).
* **Instagram** delivers the highest-quality leads, achieving the top trial-to-paid conversion rate (**15.91%**).
* **TikTok** generated 300 users but showed a **0%** trial-to-paid conversion rate (`cr_trial_to_paid = 0`).

## Retention Analysis (Python)
### Code (key parts)
```python
# Retention Heatmap Generation (Key Snippet)
plt.figure(figsize=(10, 5), dpi=300)
sns.set_theme(style="white")

# 1. Heatmap Construction (vmax capped at 50)
ax = sns.heatmap(
    cohort_pivot, 
    annot=True, 
    fmt=".1f", 
    cmap="Blues", 
    vmin=0, 
    vmax=50,  # Cap color bar range at 50%
    linewidths=1, 
    linecolor='white',
    cbar_kws={'label': '% Retention'},
    annot_kws={"size": 11, "weight": "bold"}
)

# 2. Title & Axis Customization
plt.title('Weekly Retention Rate (%) by User Cohorts', fontsize=14, fontweight='bold', pad=20)
plt.xlabel('User Lifecycle Stage (Weeks)', fontsize=11, fontweight='bold', labelpad=10)
plt.ylabel('Registration Cohort', fontsize=11, fontweight='bold', labelpad=10)

# 3. Add % Sign to Cell Values
for text in ax.texts:
    val = text.get_text()
    if val != 'nan':
        text.set_text(f"{val}%")

plt.tight_layout()

# 4. Save & Display
plt.savefig('retention_heatmap_weekly.png', dpi=300, bbox_inches='tight')
plt.show()
```

### Retention Heatmap

![Retention Heatmap](visuals/retention_heatmap_weekly.png)

### Key Insights
- The steepest drop occurs immediately after onboarding, with **Week 1 Retention dropping to ~32–41%** across cohorts (a ~60% user churn in the first 7 days).
- Later cohorts follow nearly identical curves, indicating stable long‑term behavior.
- Retention decays steadily, stabilizing around **11–12% by Week 4**.
- Cohort **Week 22** shows an noticeable retention dip at Week 2 (18.2%), suggesting possible technical issues or poor acquisition traffic during that period. 

## Unit Economics
### Code (key parts)
```python
# Calculation of LTV
ltv_raw = aov * lifespan_months * gross_margin

# Unit ROMI based on LTV per acquired customer
romi_raw = ((ltv_raw - cac_raw) / cac_raw) * 100 if cac_raw > 0 else 0
```

### Unit Economics Model Parameters

| Metric | Nomenclature | Value | Note / Formula |
| :--- | :--- | :--- | :--- |
| **Overall Conversion** | `CR1` | **1.53%** | End-to-end conversion ($\text{UA} \to \text{Paid}$) |
| **Trial-to-Paid CR** | `CR_trial_to_paid` | **~12.5%** | Baseline paywall conversion |
| **AOV** | `AOV` | **$9.99** | Monthly subscription price |
| **Customer Lifespan** | `lifespan` | **4.2 months** | Average active lifetime before churn |
| **Lifetime Value** | `LTV` | **$41.96** | AOV * Lifespan * Gross Margin (100%) |
| **Customer Acquisition Cost** | `CAC` | **$30.00** | $\frac{\text{Ad Budget}}{\text{Buyers}}$ |

**Note on LTV**: Calculated as AOV * Lifespan * Gross Margin. Gross Margin is assumed to be **100%** (pure marginal revenue per user) for unit economics modeling.

### Key Insights
FitLife cannot scale efficiently without improving overall conversion (CR1) or reducing CAC. Retention improvements directly increase LTV and unlock sustainable growth.

## A/B Test — New Paywall Design
### Hypothesis
A redesigned Paywall will increase trial‑to‑paid conversion.

### Results
| Group    | Sample Size (N) | Overall CR (CR1) | Buyers  |
|----------|-|------------|---------|
| Control  | 24,100 | 1.53%      | 362  |
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

> **Note on Revenue Calculation:** Calculated as `4,440 incremental buyers × $41.96 LTV`.

### Conclusion
The redesigned Paywall significantly improves trial monetization and should be rolled out globally.

## Executive Insights
- High‑volume channels deliver weak trial activation, indicating inefficient spend.
- Retention decays sharply after Week 1, indicating onboarding gaps.
- LTV/CAC ≈ 1.4×, indicating limited scalability.
- The new Paywall delivers a 24.7% uplift in trial-to-paid conversion, resulting in approximately $186k in additional annual revenue.

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
├── presentation/
│   └── FitLife Analytics Presentation.pdf
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
├── .gitattributes
├── .gitignore
├── README.md                  
└── requirements.txt
```

## Summary
This project demonstrates the full workflow of a product data analyst:

**SQL → Python → Cohorts → Unit Economics → A/B Testing → Business Impact.**
