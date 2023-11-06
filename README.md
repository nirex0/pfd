## Welcome 

A Plug and Play Flutter Widget Library for Primary Flight Display.

## Features

A Simple Statless PFD Widget that works across all platforms (Since it uses built-in dart drawing functionality) and has the ability to lively show **Roll** **Pitch** **Yaw**, **Air Speed** and **Ground Speed**.


## Getting started

It's extremely simple to get started with this library

simply add it to your flutter pubspec.yaml file by first running the command:

```bash
flutter pub add pfd
```

and then optionally running:

```bash
flutter pub get
```

## Usage

Simply Import the Package and use the PFD widget.

```dart

PFD(
    airSpeed: AirSpeed,
    roll: Roll,
    pitch: Pitch,
    yaw: Yaw,
    altitude: Altitude,
    width: 400,
    height: 400,
)
```

### Note: You can use a State Manager like GetX to update the PFD widget since it is indeed a stateless widget.

## Contribution

Any Contributions are welcome, this widget currently misses some more functionality such as Alpha and Beta, G-Load and most importantly a **Command** value/indicator for each of the **3-Degree angles** as well as **Air Speed** and **Ground Speed**.

