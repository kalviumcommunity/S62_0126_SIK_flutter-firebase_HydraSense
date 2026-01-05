# Sprint #2
## Project Title: HydraSense – Mobile Flood Early Warning System

## Tech Stack
### Frontend: Flutter, Dart

### Backend: Firebase (Authentication, Firestore)

### APIs: OpenWeatherMap API

## 1. Problem Statement & Solution Overview

### Problem Statement

Flood-prone districts often receive weather and flood warnings that are delayed, hard to interpret, or not localized. This prevents residents from taking timely preventive actions, leading to avoidable safety risks and property damage.

### Solution Overview

HydraSense is a mobile-first early warning application that converts open meteorological data into simple, real-time flood risk indicators for local communities. Built using Flutter and powered by Firebase, the app provides clear flood risk levels (Low / Moderate / High) along with preparedness guidance, enabling users to act before flooding occurs.

### Target Users

Residents of flood-prone districts

Families and daily commuters

Local volunteers and community coordinators

### Why Mobile?

Mobile devices enable the fastest delivery of alerts

Real-time updates are critical during emergencies

Offline access ensures reliability during poor network connectivity

## 2. Scope & Boundaries
### In Scope (Sprint #2 MVP)

Flutter-based mobile application

Firebase Authentication (Email/Password)

Firestore database for real-time alerts

District-based flood risk visualization

Rule-based flood risk scoring using weather data

Basic district-level map view

Safety checklist for preparedness

APK build for demo

### Out of Scope

Machine learning-based flood prediction

River sensor or satellite data integration

Bluetooth-based emergency alerts

Multi-language support

SMS or IVR alerts

## 3. Roles & Responsibilities

### Role and Team Member Responsibilities
UI Lead: Issac - Wireframes, Flutter UI screens, navigation, state handling
Firebase Lead: Kirana - Firebase setup, Authentication, Firestore schema, weather API integration
Deployment & Testing Lead: Sera - APK builds, testing, CI/CD setup, final demo preparation

## 4. Sprint Timeline (4 Weeks)
### Week 1 – Setup & Design

Finalize MVP features

Design app flow and UI wireframes

Flutter project setup

Firebase project creation

Firestore schema planning

### Week 2 – Core Development

Authentication flows (Login / Signup)

Home dashboard UI

Firestore read/write implementation

Weather API data fetch (basic)

### Week 3 – Integration & Testing

Connect Flutter UI with Firebase backend

Implement flood risk scoring logic

Form validation and error handling

Manual testing on Android devices

### Week 4 – MVP Completion & Deployment

Feature freeze

UI polish

Final APK build

Documentation and demo preparation

## 5. MVP (Minimum Viable Product)
MVP Features

User authentication via Firebase Auth

Real-time district flood risk level

Home dashboard with risk indicators

Map view showing risk zones

Safety checklist screen

Firestore-powered live data sync

Demo-ready APK

Core App Components

Splash Screen

Login / Signup

Home Dashboard

Map View

Safety Checklist

Profile / Settings (basic)

## 6. Functional Requirements

Users can register, log in, and log out securely

Flood risk levels update in real time

App displays district-specific alerts

Safety guidance is accessible during high-risk events

## 7. Non-Functional Requirements

Performance: UI transitions under 200 ms

Scalability: Support ~100 concurrent users

Security: Firestore rules with authenticated access

Responsiveness: Adaptive layouts for mobile devices

Reliability: Last alert cached for offline access

## 8. Success Metrics

All MVP features functional by sprint end

Firebase Auth and Firestore fully integrated

APK build runs without critical bugs

Real-time updates demonstrated during demo

Positive mentor feedback

## 9. Risks & Mitigation
Risk	Impact	Mitigation
Firebase setup issues	Backend delay	Early setup and console testing
API rate limits	Data gaps	Cache data and use mock fallback
Limited Flutter experience	UI bugs	Keep UI simple and test early
Integration delays	Sprint overrun	Parallel UI and backend development