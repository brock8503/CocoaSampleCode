/*
     File: AUPinkNoise.cpp
 Abstract: AUPinkNoise.h
  Version: 1.0.1
 
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
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
*/

#include "AUPinkNoise.h"
#include "AUBaseHelper.h"

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

AUDIOCOMPONENT_ENTRY(AUBaseFactory, AUPinkNoise)

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

AUPinkNoise::AUPinkNoise(AudioUnit component)
	: AUBase(component, 0, 1),
	  mPink (NULL)
{
	CreateElements();
	Globals()->UseIndexedParameters(kNumberOfParameters);
	SetParameter(kParam_Volume, kAudioUnitScope_Global, 0, kDefaultValue_Volume, 0);
	SetParameter(kParam_On, kAudioUnitScope_Global, 0, 1, 0);
}

void				AUPinkNoise::Cleanup()
{
	delete mPink;
	mPink = NULL;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OSStatus			AUPinkNoise::Initialize()
{
	const CAStreamBasicDescription & theDesc = GetStreamFormat(kAudioUnitScope_Output, 0);
	
	mPink = new PinkNoiseGenerator::PinkNoiseGenerator(theDesc.mSampleRate);
	
	return noErr;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OSStatus			AUPinkNoise::GetPropertyInfo (	AudioUnitPropertyID				inID,
															AudioUnitScope					inScope,
															AudioUnitElement				inElement,
															UInt32 &						outDataSize,
															Boolean &						outWritable)
{
	if (inScope == kAudioUnitScope_Global)
	{
		switch (inID)
		{
			case kAudioUnitProperty_CocoaUI:
					outWritable = false;
					outDataSize = sizeof(AudioUnitCocoaViewInfo);
					return noErr;
									
			default:
				return kAudioUnitErr_InvalidProperty;				
		}
	}

	return AUBase::GetPropertyInfo (inID, inScope, inElement, outDataSize, outWritable);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OSStatus			AUPinkNoise::GetProperty (	AudioUnitPropertyID 		inID,
														AudioUnitScope 				inScope,
														AudioUnitElement			inElement,
														void *						outData)
{
	if (inScope == kAudioUnitScope_Global)
	{
		switch (inID)
		{
			case kAudioUnitProperty_CocoaUI:
			{
				CFURLRef bundleURL = CFURLCreateWithFileSystemPath(	kCFAllocatorDefault, 
																	CFSTR("/System/Library/Frameworks/CoreAudioKit.framework"), 
																	kCFURLPOSIXPathStyle, 
																	TRUE);
				if (bundleURL == NULL) return fnfErr;
		
				CFStringRef className = CFSTR("AUGenericViewFactory");
				AudioUnitCocoaViewInfo cocoaInfo = { bundleURL, { className } };
				*((AudioUnitCocoaViewInfo *)outData) = cocoaInfo;
				
				return noErr;
			}
		}
	}
	
	return AUBase::GetProperty (inID, inScope, inElement, outData);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OSStatus			AUPinkNoise::GetParameterInfo(AudioUnitScope		inScope,
                                                        AudioUnitParameterID	inParameterID,
                                                        AudioUnitParameterInfo	&outParameterInfo )
{
	OSStatus result = noErr;

	outParameterInfo.flags = 	kAudioUnitParameterFlag_IsWritable
						|		kAudioUnitParameterFlag_IsReadable;
    
    if (inScope == kAudioUnitScope_Global) {
        switch(inParameterID)
        {
            case kParam_Volume:
                AUBase::FillInParameterName (outParameterInfo, kParameterVolumeName, false);
                outParameterInfo.unit = kAudioUnitParameterUnit_LinearGain;
                outParameterInfo.minValue = 0.0;
                outParameterInfo.maxValue = 1;
                outParameterInfo.defaultValue = kDefaultValue_Volume;
				outParameterInfo.flags |= kAudioUnitParameterFlag_DisplaySquareRoot;
                break;
            case kParam_On:
                AUBase::FillInParameterName (outParameterInfo, kParameterOnName, false);
                outParameterInfo.unit = kAudioUnitParameterUnit_Boolean;
                outParameterInfo.minValue = 0.0;
                outParameterInfo.maxValue = 1;
                outParameterInfo.defaultValue = 1;
                break;				
            default:
                result = kAudioUnitErr_InvalidParameter;
                break;
            }
	} else {
        result = kAudioUnitErr_InvalidParameter;
    }
    
	return result;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bool				AUPinkNoise::StreamFormatWritable(	AudioUnitScope					scope,
																AudioUnitElement				element)
{
	return IsInitialized() ? false : true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

UInt32				AUPinkNoise::SupportedNumChannels (	const AUChannelInfo** 			outInfo)
{
	static const AUChannelInfo sChannels[1] = { {0, -1} };
	if (outInfo) *outInfo = sChannels;
	return sizeof (sChannels) / sizeof (AUChannelInfo);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

UInt32				AUPinkNoise::GetChannelLayoutTags(	AudioUnitScope				scope,
														AudioUnitElement 			element,
														AudioChannelLayoutTag *		outLayoutTags)
{
	if (scope != kAudioUnitScope_Output) COMPONENT_THROW(kAudioUnitErr_InvalidScope);
	if (element != 0) COMPONENT_THROW(kAudioUnitErr_InvalidElement);
	
	if (outLayoutTags)
	{
		UInt32 numChannels = GetOutput(element)->GetStreamFormat().NumberChannels();
		if(numChannels == 1)
			outLayoutTags[0] = kAudioChannelLayoutTag_Mono;
		else if(numChannels == 2)
			outLayoutTags[0] = kAudioChannelLayoutTag_Stereo;
		else if(numChannels == 4)
			outLayoutTags[0] = kAudioChannelLayoutTag_Quadraphonic;
		else if(numChannels == 5)
			outLayoutTags[0] = kAudioChannelLayoutTag_Pentagonal;
		else if(numChannels == 6)
			outLayoutTags[0] = kAudioChannelLayoutTag_Hexagonal;
		else if(numChannels == 8)
			outLayoutTags[0] = kAudioChannelLayoutTag_Octagonal;
		else
			COMPONENT_THROW(kAudioUnitErr_InvalidPropertyValue);
	}
	
	return 1;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
														
UInt32				AUPinkNoise::GetAudioChannelLayout(	AudioUnitScope				scope,
														AudioUnitElement 			element,
														AudioChannelLayout *		outLayoutPtr,
														Boolean &					outWritable)
{
	if (scope != kAudioUnitScope_Output) COMPONENT_THROW(kAudioUnitErr_InvalidScope);
	if (element != 0) COMPONENT_THROW(kAudioUnitErr_InvalidElement);		

	UInt32 size = mOutputChannelLayout.IsValid() ? mOutputChannelLayout.Size() : 0;
	if (size > 0 && outLayoutPtr)
		memcpy(outLayoutPtr, mOutputChannelLayout, size);
	outWritable = true;
	return size;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OSStatus			AUPinkNoise::SetAudioChannelLayout(	AudioUnitScope 				scope, 
														AudioUnitElement 			element,
														const AudioChannelLayout *	inLayout)
{
	if (scope != kAudioUnitScope_Output) return kAudioUnitErr_InvalidScope;
	if (element != 0) return kAudioUnitErr_InvalidElement;	

	UInt32 layoutChannels = inLayout ? CAAudioChannelLayout::NumberChannels(*inLayout) : 0;
	
	if (inLayout != NULL && GetOutput(element)->GetStreamFormat().NumberChannels() != layoutChannels)
		return kAudioUnitErr_InvalidPropertyValue;

	if (inLayout)
		mOutputChannelLayout = inLayout;
	else
		mOutputChannelLayout = CAAudioChannelLayout();
		
	return noErr;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OSStatus			AUPinkNoise::RemoveAudioChannelLayout(AudioUnitScope scope, AudioUnitElement element)
{
	if (scope != kAudioUnitScope_Output) return kAudioUnitErr_InvalidScope;
	if (element != 0) return kAudioUnitErr_InvalidElement;		
	mOutputChannelLayout = CAAudioChannelLayout();

	return noErr;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

OSStatus 	AUPinkNoise::Render(		AudioUnitRenderActionFlags &ioActionFlags,
												const AudioTimeStamp &		inTimeStamp,
												UInt32						nFrames)
{		
	AUOutputElement* outputBus = GetOutput(0);
	outputBus->PrepareBuffer(nFrames); // prepare the output buffer list
	
	AudioBufferList& outputBufList = outputBus->GetBufferList();
	AUBufferList::ZeroBuffer(outputBufList);	
	
	// only render if the on parameter is true. Otherwise send the zeroed buffer
	if (Globals()->GetParameter(kParam_On))
	{
		for (UInt32 i=0; i < outputBufList.mNumberBuffers; i++)
			mPink->Render((Float32*)outputBufList.mBuffers[i].mData, nFrames, Globals()->GetParameter(kParam_Volume));
	}	
	return noErr;
}

