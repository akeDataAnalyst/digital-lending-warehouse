USE safaricom_lending_dw;

-- 1. Customer Dimension Raw Table
DROP TABLE IF EXISTS raw_dim_customer;
CREATE TABLE raw_dim_customer (
    customer_id VARCHAR(20) PRIMARY KEY,
    wallet_id VARCHAR(20),
    msisdn VARCHAR(20),
    region VARCHAR(50),
    kyc_status VARCHAR(20),
    tenure_days INT,
    created_date DATE
);

-- 2. Daily GSM Activity Raw Table
DROP TABLE IF EXISTS raw_fact_gsm_activity_daily;
CREATE TABLE raw_fact_gsm_activity_daily (
    activity_date DATE,
    customer_id VARCHAR(20),
    airtime_topup_amount DECIMAL(10,2),
    data_bundle_purchased INT,
    voice_calls_duration_mins INT,
    is_active_flag INT
);

-- 3. Wallet Transactions Raw Table
DROP TABLE IF EXISTS raw_fact_wallet_transaction;
CREATE TABLE raw_fact_wallet_transaction (
    transaction_id VARCHAR(30) PRIMARY KEY,
    wallet_id VARCHAR(20),
    customer_id VARCHAR(20),
    transaction_timestamp DATETIME,
    transaction_type VARCHAR(30),
    amount DECIMAL(12,2),
    running_balance DECIMAL(12,2),
    status VARCHAR(20)
);

-- 4. Loan Applications Raw Table
DROP TABLE IF EXISTS raw_fact_loan_application;
CREATE TABLE raw_fact_loan_application (
    application_id VARCHAR(20) PRIMARY KEY,
    customer_id VARCHAR(20),
    product_id VARCHAR(10),
    application_timestamp DATETIME,
    requested_amount DECIMAL(12,2),
    decision VARCHAR(20),
    approved_amount DECIMAL(12,2),
    decline_reason VARCHAR(50)
);

-- 5. Loans Raw Table
DROP TABLE IF EXISTS raw_fact_loan;
CREATE TABLE raw_fact_loan (
    loan_id VARCHAR(20) PRIMARY KEY,
    application_id VARCHAR(20),
    customer_id VARCHAR(20),
    product_id VARCHAR(10),
    disbursement_timestamp DATETIME,
    disbursement_amount DECIMAL(12,2),
    term_days INT,
    due_date DATE,
    total_due_amount DECIMAL(12,2),
    outstanding_balance DECIMAL(12,2),
    loan_status VARCHAR(20)
);

-- 6. Repayment Schedule Raw Table
DROP TABLE IF EXISTS raw_fact_repayment_schedule;
CREATE TABLE raw_fact_repayment_schedule (
    loan_id VARCHAR(20),
    installment_number INT,
    due_date DATE,
    amount_due DECIMAL(12,2)
);

-- 7. Repayments Raw Table
DROP TABLE IF EXISTS raw_fact_repayment;
CREATE TABLE raw_fact_repayment (
    repayment_id VARCHAR(20) PRIMARY KEY,
    loan_id VARCHAR(20),
    payment_timestamp DATETIME,
    amount_paid DECIMAL(12,2),
    dpd_at_payment INT,
    payment_channel VARCHAR(30)
);