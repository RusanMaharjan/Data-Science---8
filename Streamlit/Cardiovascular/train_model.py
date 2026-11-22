from app.models import logistics, svm

if __name__ == '__main__':
    logistics()
    print('Logistic Model and Scaler Trained Saved Successfully.')
    svm()
    print('SVM Model and Scaler Trained Saved Successfully.')