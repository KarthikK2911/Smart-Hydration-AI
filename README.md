Smart Hydration AI

Using Flutter and Dart, Smart Hydration AI is a customized hydration monitoring program. To give adaptive hydration recommendations and track hydration history, it integrates user data, water intake, activity-related inputs, real-time meteorological data, and a Mamdani Fuzzy Inference System.

Disclaimer: This project is a prototype for study and education.
It is not meant to diagnose, prevent, or treat any medical condition and is not a medical device.

Features

Personalized daily hydration goal

Daily water intake tracking

Real-time temperature and relative humidity

Device location-based weather retrieval

Mamdani fuzzy inference system with 18 IF--THEN rules

Hydration status classification

Seven-day hydration history

User profile and settings

Local data persistence

Activity/calorie-based goal adjustment

Responsive Flutter interface

Technology Stack

Application: Flutter, Dart

Weather API: Open-Meteo REST API

Location: Geolocator

Networking: Dart HTTP

Local Storage: SharedPreferences

Evaluation: Python, NumPy, pandas, scikit-fuzzy, scikit-learn,
Matplotlib, OpenPyXL

Development: Android Studio, Git, GitHub

Prerequisites

Before running the project, install the following.

Required Software

1. Git

Used to clone and manage the repository.

git --version

2. Flutter SDK

Install a current stable Flutter release, then verify it:

flutter --version

3. Dart SDK

Dart is included with Flutter, so a separate installation is normally
unnecessary.

dart --version

4. Android Studio

Install Android Studio with the Flutter and Dart plugins.

5. Android SDK

Install the required Android SDK through Android Studio's SDK Manager.

6. Android Emulator or Physical Device

Create an emulator with Android Studio Device Manager or connect an
Android phone with Developer Options and USB debugging enabled.

Environment Check

Run:

flutter doctor

Resolve required issues reported by Flutter. If necessary, accept the
Android SDK licenses:

flutter doctor --android-licenses

Additional Requirements

Internet connection for live weather retrieval

Location services enabled for location-based weather

Permission to access device location

Installation

1. Clone the Repository

git clone https://github.com/YOUR_USERNAME/smart-hydration-ai.git

2. Enter the Project

cd smart-hydration-ai

3. Install Dependencies

flutter pub get

4. Check Available Devices

flutter devices

5. Run the Application

flutter run

For a specific device:

flutter run -d DEVICE_ID

Android Studio Setup

Open Android Studio.

Select Open and choose the cloned project directory.

Allow the project to finish indexing.

Run flutter pub get.

Start an Android emulator or connect a physical Android device.

Select the target device.

Click Run, or execute flutter run from the terminal.

Location and Weather

The application uses device location to retrieve local environmental
conditions.

Device Location
      ↓
Latitude + Longitude
      ↓
Open-Meteo REST API
      ↓
Temperature + Relative Humidity
      ↓
Hydration Model

Android location permissions are configured in:

android/app/src/main/AndroidManifest.xml

Open-Meteo does not require a private API key for the basic weather
request used by this project.

Mamdani Fuzzy Inference System

The fuzzy model uses three inputs:

Input                      Range Membership Sets

Temperature             0--50 °C Low, Moderate, High
Relative Humidity        0--100% Low, Moderate, High
Water Intake          0--7000 mL Low, Moderate, High

The internal output is mapped to four hydration categories:

Hydration Score   Classification

< 40            Dehydrated
40 – <70        Normal
70 – 100        Well Hydrated
> 100           Overhydrated

The numerical output is an internal fuzzy-system score, not a
physiological percentage of body hydration.

Inference Pipeline

Temperature ──┐
Humidity ─────┼──> Fuzzification
Water Intake ─┘          ↓
                    18 IF–THEN Rules
                          ↓
                    Rule Evaluation
                          ↓
                      Aggregation
                          ↓
                Centroid Defuzzification
                          ↓
                 Crisp Hydration Score
                          ↓
                Hydration Classification

Example:

IF Temperature is High
AND Humidity is Low
AND Water Intake is Low
THEN Hydration Status is Dehydrated

Personalized Daily Goal

The application uses a body-weight baseline together with environmental,
activity, and profile-related adjustments:

Daily Goal =
Body Weight Baseline
+ Temperature Adjustment
+ Humidity Adjustment
+ Activity Adjustment
+ Profile Adjustment

Some coefficients and thresholds in the prototype are project-specific
engineering parameters and should not be interpreted as universal
clinical recommendations.

Project Structure

smart-hydration-ai/
│
├── lib/
│   ├── main.dart
│   ├── screens/
│   ├── services/
│   ├── storage/
│   └── utils/
├── assets/
├── android/
├── ios/
├── web/
├── test/
├── datasets/
├── evaluation/
├── pubspec.yaml
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
├── LICENSE
└── README.md

The exact structure may vary with the current project version.

Python Evaluation Prerequisites

Python is not required to run the Flutter application. It is needed
only to reproduce the fuzzy-model evaluation.

Verify Python and pip:

python --version
pip --version

Install evaluation dependencies:

pip install numpy pandas matplotlib scikit-fuzzy scikit-learn openpyxl

Then run your evaluation script:

python evaluate_fuzzy_model.py

The evaluation pipeline can generate prediction spreadsheets, confusion
matrices, classification reports, overall metrics, crisp hydration
outputs, maximum rule strengths, and strongest activated rules.

Synthetic Dataset Notice

The model-evaluation datasets are synthetic benchmark datasets
created computationally for controlled evaluation of the fuzzy inference
system. They were not collected from patients or human research
participants.

Scientific literature informed the selection of relevant variables and
general hydration relationships; it was not the direct source of
individual synthetic records.

Some controlled benchmark datasets may contain deliberately perturbed
reference labels to evaluate the reporting pipeline under known
disagreement levels. Their results represent synthetic benchmark
agreement and implementation consistency, not clinical diagnostic
accuracy.

Privacy and Repository Safety

Before publishing a fork or modified version, do not commit secrets or
private configuration such as:

.env
*.jks
*.keystore
key.properties
service-account*.json
API keys
passwords
access tokens
private certificates
local.properties

Generated folders such as build/, .dart_tool/, .gradle/, and
IDE-specific files should be excluded through .gitignore.

Limitations

The fuzzy rules and parameters have not been clinically validated.

Synthetic data are used for controlled model evaluation.

Water intake is a proxy and does not directly measure physiological
hydration.

Manual calorie and water entries may contain user error.

Environmental conditions do not directly measure individual fluid
loss.

The system does not account for every medical condition, medication,
electrolyte state, diet, or individual sweat rate.

The overhydration category is a software decision output, not a
medical diagnosis.

Independent real-world validation is required before clinical use.

Future Improvements

React.js web application

Wearable-device integration

Automatic activity tracking

User authentication and cloud synchronization

Longer-term hydration analytics

Improved reminder notifications

Adaptive fuzzy membership functions

Personalized rule optimization

Additional physiological variables

Independent real-world validation

Key References

L. A. Zadeh, "Fuzzy Sets," Information and Control, vol. 8, no. 3,
pp. 338--353, 1965.

E. H. Mamdani and S. Assilian, "An Experiment in Linguistic
Synthesis with a Fuzzy Logic Controller," International Journal of
Man-Machine Studies, vol. 7, no. 1, pp. 1--13, 1975.

T. J. Ross, Fuzzy Logic with Engineering Applications, 4th ed.,
Wiley, 2016.

M. N. Sawka et al., "American College of Sports Medicine Position
Stand: Exercise and Fluid Replacement," Medicine & Science in
Sports & Exercise, vol. 39, no. 2, pp. 377--390, 2007.

EFSA Panel on Dietetic Products, Nutrition and Allergies,
"Scientific Opinion on Dietary Reference Values for Water," EFSA
Journal, vol. 8, no. 3, 1459, 2010.

Disclaimer

Smart Hydration AI is an educational and research prototype
demonstrating mobile development, environmental API integration,
hydration tracking, and fuzzy-logic-based decision support.

It is not a medical device and does not provide medical diagnosis or
treatment recommendations.
