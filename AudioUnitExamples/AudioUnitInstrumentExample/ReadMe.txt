ReadMe for SinSynth
-------------------

SynSynth is a test implementation of a sin wave synth using AUInstrumentBase classes.
It artificially limits the number of notes at one time to 12, by using note-stealing algorithm.
Most of the work you need to do is defining a Note class (see TestNote). AUInstrumentBase manages the creation and destruction of notes, the various stages of a note's lifetime.

A lot of printfs have been left in (but are if'def out)
These can be useful as you figure out how this all fits together. This is true in the AUInstrumentBase class as well; To view the debug messages simply define DEBUG_PRINT to 1.
	
The project also defines CA_AUTO_MIDI_MAP (in OTHER_C_FLAGS). This adds all the code that is needed to map MIDI messages to specific parameter changes. This can be seen in AU Lab's MIDI Editor window. CA_AUTO_MIDI_MAP is implemented in AUMIDIBase.cpp/.h

To build and run “SinSynthWithMIDI” target, the factoryFunction in Info.plist should be changed to match the export function in SinSynthWithMidi.exp

Sample Requirements
-------------------
This sample project requires:
	
	Mac OS X v10.9 or later
	Xcode 5.0 or later
	
Feedback
--------
To send feedback to Apple about this sample project, use the feedback form at 
this location:

	http://developer.apple.com/contact/

Copyright (C) 2013 Apple Inc. All rights reserved.