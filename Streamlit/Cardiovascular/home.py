import streamlit as st

st.set_page_config(
    page_title='Cardiovascular Disease Prediction',
    layout='wide'
)

def Home():
    st.Page('home.py', title='Home')
    st.header('Home Page')
    
    

    logistic, svm = st.tabs([
        'Logistics', 'SVM'
    ])
    
pages = {
    "Home": {
        st.Page(Home)
    },
    "Models": {
        st.Page('app/logistics.py', title='Logistic Regression'),
        st.Page('app/svm.py', title='SVM')
    }
}

pg = st.navigation(pages, position='top')
pg.run()
