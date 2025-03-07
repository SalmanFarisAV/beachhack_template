import pandas as pd
from sklearn.model_selection import train_test_split

# Load your dataset
data = pd.read_csv("hospital_dataset_new.csv")
sentences = data["Sentence"].tolist()

# Create input-output pairs
input_output_pairs = []
for sentence in sentences:
    words = sentence.split()
    for i in range(len(words) - 1):
        input_text = " ".join(words[:i + 1])
        output_text = words[i + 1]
        input_output_pairs.append({"Input": input_text, "Output": output_text})

# Save to CSV
df = pd.DataFrame(input_output_pairs)
df.to_csv("next_word_dataset_3.csv", index=False)