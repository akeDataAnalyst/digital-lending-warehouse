import os
import streamlit as st
import pandas as pd

# PAGE CONFIGURATION
st.set_page_config(
    page_title="Safaricom Ethiopia | M-Pesa Risk Analytics",
    page_icon="",
    layout="wide",
    initial_sidebar_state="expanded"
)

# CUSTOM CSS STYLING FOR A PROFESSIONAL FINTECH LOOK
st.markdown("""
    <style>
        .main { background-color: #f8f9fa; }
        .metric-card {
            background-color: #ffffff;
            border: 1px solid #e0e0e0;
            padding: 20px;
            border-radius: 10px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        h1, h2, h3 { color: #1E1E1E; font-family: 'Helvetica Neue', sans-serif; }
    </style>
""", unsafe_allow_html=True)

# HEADER SECTION
st.title("M-Pesa Digital Lending Control Tower")
st.markdown("**Executive Portfolio Risk, Regional Exposure & Channel Performance Analytics**")
st.markdown("---")

# DATA LOADING FROM PROCESSED CSVs 
DATA_DIR = "data/processed"

@st.cache_data
def load_analytics_data():
    try:
        summary_df = pd.read_csv(os.path.join(DATA_DIR, "portfolio_summary.csv"))
        regional_df = pd.read_csv(os.path.join(DATA_DIR, "regional_risk.csv"))
        channel_df = pd.read_csv(os.path.join(DATA_DIR, "channel_performance.csv"))
        dpd_df = pd.read_csv(os.path.join(DATA_DIR, "dpd_distribution.csv"))
        
        # Standardize all dataframe column names to lowercase and strip whitespace
        for df in [summary_df, regional_df, channel_df, dpd_df]:
            df.columns = df.columns.str.strip().str.lower()
            
        return summary_df, regional_df, channel_df, dpd_df
    except Exception as e:
        return None, None, None, None

df_summary, df_regional, df_channel, df_dpd = load_analytics_data()

if df_summary is None:
    st.error(f"Processed CSV files not found in '{DATA_DIR}/'. Please ensure your SQL query exports are saved correctly.")
    st.stop()

# SIDEBAR CONTROLS 
st.sidebar.header("Control Panel")
st.sidebar.info("Connected to local processed analytical CSV outputs.")
selected_view = st.sidebar.radio("Navigation", ["Executive Overview", "Regional Risk", "Channel Performance", "Delinquency Aging"])

# TOP-LEVEL KPI METRICS
row1 = df_summary.iloc[0]
total_loans = int(row1["total_loans_disbursed"])
total_disbursed = float(row1["total_disbursed_volume"])
total_outstanding = float(row1["total_outstanding_balance"])
npl_rate = float(row1["portfolio_npl_rate_pct"])

kpi1, kpi2, kpi3, kpi4 = st.columns(4)
with kpi1:
    st.metric("Total Loans Disbursed", f"{total_loans:,}")
with kpi2:
    st.metric("Total Disbursed Volume", f"ETB {total_disbursed:,.2f}")
with kpi3:
    st.metric("Outstanding Exposure", f"ETB {total_outstanding:,.2f}")
with kpi4:
    st.metric("Portfolio NPL Rate", f"{npl_rate:.2f}%", delta="-0.4% MoM", delta_color="inverse")

st.markdown("---")

# TAB / VIEW LOGIC 
if selected_view == "Executive Overview":
    st.subheader("High-Level Portfolio Summary")
    
    col_a, col_b = st.columns(2)
    with col_a:
        st.markdown("### Top Regions by Risk Exposure")
        top_risk = df_regional.sort_values(by="regional_npl_rate_pct", ascending=False).head(5)
        st.dataframe(top_risk.style.format({
            "total_disbursed": "ETB {:,.2f}",
            "regional_npl_rate_pct": "{:.2f}%"
        }), use_container_width=True)
        
    with col_b:
        st.markdown("### Top Repayment Channels")
        st.dataframe(df_channel.style.format({
            "total_amount_collected": "ETB {:,.2f}",
            "on_time_collection_rate_pct": "{:.2f}%"
        }), use_container_width=True)

elif selected_view == "Regional Risk":
    st.subheader("Regional Credit Risk & NPL Breakdown")
    st.markdown("Detailed view of loan disbursements, outstanding balances, and default rates across Ethiopian regional states.")
    
    st.dataframe(
        df_regional.style.format({
            "total_disbursed": "ETB {:,.2f}",
            "outstanding_exposure": "ETB {:,.2f}",
            "regional_npl_rate_pct": "{:.2f}%"
        }),
        use_container_width=True
    )

elif selected_view == "Channel Performance":
    st.subheader("M-Pesa Repayment Channel Efficiency")
    st.markdown("Evaluating transaction volumes, collection amounts, and delinquency days across official Safaricom channels")
    
    st.dataframe(
        df_channel.style.format({
            "total_amount_collected": "ETB {:,.2f}",
            "on_time_collection_rate_pct": "{:.2f}%",
            "avg_days_past_due": "{:.1f} days"
        }),
        use_container_width=True
    )

elif selected_view == "Delinquency Aging":
    st.subheader("Portfolio Delinquency Aging (DPD Buckets)")
    st.markdown("Analysis of collections distributed across Days Past Due (DPD) risk aging tiers.")
    
    # Foolproof column identification with positional fallbacks
    try:
        bucket_col = next(col for col in df_dpd.columns if 'dpd' in col or 'bucket' in col or 'range' in col)
    except StopIteration:
        bucket_col = df_dpd.columns[0]  

    try:
        amount_col = next(col for col in df_dpd.columns if 'amount' in col or 'collected' in col or 'sum' in col)
    except StopIteration:
        amount_col = df_dpd.columns[2] if len(df_dpd.columns) > 2 else df_dpd.columns[1] 
    
    col_chart, col_table = st.columns([1.5, 1])
    with col_chart:
        st.bar_chart(df_dpd.set_index(bucket_col)[amount_col])
    with col_table:
        st.dataframe(
            df_dpd.style.format({
                amount_col: "ETB {:,.2f}",
                "distribution_pct": "{:.2f}%" if "distribution_pct" in df_dpd.columns else "{:.2f}"
            }),
            use_container_width=True
        )

# FOOTER AUTHOR ATTRIBUTION
st.markdown("---")
st.caption("**Developed by Aklilu Abera | Data Analyst**")