# End‑to‑end Data Analytics Case Study: SQL, Python, A/B Testing, Unit Economics
## Project Overview
FitLife is a subscription‑based mobile fitness app operating on a Freemium model with a 7‑day trial followed by a $9.99 monthly plan. Rising acquisition costs, low trial‑to‑paid conversion, and early‑month retention decay signal inefficiencies across both acquisition and retention funnels. This end‑to‑end analytics project evaluates funnel performance, user behavior, retention patterns, unit economics, and a statistically powered A/B test of a redesigned Paywall to quantify its financial impact and provide actionable recommendations for sustainable growth.

## Dataset & Tools
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
All business impact calculations (including A/B uplift and revenue estimation) are scaled to FitLife’s real annual traffic of 1,200,000 users, reflecting the actual product environment.

## Funnel & Cohort Analysis (SQL)
The analysis is based on three core tables:

- users — user profiles, acquisition source, registration date, device
- activity — user events including trial activation and weekly activity
- transactions — payment records and statuses

Using these tables, I calculated:

- Total users per acquisition channel
- Trial activation rate (CR_to_trial)
- Trial‑to‑paid conversion rate (CR_trial_to_paid)
- Paying users
- Weekly cohort size
- Weekly active users
- Weekly retention rate

### Funnel Results
Below is the final funnel table aggregated by acquisition channel:

<img width="872" height="111" alt="image" src="https://github.com/user-attachments/assets/0a6a2be0-ce21-4510-a898-bcf85936de5e" />

The funnel reveals:

- Weak acquisition quality in several channels
- Low monetization efficiency
- Retention issues across multiple cohorts

## Retention Visualization (Python)
To complement the weekly retention signals identified in the SQL analysis (early‑week engagement decay and isolated anomalies), the retention data was aggregated into monthly cohorts to visualize long‑term subscription behavior. This provides a higher‑level view of how user engagement evolves across the lifecycle and highlights structural retention patterns that are not always visible in weekly granularity.

Key findings from the monthly retention heatmap:

- Retention drops sharply after Month 1, indicating that most users disengage shortly after the trial-to-paid transition.
- Month 2–3 show consistent mid‑lifecycle decay, confirming that early onboarding alone is not sufficient to sustain engagement.
- Later months reveal accelerated decline for several cohorts, suggesting that long‑term value perception weakens over time.
- Overall retention curve aligns with unit economics, reinforcing that improving early‑month engagement is critical for increasing LTV.

The heatmap below summarizes monthly cohort retention and visually highlights these patterns.

![Retention Heatmap](retention_heatmap_percent.png)

## Unit Economics Analysis
Key metrics:

- AOV: $9.99
- Average lifespan: 4.2 months
- LTV: $41.95
- CAC: varies by channel
- LTV/CAC: ≈ 1.4× (borderline sustainable)
- ROMI: negative for several channels

Conclusion: FitLife cannot scale acquisition without improving conversion or reducing CAC.

## A/B Test — New Paywall Design
### Hypothesis
A redesigned Paywall highlighting the annual discount will increase trial‑to‑paid conversion by reducing decision friction.

### Experiment Setup
- Baseline CR: 1.5%
- MDE: +20% relative
- Power: 80%
- Significance level: 5%
- Required sample size: ~23,500 users per group

### Results
- Control (A): 1.50%
- Variant (B): 1.87%
- Uplift: +24%
- p‑value: < 0.05 → statistically significant

Conclusion: The new Paywall significantly improves conversion and should be rolled out to all users.

## Business Impact
With annual traffic of 1,200,000 users:

- Control: 18,000 buyers
- Variant B: 22,440 buyers
- Additional buyers: +4,440
- Incremental revenue: +$186,258 (based on LTV $41.95)

The redesigned Paywall provides a clear and measurable financial benefit.

## Key Insights
- High‑volume channels deliver low trial activation, indicating inefficient marketing spend.
- Trial‑to‑paid conversion is significantly lower on Android, suggesting UX or Paywall issues.
- Week 22 cohort shows abnormal retention drop, likely due to technical or traffic‑quality problems.
- Retention consistently declines in Weeks 2–3, confirming mid‑lifecycle engagement issues.
- Unit economics are borderline sustainable (LTV/CAC ≈ 1.4×), limiting growth potential.
- The new Paywall increases conversion by +24% (statistically significant).
- Rolling out the new Paywall yields an estimated +$186k in annual incremental revenue.

## Recommendations
- Roll out the new Paywall globally
- Improve onboarding flow and early‑week engagement
- Investigate Week 22 technical logs
- Reallocate budget from low‑performing channels
- Strengthen mid‑lifecycle retention mechanics (pushes, challenges, content)

## Repository Structure

## Summary
This end‑to‑end analytics project demonstrates:

- SQL data extraction
- Funnel and cohort analysis
- Python visualization
- Unit economics modeling
- A/B testing with statistical validation
- Business impact estimation

It showcases the full workflow of a product data analyst and provides a realistic example of how data drives product decisions.
