ReadMe for AudioUnitExamples
-----------------------------
version 1.0 (November 2013)

AudioUnitExamples is a collection of AudioUnit sample code. Each project demonstrates how to create an AudioUnit of a specific type (i.e. Effect, Generator, Instrument, Offline Effect).

AudioUnitEffectExample
	This sample builds a simple low pass filter as an Effect AudioUnit with custom view. 
AudioUnitGeneratorExample
	This sample builds a pink noise generator as a Generator AudioUnit. 
AudioUnitInstrumentExample
	This sample builds a basic sin wave synth as an Instrument AudioUnit.
AudioUnitOfflineEffectExample
	This sample builds a simple Offline Effect AudioUnit.
StarterAudioUnitExample
	This sample is referenced in the AudioUnit programming guide.
    
Note: In the LLVM Preprocessing build setting for each of these samples CA_USE_AUDIO_PLUGIN_ONLY is defined removing all dependency on the deprecated Component Manager APIs. See ComponentBase.h. Also see "Audio Unit AUPlugIn - Updating an existing Audio Unit for OS X Lion and later < https://developer.apple.com/library/mac/technotes/tn2276/ > for AUPlugIn details.

The tutorial for Audio Unit Programming Guide is available in the ADC Reference Library at this location:

	http://developer.apple.com/documentation/MusicAudio/Conceptual/AudioUnitProgrammingGuide/

The following technical note (TN2247) describes how to support sandboxing in an AudioUnit

Audio Components and the Application Sandbox
	https://developer.apple.com/library/mac/technotes/tn2247/

Audio Unit Host Sandboxing Guide
    https://developer.apple.com/library/mac/technotes/tn2312/


Installation
------------
To install one of the sample audio unit for testing, place the built audio unit (e.g. FilterDemo.component) to the following directory. 

	~/Library/Audio/Plug-Ins/Components/
or to:

	/Library/Audio/Plug-Ins/Components/


Testing the Audio Unit
----------------------
To test your Audio Unit after installing it, use an Audio Unit hosting application such as "AU Lab".  AU Lab is part of the Audio Tools for Xcode. 
Please refer to the following technical Q&A (QA1731) on how to download Audio Tools.

	https://developer.apple.com/library/mac/qa/qa1731

"AULab" must be run as a 64-bit host application for these sample Audio Units to be available. This means that in the Finder Info window for the application, the "Open in 32-bit mode" checkbox must NOT be checked.


Sample Requirements
-------------------
This sample project requires:
	
	Mac OS X v10.9 or later
	Xcode 5.0.2 or later

	
Feedback
--------
To send feedback to Apple about this sample project, use the bug reporter at
this location:

	https://developer.apple.com/bug-reporting/

Copyright (C) 2013 Apple Inc. All rights reserved.