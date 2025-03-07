import pandas as pd
from tensorflow.keras.preprocessing.text import Tokenizer
import pickle

# Load the dataset
df = pd.read_csv('next_word_dataset_2.csv')

# Recreate the tokenizer
tokenizer = Tokenizer()
tokenizer.fit_on_texts(df["Input"] + df["Output"])

# Save the tokenizer
with open("tokenizer.pkl", "wb") as f:
    pickle.dump(tokenizer, f)

print("Tokenizer saved as tokenizer.pkl")