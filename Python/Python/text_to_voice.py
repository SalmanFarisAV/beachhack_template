import pyttsx3

engine = pyttsx3.init()

voices = engine.getProperty('voices')

engine.setProperty('voice', voices[0].id) # index 1 is female

engine.say("Hello, this is a male voice.")

engine.runAndWait()


