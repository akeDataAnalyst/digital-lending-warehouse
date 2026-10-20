# **M-Pesa Digital Lending Data Warehouse & Risk Analytics Engine**

A production-style SQL Data Warehouse and BI Analytics Control Tower engineered to process, model, and monitor digital micro-lending transactions across the Safaricom Ethiopia (M-Pesa) ecosystem.

---

## **Description**

This project models an end-to-end FinTech analytical data pipeline—from synthetic raw data generation and staging transformations to a star-schema production warehouse and an interactive Streamlit Executive Control Tower (`app.py`). 

The warehouse integrates multi-domain telemetry across customer KYC profiles, daily GSM airtime/data activity, M-Pesa wallet transactions, loan origination applications, active loan balances, repayment schedules, and collection channel events. It enforces standardized credit risk KPIs—including Non-Performing Loan (NPL) rates, Portfolio at Risk (PAR), and Days Past Due (DPD) delinquency aging buckets—giving executive decision-makers full visibility into credit risk and repayment channel efficiency across all Ethiopian administrative regions.

---

## **Problem Statement**

Digital financial services (DFS) platforms generate high-velocity telemetry across disparate transactional systems. At Safaricom Ethiopia, evaluating M-Pesa digital microloan performance presents key analytical challenges:

1. **Siloed & Unstructured Data:** Customer profiles, wallet transactions, and core banking loan records reside in separate operational databases with inconsistent phone number formatting, variable date formats, and unstandardized categorical labels.
2. **Lack of Single Source of Truth:** Absence of governed metric definitions leads to conflicting figures for default rates, active exposure, and collection rates across regional teams.
3. **Inability to Track Channel Efficiency:** Operations leadership lacks visibility into how collection performance and delinquency roll-rates vary across customer touchpoints.
4. **Delayed Credit Risk Monitoring:** Traditional month-end manual reporting delays detection of non-performing loans, exposing the business to elevated credit default risks.

---

## **The Solution**

To solve these challenges, this project implements a multi-tiered, governed Star-Schema Data Warehouse coupled with an interactive Streamlit BI Control Tower:

### **Key Architectural Layers:**
- **Raw Layer:** High-fidelity synthetic source datasets strictly aligned with Safaricom Ethiopia operational standards 
- **Staging Layer:** SQL views performing data type casting, whitespace trimming, uppercase code standardization, and null handling.
- **Clean / Production Layer:** Primary/foreign key enforced star-schema dimensional models with explicit performance indexes and embedded business logic.
- **Analytics & BI Control Tower:** Executive multi-view Streamlit dashboard serving top-level KPIs, regional risk heatmaps, delinquency aging distributions, and repayment channel performance metrics.

---

## **Tech Stack**

- **Database Engine:** MySQL 8.0 / PostgreSQL (DDL, DML, Window Functions, Views, CTEs, Foreign Keys, Indexes)
- **Data Engineering & Processing:** Python 3.13, Pandas, NumPy, SQLAlchemy, PyMySQL
- **Visualization & BI Dashboard:** Streamlit, Matplotlib/Plotly
- **Data Standards:** Safaricom Ethiopia M-Pesa Standards (`+251 7` prefixes, 14 Ethiopian Administrative Regions, Official M-Pesa Channels)
- **Version Control & Docs:** Git, GitHub, Markdown

---

## **Core Business & Risk Metrics Implemented**

| Metric | Business Definition | Formula / Logic |
| :--- | :--- | :--- |
| **Gross Loan Portfolio** | Sum of total principal disbursed across all active & historical loans | `SUM(disbursement_amount)` |
| **Outstanding Exposure** | Current outstanding balance owed across active & defaulted portfolio | `SUM(outstanding_balance)` |
| **Portfolio NPL Rate (%)** | Percentage of total portfolio loans classified as Non-Performing (90+ DPD / Defaulted) | `(SUM(is_npl_flag) / COUNT(loan_id)) * 100` |
| **Delinquency Aging (DPD)**| Categorization of payments into risk tiers based on days past due | `Current (0 DPD)`, `1-7 DPD`, `8-30 DPD`, `31-60 DPD`, `61-90 DPD`, `90+ DPD` |
| **On-Time Collection Rate**| Proportion of repayments collected with zero days past due | `(On-Time Payments / Total Repayment Txns) * 100` |

---

## **Executive Recommendations & Business Insights**

1. **Weekly PAR 30 & Roll-Rate Tracking:** Transition credit risk oversight from monthly NPL reporting to active weekly PAR 30 tracking. Early intervention on 1–30 DPD accounts prevents migration into hard default (90+ DPD).
2. **Channel-Specific Repayment Optimization:** Promote auto-debit via M-PESA App and push notifications. Data shows self-service digital channels exhibit higher on-time collection rates compared to physical Agent Network cash-ins.
3. **Regional Risk-Based Credit Limits:** Adjust loan underwriting caps dynamically based on regional default rates. Regions demonstrating elevated NPL ratios should undergo lower initial credit caps until repayment tenure matures.
4. **Reconciliation Automation:** Enforce continuous daily automated mass-balance reconciliation between mobile money wallet cash-in records and credit management platform loan repayments prior to publishing risk statements.

---

**Developed by: Aklilu Abera | Data Analyst**
