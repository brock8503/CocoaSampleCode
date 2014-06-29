/*
     File: Biquad.h
 Abstract: Biquad.h
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


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//	Biquad.h
//
//		A generic biquad (two zero - two pole) IIR filter:
//
//			lopass
//			hipass
//			parametric peaking
//			low shelving
//			high shelving
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#ifndef __Biquad
#define __Biquad

#include <math.h>
#include <stdio.h>

class Complex;


class Biquad
{
public:
	Biquad();
	
	void			Reset();
	
	static void		GetLopassParams(	float inFreq,
										float &a0,
										float &a1,
										float &a2,
										float &b1,
										float &b2  );

	// version which also has resonance parameter
	static void		GetLopassParams(	float inFreq,
		                                float inResonance,
										float &a0,
										float &a1,
										float &a2,
										float &b1,
										float &b2  );

	static void		GetHipassParams(	float inFreq,
										float &a0,
										float &a1,
										float &a2,
										float &b1,
										float &b2  );

	// version which also has resonance parameter
	static void 	GetHipassParams(	float inFreq,
		                                float inResonance,
										float &a0,
										float &a1,
										float &a2,
										float &b1,
										float &b2  );


	static void		GetLowShelfParams(	float inFreq,
										float inDbGain,			// +/- 40dB
										float &outA0,
										float &outA1,
										float &outA2,
										float &outB1,
										float &outB2);

	static void		GetHighShelfParams(	float inFreq,
										float inDbGain,			// +/- 40dB
										float &outA0,
										float &outA1,
										float &outA2,
										float &outB1,
										float &outB2);


	void			GetLopassParams(	float inFreq );
	void			GetLopassParams(	float inFreq, float inResonance );
	void			GetHipassParams(	float inFreq );
	void			GetHipassParams(	float inFreq, float inResonance );
	
	void			GetLowShelfParams(	float inFreq, float inDbGain );
	void			GetHighShelfParams(	float inFreq, float inDbGain );
	
	
	
	void			GetAllpassParams( const Complex	&inComplexPole );


	void 			GetNotchParams(	float inFreq,
                                	float inQ );
                                	

	static void		PolarToRect(	float	inTheta,
									float	inMag,
									float	&outX,
									float	&outY	);

	static void		ConjugateRootToQuadCoeffs(	float	inTheta,
												float	inMag,
												float	&out0,
												float	&out1,
												float	&out2	);
										
	static void		RealRootsToQuadCoeffs(	float	inRoot1,
											float	inRoot2,
											float	&out0,
											float	&out1,
											float	&out2	);

										
	void			SetZeroConjugateRoot(	float	inZeroTheta,
											float	inZeroMag  );
												
	void			SetPoleConjugateRoot(	float	inPoleTheta,
											float	inPoleMag );
												
	void			SetZeroConjugateRoot(	const Complex	&inComplexZero  );
												
	void			SetPoleConjugateRoot(	const Complex	&inComplexPole );



	void			SetZeroRealRoots(	float	inRoot1,
										float	inRoot2  );
										
	void			SetPoleRealRoots(	float	inRoot1,
										float	inRoot2  );

											
											
										
	void 			Process(	const float	*inSourceP,
								float	*inDestP,
								int		inFramesToProcess,
								int		inInputNumberOfChannels,
								int		inOutputNumberOfChannels
								);

	inline float Process1(	float	x)
	{
		float y = mA0*x + mA1*mX1 + mA2*mX2 - mB1*mY1 - mB2*mY2;

		mX2 = mX1;
		mX1 = x;
		mY2 = mY1;
		mY1 = y;
		
		return y;
	}


private:
	float	mA0;
	float	mA1;
	float	mA2;
	float	mB1;
	float	mB2;
	
	float	mX1;
	float	mX2;
	float	mY1;
	float	mY2;
};

const double kInv1200 = 1.0 / 1200.0;
const double kInv440 = 1.0 / 440.0;
const double kInvLog2 = 1.0 / log(2.0);

inline double	AbsoluteCentsToHertz(double inAbsCents) {return 440.0 * pow(2.0, (inAbsCents - 6900.0) * kInv1200 );};
inline double	HertzToAbsoluteCents(double inHertz) {return 1200.0 * kInvLog2 * log(inHertz * kInv440) + 6900.0;};
#define kMinAbsoluteCents	1200.0 /* 0 is approx 8.175799Hz :: 1200.0 is approx 16Hz */
#define kMaxAbsoluteCents	15023.0 /* approx 48000Hz */



#endif // __Biquad
