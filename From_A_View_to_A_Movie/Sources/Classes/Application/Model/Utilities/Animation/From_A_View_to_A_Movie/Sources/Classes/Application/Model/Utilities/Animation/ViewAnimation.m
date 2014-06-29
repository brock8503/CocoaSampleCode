/*
     File: ViewAnimation.m
 Abstract: 
 Utility class to animate views and windows.
 
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

#import "ViewAnimation.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation ViewAnimation

//---------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return( nil );
} // init

//---------------------------------------------------------------------------

- (id) initViewAnimation:(id)theAnimationObject
				  effect:(NSString *)theAnimationEffect
				duration:(const NSTimeInterval)theAnimationDuration
				   curve:(const NSAnimationCurve)theAnimationCurve
					mode:(const NSAnimationBlockingMode)theAnimationMode
{
	self = [super init];
	
	if( self )
	{
		// Create the attributes dictionary for the object we wish to animate.
		
		mpDictionary = [NSMutableDictionary new];
		
		if( mpDictionary )
		{
			// Set the target object
			
			[mpDictionary setObject:theAnimationObject
							 forKey:NSViewAnimationTargetKey];
			
			// We wish to animate an object with a frame
			
			NSRect viewSize = [theAnimationObject frame];
			
			[mpDictionary setObject:[NSValue valueWithRect:viewSize]
							 forKey:NSViewAnimationEndFrameKey];
			
			// Set this object to use the effect
			
			[mpDictionary setObject:theAnimationEffect
							 forKey:NSViewAnimationEffectKey];
			
			// Create the view animation object.
			
			mpAnimation = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObjects:mpDictionary, nil]];
			
			if( mpAnimation )
			{
				// Set some additional attributes for the animation.
				
				[mpAnimation setAnimationBlockingMode:theAnimationMode];
				[mpAnimation setDuration:theAnimationDuration];
				[mpAnimation setAnimationCurve:theAnimationCurve];
			} // if
		} // if
	} // if
	
	return( self );
} // initViewAnimation

//---------------------------------------------------------------------------

- (void) cleanUpViewAnimation
{
	if( mpDictionary )
	{
		[mpDictionary release];
		
		mpDictionary = nil;
	} // if
	
	if( mpAnimation )
	{
		[mpAnimation release];
		
		mpAnimation = nil;
	} // if
} // cleanUpViewAnimation

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpViewAnimation];
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

- (void) start
{
	[mpAnimation startAnimation];
} // start

//---------------------------------------------------------------------------

- (void) stop
{
	[mpAnimation stopAnimation];
} // stop

//---------------------------------------------------------------------------

- (BOOL) isStarted
{
	return( [mpAnimation isAnimating] );
} // isStarted

//---------------------------------------------------------------------------

- (BOOL) isStopped
{
	return( ![mpAnimation isAnimating] );
} // isStopped

//---------------------------------------------------------------------------

- (void) setDuration:(const NSTimeInterval)theAnimationDuration
{
	[mpAnimation setDuration:theAnimationDuration];
} // setDuration

//---------------------------------------------------------------------------

- (void) setCurve:(const NSAnimationCurve)theAnimationCurve
{
	[mpAnimation setAnimationCurve:theAnimationCurve];
} // setCurve

//---------------------------------------------------------------------------

- (void) setBlockingMode:(const NSAnimationBlockingMode)theAnimationMode
{
	[mpAnimation setAnimationBlockingMode:theAnimationMode];
} // setBlockingMode

//---------------------------------------------------------------------------

- (void) setEffect:(NSString *)theAnimationEffect
{
	[mpDictionary setObject:theAnimationEffect
					 forKey:NSViewAnimationEffectKey];
	
	[mpAnimation setViewAnimations:[NSArray arrayWithObjects:mpDictionary, nil]];
} // setEffect

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

