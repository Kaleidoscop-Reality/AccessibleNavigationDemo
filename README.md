# Accessible Navigation Demo


<p align="left">
  <img src="https://img.shields.io/badge/Platform-iOS-000000?style=for-the-badge&logo=apple&logoColor=white" alt="Platform iOS">
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 6">
  <img src="https://img.shields.io/badge/UI-SwiftUI-0D96F6?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI">
  <img src="https://img.shields.io/badge/IDE-Xcode-147EFB?style=for-the-badge&logo=xcode&logoColor=white" alt="Xcode">
  <img src="https://img.shields.io/badge/Minimum-iOS%2018-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 18">
</p>

<p align="left">
  <img src="https://img.shields.io/badge/Audio-AVFoundation-555555?style=flat-square" alt="AVFoundation">
  <img src="https://img.shields.io/badge/Haptics-Core%20Haptics-555555?style=flat-square" alt="Core Haptics">
  <img src="https://img.shields.io/badge/State-Observation-555555?style=flat-square" alt="Observation">
  <img src="https://img.shields.io/badge/Data-Codable-555555?style=flat-square" alt="Codable">
  <img src="https://img.shields.io/badge/Architecture-Domain%20Driven-555555?style=flat-square" alt="Domain Driven Architecture">
</p>

<p align="left">
  <img src="https://img.shields.io/badge/Planned-RealityKit-lightgrey?style=flat-square" alt="RealityKit Planned">
  <img src="https://img.shields.io/badge/Planned-ARKit-lightgrey?style=flat-square" alt="ARKit Planned">
  <img src="https://img.shields.io/badge/Planned-OpenUSD-lightgrey?style=flat-square" alt="OpenUSD Planned">
</p>



AccessibleNavigationDemo is an iOS technical prototype built with Swift 6 and SwiftUI. It demonstrates how semantic navigation metadata can be transformed into accessible navigation events delivered through audio, haptic feedback, visual information, user preference adaptation, fallback strategies, and interaction traceability.

The project is intended as a technical demonstrator, standards walkthrough, implementation reference, and foundation for future integration with RealityKit, ARKit, and OpenUSD.

## Purpose

The prototype explores an interoperable accessibility pipeline for physical, augmented reality, and mixed reality environments:

```text
Physical or Mixed Reality Environment
        ↓
Accessible Navigation Metadata
        ↓
Navigation Events
        ↓
Priority Resolution
        ↓
Audio Cue Taxonomy
        ↓
Haptic Cue Taxonomy
        ↓
User Preference Adaptation
        ↓
Fallback Resolution
        ↓
Accessible User Response
        ↓
Traceability
```

The goal is not to standardize a specific application, device, XR platform, sensor, actuator, mapping provider, or artificial intelligence system.

The goal is to demonstrate platform-independent models for:

* semantic navigation entities;
* navigation events;
* event priorities;
* accessible audio cues;
* accessible haptic cues;
* user preferences;
* device capabilities;
* fallback behavior;
* safety handling;
* user responses;
* implementation traceability.

## Current Features

The current prototype includes:

* a sequential accessible navigation walkthrough;
* seven simulated navigation events;
* semantic navigation entity types;
* navigation directions;
* priority levels from P0 to P4;
* audio cue families;
* haptic cue families;
* synthesized spoken instructions;
* Core Haptics support on compatible iPhones;
* UIKit haptic fallback;
* event acknowledgement and repetition;
* pause, resume, restart, and emergency stop controls;
* user response tracking;
* event delivery logging;
* an event traceability log;
* predefined user preference profiles;
* configurable audio and haptic preferences;
* minimum event priority filtering;
* device capability modelling;
* accessible output fallback resolution;
* protection of critical P4 events.

## User Preference Profiles

The application currently defines three initial preference profiles.

### Audio First

Designed for users who prefer detailed spoken guidance.

* detailed audio instructions;
* spatial audio preference;
* medium haptic reinforcement;
* contextual information enabled;
* points of interest enabled.

### Haptic Reinforced

Designed for users who prefer stronger tactile reinforcement.

* concise spoken instructions;
* strong haptic intensity;
* contextual events disabled;
* points of interest disabled;
* early warnings enabled.

### Low Cognitive Load

Designed to reduce optional information and interaction complexity.

* minimal instructions;
* only P2 to P4 events;
* contextual information disabled;
* points of interest disabled;
* simplified output;
* early warnings enabled.

## Safety and Fallback Behavior

User preferences can reduce or disable optional information, but critical P4 events are never filtered.

When the preferred output modality is unavailable, the system evaluates alternative delivery methods.

The current fallback order is:

```text
Preferred audio or haptics
        ↓
Alternative accessible modality
        ↓
Visual output
        ↓
Unsafe delivery state
```

For non-critical events, disabled user preferences are respected whenever possible.

For critical events, the system may force an available accessible modality to prevent silent failure. If no accessible output modality is available, the delivery is marked as unsafe and recorded in the traceability log.

## Priority Model

| Priority | Name        | Intended use                                        |
| -------- | ----------- | --------------------------------------------------- |
| P0       | Informative | Non-essential contextual information                |
| P1       | Low         | Orientation support                                 |
| P2       | Medium      | Ordinary navigation instructions                    |
| P3       | High        | Obstacles, diversions, or important route decisions |
| P4       | Critical    | Immediate safety risks                              |

The intended priority behavior is:

* P4 may interrupt any lower-priority event;
* P3 may interrupt P0 to P2;
* P2 does not interrupt P3 or P4;
* P0 and P1 must not interfere with safety-critical navigation;
* preferences may reduce P0 to P2 events;
* P4 events require a safe fallback whenever the preferred modality is unavailable.

## Audio Cue Families

| Identifier | Purpose      |
| ---------- | ------------ |
| `AUD-DIR`  | Direction    |
| `AUD-OBS`  | Obstacle     |
| `AUD-DST`  | Destination  |
| `AUD-CTX`  | Context      |
| `AUD-SEC`  | Safety       |
| `AUD-SYS`  | System state |

## Haptic Cue Families

| Identifier | Purpose      |
| ---------- | ------------ |
| `HAP-DIR`  | Direction    |
| `HAP-OBS`  | Obstacle     |
| `HAP-DST`  | Destination  |
| `HAP-CTX`  | Context      |
| `HAP-SEC`  | Safety       |
| `HAP-SYS`  | System state |

The current iPhone implementation does not claim physical left or right haptic localization. An iPhone contains a single integrated haptic actuator, so left and right navigation events may preserve different semantics while using similar physical pulse patterns.

Future implementations may distinguish direction through spatial audio, visual information, or external wearable devices.

## Technology Stack

* Swift 6
* SwiftUI
* Observation
* AVFoundation
* AVFAudio
* AVSpeechSynthesizer
* Core Haptics
* UIKit haptic fallback
* Codable
* Xcode
* iOS 18 or later
* physical iPhone testing

Planned technologies include:

* RealityKit
* ARKit
* USD
* USDA
* USDZ
* OpenUSD metadata mapping

## Project Structure

```text
AccessibleNavigationDemo
├── App
│   └── AccessibleNavigationDemoApp.swift
│
├── Domain
│   ├── NavigationPriority.swift
│   ├── AudioCueFamily.swift
│   ├── HapticCueFamily.swift
│   ├── NavigationEntityType.swift
│   ├── NavigationDirection.swift
│   ├── UserResponse.swift
│   ├── NavigationEvent.swift
│   ├── NavigationEvent+Samples.swift
│   ├── HapticPattern.swift
│   ├── TraceAction.swift
│   ├── TraceLogEntry.swift
│   ├── UserPreferenceProfile.swift
│   └── DeviceCapabilities.swift
│
├── Engine
│   ├── ScenarioStatus.swift
│   ├── ScenarioState.swift
│   ├── ScenarioEngine.swift
│   ├── PreferenceAdapter.swift
│   └── FallbackResolver.swift
│
├── Services
│   ├── EventLogService.swift
│   ├── SpeechService.swift
│   └── HapticService.swift
│
├── Views
│   ├── ContentView.swift
│   ├── EventDetailView.swift
│   ├── ScenarioDemoView.swift
│   ├── EventLogView.swift
│   └── ProfileView.swift
│
└── Assets.xcassets
```

The architecture is expected to evolve as the RealityKit, OpenUSD, requirements validation, and live mixed reality components are introduced.

## Example Navigation Event

A navigation event represents more than a displayed message.

```text
Environment condition:
Temporary obstacle ahead

Metadata entity:
Obstacle

Navigation event:
Obstacle warning

Priority:
P3 High

Audio family:
AUD-OBS

Haptic family:
HAP-OBS

Expected response:
Reduce speed and move left
```

Each event can include:

* a unique event identifier;
* a source entity identifier;
* an entity type;
* a title;
* an instruction;
* an optional direction;
* a priority;
* an audio cue family;
* a haptic cue family;
* an optional distance;
* a semantic description;
* an expected response;
* the recorded user response.

## Running the Project

Requirements:

* macOS with a compatible version of Xcode;
* iOS 18 or later;
* Swift 6;
* an iPhone for complete Core Haptics testing.

Steps:

1. Clone the repository.
2. Open `AccessibleNavigationDemo.xcodeproj`.
3. Select an iPhone simulator or physical device.
4. Confirm that the deployment target is compatible with the selected device.
5. Build and run the project.
6. Open the demonstration walkthrough.
7. Select or configure a preference profile.
8. Start the navigation scenario.
9. Review the Event Log to inspect traceability.

Core Haptics behavior should be validated on physical hardware. Simulator behavior is not equivalent to an actual iPhone.

## Current Limitations

The following components are not yet complete:

* live camera navigation;
* RealityKit scenes;
* ARKit tracking;
* 3D navigation objects;
* proximity-based event activation;
* spatial audio delivery;
* local JSON scenario loading;
* USDA or USDZ scene loading;
* OpenUSD metadata mapping;
* live technical inspector;
* complete VoiceOver optimization;
* requirements conformance matrix;
* JSON trace export;
* formal priority interruption management.

The current project is a prototype and should not be treated as a certified navigation or safety system.

## Planned Development

The next development stages include:

1. complete the user profile interface;
2. expose active delivery and fallback decisions in the walkthrough;
3. implement a dedicated priority manager;
4. improve event repetition policies;
5. add complete VoiceOver labels and navigation;
6. separate the Standards Walkthrough from the Live MR Demo;
7. introduce RealityKit and ARKit;
8. add proximity-based event activation;
9. create a local USDA navigation scene;
10. map OpenUSD metadata to Swift navigation events;
11. add live traceability inspection;
12. implement requirements validation and export.

## OpenUSD Direction

The planned architecture preserves the Swift domain models while allowing scene metadata to generate navigation events:

```text
USD, USDA, or USDZ Scene
        ↓
Experimental Accessibility Metadata
        ↓
USDMetadataMapper
        ↓
NavigationEvent
        ↓
Priority, Preferences, and Fallback
        ↓
Audio, Haptics, and Visual Output
```

Potential experimental metadata fields include:

```text
accessibility:entityId
accessibility:entityType
accessibility:direction
accessibility:priority
accessibility:audioCueFamily
accessibility:hapticCueFamily
accessibility:instruction
accessibility:semanticDescription
accessibility:expectedResponse
accessibility:warningDistance
accessibility:reliability
```

These fields are experimental project concepts and are not presented as an official OpenUSD accessibility schema.

## Project Status

AccessibleNavigationDemo is under active development.

The current implementation is suitable for:

* technical demonstrations;
* architecture validation;
* accessibility model experimentation;
* standards discussions;
* prototype testing;
* future OpenUSD accessibility research.

It is not intended for production navigation, medical use, emergency response, or safety-critical deployment.

## License

No license has been selected yet.

Until a license is added, all rights remain reserved by the repository owner.
