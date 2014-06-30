There are two sample audio files included with this project:

SampleIMACodecTest.caf
SampleIMACodecTest.mov

Both will playback correctly thereby testing the decoder when the AudioCodecExample.component is built and placed in one of these locations:

/Library/Audio/Plug-Ins/Components
~/Library/Audio/Plug-Ins/Components


SampleIMACodecTest.caf - is an Acme/DEMO IMA encoded 2 channels 44.1kHz Core Audio Format file, created from an uncompressed Garage Band .aif file using afconvert.

The command used to create the above test file is as follows and can be used to test the encoder using your own source file.

     afconvert -f caff -d DEMO sourceFile.aif


SampleIMACodecTest.mov - is an Acme/DEMO IMA encoded 2 channels 16kHz audio only QuickTime Movie file, created from an uncompressed Garage Band .aif file using QuickTime 7 Export to Movie File.