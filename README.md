# Gemini Chat App

[![Platform](https://img.shields.io/badge/Platform-Flutter-blue.svg)](https://flutter.dev/)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://developer.android.com/)

This is a Flutter-based chat application that utilizes the Gemini API for communication. 

## Project Overview

This application provides a basic chat interface where users can send and receive messages. The Gemini API is used to handle the communication logic. 

## Features

- Real-time chat functionality.
- Integration with the Gemini API.
- User authentication (using Firebase).
- Basic message display and input.

## Project Setup

1. **Install Flutter:** If you haven't already, install Flutter by following the instructions on the official Flutter website: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)
2. **Clone the repository:** Clone this repository to your local machine.
3. **Install dependencies:** Navigate to the project directory and run `flutter pub get` to install the required dependencies.
4. **Configure Firebase:**
   - Create a Firebase project and add the `google-services.json` file to the `android/app` directory.
   - Enable Firebase Authentication for your project.
5. **Set up Gemini API:** 
    - Configure any necessary API keys or credentials for the Gemini API within the application code (e.g., in `lib/services/gemini_service.dart`).

## Running the Application

1. Connect your device or start an emulator.
2. Run the application using the command `flutter run`.

## Project Structure

- **android:** Contains Android-specific project files.
- **ios:** Contains iOS-specific project files (if applicable).
- **lib:** Contains the core Flutter code for the application:
    - **models:** Data models for the application (e.g., `chat_users.dart`).
    - **pages:** UI screens for the application (e.g., `chat_page.dart`).
    - **services:** Services for interacting with APIs and handling application logic (e.g., `gemini_service.dart`).
    - **utils:** Utility functions and classes (e.g., `file_handlers.dart`).
    - **widgets:** Reusable UI components (e.g., `chat_typing_indicator.dart`).
- **test:** Contains unit and widget tests for the application.
- **web:** Contains files for the web version of the application.
- **pubspec.yaml:** Defines the project's dependencies and metadata.




