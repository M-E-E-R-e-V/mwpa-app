<p align="center">NOTE: This document is under development. Please check regularly for updates!</p>

<h1 align="center">

![MWPA](doc/public/whale-ico.png)

App for MWPA

</h1>

<p align="center">Mammal watching. Processing. Analysing.</p>
<p align="center">Processing and analysing data gathered by mammal watching.</p>

## Information

More information about the project can be found here: [MWPA](https://github.com/M-E-E-R-e-V/mwpa)

This part of MWPA is for the end devices. The software synchronizes data, new data can be recorded (also offline) and transferred back to the MWPA.



The app is implemented with Flutter (Dart) and should support the following platforms:

* Android
* IOS
* Web

## Screenshots
<table>
  <tr>
    <td> 
      <img src="doc/screenshots/login.jpeg" alt="1" width="360px" >
    </td>
    <td> 
      <img src="doc/screenshots/main_tablet.jpeg" alt="1" width="360px" >
    </td>
  </tr>
  <tr>
    <td> 
      <img src="doc/screenshots/add_sighting.jpeg" alt="1" width="360px" >
    </td>
    <td> 
      <img src="doc/screenshots/set_default.jpeg" alt="1" width="360px" >
    </td>
  </tr>
  <tr>
    <td colspan="2">
        <img src="doc/screenshots/add_short.jpeg" alt="1" width="360px" >
    </td>
  </tr>
</table>

## IDE Setup
* Use Android Studio
* Install Flutter: https://docs.flutter.dev/get-started/install/linux
  * Install Dart SDK: https://dart.dev/get-dart
  * Install Android Studio Flutter Plugin
  * Set the Dart SDK in Android Studio: Settings -> Language & Frameworks -> Dart -> Dart SDK Path: /home/user/flutter/bin/cache/dart-sdk

* Right Click to pubspec.yaml
  * Flutter -> Flutter Pub Get
  * Flutter -> Flutter Pub Upgrade
  * Flutter -> Flutter Upgrade

* Add for Debuger 2 Task:
  * Edit Configration main.dart
    * Add "Create Tool" with:
      * Name: Flutter icon
      * Group: External Tools
      * Program: /home/user/fluter/bin/flutter
      * Arguments: pub run flutter_launcher_icons:main
      * Working directory: /home/user/*/mwpa-app
    * Add "Create Tool" with:
      * Name: Flutter name
      * Description: Flutter App Name
      * Group: External Tools
      * Program: /home/user/fluter/bin/flutter
      * Arguments: pub run flutter_app_name
      * Working directory: /home/user/*/mwpa-app

Now you can work with the project!

## TODO 
https://docs.flutter.dev/cookbook/persistence/sqlite
