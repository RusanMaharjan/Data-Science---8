import streamlit as st

st.header('Cardiovascular Disease Prediction')
st.subheader('Using Logistic Regression')

# 'age', 'gender', 'height', 'weight', 'ap_hi', 'ap_lo','cholesterol', 'gluc', 
#             'smoke', 'alco', 'active'

st.sidebar.header(
    'Features'
)

age = st.sidebar.slider(
    'Age',
    max_value = 65,
    min_value = 28,
    value = 35
)

gender_dict = {1: 'Female', 2: 'Male'}
gender = st.sidebar.radio(
    'Gender',
    options=gender_dict.keys(),
    format_func = lambda x : gender_dict.get(x)
)