from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
import numpy as np
import pandas as pd
import tensorflow as tf

# Load the dataset
df = pd.read_csv('next_word_dataset_2.csv')

# Tokenize the words
tokenizer = Tokenizer()
tokenizer.fit_on_texts(df["Input"] + df["Output"])
total_words = len(tokenizer.word_index) + 1

# Convert input-output pairs to sequences
input_sequences = tokenizer.texts_to_sequences(df["Input"])
output_sequences = tokenizer.texts_to_sequences(df["Output"])

# Flatten output_sequences to a list of single integers
# Ensure each output is a single word and handle empty sequences
output_sequences = [seq[0] if seq else 0 for seq in output_sequences]  # Use 0 for empty sequences

# Pad input sequences to ensure uniform input size
max_sequence_length = max(len(seq) for seq in input_sequences)
input_sequences = pad_sequences(input_sequences, maxlen=max_sequence_length, padding="pre")

# Convert output_sequences to a NumPy array and reshape
output_sequences = np.array(output_sequences).reshape(-1, 1)

# One-hot encode the output
output_sequences = tf.keras.utils.to_categorical(output_sequences, num_classes=total_words)

# Define the model
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Embedding, LSTM, Dense

model = Sequential([
    Embedding(input_dim=total_words, output_dim=100, input_length=max_sequence_length),
    LSTM(150, return_sequences=False),
    Dense(total_words, activation="softmax")
])

# Compile the model
model.compile(loss="categorical_crossentropy", optimizer="adam", metrics=["accuracy"])
model.summary()

# Train the model
model.fit(input_sequences, output_sequences, epochs=50, verbose=1)

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

# Example usage
input_text = "I have"
suggestions = predict_next_word(input_text)
print(suggestions)

# Save the model
model.save("lstm.h5")