import joblib
from sklearn.feature_extraction.text import TfidfVectorizer
import pandas as pd
from project.settings import BASE_DIR
import os

vectorizer = joblib.load(os.path.join(BASE_DIR, 'schoolMeal', 'mealNameClassifier', 'vectorizer.pkl'))
model = joblib.load(os.path.join(BASE_DIR, 'schoolMeal', 'mealNameClassifier', 'model.pkl'))

def classify(menuname):
    return model.predict(vectorizer.transform([menuname]))[0]