
### Converting an Image with Black Point Compensation ###

===========================================================================
DESCRIPTION:

Shows how to convert any image to sRGB applying Black Point Compensation 
using ImageIO, ColorSync and vImage.

ICC profiles specify how to convert the lightest level of white from the 
source device to the destination device, but they do not specify how black 
should be converted. To account for this, you can activate Black Point 
Compensation (BPC) in the color matching performed by ColorSync. Just create 
a ColorSync transform using the ColorSyncTransformCreate function and specify
the optional key kColorSyncBlackPointCompensation to enable BPC. 

In the OS X SDK, see the ColorSync/ColorSyncTransform.h interface files for 
the details.

===========================================================================
BUILD REQUIREMENTS:

OS X 10.9 SDK

===========================================================================
RUNTIME REQUIREMENTS:

OS X 10.9

===========================================================================
USING THE SAMPLE:

 To build from the command line:
 
 cc -g -O0 -o convertimage convertimage.c -Wall -framework ApplicationServices -framework Accelerate
 
 To run from the command line:
 
 ./convertimage "path to source image" "path to destination image"
 
 e.g. ./convertimage myCMYKImage.jpg mySRGBImage.jpg
 
 A test image is included with this project.

===========================================================================
NOTES:

For general information about Black Point Compensation, please see the white 
papers on the ICC website (www.color.org). 

Black Point Compensation will work only if there is a difference in black points 
in the source and destination profiles. That difference is calculated directly 
from the profile data, i.e. does not depend on the Black Point tags in the profiles.

===========================================================================
CHANGES FROM PREVIOUS VERSIONS:

1.0 - First Release

===========================================================================
Copyright (C) 2013 Apple Inc. All rights reserved.