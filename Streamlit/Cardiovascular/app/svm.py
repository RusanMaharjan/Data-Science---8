import streamlit as st
import numpy as np
from app.models import read_svm_cardio

st.header('Cardiovascular Disease Prediction')
st.subheader('Using Support Vector Machine')

model, scaler = read_svm_cardio()

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

height = st.sidebar.slider(
    'Height',
    min_value = 150,
    max_value = 185,
    value = 160,
    step=1
)

weight = st.sidebar.slider(
    'Weight',
    min_value = 45,
    max_value = 120,
    value = 55
)

ap_hi = st.sidebar.slider(
    'Systolic Pressure',
    min_value = 90,
    max_value = 190,
    value = 120
)

ap_lo = st.sidebar.slider(
    'Di-Systolic Pressure',
    min_value = 50,
    max_value = 90,
    value = 80
)

cholesterol_dict = {1: 'Low Cholesterol', 2: 'Mild Cholesterol', 3: 'High Cholesterol'}
cholesterol = st.sidebar.radio(
    'Cholesterol',
    options = cholesterol_dict.keys(),
    format_func = lambda x : cholesterol_dict.get(x)
)

gluc_dict = {1: 'Low Glucose', 2: 'Mild Glucose', 3: 'High Glucose'}
gluc = st.sidebar.radio(
    'Glucose',
    options = gluc_dict.keys(),
    format_func = lambda x : gluc_dict.get(x)
)

smoke_dict = {0: 'Doesnot Smoke', 1: 'Does Smoke'}
smoke = st.sidebar.radio(
    'Smoke',
    options = smoke_dict.keys(),
    format_func = lambda x : smoke_dict.get(x)
)

alco_dict = {0: 'Doesnot Drink Alcohol', 1: 'Does Drink Alcohol'}
alco = st.sidebar.radio(
    'Alcohol',
    options = alco_dict.keys(),
    format_func = lambda x : alco_dict.get(x)
)

active_dict = {0: 'Doesnot Do PA', 1: 'Does Do PA'}
active = st.sidebar.radio(
    'Physical Activities (PA)',
    options = active_dict.keys(),
    format_func = lambda x : active_dict.get(x)
)

## Prediction Button
if st.button('Predict Cardio'):
    data = np.array([[
        age, gender, height, weight, ap_hi, ap_lo,cholesterol, gluc, smoke, alco, active
    ]])
    data_scale = scaler.transform(data)
    prediction = model.predict(data_scale)[0]
    
    if prediction == 0:
        st.success('No cardiovascular disease found.')
        st.write('Likely to be Healthy.')
    else:
        st.warning('Cardiovascular disease found.')
        st.write('Likely to be Unhealthy')