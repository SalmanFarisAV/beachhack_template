from tensorflow.keras.preprocessing.text import Tokenizer
from tensorflow.keras.preprocessing.sequence import pad_sequences
import numpy as np
import pandas as pd
import tensorflow as tf
import pickle

# Load the dataset
df = pd.read_csv('next_word_dataset_3.csv')

# Tokenize the words
tokenizer = Tokenizer()
tokenizer.fit_on_texts(df["Input"] + df["Output"])
total_words = len(tokenizer.word_index) + 1

# Convert input-output pairs to sequences
input_sequences = tokenizer.texts_to_sequences(df["Input"])
output_sequences = tokenizer.texts_to_sequences(df["Output"])

# Flatten output_sequences to a list of single integers
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

# Save the model
model.save("lstm_new.h5")

# Save the tokenizer
with open('tokenizer_new.pkl', 'wb') as tokenizer_file:
    pickle.dump(tokenizer, tokenizer_file)