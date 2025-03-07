from transformers import BioGptTokenizer, BioGptForCausalLM

# Load BioGPT model and tokenizer
model_name = "microsoft/BioGPT"
tokenizer = BioGptTokenizer.from_pretrained(model_name)
model = BioGptForCausalLM.from_pretrained(model_name)

# Function to generate sentences
def generate_sentences(input_words, num_sentences=5, max_length=20):
    prompt = " ".join(input_words)
    input_ids = tokenizer.encode(prompt, return_tensors="pt")
    output = model.generate(
        input_ids,
        max_length=max_length,
        num_return_sequences=num_sentences,
        no_repeat_ngram_size=2,
        top_k=50,
        top_p=0.95,
        temperature=0.7,
        do_sample=True,
    )
    sentences = [tokenizer.decode(seq, skip_special_tokens=True) for seq in output]
    return sentences

# Example usage
input_words = ["I", "headache"]
sentences = generate_sentences(input_words, num_sentences=5)
print("Input Words:", input_words)
print("Generated Sentences:")
for i, sentence in enumerate(sentences):
    print(f"{i + 1}. {sentence}")