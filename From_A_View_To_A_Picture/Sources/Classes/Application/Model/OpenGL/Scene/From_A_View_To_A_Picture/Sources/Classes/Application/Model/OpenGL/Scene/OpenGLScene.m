//---------------------------------------------------------------------------------------
//
//	File: OpenGLAnimation.m
//
//  Abstract: Animated OpenGL scene utility kit
//
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Inc. ("Apple") in consideration of your agreement to the following terms,
//  and your use, installation, modification or redistribution of this Apple
//  software constitutes acceptance of these terms.  If you do not agree with
//  these terms, please do not use, install, modify or redistribute this
//  Apple software.
//
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software.
//  Neither the name, trademarks, service marks or logos of Apple Inc. may
//  be used to endorse or promote products derived from the Apple Software
//  without specific prior written permission from Apple.  Except as
//  expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  Copyright (c) 2008-2009, 2012 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#import "OpenGLScene.h"

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------------------

@implementation OpenGLScene

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialize Timer

//---------------------------------------------------------------------------------------
//
// Update the scene animation
//
//---------------------------------------------------------------------------------------

- (void) sceneUpdate
{
	// Change the state of the scene by updating the
	// object's rotation state
	
	[self updateRotation:mnReferenceTime];
	
	//	Reset time in all cases
	
	mnReferenceTime = CFAbsoluteTimeGetCurrent();
	
	// Draw the contents of the mpView
	
	[mpView drawRect:[mpView bounds]];
} // sceneUpdate

//---------------------------------------------------------------------------------------

- (void) initSceneTimer:(const NSTimeInterval)theTimeInterval
{
	mpTimer = [NSTimer timerWithTimeInterval:theTimeInterval
									  target:self
									selector:@selector(sceneUpdate)
									userInfo:nil
									 repeats:YES];
	
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	
	if( runLoop )
	{
		[runLoop addTimer:mpTimer
				  forMode:NSDefaultRunLoopMode];
		
		// Ensure mpTimer fires during resize
		
		[runLoop addTimer:mpTimer
				  forMode:NSEventTrackingRunLoopMode];
	} // if
} // initSceneTimer

//---------------------------------------------------------------------------------------

- (void) initOpenGLScene:(const NSTimeInterval)theTimeInterval
{
	// Initialize last frame's reference time
	
	mnReferenceTime = CFAbsoluteTimeGetCurrent();
	mnTimeInterval  = theTimeInterval;
	
	// New mpTimer for updating (animating) a 3D object
	
	[self initSceneTimer:theTimeInterval];
} // initOpenGLScene

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated initializer

//---------------------------------------------------------------------------------------

- (id) initWithOpenGLView:(NSOpenGLView *)theView
			 timeInterval:(const NSTimeInterval)theTimeInterval
{
	self = [super init];
	
	if( self )
	{
		mpView = theView;
		
		[self initOpenGLScene:theTimeInterval];
	} // if
	
	return self;
} // initWithOpenGLView

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//---------------------------------------------------------------------------------------

- (void) cleanUpTimer
{
	if( mpTimer )
	{
		[mpTimer invalidate];
		[mpTimer release];
		
		mpTimer = nil;
	} // if
} // cleanUpTimer

//---------------------------------------------------------------------------------------

- (void) dealloc
{
	// Release the update (animation) mpTimer
	
	[self cleanUpTimer];
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Animation States

//---------------------------------------------------------------------------------------

- (void) setTimeInterval:(const NSTimeInterval)theTimeInterval
{
	mnTimeInterval = theTimeInterval;
} // setTimeInterval

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Rotation States

//---------------------------------------------------------------------------------------

- (void) start
{
	[self setRotation:YES];
} // start

//---------------------------------------------------------------------------------------

- (void) stop
{
	[self setRotation:NO];
} // stop

//---------------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

