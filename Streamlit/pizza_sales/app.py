import streamlit as st
import pandas as pd
import plotly.express as px
from style import subheaderStyle, kpiStyle, headerStyle

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

st.markdown(headerStyle('Pizza Sales Dashboard'), 
            unsafe_allow_html=True)

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

if filter_data.empty:
    st.warning('No data selected. Select data from sidebar.')
    st.stop()

# KPI
total_revene = filter_data['total_price'].sum()
total_pizza_sold = filter_data['quantity'].sum()
total_orders = filter_data['order_id'].nunique()
average_order_value = total_revene / total_orders
average_pizza_per_order = total_pizza_sold / total_orders

col1, col2, col3, col4, col5 = st.columns(5)

with col1:
    st.markdown(kpiStyle('Total Revenue', f'${total_revene:,.2f}', '💵'),
            unsafe_allow_html=True)
    
with col2:
    st.markdown(kpiStyle('Total Pizza Sold', f'{total_pizza_sold:,.2f}', '🍕'),
            unsafe_allow_html=True)

with col3:
    st.markdown(kpiStyle('Total Orders', f'{total_orders:,.2f}', '🧑‍🦱'),
                unsafe_allow_html=True)

with col4:
    st.markdown(kpiStyle('Average Order Value', f'{average_order_value:,.2f}', '🦁'),
                unsafe_allow_html=True)

with col5:
    st.markdown(kpiStyle('Average Pizza/Order', f'${average_pizza_per_order:,.2f}', '💸'),
                unsafe_allow_html=True)
    

# Tabs for Visualizations
tab_overview, tab_time, tab_top_bottom, raw_data = st.tabs(
    ['Overview', 'Time Analysis', 'Top/Bottom', 'Raw Data']
)


with tab_overview:
    left, right = st.columns(2)
    
    with left:
        # % of Sales by Category
        cat_sales_pct = filter_data.groupby('pizza_category')['total_price'].sum().reset_index()
        st.markdown(subheaderStyle('Pct(%) of Sales by Category'), 
                        unsafe_allow_html=True)
        
        fig = px.pie(
            cat_sales_pct,
            names='pizza_category',
            values='total_price',
            hole=0.7,
            labels={'pizza_cateogry': 'Pizza Category', 'total_price': 'Total Price'}
        )
        st.plotly_chart(fig, use_container_width=True)
                
    with right:
        # % Sales by Pizza Size & Category
        size_cat_sales = filter_data.groupby(['pizza_size', 'pizza_category'])['total_price'].sum().reset_index()
        st.markdown(subheaderStyle('% Sales by Pizza Size & Category'), 
                unsafe_allow_html=True)
        fig = px.bar(
            size_cat_sales,
            x='pizza_size',
            y='total_price',
            color='pizza_category',
            barmode='group',
            labels = {'pizza_cateogry': 'Pizza Category', 'total_price': 'Total Price', 'pizza_size': 'Pizza Size'}
            # color_discrete_sequence=px.colors.sequential.BuPu_r
        )
        st.plotly_chart(fig, use_container_width=True)

    st.divider()
    # Tree Map
    st.markdown(subheaderStyle('Tree Map'), 
                        unsafe_allow_html=True)

    tree = (
        filter_data.groupby(['pizza_category', 'pizza_size', 'pizza_name'])['total_price'].sum().reset_index()
    )
    
    fig = px.treemap(
        tree,
        path = ['pizza_category', 'pizza_size', 'pizza_name'],
        values = 'total_price'
    )
    
    st.plotly_chart(fig, use_container_width=True)


with tab_time:
    left, right = st.columns(2)
    
    with left:
        # Sales by day of week
        day_sales = filter_data.groupby('Order_Day')['total_price'].sum().reset_index()
        # st.subheader('Sales by Day of Week')

        st.markdown(subheaderStyle('Sales by Day of Week'), 
                    unsafe_allow_html=True)

        fig = px.bar(
            day_sales,
            x='Order_Day',
            y='total_price',
            color_continuous_scale='blues',
            labels={'Order_Day': 'Weekdays', 'total_price': 'Total Sales'}
        )
        st.plotly_chart(fig)
    
    with right:
        hour_sales = filter_data.groupby('Order_Hour')['total_price'].sum().reset_index()
        
        st.markdown(subheaderStyle('Sales by Hour of Day'), 
                            unsafe_allow_html=True)
        
        fig = px.line(
            hour_sales,
            x='Order_Hour',
            y='total_price',
            markers='o'
        )
        fig.update_xaxes(dtick=1)
        st.plotly_chart(fig, use_container_width=True)
        
    # Monthly Sales
    monthly_sales = filter_data.groupby('Order_Month').agg(
        Total_Price = ('total_price', 'sum'),
        Total_Orders = ('order_id', 'nunique')
    ).reset_index()
    
    st.markdown(subheaderStyle('Monthly Sales and Revenue'), 
                                unsafe_allow_html=True)
    
    fig = px.line(
        monthly_sales,
        x='Order_Month',
        y='Total_Price',
        markers='o'
    )
    
    fig.add_bar(
        x=monthly_sales['Order_Month'],
        y=monthly_sales['Total_Orders'],
        name='Orders',
        yaxis='y2',
        opacity=0.60
    )
    
    fig.update_layout(
        yaxis=dict(title='Total Price'),
        yaxis2=dict(title='Orders', overlaying='y', side='right'),
        legend=dict(orientation='h', y=1.1),
        hovermode='x unified'
    )
    
    st.plotly_chart(fig, use_container_width=True)

# Top and Bottom Sales Pizza
with tab_top_bottom:
    top_n = st.slider('How many pizza you want to show: ', min_value = 3, max_value = 10, value=5)
    left, right = st.columns(2)
    
    # Top 5 Best Selling Pizzas
    with left:
        st.markdown(subheaderStyle(f'Top {top_n} Best Selling Pizza'), 
                                        unsafe_allow_html=True)
        top_5 = filter_data.groupby('pizza_name')['total_price'].sum().reset_index().sort_values(
            by='total_price', ascending=False
        ).head(top_n)
        
        fig = px.bar(
            top_5,
            x = 'total_price',
            y='pizza_name',
            labels = {'pizza_name': 'Pizza Name', 'total_price': 'Total Revenue ($)'},
            color='total_price',
            color_continuous_scale='blues'
        )
        fig.update_layout(coloraxis_showscale=False)
        st.plotly_chart(fig, use_container_width=True)
    
    with right:
        st.markdown(subheaderStyle(f'Bottom {top_n} Least Selling Pizza'),
                    unsafe_allow_html=True)
        
        bottom_5 = filter_data.groupby('pizza_name')['total_price'].sum().reset_index().sort_values(
                    by='total_price', ascending=True
                ).head(top_n)
        
        fig = px.bar(
            bottom_5,
            x='total_price',
            y='pizza_name',
            labels = {'pizza_name': 'Pizza Name', 'total_price': 'Total Revenue ($)'},
            color='total_price',
            color_continuous_scale='greens'
        )
        fig.update_layout(coloraxis_showscale=False)
        st.plotly_chart(fig, use_container_width=True)

with raw_data:
    st.markdown(subheaderStyle('Pizza Sales Data - 2015'), unsafe_allow_html=True)
    
    form_data = df.drop(columns = ['Order_Hour', 'Order_Day', 'Order_Month', 'month_num'])
    
    with st.form('Submit Form'):
        search_text = st.text_input('Search Data', placeholder='Eg. The Hawaiian Pizza')    
        submitted = st.form_submit_button('Search🔍')
        
        if submitted or search_text:
            form_data[
                form_data['pizza_name'].str.contains(search_text, case=False, na=False)
            ]
        else:
            form_data