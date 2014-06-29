AudioDeviceNotify

===========================================================================
DESCRIPTION:

Demonstrates how to enumerate all audio devices attached to a system and display each device's basic information (id, name, number of channels). Also demonstrates how to setup and receive notifications from Core Audio when audio devices are installed or removed from the system.

===========================================================================
RELATED INFORMATION:

The AudioDeviceNotify project contains two Targets; AudioDeviceNotify and AudioDeviceNotify2.

The targets build samples that are exactly identical in functionality except for the implementation files for each described as follows:

AppController.m demonstrates the above functionality using standard CoreAudio AudioObject APIs and is only included in the AudioDeviceNotify Target which builds AudioDeviceNotify.app

AppController.mm demonstrates the above functionality using the Core Audio Utility Classes and is only included in the AudioDeviceNotify2 Target and builds AudioDeviceNotify2.app.

All source in the PublicUtility Group are only included in the AudioDeviceNotify2 project.

Having two implementations building separate targets yet performing the exact same task (one with and one without the use of Public Utility helpers) allows developers to easily compare and contrast how using the Core Audio Utility classes may be useful to simplify and speed up their work with the Core Audio APIs.

Core Audio Utility Classes download can be found here:
http://developer.apple.com/library/mac/#samplecode/CoreAudioUtilityClasses/Introduction/Intro.html

We do recommend being completely familiar with the standard C APIs before jumping into the C++ Utility classes.

===========================================================================
BUILD REQUIREMENTS:

Mac OS X v10.7, Xcode 4.5


===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X v10.7 or later.