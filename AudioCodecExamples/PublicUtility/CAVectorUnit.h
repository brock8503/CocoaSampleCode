/*
     File: CAVectorUnit.h 
 Abstract:  Part of CoreAudio Utility Classes  
  Version: 1.0 
  
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
#ifndef __CAVectorUnit_h__
#define __CAVectorUnit_h__

#include <TargetConditionals.h>
#include "CAVectorUnitTypes.h"
#include <stdlib.h>
#include <stdio.h>

#if !defined(__COREAUDIO_USE_FLAT_INCLUDES__)
	#include <CoreFoundation/CFBase.h>
#else
	#include "CFBase.h"
#endif

// Unify checks for vector units.
// Allow setting an environment variable "CA_NoVector" to turn off vectorized code at runtime (very useful for performance testing).

extern int gCAVectorUnitType;

#ifdef __cplusplus
extern "C" {
#endif

extern SInt32 CAVectorUnit_Examine();	// expensive. use GetType() for lazy initialization and caching.

static inline SInt32 CAVectorUnit_GetType()
{
	int x = gCAVectorUnitType;
	return (x != kVecUninitialized) ? x : CAVectorUnit_Examine();
}

static inline Boolean CAVectorUnit_HasVectorUnit()
{
	return CAVectorUnit_GetType() > kVecNone;
}

#ifdef __cplusplus
}
#endif


#ifdef __cplusplus
class CAVectorUnit {
public:
	static SInt32		GetVectorUnitType() { return CAVectorUnit_GetType(); }
	static bool			HasVectorUnit() { return GetVectorUnitType() > kVecNone; }
	static bool			HasAltivec() { return GetVectorUnitType() == kVecAltivec; }
	static bool			HasSSE2() { return GetVectorUnitType() >= kVecSSE2; }
	static bool			HasSSE3() { return GetVectorUnitType() == kVecSSE3; }
	static bool			HasNeon() { return GetVectorUnitType() == kVecNeon; }
};
#endif

#endif // __CAVectorUnit_h__
