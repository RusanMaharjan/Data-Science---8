# UI
import streamlit as st
from models import gemini
# st.title(':red[GEMINI] :blue[LLM] :orange[Project]🅰️')

# st.header('Model: 3.8-Flash :camera:')

# st.subheader('Practice Project')

st.title('GEMINI LLM PROJECT')
st.header('Using 3.6-Flash Model')

prompt = st.text_area(
    'Where should we begin?',
    placeholder='Eg: What is relativity of gravity?'
)

if st.button('Search', type='secondary'):
    if prompt.strip() == '':
        st.toast(':red[Input field cannot be empty.]', duration='long')
    else:
        with st.spinner('Generating Content'):
            answer = gemini(prompt)
            st.success('Content Generated Successfully.')
            st.write(answer)