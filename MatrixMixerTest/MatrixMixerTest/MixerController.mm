/*
    File: MixerController.mm 
Abstract: The main mixer controller. 
 Version: 1.2 
 
Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
Inc. ("Apple") in consideration of your agreement to the following 
terms, and your use, installation, modification or redistribution of 
this Apple software constitutes acceptance of these terms.  If you do 
not agree with these terms, please do not use, install, modify or 
redistribute this Apple software. 
 
In consideration of your agreement to abide by the following terms, and 
subject to these terms, Apple grants you a personal, non-exclusive 
license, under Apple's copyrights in this original Apple software (the 
"Apple Software"), to use, reproduce, modify and redistribute the Apple 
Software, with or without modifications, in source and/or binary forms; 
provided that if you redistribute the Apple Software in its entirety and 
without modifications, you must retain this notice and the following 
text and disclaimers in all such redistributions of the Apple Software. 
Neither the name, trademarks, service marks or logos of Apple Inc. may 
be used to endorse or promote products derived from the Apple Software 
without specific prior written permission from Apple.  Except as 
expressly stated in this notice, no other rights or licenses, express or 
implied, are granted by Apple herein, including but not limited to any 
patent rights that may be infringed by your derivative works or by other 
works in which the Apple Software may be incorporated. 
 
The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
 
IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
POSSIBILITY OF SUCH DAMAGE. 
 
Copyright (C) 2013 Apple Inc. All Rights Reserved. 
 
*/

#import "MixerController.h"

#import <AudioUnit/AudioUnitParameters.h>
#import <AudioUnit/AudioUnitProperties.h>
#import "MeteringView.h"

#import "CAStreamBasicDescription.h"
#import "CAComponentDescription.h"

#define RequireNoErr(error)	do { if( (error) != noErr ) throw OSStatus(error); } while (false)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#pragma mark ____AUComponentDescription

// a convenience wrapper for ComponentDescription
const Float64 kGraphSampleRate = 44100.;

OSStatus renderInput(void *inRefCon, 
	AudioUnitRenderActionFlags *ioActionFlags, 
	const AudioTimeStamp *inTimeStamp, 
	UInt32 inBusNumber, 
	UInt32 inNumberFrames, 
	AudioBufferList *ioData)
{
    SynthData& d = *(SynthData*)inRefCon; // get access to Sinewave's data
	UInt32 bufSamples = d.bufs[inBusNumber].numFrames << 1;
	float *in = d.bufs[inBusNumber].data;

	float *outA = (float*)ioData->mBuffers[0].mData;
	float *outB = (float*)ioData->mBuffers[1].mData;
	if (!in) {
		for (UInt32 i=0; i<inNumberFrames; ++i) 
		{
			outA[i] = 0.f;
			outB[i] = 0.f;
		}
	} else {
		UInt32 phase = d.bufs[inBusNumber].phase;
		for (UInt32 i=0; i<inNumberFrames; ++i) 
		{
			outA[i] = in[phase++];
			outB[i] = in[phase++];
			if (phase >= bufSamples) phase = 0;
		}
		d.bufs[inBusNumber].phase = phase;
	}
	return noErr;
}

@implementation MixerController

- (void)awakeFromNib
{	
	isPlaying = false;
	automate = false;
	automatePhase = 0;

	memset(&d, 0, sizeof(d));
	[self initializeGraph];
    
    meterInPreArray = [[NSMutableArray arrayWithCapacity:4] retain];
    meterInArray = [[NSMutableArray arrayWithCapacity:4] retain];
    meterOutArray = [[NSMutableArray arrayWithCapacity:5] retain];
    xpmeterArray = [[NSMutableArray arrayWithCapacity:20] retain];
        
    NSView *theContentView = theWindow.contentView;
    
    for (int i=0, k=8101; i<4; ++i, k+=100) { // matrix meter tags for these controls are 8101 - 8105, 8201 - 8205, 8301 - 8305, 8401 - 8405
        for (int j=0; j<5; ++j) {
            NSSlider *oldMeter = [theContentView viewWithTag:k+j];
            NSRect newFrame = [oldMeter frame];
			newFrame.size.width = 11;
            MeteringView* mv = [[[MeteringView alloc] initWithFrame: newFrame] autorelease];
            [mv setNumChannels: 1];
            NSView* parent = [oldMeter superview];
			[parent replaceSubview: oldMeter with: mv];
            [xpmeterArray addObject:mv];
        }
    }
    
	for (int j=5000; j<5005; ++j) { // output meter tags for these controls are 5000 - 5004
        NSSlider *oldMeter = [theContentView viewWithTag:j];
		NSRect newFrame = [oldMeter frame];
		newFrame.size.width = 11;
		MeteringView* mv = [[[MeteringView alloc] initWithFrame: newFrame] autorelease];
		[mv setNumChannels: 1];
		NSView* parent = [oldMeter superview];
		[parent replaceSubview: oldMeter with: mv];
        [meterOutArray addObject:mv];
	}
    
    for (int j=7101; j<7501; j+=100) { // input meter tags for these controls are 7101 - 7501
        NSSlider *oldMeter = [theContentView viewWithTag:j];
		NSRect newFrame = [oldMeter frame];
		newFrame.size.width = 11;
		MeteringView* mv = [[[MeteringView alloc] initWithFrame: newFrame] autorelease];
		[mv setNumChannels: 1];
		NSView* parent = [oldMeter superview];
		[parent replaceSubview: oldMeter with: mv];
        [meterInArray addObject:mv];
	}
    
    for (int j=6101; j<6501; j+=100) { // pre input meter tags for these controls are 6101 - 6501
        NSSlider *oldMeter = [theContentView viewWithTag:j];
		NSRect newFrame = [oldMeter frame];
		newFrame.size.width = 11;
		MeteringView* mv = [[[MeteringView alloc] initWithFrame: newFrame] autorelease];
		[mv setNumChannels: 1];
		NSView* parent = [oldMeter superview];
		[parent replaceSubview: oldMeter with: mv];
        [meterInPreArray addObject:mv];
	}
    
    mTimer = [NSTimer scheduledTimerWithTimeInterval: 0.02 target: self selector: @selector(doTimer:) userInfo: nil repeats: YES];
		
	[[NSRunLoop currentRunLoop] addTimer: mTimer forMode: NSModalPanelRunLoopMode];
	[[NSRunLoop currentRunLoop] addTimer: mTimer forMode: NSEventTrackingRunLoopMode];
}

- (void)dealloc
{
    [mTimer invalidate];
    [self stop:nil];
    
    DisposeAUGraph(mGraph);
    
    [meterInPreArray release];
    [meterInArray release ];
    [meterOutArray release];
    [xpmeterArray release];
    
    [super dealloc];
}

extern double dbamp(double x);

- (void)doTimer: (NSTimer*) timer
{
	// set meters
	Float32 value = 0.0f;
	OSStatus err;
    
    MeteringView *meter;
	NSSlider **slider;
	
	if (automate) {
		automatePhase++;
	}
    
	for (int i=0; i<4; ++i) {
		float amps[2] = {0};
		err = AudioUnitGetParameter(mixer, kMatrixMixerParam_PostAveragePower, kAudioUnitScope_Input, i, &amps[0]);
        if (err) printf("AudioUnitGetParameter %ld", (long)err);
		err = AudioUnitGetParameter(mixer, kMatrixMixerParam_PostPeakHoldLevel, kAudioUnitScope_Input, i, &amps[1]);
        if (err) printf("AudioUnitGetParameter %ld", (long)err);
		value = sqrt(dbamp(value));

        // input meters
        meter = [meterInArray objectAtIndex:i];
        [meter updateMeters: amps];
        
		err = AudioUnitGetParameter(mixer, kMatrixMixerParam_PreAveragePower, kAudioUnitScope_Input, i, &amps[0]);
        if (err) printf("AudioUnitGetParameter %ld", (long)err);
		err = AudioUnitGetParameter(mixer, kMatrixMixerParam_PrePeakHoldLevel, kAudioUnitScope_Input, i, &amps[1]);
        if (err) printf("AudioUnitGetParameter %ld", (long)err);
		value = sqrt(dbamp(value));
        
        // pre meters
        meter = [meterInPreArray objectAtIndex:i];
        [meter updateMeters: amps];
	}
    
	for (int i=0; i<5; ++i) {
		float amps[2] = {0};
		err = AudioUnitGetParameter(mixer, kMatrixMixerParam_PostAveragePower, kAudioUnitScope_Output, i, &amps[0]);
        if (err) printf("AudioUnitGetParameter %ld", (long)err);
		err = AudioUnitGetParameter(mixer, kMatrixMixerParam_PostPeakHoldLevel, kAudioUnitScope_Output, i, &amps[1]);
        if (err) printf("AudioUnitGetParameter %ld", (long)err);
		value = sqrt(dbamp(value));
        
        // output meters
        meter = [meterOutArray objectAtIndex:i];
        [meter updateMeters: amps];
	}

	Float32 phaseinc = ( 2. * 3.14159 ) / 32.0;
	slider = &xpslider11;
	for (int i=0, k=0; i<4; ++i) {
		for (int j=0; j<5; ++j, ++k) {
			float amps[2] = {0};
			UInt32 element = (i<<16) | j;
			err = AudioUnitGetParameter(mixer, kMatrixMixerParam_PostAveragePower, kAudioUnitScope_Global, element, &amps[0]);
            if (err) printf("AudioUnitGetParameter %ld", (long)err);
			err = AudioUnitGetParameter(mixer, kMatrixMixerParam_PostPeakHoldLevel, kAudioUnitScope_Global, element, &amps[1]);
            if (err) printf("AudioUnitGetParameter %ld", (long)err);
            
            meter = [xpmeterArray objectAtIndex:k];
            [meter updateMeters: amps];
			
            if (automate) {
				Float32 phase = phaseinc * automatePhase * (1.0 + 0.1 * k);
				Float32 volume = 0.5 + 0.5 * sin(phase);
				volume = volume > 0.7 ? volume : 0.0;
                
				// this should be ModelViewController, but for demo purposes, cheat..
				[slider[k] setFloatValue: volume * 100.];
				err = AudioUnitSetParameter(mixer, kMatrixMixerParam_Volume, kAudioUnitScope_Global, element, volume, 0);
                if (err) printf("AudioUnitSetParameter %ld", (long)err);
			}
		}
	}
}

- (IBAction)play:(id)sender
{
	if (isPlaying) return;

	printf("PLAY\n");
	OSStatus err = AUGraphStart(mGraph);
	isPlaying = true;
	printf("AUGraphStart %08lX\n", (long)err);
}

- (IBAction)setInputVolume:(id)sender
{
	UInt32 inputNum = [sender tag] / 100 - 1;
	AudioUnitSetParameter(mixer, kMatrixMixerParam_Volume, kAudioUnitScope_Input, inputNum, [sender doubleValue] * .01, 0);
}

- (IBAction)setMasterVolume:(id)sender
{
	AudioUnitSetParameter(mixer, kMatrixMixerParam_Volume, kAudioUnitScope_Global, 0xFFFFFFFF, [sender doubleValue] * .01, 0);
}

- (IBAction)setMatrixVolume:(id)sender
{
	UInt32 inputNum = [sender tag] / 100 - 1;
	UInt32 outputNum = [sender tag] % 100 - 1;
	UInt32 element = (inputNum << 16) | (outputNum & 0x0000FFFF);
	AudioUnitSetParameter(mixer, kMatrixMixerParam_Volume, kAudioUnitScope_Global, element, [sender doubleValue] * .01, 0);
}

- (IBAction)setOutputVolume:(id)sender
{
	UInt32 outputNum = [sender tag] % 100 - 1;
	AudioUnitSetParameter(mixer, kMatrixMixerParam_Volume, kAudioUnitScope_Output, outputNum, [sender doubleValue] * .01, 0);
}

- (IBAction)stop:(id)sender
{
	if (!isPlaying) return;
	printf("STOP\n");
	OSStatus err = AUGraphStop(mGraph);
	printf("AUGraphStop %08lX\n", (long)err);
	isPlaying = false;
}

- (IBAction)enableInput:(id)sender
{
	UInt32 inputNum = [sender tag] % 1000 - 1;
	AudioUnitSetParameter(mixer, kMatrixMixerParam_Enable, kAudioUnitScope_Input, inputNum, [sender doubleValue], 0);
}

- (IBAction)enableOutput:(id)sender
{
	UInt32 outputNum = [sender tag] % 1000 - 1;
	AudioUnitSetParameter(mixer, kMatrixMixerParam_Enable, kAudioUnitScope_Output, outputNum, [sender doubleValue], 0);
}

- (void)initializeGraph
{
	CAStreamBasicDescription desc;
	
	OSStatus result = noErr;
	
	result = NewAUGraph(&mGraph);

	AUNode outputNode;
	AUNode mixerNode;
    
		printf("Creating AUGraph\n");
    
    CAComponentDescription output_desc(kAudioUnitType_Output,
                                       kAudioUnitSubType_DefaultOutput,
                                       kAudioUnitManufacturer_Apple);
    
    output_desc.componentFlags = kAudioComponentFlag_SandboxSafe;
    
		output_desc.Print();

    CAComponentDescription mixer_desc(kAudioUnitType_Mixer,
                                      kAudioUnitSubType_MatrixMixer,
                                      kAudioUnitManufacturer_Apple);
    
    mixer_desc.componentFlags = kAudioComponentFlag_SandboxSafe;
    
		mixer_desc.Print();

	result = AUGraphAddNode(mGraph, &output_desc, &outputNode);
	if (result) {
		printf("AUGraphAddNode 1 result %lu %4.4s\n", (unsigned long)result, (char*)&result);
		return;
	}

	result = AUGraphAddNode(mGraph, &mixer_desc, &mixerNode );
	if (result) {
		printf("AUGraphAddNode 2 result %lu %4.4s\n", (unsigned long)result, (char*)&result);
		return;
	}

	result = AUGraphConnectNodeInput(mGraph, mixerNode, 0, outputNode, 0 );
	if (result) {
		printf("AUGraphConnectNodeInput result %lu %4.4s\n", (unsigned long)result, (char*)&result);
		return;
	}
	
	result = AUGraphOpen(mGraph);
	if (result) {
		printf("AUGraphOpen result %u %4.4s\n", (unsigned int)result, (char*)&result);
		return;
	}
	
	result = AUGraphNodeInfo(mGraph, mixerNode, NULL, &mixer );
	if (result) {
		printf("AUGraphNodeInfo result %u %4.4s\n", (unsigned int)result, (char*)&result);
		return;
	}
	
	UInt32 size;
	UInt32 data = 1;

	// turn metering ON
	result = AudioUnitSetProperty(	mixer,
							kAudioUnitProperty_MeteringMode,
							kAudioUnitScope_Global,
							0,
							&data,
							sizeof(data) );	
													
	UInt32 numbuses;
	size = sizeof(numbuses);
	
	// set bus counts
	numbuses = 2;
		printf("set input bus count %u\n", (unsigned int)numbuses);
	result = AudioUnitSetProperty(	mixer,
							kAudioUnitProperty_ElementCount,
							kAudioUnitScope_Input,
							0,
							&numbuses,
							sizeof(UInt32) );
	
	numbuses = 1;
		printf("set output bus count %u\n", (unsigned int)numbuses);
	result = AudioUnitSetProperty(	mixer,
							kAudioUnitProperty_ElementCount,
							kAudioUnitScope_Output,
							0,
							&numbuses,
							sizeof(UInt32) );
	
	for (int i=0; i<2; ++i) {
		// set render callback
        printf("set render callback\n");
		AURenderCallbackStruct rcbs;
		rcbs.inputProc = &renderInput;
		rcbs.inputProcRefCon = &d;
		result = AudioUnitSetProperty(	mixer,
								kAudioUnitProperty_SetRenderCallback,
								kAudioUnitScope_Input,
								i,
								&rcbs,
								sizeof(rcbs) );
								
		// set input stream format
		size = sizeof(desc);
		result = AudioUnitGetProperty(	mixer,
								kAudioUnitProperty_StreamFormat,
								kAudioUnitScope_Input,
								i,
								&desc,
								&size );
		
		desc.ChangeNumberChannels(2, false);						
		desc.mSampleRate = kGraphSampleRate;
		
		printf("set input format %d\n", i);
        desc.Print();
		result = AudioUnitSetProperty(	mixer,
								kAudioUnitProperty_StreamFormat,
								kAudioUnitScope_Input,
								i,
								&desc,
								sizeof(desc) );
	}
	
								
	// set output stream format
	result = AudioUnitGetProperty(	mixer,
							kAudioUnitProperty_StreamFormat,
							kAudioUnitScope_Output,
							0,
							&desc,
							&size );
	
	desc.ChangeNumberChannels(5, false);						
	desc.mSampleRate = kGraphSampleRate;
    

		printf(">>set output format %d\n", 0);
        desc.Print();
	result = AudioUnitSetProperty(	mixer,
							kAudioUnitProperty_StreamFormat,
							kAudioUnitScope_Output,
							0,
							&desc,
							sizeof(desc) );
    
		printf("AUGraphInitialize\n");
// NOW that we've set everything up we can initialize the graph 
// (which will also validate the connections)
	RequireNoErr(AUGraphInitialize(mGraph));
    
        CAShow(mGraph);

}

- (IBAction)addFile:(id)sender
{
	[self stop: nil];
	
    NSInteger result;
    NSArray *fileTypes = [NSArray arrayWithObjects: @"AIFF", @"aif", @"aiff", @"aifc", @"wav", @"WAV", nil];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];

    [oPanel setAllowsMultipleSelection:YES];
    [oPanel setAllowedFileTypes:fileTypes];
    [oPanel setDirectoryURL:[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] objectAtIndex:0]];
    
    result = [oPanel runModal];
    if (result == NSOKButton) {
    
        NSArray *filesToOpen = [oPanel URLs];
        int i, count = [filesToOpen count];
		for (i=0; i<MAXBUFS; ++i) 
		{
			if (d.bufs[i].data) 
			{
				free(d.bufs[i].data);
				d.bufs[i].data = 0;
			}
			if (d.bufs[i].name) 
			{
				[d.bufs[i].name release];
				d.bufs[i].name = 0;
			}
		}

        for (i=0; i<count && i<MAXBUFS; i++) 
		{
            NSString *aFile = [filesToOpen objectAtIndex: i];
			NSString *name = [aFile lastPathComponent];
            NSLog(@"loading file %d, %@\n", i, aFile);

			ExtAudioFileRef xafref;
            OSStatus err = ExtAudioFileOpenURL((CFURLRef)aFile, &xafref);
			if (err || !xafref) {
				printf("couldn't open file\n");
				continue;
			}
						
			UInt32 propSize = sizeof(UInt64);
			CAStreamBasicDescription clientFormat;
			
			propSize = sizeof(clientFormat);
			err = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileDataFormat, &propSize, &clientFormat);
			if (err) {
				printf("couldn't get file data format\n");
				continue;
			}
			
			double rateRatio = kGraphSampleRate / clientFormat.mSampleRate;
			clientFormat.mSampleRate = kGraphSampleRate;
			clientFormat.SetAUCanonical(2, true);
			
			propSize = sizeof(clientFormat);
			err = ExtAudioFileSetProperty(xafref, kExtAudioFileProperty_ClientDataFormat, propSize, &clientFormat);
			if (err) {
				printf("couldn't set file client format\n");
				continue;
			}
			
			propSize = sizeof(UInt64);
			UInt64 numFrames = 0;
			err = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileLengthFrames, &propSize, &numFrames);
			if (err) {
				printf("couldn't get file length\n");
				continue;
			}
			
			numFrames = (UInt32)(numFrames * rateRatio); // account for sample rate conversion
			
			d.bufs[i].numFrames = numFrames;
			d.bufs[i].asbd = clientFormat;						
			d.bufs[i].name = name;
			[d.bufs[i].name retain];
			
			int samples = numFrames * d.bufs[i].asbd.mChannelsPerFrame;
			d.bufs[i].data = (float*)calloc(samples, sizeof(Float32));
			d.bufs[i].phase = 0;
			
			AudioBufferList bufList;
			bufList.mNumberBuffers = 1;
			bufList.mBuffers[0].mNumberChannels = 2;
			bufList.mBuffers[0].mData = d.bufs[i].data;
			bufList.mBuffers[0].mDataByteSize = samples * sizeof(Float32);

			UInt32 numPackets = numFrames;
			err = ExtAudioFileRead(xafref, &numPackets, &bufList);
			if (err) {
				printf("couldn't read data\n");
				free(d.bufs[i].data);
				d.bufs[i].data = 0;
				continue;
			}
			
			ExtAudioFileDispose(xafref);
        }
		d.numbufs = count;
    }	
}

- (IBAction)automateOn:(id)sender;
{
	automate = true;
}

- (IBAction)automateOff:(id)sender;
{
	automate = false;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
}

@end
