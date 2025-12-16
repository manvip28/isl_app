
## AI tool/mobile app for Indian Sign language(ISL) generator from audio-visual content in English/Hindi to ISL content and vice-versa

This project is a Flutter-based application that enables two-way translation between spoken or written languages (English and Hindi) and Indian Sign Language (ISL). Users can input text, speech, or gestures to receive corresponding ISL video output or translated text, helping bridge communication gaps between signers and non-signers.

Indian Sign Language (ISL) is a vital visual language used by the deaf and hard-of-hearing community in India. However, communication barriers persist in public domains such as education, healthcare, and transportation due to the lack of accessible, real-time ISL translation tools.

The proposed solution leverages speech recognition, natural language processing, and computer vision to provide real-time ISL translation. It focuses on accuracy, usability, and accessibility, with potential applications including public announcement translation and real-time sign language interpretation through a mobile camera.


## Web Demo

https://isl-app-50765.web.app/ 

## Android App (APK)

You can download and install the Android APK from GitHub Releases:

[https://github.com/manvip28/isl_app/releases/tag/v1.0.0](https://github.com/manvip28/isl_app/releases/tag/v1.0.1) 

**Tested on:** Android 11+  
**Note:** Allow “Install from unknown sources” when installing.

##  Tech Stack

- **Frontend** : Flutter (Android & Web), Dart
- **Backend** : Python, Flask, Flask-CORS
- **Machine Learning & NLP** : TensorFlow Lite (ISL model inference), NLTK (tokenization, POS tagging, lemmatization), Custom NLP pipeline for English → ISL grammar conversion
- **Storage & Cloud** :  Supabase Storage (ISL video assets), Firebase Hosting (Flutter Web frontend), Render (Flask backend API)
- **Mobile & Platform**: Android (APK release), Flutter Web (browser-based demo)
- **DevOps & Tools**: Git & GitHub, GitHub Releases (APK distribution), Firebase CLI, Render deployment

## Platform Limitations

Live ISL gesture detection is optimized for the Android app using a TensorFlow Lite model.

In the web version, browser limitations can affect TensorFlow Lite execution. Therefore, the web deployment primarily serves as a demo for the application flow and text-based ISL translation, while gesture detection may not function as expected in all cases.


## Features

- **Two-way ISL Translation**
  - Converts English and Hindi text or speech into Indian Sign Language (ISL)
  - Translates ISL gestures captured via the mobile camera into understandable text

- **Real-Time Gesture Recognition (Android)**
  - Uses a TensorFlow Lite model for on-device ISL gesture detection
  - Works offline without sending camera data to a server

- **Text & Speech Input Support**
  - Accepts both typed text and spoken input for translation
  - Provides flexibility for different user needs

- **ISL Video-Based Output**
  - Displays corresponding ISL videos for translated content
  - Ensures clear and visually accurate sign representation

- **Cross-Platform Support**
  - Android mobile app with full functionality
  - Web-based demo for interaction preview and text-based translation

- **Scalable Backend Architecture**
  - Flask-based REST API for NLP processing and ISL content retrieval
  - Deployed on cloud infrastructure for public access


## Developer Setup

- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [Create a Virtual Environment](#create-a-virtual-environment)
  - [Activate the Virtual Environment](#activate-the-virtual-environment)
  - [Install Dependencies](#install-dependencies)
  - [Set Up Python Community Edition Plugin (For IDE)](#set-up-python-community-edition-plugin-for-ide)
  - [Set Up NLP Packages](#set-up-nlp-packages)
  - [Run the Flask Server and Set Up for Physical Device](#run-the-flask-server-and-set-up-for-physical-device)
- [Flutter Setup Instructions](#flutter-setup-instructions)
  - [Add Dependencies](#add-dependencies)
  - [Add Assets](#add-assets)
  - [Add Camera, Internet, and Microphone Permissions](#add-camera-internet-and-microphone-permissions)
  - [Modify `language_to_isl_page.dart` and `main.dart`](#modify-language_to_isl_pagedart_and_maindart)
  - [Run Flutter Pub Get](#run-flutter-pub-get)
- [Running the App](#running-the-app)
- [Requirements](#requirements)
- [Versioning](#versioning)
- [Troubleshooting](#troubleshooting)

## Project Structure

The project is organized into the following folders:

```bash
isl_app/
└── android/
    ├── app/
        ├── src/
            ├── debug/
                └── AndroidManifest.xml  
└── assets/
    └── sign_langauage_model.tflite
└── backend/
    ├── venv/
    ├── app.py
    └── requirements.txt
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

### Run the Flask Server and Set Up for Physical Device
To run the Flask server and use the app on a physical device, follow these steps:
1. Start the Flask Server: Open a terminal and navigate to the backend folder. Then run the following command to start the Flask server:
   ```bash
   flask run --host=0.0.0.0 --port=5000
   ```
   You can replace 5000 with any port number of your choice.

2. Set Up ADB for Physical Device:
   Ensure ADB (Android Debug Bridge) is installed on your laptop (it comes by default with Android Studio).
   - Open a new terminal window, and navigate to the platform-tools directory. This can be found under C:\Users\<YourUser>\AppData\Local\Android\Sdk\platform-tools (on Windows).
   - Run the following command to reverse the port for the Flask server to allow the physical device to communicate with the server:
      ```bash
      .\adb.exe reverse tcp:5000 tcp:5000
      ```
      This command ensures that the physical device can connect to the Flask server running on your laptop.
3. Run the Flask Server with Python (For Emulator): Alternatively, if you're using an emulator, you can run the Flask server using Python directly by typing the following command:
  ```bash
  python app.py
  ```


## Flutter Setup Instructions 
### Add Dependencies:
Open pubspec.yaml and add the following dependencies mentioned in the pubspec.yaml

### Add Camera, Internet, and Microphone Permissions:
To add the necessary permissions, open the AndroidManifest.xml file located in android/app/src/debug/AndroidManifest.xml, and add the following permissions:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.MICROPHONE" />
```


### Modify language_to_isl_page.dart and main.dart:
In line 81 of language_to_isl_page.dart, replace with your machine's IP address (e.g., http://192.168.x.x:5000/convert_to_isl), or use http://10.0.2.2:5000/convert_to_isl if using an emulator.
In your main.dart, ensure you replace the placeholders with your actual Supabase project URL and anonymous key:
<SUPABASE_PROJECT_URL> & <SUPABASE_ANON_KEY>

### Run flutter pub get:
After modifying pubspec.yaml, run the following command in the terminal to install dependencies and include assets:

```bash
flutter pub get
```


## Running the App

To run the application in the correct order, follow these steps:

1. Start the Android emulator in Android Studio (or connect your physical device).
2. Run the Flask server:
   - If using an emulator, run the server using
     ```bash
     python app.py
     ```
   - If using a physical device, ensure the Flask server is running and properly set up for the device, as described in the [Run the Flask Server and Set Up for Physical Device](#run-the-flask-server-and-set-up-for-physical-device) section.
3. Run main.dart to start the Flutter app.


## Deployment

- The Flask backend is deployed on Render, making the API publicly accessible without running the server locally.
- The Flutter web application is deployed on Firebase Hosting, allowing users and recruiters to access the app directly via a browser.

## Troubleshooting

If you encounter any issues during the setup process, please check the following:

- Ensure the virtual environment is active before installing dependencies or running the Flask server.
- Verify that the Python interpreter in Android Studio is correctly configured to use the virtual environment.
- Check the Flask server logs for any error messages that could help identify the problem.
- Make sure the necessary NLP packages have been properly installed and imported in the virtual environment.

If you're still facing issues, feel free to reach out for assistance.

