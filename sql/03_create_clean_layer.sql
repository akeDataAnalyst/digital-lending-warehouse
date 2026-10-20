USE safaricom_lending_dw;

-- Clean Customer Dimension
DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer (
    customer_id VARCHAR(20) PRIMARY KEY,
    wallet_id VARCHAR(20) NOT NULL,
    msisdn VARCHAR(20) NOT NULL,
    region VARCHAR(50) NOT NULL,
    kyc_status VARCHAR(20) NOT NULL,
    tenure_days INT UNSIGNED NOT NULL,
    customer_creation_date DATE NOT NULL,
    INDEX idx_region (region),
    INDEX idx_kyc (kyc_status)
);

-- Clean Loans Fact Table
DROP TABLE IF EXISTS fact_loan;
CREATE TABLE fact_loan (
    loan_id VARCHAR(20) PRIMARY KEY,
    application_id VARCHAR(20) NOT NULL,
    customer_id VARCHAR(20) NOT NULL,
    product_id VARCHAR(10) NOT NULL,
    disbursement_timestamp DATETIME NOT NULL,
    disbursement_amount DECIMAL(12,2) NOT NULL,
    term_days INT UNSIGNED NOT NULL,
    due_date DATE NOT NULL,
    total_due_amount DECIMAL(12,2) NOT NULL,
    outstanding_balance DECIMAL(12,2) NOT NULL,
    loan_status VARCHAR(20) NOT NULL,
    is_npl_flag TINYINT(1) DEFAULT 0, 
    INDEX idx_cust_loan (customer_id),
    INDEX idx_status (loan_status)
);

-- Clean Repayments Fact Table
DROP TABLE IF EXISTS fact_repayment;
CREATE TABLE fact_repayment (
    repayment_id VARCHAR(20) PRIMARY KEY,
    loan_id VARCHAR(20) NOT NULL,
    payment_timestamp DATETIME NOT NULL,
    amount_paid DECIMAL(12,2) NOT NULL,
    dpd_at_payment INT UNSIGNED NOT NULL,
    payment_channel VARCHAR(30) NOT NULL,
    dpd_bucket VARCHAR(20) NOT NULL,
    INDEX idx_loan_rep (loan_id),
    INDEX idx_channel (payment_channel)
);

-- Populate Clean Customer Dimension
INSERT INTO dim_customer
SELECT * FROM stg_dim_customer;

-- Populate Clean Loans Fact with calculated NPL risk flag
INSERT INTO fact_loan
SELECT 
    loan_id,
    application_id,
    customer_id,
    product_id,
    disbursement_timestamp,
    disbursement_amount,
    term_days,
    due_date,
    total_due_amount,
    outstanding_balance,
    loan_status,
    CASE WHEN loan_status = 'DEFAULTED' THEN 1 ELSE 0 END AS is_npl_flag
FROM stg_fact_loan;

-- Populate Clean Repayments Fact with calculated DPD risk buckets
INSERT INTO fact_repayment
SELECT 
    repayment_id,
    loan_id,
    payment_timestamp,
    amount_paid,
    dpd_at_payment,
    payment_channel,
    CASE 
        WHEN dpd_at_payment = 0 THEN 'Current (0 DPD)'
        WHEN dpd_at_payment BETWEEN 1 AND 7 THEN '1 - 7 DPD'
        WHEN dpd_at_payment BETWEEN 8 AND 30 THEN '8 - 30 DPD'
        WHEN dpd_at_payment BETWEEN 31 AND 60 THEN '31 - 60 DPD'
        WHEN dpd_at_payment BETWEEN 61 AND 90 THEN '61 - 90 DPD'
        ELSE '90+ DPD (Default)'
    END AS dpd_bucket
FROM stg_fact_repayment;