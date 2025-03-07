import random
import pandas as pd

symptoms = [
    "Fatigue", "Dizziness", "Shortness of breath", "Sore throat", "Runny nose",
    "Muscle pain", "Joint pain", "Weakness", "Sweating", "Chills",
    "Loss of appetite", "Numbness", "Tingling sensation", "Blurred vision", "Double vision",
    "Swelling", "Palpitations", "Vomiting", "Diarrhea", "Constipation",
    "Abdominal pain", "Back pain", "Neck pain", "Chest tightness", "Skin rash",
    "Itching", "Burning sensation", "Frequent urination", "Difficulty swallowing", "Hoarseness",
    "Light sensitivity", "Dark-colored urine", "Blood in urine", "Blood in stool", "Excessive thirst",
    "Dry mouth", "Unexplained weight loss", "Unexplained weight gain", "Memory loss", "Confusion",
    "Mood swings", "Depression", "Anxiety", "Insomnia", "Hallucinations",
    "Seizures", "Tremors", "Hearing loss", "Ear pain", "Loss of taste or smell"
]

locations = [
    "Pharmacy", "Doctor", "Nurse station", "Emergency room", "ICU",
    "Operation theater", "Waiting area", "Reception", "Laboratory", "Radiology",
    "MRI room", "CT scan room", "X-ray room", "Ultrasound room", "Blood bank",
    "Dialysis center", "Maternity ward", "Pediatric ward", "Orthopedic ward", "Cardiology unit",
    "Neurology unit", "Oncology unit", "Psychiatry ward", "Physical therapy room", "Burn unit",
    "Isolation ward", "Hospital cafeteria", "Parking area", "Ambulance bay", "Gift shop",
    "Medical records office", "Billing counter", "Counseling center", "Intensive care unit", "Neonatal ICU",
    "Respiratory therapy room", "Triage area", "Outpatient clinic", "Dental clinic", "Eye clinic",
    "Physiotherapy room", "Endoscopy room", "Rehabilitation center", "Pathology lab", "Surgical ward",
    "Blood donation center", "Medical waste disposal area", "Hospital chapel", "Helipad", "Public restroom"
]

actions = [
    "Help", "Find", "See", "Check", "Diagnose",
    "Treat", "Examine", "Prescribe", "Monitor", "Assess",
    "Consult", "Admit", "Discharge", "Operate", "Inject",
    "Measure", "Scan", "Test", "Inspect", "Observe",
    "Analyze", "Refer", "Schedule", "Record", "Assist",
    "Resuscitate", "Stabilize", "Examine", "Bandage", "Suture",
    "Vaccinate", "Transport", "Administer", "Monitor", "Explain",
    "Perform", "Recommend", "Counsel", "Rehabilitate", "Support",
    "Educate", "Prescribe", "Adjust", "Remove", "Apply",
    "Position", "Prepare", "Clean", "Sedate", "Intubate"
]

modifiers = [
    "Severe", "Mild", "Urgent", "Chronic", "Acute",
    "Persistent", "Sudden", "Temporary", "Constant", "Intense",
    "Moderate", "Slight", "Progressive", "Recurring", "Unbearable",
    "Sharp", "Dull", "Burning", "Throbbing", "Stabbing",
    "Faint", "Crippling", "Excruciating", "Intermittent", "Severe-onset",
    "Gradual", "Worsening", "Relieved", "Continuous", "Localized",
    "Widespread", "Subtle", "Noticeable", "Unusual", "Disruptive",
    "Mildly irritating", "Highly concerning", "Life-threatening", "Emergency", "Critical",
    "Tolerable", "Nagging", "Bearable", "Pressing", "Suddenly worsening",
    "Developing", "Episodic", "Lingering", "Unpredictable", "Overwhelming"
]

# Required sentence starters
valid_starters = ["I", "You", "Where", "Help", "Can", "We", "They", "Will", "Our", "My", "Should", "Could"]

# Define templates ensuring correct sentence starters
templates = [
    "I have a {mod} {sym}.",
    "You might be experiencing {mod} {sym}.",
    "Where is the {loc}?",
    "Help me, I feel {mod} {sym}.",
    "Can you {act} me with my {sym}?",
    "We need to {act} the {loc}.",
    "They should {act} the {sym}.",
    "Will I recover from {mod} {sym}?",
    "Our {loc} needs better equipment.",
    "My {sym} is getting worse.",
    "Should I visit the {loc}?",
    "Could you {act} the {sym} for me?"
]

# Generate sentences (allowing duplicates initially)
sentences = []
for _ in range(25000):  # Generate exactly 10,000 sentences
    template = random.choice(templates)
    sentence = template.format(
        mod=random.choice(modifiers),
        sym=random.choice(symptoms),
        loc=random.choice(locations),
        act=random.choice(actions)
    )
    sentences.append(sentence)

# Remove duplicates after generation
unique_sentences = list(dict.fromkeys(sentences))  # Preserves order, removes duplicates

df = pd.DataFrame(unique_sentences, columns=["Sentence"])
df.to_csv("hospital_dataset_new.csv", index=False)

# Report results
print(f"Generated 10,000 sentences, {len(unique_sentences)} were unique.")
