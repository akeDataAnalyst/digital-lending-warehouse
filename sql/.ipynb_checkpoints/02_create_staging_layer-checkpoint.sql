USE safaricom_lending_dw;

-- 1. Staging Customer Dimension
CREATE OR REPLACE VIEW stg_dim_customer AS
SELECT 
    TRIM(customer_id) AS customer_id,
    TRIM(wallet_id) AS wallet_id,
    TRIM(msisdn) AS msisdn,
    TRIM(region) AS region,
    UPPER(TRIM(kyc_status)) AS kyc_status,
    CAST(tenure_days AS UNSIGNED) AS tenure_days,
    CAST(created_date AS DATE) AS customer_creation_date
FROM raw_dim_customer;

-- 2. Staging Daily GSM Activity
CREATE OR REPLACE VIEW stg_fact_gsm_activity_daily AS
SELECT 
    CAST(activity_date AS DATE) AS activity_date,
    TRIM(customer_id) AS customer_id,
    COALESCE(airtime_topup_amount, 0.00) AS airtime_topup_amount,
    COALESCE(data_bundle_purchased, 0) AS data_bundle_purchased,
    COALESCE(voice_calls_duration_mins, 0) AS voice_calls_duration_mins,
    COALESCE(is_active_flag, 0) AS is_active_flag
FROM raw_fact_gsm_activity_daily;

-- 3. Staging Wallet Transactions
CREATE OR REPLACE VIEW stg_fact_wallet_transaction AS
SELECT 
    TRIM(transaction_id) AS transaction_id,
    TRIM(wallet_id) AS wallet_id,
    TRIM(customer_id) AS customer_id,
    CAST(transaction_timestamp AS DATETIME) AS transaction_timestamp,
    UPPER(TRIM(transaction_type)) AS transaction_type,
    CAST(amount AS DECIMAL(12,2)) AS amount,
    CAST(running_balance AS DECIMAL(12,2)) AS running_balance,
    UPPER(TRIM(status)) AS transaction_status
FROM raw_fact_wallet_transaction;

-- 4. Staging Loan Applications
CREATE OR REPLACE VIEW stg_fact_loan_application AS
SELECT 
    TRIM(application_id) AS application_id,
    TRIM(customer_id) AS customer_id,
    TRIM(product_id) AS product_id,
    CAST(application_timestamp AS DATETIME) AS application_timestamp,
    CAST(requested_amount AS DECIMAL(12,2)) AS requested_amount,
    UPPER(TRIM(decision)) AS application_decision,
    CAST(approved_amount AS DECIMAL(12,2)) AS approved_amount,
    COALESCE(UPPER(TRIM(decline_reason)), 'N/A') AS decline_reason
FROM raw_fact_loan_application;

-- 5. Staging Loans
CREATE OR REPLACE VIEW stg_fact_loan AS
SELECT 
    TRIM(loan_id) AS loan_id,
    TRIM(application_id) AS application_id,
    TRIM(customer_id) AS customer_id,
    TRIM(product_id) AS product_id,
    CAST(disbursement_timestamp AS DATETIME) AS disbursement_timestamp,
    CAST(disbursement_amount AS DECIMAL(12,2)) AS disbursement_amount,
    CAST(term_days AS UNSIGNED) AS term_days,
    CAST(due_date AS DATE) AS due_date,
    CAST(total_due_amount AS DECIMAL(12,2)) AS total_due_amount,
    CAST(outstanding_balance AS DECIMAL(12,2)) AS outstanding_balance,
    UPPER(TRIM(loan_status)) AS loan_status
FROM raw_fact_loan;

-- 6. Staging Repayment Schedule
CREATE OR REPLACE VIEW stg_fact_repayment_schedule AS
SELECT 
    TRIM(loan_id) AS loan_id,
    CAST(installment_number AS UNSIGNED) AS installment_number,
    CAST(due_date AS DATE) AS due_date,
    CAST(amount_due AS DECIMAL(12,2)) AS amount_due
FROM raw_fact_repayment_schedule;

-- 7. Staging Repayments
CREATE OR REPLACE VIEW stg_fact_repayment AS
SELECT 
    TRIM(repayment_id) AS repayment_id,
    TRIM(loan_id) AS loan_id,
    CAST(payment_timestamp AS DATETIME) AS payment_timestamp,
    CAST(amount_paid AS DECIMAL(12,2)) AS amount_paid,
    CAST(dpd_at_payment AS UNSIGNED) AS dpd_at_payment,
    UPPER(TRIM(payment_channel)) AS payment_channel
FROM raw_fact_repayment;