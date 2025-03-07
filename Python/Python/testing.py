from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
import numpy as np
import pickle

# Load the saved model
model = load_model("lstm.h5")

# Load the tokenizer
with open("tokenizer.pkl", "rb") as f:
    tokenizer = pickle.load(f)

# Define max_sequence_length (either calculate or set manually)
max_sequence_length = 10  # Replace with the actual value used during training

# Function to predict the next word
def predict_next_word(input_text, num_suggestions=12):
    # Tokenize the input text
    input_seq = tokenizer.texts_to_sequences([input_text])
    input_seq = pad_sequences(input_seq, maxlen=max_sequence_length, padding="pre")

    # Predict the next word
    predicted_probs = model.predict(input_seq, verbose=0)[0]
    predicted_indices = np.argsort(predicted_probs)[-num_suggestions:][::-1]
    predicted_words = [tokenizer.index_word.get(idx, "") for idx in predicted_indices if idx in tokenizer.index_word]
    return predicted_words

# Define stop words
default_stop_words = set(["a", "an", "the", "is", "was", "have", "had", "are", "were", "me", "i", "of", "my"])

# Function to predict the next word with stop words and input words filtered out
def predict_next_word_filtered(input_text, num_suggestions=12):
    input_words = set(input_text.lower().split())  # Get words from input text
    stop_words = default_stop_words.union(input_words)  # Combine default stop words with input words

    suggestions = predict_next_word(input_text, num_suggestions * 2)  # Get more suggestions
    filtered_suggestions = [word for word in suggestions if word not in stop_words]
    return filtered_suggestions[:num_suggestions]

# Example usage
input_text = "I suddenly worsening"
suggestions = predict_next_word_filtered(input_text)
print("Input:", input_text)
print("Filtered Suggestions:", suggestions)
