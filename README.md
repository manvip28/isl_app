
## AI tool/mobile app for Indian Sign language(ISL) generator from audio-visual content in English/Hindi to ISL content and vice-versa

This is a Flutter-based mobile application that allows users to convert various languages to Indian Sign Language (ISL). The app utilizes a Flask backend for language translation and ISL video retrieval. Users can input text or speech, which is then translated to English and subsequently converted to ISL. Relevant ISL videos are fetched from a database and displayed to the user, enabling them to learn and practice ISL.

Background: Indian Sign Language (ISL) is a visual-gestural language used by deaf and hard-of-hearing individuals across India. It encompasses a rich vocabulary of hand movements, facial expressions and body postures to convey messaging. ISL facilitates communication and fosters community among deaf individuals, enabling them to express emotions, share ideas and engage in every day interactions. Description: The need for audio to Indian Sign Language (ISL) conversion arrises from the communication barrier between the deaf community, which primarily uses ISL, and individuals who do not know sign language but communicate through spoken language. This barrier hinder effective communication in various settings, including education, healthcare and various interactions. Without a mean to convert audio into ISL, deaf individual faces challenging in accessing information and participating fully in society. Expected Solution: The expected solution entails developing technology-such as software or devices-capable of accurately converting spoken language to Indian Sign Language (ISL). This technology should use speech recognition, natural level processing, and computer vision to transcribe and interpret audio input, generating corresponding ISL gestures in real-time. It should prioritize accuracy, user-friendliness, and adaptibility to regional variation of ISL, thereby facilitating seamless communication between deaf individual and those who do not know sign language. For example: 1. Development of application by which announcement/ text display in railway platform Display Unit Converted to Indian Sign Language, so that deaf people can see it and understand the announcement. 2. Development of Mobile app through by which using Mobile Camera, normal person can understand sign language used by dead individuals.


## Table of Contents

- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [Create a Virtual Environment](#create-a-virtual-environment)
  - [Activate the Virtual Environment](#activate-the-virtual-environment)
  - [Install Dependencies](#install-dependencies)
  - [Set Up Python Community Edition Plugin (For IDE)](#set-up-python-community-edition-plugin-for-ide)
  - [Set Up NLP Packages](#set-up-nlp-packages)
  - [Run the Flask Server](#run-the-flask-server)
- [Flutter Setup Instructions](#flutter-setup-instructions)
  - [Add Dependencies](#add-dependencies)
  - [Add Assets](#add-assets)
  - [Run Flutter Pub Get](#run-flutter-pub-get)
- [Running the App](#running-the-app)
- [Requirements](#requirements)
- [Versioning](#versioning)
- [Troubleshooting](#troubleshooting)

## Project Structure

The project is organized into the following folders:

```bash
isl_app/
├── assets/
│   └── videos/
├── backend/
│   ├── venv/
│   ├── app.py
│   └── requirements.txt
└── lib/
    ├── main.dart
    └── pages/
        ├── home_page.dart
        ├── isl_to_language_page.dart
        ├── language_to_isl_page.dart
        └── result_page.dart
    

```

## Setup Instructions

### Create a Virtual Environment

Navigate to the `backend` folder and create a virtual environment by running the following command:

```bash
python -m venv venv
```

### Activate the Virtual Environment

- On **Windows**, run the following command:

  ```bash
  venv\Scripts\activate
  ```

- On **macOS or Linux**, run:

  ```bash
  source venv/bin/activate
  ```

You should now see `(venv)` at the beginning of your terminal prompt, indicating that the virtual environment is active.

### Install Dependencies

Once the virtual environment is active, install the required dependencies by running:

```bash
pip install -r requirements.txt
```

### Set Up Python Community Edition Plugin (For IDE)

To run the `app.py` file smoothly, you need to configure your Python interpreter in Android Studio.

1. Open the project in Android Studio.
2. Go to **File** > **Project Structure**.
3. Under **SDK**, select Python 3.11 and click **Apply** and then **OK**.
4. Go to **Tools** > **Sync Python Requirements** to sync the virtual environment with your IDE.

### Set Up NLP Packages

To ensure the app runs smoothly, you need to create and import the necessary NLP packages in the virtual environment.

1. Navigate to the `venv` folder.
2. Create a folder named `nltk_data` if it doesn't already exist.
3. Open a terminal and run the following Python code (you can execute it by typing `python` in the command prompt):

   ```python
   import nltk
   nltk.download('punkt_tab')
   nltk.download('averaged_perceptron_tagger_eng')
   nltk.download('stopwords')
   nltk.download('wordnet')
   nltk.download('omw-1.4')
   ```

4. Exit Python by typing:

   ```python
   exit()
   ```

### Run the Flask Server

To run the Flask server, type the following command in the command prompt:

```bash
python app.py
```

## Flutter Setup Instructions 
### Add Dependencies:
Open pubspec.yaml and add the following dependencies under dependencies::

```yaml
dependencies:
  flutter:
    sdk: flutter
  video_player: ^2.8.0
  path_provider: ^2.0.11
  http: ^0.13.5
```
### Add Assets:
Under flutter: in the pubspec.yaml, specify the video assets:

```yaml
flutter:
  assets:
    - assets/videos/Abacus.mp4
    - assets/videos/Abstract.mp4
    - assets/videos/Chocolate.mp4
    - assets/videos/Like.mp4
```

### Run flutter pub get:
After modifying pubspec.yaml, run the following command in the terminal to install dependencies and include assets:

```bash
flutter pub get
```


## Running the App

To run the application in the correct order, follow these steps:

1. Start the **Android emulator** in Android Studio.
2. Run the **Flask server** using the command `python app.py`.
3. Finally, run **main.dart** to start the Flutter app.

## Requirements

Ensure you have the following installed on your system:

- Python 3.11 or later
- Flask
- NLTK
- Flutter SDK (for the front-end)

## Versioning

- **Python**: 3.11
- **Flutter SDK**: 3.3.10
- **Flask**: 2.2.2
- **NLTK**: 3.7

## Troubleshooting

If you encounter any issues during the setup process, please check the following:

- Ensure the virtual environment is active before installing dependencies or running the Flask server.
- Verify that the Python interpreter in Android Studio is correctly configured to use the virtual environment.
- Check the Flask server logs for any error messages that could help identify the problem.
- Make sure the necessary NLP packages have been properly installed and imported in the virtual environment.

If you're still facing issues, feel free to reach out for assistance.
```
