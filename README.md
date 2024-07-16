
# BFRBSys version 2.1.0
[![Build Status](https://img.shields.io/badge/Build-passing-brightgreen.svg)](https://github.com/xtnctx/bfrbsys/blob/main/FlutterApp/android/build.gradle)
[![Platform](https://img.shields.io/badge/Platform-Android-green.svg)](https://github.com/xtnctx/bfrbsys/blob/main/FlutterApp/android/app/src/main/AndroidManifest.xml)
[![Version](https://img.shields.io/badge/version-2.1.0-blue.svg)](https://github.com/xtnctx/bfrbsys/releases/tag/v2.1.0)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Repo Size](https://img.shields.io/github/repo-size/xtnctx/bfrbsys)](https://github.com/xtnctx/bfrbsys/tags#:~:text=b0ad94f-,zip,-tar.gz)
[![Docs](https://img.shields.io/badge/Docs-available-brightgreen.svg)](https://github.com/xtnctx/bfrbsys/tree/main/Docs)



### What is Body-Focused Repetitive Behavior (BFRB)?
These are repetitive self-grooming behaviors where an individual damages their appearance or causes physical harm, often as a coping mechanism for stress or anxiety. 
Common examples includes:
 - Hair pulling (trichotillomania)
 - Nail biting (onychophagia).
 - Skin picking (dermatillomania)

-------------------
### System Overview
It comprises three (3) main components necessary for its operation: the wearable device, mobile application, and web server.

The wearable device is the main component that classifies the anticipatory behavior of the user. The microcontroller used is the Arduino Nano 33 BLE Sense, the wearable needs to connect to the web server to access the file of the user. 

However, this microcontroller only supports Bluetooth Low Energy (BLE) and does not support connecting via the internet. Therefore, the I used a bridge to support connection to the server through a mobile application connecting via BLE. 

To maintain communication without relying on a physical server, I have integrated the server into the cloud. This allows users to effectively utilize the system over the internet.

<p align="center">
    <img src="https://github.com/user-attachments/assets/901ff85a-3107-4638-b206-344b27f8ff6d">
</p>

------------
### Software 🔥
The design for building the mobile application is shown. I carefully considered the simplicity of the mobile application for user experience. The system views or the pages serve as the frontend that divides its individual functions for the application. 

Accounts management, file management, and other API workflow are done in the backend. These workflows effectively reduce the complexity of the user interface making it easier to use. The mobile application also has its limitations for creating machine learning components. 

Therefore, I used a server to connect the application and access the database using the Hypertext Transfer Protocol (HTTP) services.

<p align="center">
    <img src="https://github.com/user-attachments/assets/8c44bf6d-42c8-4d04-84c7-fbcc54fde104">
</p>

-------------------------
### Device Specifications
|BLE DISTANCE (FEET)|BATTERY CAPACITANCE (mAh)|BATTERY LOAD CURRENT (mA)|FILE TRANSFER SPEED (BYTE/S)|
|:-----------------:|:----------------------:|:------------------------:|:--------------------------:|
|        67         |          1000          |            30            |            380             |

-------------------------------------
### Schematic Diagram of the Wearable
The primary tasks of the microcontroller include enabling the functionality of other components, establishing connections via BLE, and performing calculations based on sensor readings. 

The sensors used include the accelerometer and gyroscope of the LSM9DS1 inertial measurement unit (IMU) sensor, the VL53L0X time-of-flight (ToF) distance sensor, and the MLX90614 infrared (IR) temperature sensor, which are crucial for detecting user’s anticipating behavior.

The data are then used to classify anticipating behavior and use this as a signal to operate the vibration and passive buzzer.

<p align="center">
    <img src="https://github.com/user-attachments/assets/854de24f-7be4-4dee-a14c-a28b166f9861">
</p>

-------------------
### Wearable Device 
<p align="center">
    <img src="https://github.com/user-attachments/assets/de60b270-b047-4fb0-8bff-7942f879fb32">
</p>

----------------------
### Mobile Application
The purpose of this [app](https://github.com/xtnctx/bfrbsys/tree/main/FlutterApp) is to get input values from the wearable and train it using the Feedforward Neural Network on the web then sends the machine learning model file contents through BLE. User can also see their improvements weekly or monthly.

<p align="center">
    <img src="https://github.com/user-attachments/assets/570126fd-c0bc-474d-8f4c-320b08da19b1">
</p>

------------
## Documents 📄
- [Title proposal](https://github.com/xtnctx/bfrbsys/blob/main/Docs/Capsule_Bahillo-Dalanon.pdf)
- [Outline](https://github.com/xtnctx/bfrbsys/blob/main/Docs/outline.pdf)
- [Manuscript](https://github.com/xtnctx/bfrbsys/blob/main/Docs/Development%20of%20Microcontroller-Based%20Wearable%20Device%20with%20Monitoring%20System%20for%20Body-Focused%20Repetitive%20Behavior.pdf)
