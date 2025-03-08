# Install required libraries
#!pip install transformers datasets torch

# Import necessary classes
from transformers import GPT2Tokenizer, GPT2LMHeadModel, TrainingArguments, Trainer
from datasets import Dataset, DatasetDict

# Load the tokenizer and model
model_name = "gpt2-medium"  # Use a larger model
tokenizer = GPT2Tokenizer.from_pretrained(model_name)
model = GPT2LMHeadModel.from_pretrained(model_name)

# Add a padding token if it doesn't exist
if tokenizer.pad_token is None:
    tokenizer.add_special_tokens({"pad_token": "[PAD]"})
    model.resize_token_embeddings(len(tokenizer))


import pandas as pd
df = pd.read_csv("hospital_dataset_new.csv")
sentences = df["Sentence"].tolist()

# Tokenize the dataset
def tokenize_function(examples):
    # Tokenize the input text
    tokenized_inputs = tokenizer(
        examples["text"],
        padding="max_length",
        truncation=True,
        max_length=50,
        return_tensors="pt",  # Return PyTorch tensors
    )
    # Set labels to the same as input_ids for causal language modeling
    tokenized_inputs["labels"] = tokenized_inputs["input_ids"].clone()
    return tokenized_inputs

# Convert the list of sentences into a Hugging Face Dataset
dataset = Dataset.from_dict({"text": sentences})
tokenized_dataset = dataset.map(tokenize_function, batched=True)

# Split the dataset into training and evaluation sets
train_test_split = tokenized_dataset.train_test_split(test_size=0.2)  # 80% training, 20% evaluation
train_dataset = train_test_split["train"]
eval_dataset = train_test_split["test"]

# Set up training arguments
training_args = TrainingArguments(
    output_dir="./results",
    overwrite_output_dir=True,
    num_train_epochs=10,  # Increase the number of epochs
    per_device_train_batch_size=8,
    learning_rate=1e-5,  # Reduce the learning rate
    save_steps=500,
    save_total_limit=2,
    logging_dir="./logs",
    logging_steps=100,
    evaluation_strategy="steps",  # Evaluate during training
    eval_steps=500,  # Evaluate every 500 steps
    report_to="none",
)

# Initialize the Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=train_dataset,
    eval_dataset=eval_dataset,  # Pass the evaluation dataset
)

# Fine-tune the model
trainer.train()

# Save the fine-tuned model and tokenizer
model.save_pretrained("./fine_tuned_model")
tokenizer.save_pretrained("./fine_tuned_model")

# Verify the saved files
"""
import os
print(os.listdir("./fine_tuned_model"))

# Load the saved model and tokenizer
model = GPT2LMHeadModel.from_pretrained("./fine_tuned_model")
tokenizer = GPT2Tokenizer.from_pretrained("./fine_tuned_model")
"""

# Test the loaded model
input_text = "I headache"
inputs = tokenizer(input_text, return_tensors="pt", padding=True, truncation=True)

# Generate text with attention mask
output = model.generate(
    input_ids=inputs["input_ids"],
    attention_mask=inputs["attention_mask"],
    max_length=20,
    num_return_sequences=1,
    temperature=0.7,  # Add randomness to the output
    top_k=50,  # Limit the sampling pool to the top-k tokens
    top_p=0.9,  # Use nucleus sampling
    do_sample=True,  # Enable sampling
)

# Decode and print the output
generated_text = tokenizer.decode(output[0], skip_special_tokens=True)
print(generated_text)