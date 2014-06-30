/*
     File: Pink.h
 Abstract: Pink.h
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

class PinkFilter
{
public:
	PinkFilter() {Reset();};

	void			Reset() {buf0=buf1=buf2=buf3=buf4=buf5=buf6=0.0;};

	void 			Process(	const float	*inSourceP,
								float	*inDestP,
								int		inFramesToProcess,
								int		inInputHop,
								int		inOutputHop
								)
	{
		register int n = inFramesToProcess;
		register const float *sourceP = inSourceP;
		register float *destP = inDestP;
		
		register int inputHop = inInputHop;
		register int outputHop = inOutputHop;
		
		while(n--)
		{
			float white= *sourceP;
			sourceP += inputHop;
			
			// pink noise algorithim courtesy of 
			// http://www.firstpr.com.au/dsp/pink-noise/
			buf0= 0.99886 * buf0 + 0.0555179 * white;
			buf1= 0.99332 * buf1 + 0.0750759 * white;
			buf2= 0.96900 * buf2 + 0.1538520 * white;
			buf3= 0.86650 * buf3 + 0.3104856 * white;
			buf4= 0.55000 * buf4 + 0.5329522 * white;
			buf5= -0.7616 * buf5 + 0.0168980 * white;
			float pink=buf0 + buf1 + buf2 + buf3 + buf4  
				+ buf5 + buf6 + white * .5362;
			buf6= 0.115926 * white;
			
			*destP = pink;
			destP += outputHop;
		}
	};



private:
	float			buf0;
	float			buf1;
	float			buf2;
	float			buf3;
	float			buf4;
	float			buf5;
	float			buf6;
};


/*
Pink filter:
	white=(whichever method you choose);
	buf0=0.997 * buf0 + 0.029591 * white;
	buf1=0.985 * buf1 + 0.032534 * white;
	buf2=0.950 * buf2 + 0.048056 * white;
	buf3=0.850 * buf3 + 0.090579 * white;
	
	buf4=0.620 * buf4 + 0.108990 * white;
	buf5=0.250 * buf5 + 0.255784 * white;
	pink=buf0 + buf1 + buf2 + buf3 + buf4  
		+ buf5;
*/

#include "TRandom.h"
#include "Biquad.h"

class PinkNoiseGenerator
{
public:
	PinkNoiseGenerator(Float32 inSampleRate )
	{
		nyquist = 0.5 * inSampleRate;
		rumbleFilter.GetHipassParams(10.0/*Hertz*/ / nyquist, 0.0 );
	}
	
	void Render(Float32 *inBuffer, UInt32 inNumFrames, Float32 inVolume )
	{
		const Float32 kInv32768 = (1.0 / 32768.0) * 0.5;
		
		Float32 *destP = inBuffer;
		int n = inNumFrames;
		
		while(n--)
		{
			SInt32 r = SInt32(GetRandomLong(65536) ) - 32768;
			Float32 sample = r * kInv32768 * inVolume;
			
			*destP++ = sample;
		}
	
		
		// filter "backwards" since kernel is in reverse order
		filter.Process(	inBuffer,
						inBuffer,
						inNumFrames,
						1,
						1
						);
	
	
		// Hipass rumble filter to remove potential skanky DC offset
		rumbleFilter.Process(	inBuffer,
								inBuffer,
								inNumFrames,
								1,
								1
								);
	}


private:
	float			nyquist;
	Biquad 			rumbleFilter;
	PinkFilter 		filter;
};
