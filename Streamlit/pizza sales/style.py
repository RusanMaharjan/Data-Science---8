# Styling for Visualization Title
def subheaderStyle(header):
    return f'''
        <div style='
            font-size: 1.4rem;
            font-weight: bold;
            font-family: Arial;
            text-align: center;
        '>
            {header}
        </div>        
    '''


# Styling for KPI
def kpiStyle(label, value, icon):
    return f'''
        <div style='
            text-align: center; 
            border-left: 3px solid #fff000;
            border-bottom-left-radius: 5px;
            border-top-left-radius: 5px;
            margin: 10px 0 30px 0;
        '>
            <div style='font-size: 1.3rem;'>
                {label}{icon}
            </div>
            <div style='font-size: 1.7rem; font-weight: bold;'>
                {value}
            </div>
        </div>
    '''
