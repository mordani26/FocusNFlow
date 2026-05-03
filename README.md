# FocusNFlow

FocusNFlow is a Flutter-based study management application designed to help students organize their academic activities using real-time features powered by Firebase.

---

## Features

* Firebase Authentication (login/register with email)
* Student Profile Management
* Study Room Finder (real-time occupancy tracking)
* Study Groups (create and join groups)
* Group Chat (real-time messaging)
* Study Session Scheduling
* Shared Study Timer (real-time synchronization)
* Weekly Study Plan Assistant (priority-based task ranking)

---

## Technologies Used

* Flutter (Dart)
* Firebase Authentication
* Cloud Firestore

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/mordani26/FocusNFlow.git
cd FocusNFlow
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

Ensure your Firebase project is properly configured.

Enable the following services in Firebase:

* Authentication (Email/Password)
* Firestore Database

The file `firebase_options.dart` is already included and configured.

---

### 4. Run the app

```bash
flutter run
```

---

## How to Use

1. Register or log in with your email
2. Use the home screen to navigate:

* Student Profile: edit personal and academic information
* Study Room Finder: check in and check out of study rooms
* Study Groups: create or join study groups
* Group Chat: send and receive messages in real time
* Study Sessions: create and manage study sessions
* Shared Study Timer: start, pause, and reset a shared timer
* Weekly Study Plan Assistant: add tasks and view prioritized study plans

---

## Study Plan Logic

Tasks are ranked using transparent rules based on:

* Due date urgency
* Effort level (scale 1–5)
* Course weight (scale 1–5)

Each task includes an explanation describing how its priority score is calculated.



## Project Structure

```
lib/
  screens/
  services/
  models/
  main.dart
```



## Author

Daniel Moreno
Georgia State University



## Notes

* Firestore indexes may be required for certain queries
* Real-time features require an active internet connection
* This application is designed for academic demonstration purposes
