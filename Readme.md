# TapTalk (Assistive Communication for Hearing and Speech Impaired Individuals)

## 🚀 Project Description
This project enables faster communication for hearing and speech-impaired individuals by allowing them to select keywords that generate contextually relevant sentences. The selected sentences are converted into natural-sounding speech using Text-to-Speech (TTS) technology. The sentences are dynamically generated through an ML model that predicts the most relevant sentences based on the input keywords, helping users communicate effectively and efficiently without needing to type entire sentences. This solution is designed for a wide range of users, including those with cochlear implants, as well as individuals who rely on alternative communication methods.

## 🎯 Link to Project
[live link of project](live_link)

## 🛠 Tech Stack
- Frontend: Flutter (for mobile app development)
- Backend: Firebase / Postgresql (for storing predefined phrases and user preferences)
- NLP for Sentence Prediction: BERT / GPT-3.5 / N-gram model
- ML Model: Supervised learning (Naïve Bayes / Logistic Regression for keyword-to-sentence mapping), Transformer models (for context-aware sentence generation)
- Text-to-Speech (TTS): Google TTS / Azure Speech

## 📦 Prerequisites
- List all required software and versions
- Include installation instructions
- Example:
  ```
  - Node.js (v14+)
  - npm (v6+)
  - Python (v3.8+)
  ```

## 🔧 Installation & Setup

1. Install dependencies
   ```bash
   # Frontend
   cd frontend
   npm install

   # Backend
   cd ../backend
   pip install -r requirements.txt
   ```

2. Configure Environment Variables
   
   - Create a `.env` file
   - Add necessary configuration details
     
   ```
   API_KEY=your_api_key
   DATABASE_URL=your_database_connection_string
   ```

4. Run the Application
   ```bash
   # Start frontend
   npm start

   # Start backend
   python app.py
   ```

## Team Members
  [1.Salman Faris AV](https://github.com/SalmanFarisAV)   
  [2.Jishnu Vijayan](https://github.com/JishnuVijayan)   
  [3.Vidhya K](https://github.com/VidhyaKalapappara)   
  [4.Sayand KK](https://github.com/sayandkk) 

**Made with ❤️ at Beachhack 6**
