# TapTalk (Assistive Communication for Hearing and Speech Impaired Individuals)

## 🚀 Project Description
This project enables faster communication for hearing and speech-impaired individuals by allowing them to select keywords that generate contextually relevant sentences. The selected sentences are converted into natural-sounding speech using Text-to-Speech (TTS) technology. The sentences are dynamically generated through an ML model that predicts the most relevant sentences based on the input keywords, helping users communicate effectively and efficiently without needing to type entire sentences. This solution is designed for a wide range of users, including those with cochlear implants, as well as individuals who rely on alternative communication methods.


## 🛠 Tech Stack
- Frontend: Flutter (for mobile app development)
- Backend: Firebase / Flask (for storing predefined phrases and user preferences)
- Deep Learning Model: LSTM (for keyword prediction),LLM
- Text-to-Speech (TTS): Flutter tts 

## 📦 Prerequisites
- Before setting up the project, ensure you have the following installed:
  ```
  - Flutter SDK (v3.0+)
  - Python
  - Firebase CLI
  - Dart SDK 
  ```

## 🔧 Installation & Setup

1. Install dependencies
   ```bash
   # Frontend
   git clone https://github.com/SalmanFarisAV/beachhack_template.git
   cd TapTalk

   # Backend
   cd python/python
   ```

2. Configure Environment Variables
   
   - Create a environmental variable
     
   ```
   GEMINI_KEY=your_api_key
   ```

4. Run the Application
   ```bash
   # Start frontend
   flutter run

   # Start backend
   python app.py
   ```

## Team Members
  [1.Salman Faris AV](https://github.com/SalmanFarisAV)   
  [2.Jishnu Vijayan](https://github.com/JishnuVijayan)   
  [3.Vidhya K](https://github.com/VidhyaKalapappara)   
  [4.Sayand KK](https://github.com/sayandkk) 

**Made with ❤️ at Beachhack 6**
