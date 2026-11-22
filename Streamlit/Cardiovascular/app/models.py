from pathlib import Path
import joblib

BASE_DIR = Path(__file__).resolve().parent.parent

LOGISTIC_SCALER_PATH = BASE_DIR / "models" / "logistics" / "logistic_scaler.pkl"
LOGISTIC_MODEL_PATH = BASE_DIR / "models" / "logistics" / "logistic_model.pkl"

SVM_SCALER_PATH = BASE_DIR / "models" / "svm" / "svm_scaler.pkl"
SVM_MODEL_PATH = BASE_DIR / "models" / "svm" / "svm_model.pkl"

def read_logistic_cardio():
    model = joblib.load(LOGISTIC_MODEL_PATH)
    scaler = joblib.load(LOGISTIC_SCALER_PATH)
    
    return model, scaler

def read_svm_cardio():
    model = joblib.load(SVM_MODEL_PATH)
    scaler = joblib.load(SVM_SCALER_PATH)
    
    return model, scaler