# 💧 Smart Hydration AI

A personalized hydration monitoring application built with **Flutter and Dart** that combines real-time environmental data with a **Mamdani Fuzzy Inference System** to provide adaptive hydration recommendations.

The application considers **water intake, temperature, humidity, user profile information, and activity-related inputs** to help users monitor their daily hydration.

> **Note:** Smart Hydration AI is a research and wellness prototype. It is not intended to diagnose, prevent, or treat any medical condition.

---

## 📌 Overview

Traditional hydration trackers typically rely on fixed daily water goals. However, hydration requirements can vary depending on factors such as body weight, environmental conditions, activity, and physiological characteristics.

Smart Hydration AI was developed to explore a more adaptive approach.

The application combines:

- User profile information
- Daily water intake
- Real-time temperature
- Relative humidity
- Activity information
- Mamdani fuzzy logic

to generate personalized hydration goals and interpretable hydration feedback.

---

## ✨ Features

- 💧 Daily water intake tracking
- 🎯 Personalized hydration goal calculation
- 🌡️ Real-time temperature retrieval
- 💦 Relative humidity monitoring
- 📍 Device location-based weather data
- 🧠 Mamdani fuzzy inference system
- 📊 Hydration status classification
- 📈 Seven-day hydration history
- 👤 User profile management
- 🔄 Daily hydration reset
- 💾 Local data persistence
- 📱 Responsive Flutter interface

---

## 🧠 Mamdani Fuzzy Logic Model

The core decision-support component of the application is a **Mamdani Fuzzy Inference System**.

### Inputs

The fuzzy model evaluates three primary inputs:

| Input | Range | Fuzzy Sets |
|---|---:|---|
| Temperature | 0–50 °C | Low, Moderate, High |
| Relative Humidity | 0–100% | Low, Moderate, High |
| Water Intake | 0–7000 mL | Low, Moderate, High |

### Output

The model generates an internal hydration score that is mapped into four hydration-status categories:

| Hydration Score | Classification |
|---|---|
| `< 40` | Dehydrated |
| `40 – <70` | Normal |
| `70 – 100` | Well Hydrated |
| `> 100` | Overhydrated |

The numerical output is an **internal fuzzy-system score** and should not be interpreted as a physiological percentage of body hydration.

---

## ⚙️ How the Fuzzy System Works

The hydration model follows the standard Mamdani inference pipeline:

1. **Fuzzification**  
   Converts temperature, humidity, and water intake into degrees of membership.

2. **Rule Evaluation**  
   Evaluates 18 human-readable IF–THEN fuzzy rules.

3. **Rule Aggregation**  
   Combines the activated fuzzy rule outputs.

4. **Defuzzification**  
   Converts the aggregated fuzzy output into a crisp hydration score.

5. **Classification**  
   Maps the resulting score into one of the four hydration categories.

### Example Rule

```text
IF Temperature is High
AND Humidity is Low
AND Water Intake is Low
THEN Hydration Status is Dehydrated
