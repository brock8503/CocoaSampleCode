### MatrixMixerTest ###

===========================================================================
DESCRIPTION:

MatrixMixerTest is a Cocoa-based application that provides an example of obtaining an instance of the matrix mixer audio unit and using it for audio mixing. The application also provides an example of creating metering views for viewing audio signal levels.

===========================================================================
BUILD REQUIREMENTS:

Mac OS X v10.8 or later

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X v10.8 or later

===========================================================================
PACKAGING LIST:

main.mm
- The main file of the project

MeteringView.h
MeteringView.mm
- MeteringView class for displaying the input signal levels

MixerController.h
MixerController.mm
- Controller class for managing and manipulating the matrix mixer

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0 - First version.
Version 1.1 - Project Updated for Xcode 4.6.3 and 10.8 SDK. Fixed MeterView
              crashing bugs in 64-bit, some re-factoring, added Core Audio Utility
              files, added more logging. App is sandboxed.

===========================================================================
Copyright (C) 2002-2013 Apple Inc. All rights reserved.
