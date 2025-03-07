from flask import Flask, request, jsonify
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

# Define stop words
default_stop_words = set(["a", "an", "the", "is", "was", "have", "had", "are", "were", "me", "i", "of", "my"])

# Function to predict the next word with stop words filtered out
def predict_next_word(input_text, num_suggestions=12, filter_stop_words=True):
    # Tokenize the input text
    input_seq = tokenizer.texts_to_sequences([input_text])
    input_seq = pad_sequences(input_seq, maxlen=max_sequence_length, padding="pre")

    # Predict the next word
    predicted_probs = model.predict(input_seq, verbose=0)[0]
    predicted_indices = np.argsort(predicted_probs)[-num_suggestions * 2:][::-1]  # Get more suggestions
    predicted_words = [tokenizer.index_word.get(idx, "") for idx in predicted_indices if idx in tokenizer.index_word]

    if filter_stop_words:
        input_words = set(input_text.lower().split())  # Get words from input text
        stop_words = default_stop_words.union(input_words)  # Combine default stop words with input words
        predicted_words = [word for word in predicted_words if word not in stop_words]

    # Return the top N suggestions
    return predicted_words[:num_suggestions]

# Initialize Flask app
app = Flask(__name__)


@app.route("/predict_next_word", methods=["GET"])
def api_predict_next_word():
    # Get input text and parameters from query parameters
    input_text = request.args.get("input_text", "")
    num_suggestions = int(request.args.get("num_suggestions", 12))
    filter_stop_words = request.args.get("filter_stop_words", "true").lower() == "true"  # Default is True

    # Get predictions
    suggestions = predict_next_word(input_text, num_suggestions, filter_stop_words)

    # Return predictions as JSON
    return jsonify({"input_text": input_text, "suggestions": suggestions})

# Run the Flask app
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)