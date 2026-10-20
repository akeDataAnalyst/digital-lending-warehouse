USE safaricom_lending_dw;

-- 1. OVERALL PORTFOLIO SUMMARY & NPL RATE
-- Calculates total disbursed volume, outstanding balances, and Non-Performing Loan (NPL) rate

SELECT 
    COUNT(l.loan_id) AS total_loans_disbursed,
    SUM(l.disbursement_amount) AS total_disbursed_volume,
    SUM(l.outstanding_balance) AS total_outstanding_balance,
    SUM(l.is_npl_flag) AS total_npl_loans,
    ROUND((SUM(l.is_npl_flag) / COUNT(l.loan_id)) * 100, 2) AS portfolio_npl_rate_pct
FROM fact_loan l;

-- 2. REGIONAL CREDIT RISK BREAKDOWN
-- Analyzes loan performance, default rates, and exposure across Ethiopian regions

SELECT 
    c.region,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.disbursement_amount) AS total_disbursed,
    SUM(l.outstanding_balance) AS outstanding_exposure,
    SUM(l.is_npl_flag) AS defaulted_loans,
    ROUND((SUM(l.is_npl_flag) / COUNT(l.loan_id)) * 100, 2) AS regional_npl_rate_pct
FROM fact_loan l
JOIN dim_customer c ON l.customer_id = c.customer_id
GROUP BY c.region
ORDER BY regional_npl_rate_pct DESC;

-- 3. REPAYMENT CHANNEL PERFORMANCE & ADOPTION
-- Evaluates collection volume and delinquency (DPD buckets) by official M-Pesa touchpoints

SELECT 
    r.payment_channel,
    COUNT(r.repayment_id) AS total_repayment_transactions,
    SUM(r.amount_paid) AS total_amount_collected,
    ROUND(AVG(r.dpd_at_payment), 1) AS avg_days_past_due,
    SUM(CASE WHEN r.dpd_at_payment = 0 THEN 1 ELSE 0 END) AS on_time_repayments,
    ROUND((SUM(CASE WHEN r.dpd_at_payment = 0 THEN 1 ELSE 0 END) / COUNT(r.repayment_id)) * 100, 2) AS on_time_collection_rate_pct
FROM fact_repayment r
GROUP BY r.payment_channel
ORDER BY total_amount_collected DESC;

-- 4. DELINQUENCY AGING (DPD BUCKET DISTRIBUTION)
-- Breaks down repayment volume and counts across standard risk aging buckets

SELECT 
    dpd_bucket,
    COUNT(repayment_id) AS repayment_count,
    SUM(amount_paid) AS total_collected_amount,
    ROUND((COUNT(repayment_id) / (SELECT COUNT(*) FROM fact_repayment)) * 100, 2) AS distribution_pct
FROM fact_repayment
GROUP BY dpd_bucket
ORDER BY MIN(dpd_at_payment);