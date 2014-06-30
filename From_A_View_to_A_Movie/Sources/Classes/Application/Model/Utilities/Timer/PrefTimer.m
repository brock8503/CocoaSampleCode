/*
     File: PrefTimer.m
 Abstract: 
 Simple MACH-based performance timer utility toolkit.
 
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

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import <mach/mach.h>
#import <mach/mach_time.h>
#import <unistd.h>

//---------------------------------------------------------------------------

#import "PrefTimer.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

static const double kPrefTimerMachScaleFactor  = 0.000000001;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

struct PrefTimerData
{
	double  mnTimeBase;
	double  mnMarkTime;
	double  mnFPS;
	long    mnCounter;
};

typedef struct PrefTimerData  PrefTimerData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation PrefTimer

//---------------------------------------------------------------------------

- (void) initTimeBaseInfo
{
	kern_return_t err = KERN_SUCCESS;
	
	mach_timebase_info_data_t  timebaseInfo;
	
	timebaseInfo.numer = 0;
	timebaseInfo.denom = 0;
	
	err = mach_timebase_info(&timebaseInfo);
	
	// Check errors
	
	check(err == KERN_SUCCESS);
	
	if( err != KERN_SUCCESS )
	{
		NSLog( @">> ERROR[%d]: Pref Timer - Getting mach timebase info!", err );
	} // if
	else
	{
		double numer = (double)timebaseInfo.numer;
		double denom = (double)timebaseInfo.denom;
		
		mpPrefTimer->mnTimeBase = kPrefTimerMachScaleFactor * ( numer / denom );
	} // else
} // initTimeBaseInfo

//---------------------------------------------------------------------------

- (id) init
{
	self = [super init];
	
	if( self )
	{
		mpPrefTimer = (PrefTimerDataRef)calloc(1, sizeof(PrefTimerData));
		
		if( mpPrefTimer != NULL )
		{
			[self initTimeBaseInfo];
		} // if
		else
		{
			NSLog( @">> ERROR: Pref Timer - Failure Allocating Memory For Attributes!" );
		}  // else
	} // if
	
	return( self );
} // init

//---------------------------------------------------------------------------

+ (id) prefTimer
{
	return( [[[PrefTimer allocWithZone:[self zone]] init] autorelease] );
} // prefTimer

//---------------------------------------------------------------------------

- (void) dealloc
{
	if( mpPrefTimer != NULL )
	{
		free( mpPrefTimer );
		
		mpPrefTimer = NULL;
	} // if
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

- (double) machAbsoluteTime
{
	// Get Mach absolute time.
	
	double machTime = (double)mach_absolute_time();
	
	// Convert to seconds.
	
	double machTimeSec = mpPrefTimer->mnTimeBase * machTime;
	
	return( machTimeSec );
} // machAbsoluteTime

//---------------------------------------------------------------------------

- (double) perfTick
{
	double deltaTime   = 0.0;
	double currentTime = 0.0;
	
	mpPrefTimer->mnCounter++;
	
	currentTime = [self machAbsoluteTime];
	deltaTime   = currentTime - mpPrefTimer->mnMarkTime;
	
	if( deltaTime > 1.0 )
	{
		mpPrefTimer->mnFPS      = mpPrefTimer->mnCounter / deltaTime;
		mpPrefTimer->mnMarkTime = [self machAbsoluteTime];
		mpPrefTimer->mnCounter  = 0;
	} // if
	
	return( mpPrefTimer->mnFPS );
} // perfTick

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

