import streamlit as st
import pandas as pd
import plotly.express as px

# Set Page Configuration
st.set_page_config(
    page_title='Pizza Sales Dashboard',
    page_icon=':pizza:',
    layout='wide'
)

# Read Data
@st.cache_data
def load_data(path:str) -> pd.DataFrame:
    df = pd.read_csv(path)
    return df

@st.cache_data
def clean_data(df:pd.DataFrame) -> pd.DataFrame:
    df = df.copy()
    df["order_date"] = pd.to_datetime(df["order_date"], format="mixed")
    df["order_time"] = pd.to_datetime(df["order_time"], format="mixed").dt.time

    # Feature engineering
    df["Order_Day"]    = df["order_date"].dt.day_name()
    df["Order_Month"]  = df["order_date"].dt.month_name()
    df["month_num"]    = df["order_date"].dt.month
    df["Order_Hour"]   = pd.to_datetime(df["order_time"], format="%H:%M:%S").dt.hour

    # Categorical ordering so plots sort correctly
    weekdays = ["Sunday", "Monday", "Tuesday", "Wednesday",
                "Thursday", "Friday", "Saturday"]
    df["Order_Day"] = pd.Categorical(df["Order_Day"], categories=weekdays, ordered=True)

    months = ["January", "February", "March", "April", "May", "June",
              "July", "August", "September", "October", "November", "December"]
    df["Order_Month"] = pd.Categorical(df["Order_Month"], categories=months, ordered=True)

    return df

df_raw = load_data('pizza_sales.csv')
df = clean_data(df_raw)

st.header('Pizza Sales Dashboard')

# Sidebar
st.sidebar.header('Filter Data')

# Sizes
sizes = sorted(df['pizza_size'].unique())
size_data = st.sidebar.multiselect(
    'Select Pizza Size',
    options=sizes,
    default=sizes
)

# Category
categories = sorted(df['pizza_category'].unique())
category_data = st.sidebar.multiselect(
    'Select Pizza Categories',
    options=categories,
    default=categories
)

# Filter Data
filter_data = df[
    (df['pizza_size'].isin(size_data)) &
    (df['pizza_category'].isin(category_data))
]

# KPI
total_revene = filter_data['total_price'].sum()
total_pizza_sold = filter_data['quantity'].sum()
total_orders = filter_data['order_id'].nunique()
average_order_value = total_revene / total_orders
average_pizza_per_order = total_pizza_sold / total_orders

col1, col2, col3, col4, col5 = st.columns(5)

with col1:
    st.metric('Total Revenue', f'${total_revene:,.2f}')
    
with col2:
    st.metric('Total Pizza Sold', f'{total_pizza_sold:,}')

with col3:
    st.metric('Total Orders', f'{total_orders:,}')

with col4:
    st.metric('Average Order Value', f'{average_order_value:,.2f}')

with col5:
    st.metric('Average Pizza Per Order', f'${average_pizza_per_order:,.2f}')


# Sales by day of week
day_sales = filter_data.groupby('Order_Day')['total_price'].sum().reset_index()
st.subheader('Sales by Day of Week')
fig = px.bar(
    day_sales,
    x='Order_Day',
    y='total_price',
    labels={'Order_Day': 'Weekdays', 'total_price': 'Total Sales'}
)
st.plotly_chart(fig)