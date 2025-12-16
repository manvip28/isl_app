
## AI tool/mobile app for Indian Sign language(ISL) generator from audio-visual content in English/Hindi to ISL content and vice-versa

This project presents a Flutter-based mobile application that enables two-way translation between spoken/text languages (English and Hindi) and Indian Sign Language (ISL). The system uses a Flask backend to handle speech recognition, language translation, and ISL content retrieval. Users can provide input via text or speech, which is translated and converted into corresponding ISL videos. Conversely, the app can interpret ISL gestures using the mobile camera to help non-signers understand sign language.

Indian Sign Language (ISL) is a vital visual language used by the deaf and hard-of-hearing community in India. However, communication barriers exist between ISL users and the general population, especially in public spaces such as education, healthcare, and transportation. The absence of real-time ISL translation limits access to information and everyday interactions for deaf individuals.

The proposed solution leverages speech recognition, natural language processing, and computer vision to convert audio-visual content into ISL in real time. The system emphasizes accuracy, ease of use, and adaptability to regional ISL variations. Potential applications include converting public announcements (for example, railway platform displays) into ISL and enabling real-time sign language interpretation through a mobile camera, thereby fostering inclusive and accessible communication.

## Deployment Link

https://isl-app-50765.web.app/ 

## Android App (APK)

You can download and install the Android APK from GitHub Releases:

https://github.com/manvip28/isl_app/releases/tag/v1.0.0

**Tested on:** Android 11+  
**Note:** Allow “Install from unknown sources” when installing.

##  Tech Stack

- **Frontend** : Flutter (Android & Web), Dart
- **Backend** : Python, Flask, Flask-CORS
- **Machine Learning & NLP** : TensorFlow Lite (ISL model inference), NLTK (tokenization, POS tagging, lemmatization), Custom NLP pipeline for English → ISL grammar conversion
- **Storage & Cloud** :  Supabase Storage (ISL video assets), Firebase Hosting (Flutter Web frontend), Render (Flask backend API)
- **Mobile & Platform**: Android (APK release), Flutter Web (browser-based demo)
- **DevOps & Tools**: Git & GitHub, GitHub Releases (APK distribution), Firebase CLI, Render deployment

## ⚠️ Platform Limitations

Live ISL gesture detection uses a TensorFlow Lite model and is supported **only on the Android app**.

Flutter Web runs in a browser environment and does not support TensorFlow Lite execution.  
The web version is provided as a functional demo for UI flow and text-based ISL translation.

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

