### AVGreenScreenPlayer ###

===========================================================================
DESCRIPTION:

This OS X sample application demonstrates real-time video processing, specifically chroma key-effect, using AVPlayerItemVideoOutput. It uses AVPlayerItemVideoOutput in combination with a custom CIFilter to do basic chroma keying. The sample demonstrates the use of CVDisplayLink to drive AVPlayerItemVideoOutput to vend pixel buffers and also AVSampleBufferDisplayLayer to display the processed buffers. The user can input color using the color well and this color is used for the chroma key effect through a CIFilter which is added as a filter to the AVSampleBufferDisplayLayer.

===========================================================================
BUILD REQUIREMENTS:

Xcode 4.4 or later, Mac OS X v10.8 or later

===========================================================================
RUNTIME REQUIREMENTS:

Mac OS X v10.8 or later

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

Version 1.0
- First version.

===========================================================================
Copyright (C) 2012 Apple Inc. All rights reserved.
