import pandas as pd
from sqlalchemy import create_engine, text

# MySQL Connection Credentials
DB_USER = "root"
DB_PASSWORD = "**********"  # Update with your password
DB_HOST = "localhost"
DB_PORT = "3306"
DB_NAME = "safaricom_lending_dw"

engine = create_engine(f"mysql+pymysql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")

print("Starting robust data ingestion into MySQL...")

# Mapping tables to their CSV files
tables = {
    "raw_dim_customer": "data/raw/dim_customer.csv",
    "raw_fact_gsm_activity_daily": "data/raw/fact_gsm_activity_daily.csv",
    "raw_fact_wallet_transaction": "data/raw/fact_wallet_transaction.csv",
    "raw_fact_loan_application": "data/raw/fact_loan_application.csv",
    "raw_fact_loan": "data/raw/fact_loan.csv",
    "raw_fact_repayment_schedule": "data/raw/fact_repayment_schedule.csv",
    "raw_fact_repayment": "data/raw/fact_repayment.csv"
}

# Use a transaction connection to safely truncate and reload tables
with engine.begin() as connection:
    for table_name, csv_path in tables.items():
        try:
            print(f"\nProcessing {table_name}...")
            
            # Disable foreign key checks temporarily and truncate table to prevent duplicates
            connection.execute(text("SET FOREIGN_KEY_CHECKS = 0;"))
            connection.execute(text(f"TRUNCATE TABLE {table_name};"))
            connection.execute(text("SET FOREIGN_KEY_CHECKS = 1;"))
            
            # Read CSV and append to table in chunks
            df = pd.read_csv(csv_path)
            df.to_sql(table_name, con=connection, if_exists="append", index=False, chunksize=10000)
            
            print(f"Successfully loaded {len(df):,} rows into {table_name}.")
            
        except Exception as e:
            print(f"ERROR loading {table_name}: {e}")

print("\n Ingestion script execution completed successfully!")