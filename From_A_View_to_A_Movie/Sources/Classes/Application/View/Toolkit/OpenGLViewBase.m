/*
     File: OpenGLViewBase.m
 Abstract: 
 Animated OpenGL view with 3D object interaction.
 
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

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#import "OpenGLViewPixelFormat.h"
#import "OpenGLViewBase.h"

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Constants

//---------------------------------------------------------------------------------------

static const NSTimeInterval  kScheduledTimerInSeconds = 1.0f/30.0f;

static const unichar kESCKey = 27;

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------------------

@implementation OpenGLViewBase

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Post Notification

//---------------------------------------------------------------------------------------

- (void) postOpenGLViewBaseNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(viewBaseWillTerminate:)
												 name:@"NSApplicationWillTerminateNotification"
											   object:NSApp];
} // postOpenGLViewBaseNotification

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Other Initializations

//---------------------------------------------------------------------------------------
//
// Sync to VBL to avoid tearing.
//
//---------------------------------------------------------------------------------------

- (void) initOpenGLSyncToVBL
{
	GLint  swapInterval = 1;
	
	[mpContext setValues:&swapInterval
			forParameter:NSOpenGLCPSwapInterval];
} // initOpenGLSyncToVBL

//---------------------------------------------------------------------------------------

- (void) initOpenGLStates
{
	[mpContext makeCurrentContext];
	
	//-----------------------------------------------------------------
	//
	// For some OpenGL implementations, texture coordinates generated
	// during rasterization aren't perspective correct. However, you
	// can usually make them perspective correct by calling the API
	// glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST).  Colors
	// generated at the rasterization stage aren't perspective correct
	// in almost every OpenGL implementation, / and can't be made so.
	// For this reason, you're more likely to encounter this problem
	// with colors than texture coordinates.
	//
	//-----------------------------------------------------------------
	
	glHint(GL_PERSPECTIVE_CORRECTION_HINT,GL_NICEST);
	
	// Set up the projection
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	
	glFrustum(-0.3, 0.3, 0.0, 0.6, 1.0, 8.0);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	glTranslatef(0.0f, 0.0f, -2.0f);
	
	// Turn on depth test
	
    glEnable(GL_DEPTH_TEST);
	
	// front - or back - facing facets can be culled
	
    glEnable(GL_CULL_FACE);
} // initOpenGLStates

//---------------------------------------------------------------------------------------

- (void) initOpenGLContext
{
	mpContext = [self openGLContext];
	
	if( mpContext )
	{
		// Sync to VBL to avoid tearing
		
		[self initOpenGLSyncToVBL];
		
		// Initialize some miscellaneous OpenGL states
		
		[self initOpenGLStates];
	} // if
	else
	{
		NSLog( @">> ERROR: OpenGL View Base - Failed to initilize the OpenGL mpContext!" );
	} // else
} // initOpenGLContext

//---------------------------------------------------------------------------------------

- (void) initOpenGLAnimatedView:(const NSRect *)theFrame
{
	// Setting the view's frame size
	
	[self setFrameSize:theFrame->size];
	
	// Initialize the OpenGL mpContext
	
	[self initOpenGLContext];
	
	// Instantiate an animated (i.e., a 3D object + timer) object
	
	mpScene = [[OpenGLScene alloc] initWithOpenGLView:self
										 timeInterval:kScheduledTimerInSeconds];
	
	// Did the frame change?
	
	[self setPostsFrameChangedNotifications:YES];
} // initOpenGLAnimatedView

//---------------------------------------------------------------------------------------

- (void) initOpenGLFullScreen
{
	mpFullScreenOptions = [[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
													   forKey:NSFullScreenModeSetting] retain];
	
	mpFullScreen = [[NSScreen mainScreen] retain];
} // initOpenGLFullScreen

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated initializer

//---------------------------------------------------------------------------------------
//
// Create an OpenGL Context to use - i.e. init with frame the superclass
//
//---------------------------------------------------------------------------------------

- (id) initWithFrame:(NSRect)theFrame
		 pixelFormat:(NSOpenGLPixelFormat *)thePixelFormat
{
	if( thePixelFormat )
	{
		self = [super initWithFrame:theFrame
						pixelFormat:thePixelFormat];
	} // if
	else
	{
		NSOpenGLPixelFormat *pixelFormat = [[OpenGLViewPixelFormat withPixelAttributes:nil] pixelFormat];
		
		self = [super initWithFrame:theFrame
						pixelFormat:pixelFormat];
	} // else
	
	if( self )
	{
		[self initOpenGLAnimatedView:&theFrame];
		[self initOpenGLFullScreen];
		
		[self postOpenGLViewBaseNotification];
	} // if
	
	return( self );
} // initWithFrame

//---------------------------------------------------------------------------------------

- (id) initWithFrame:(NSRect)theFrame
{
	return [self initWithFrame:theFrame
				   pixelFormat:nil];
} // initWithFrame

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//---------------------------------------------------------------------------------------

- (void) cleanUpOpenGLViewBase
{
	// Release full screen resources
	
	if( mpFullScreenOptions )
	{
		[mpFullScreenOptions release];
		
		mpFullScreenOptions = nil;
	} // if
	
	if( mpFullScreen )
	{
		[mpFullScreen release];
		
		mpFullScreen = nil;
	} // if
	
	// We don't require an animated scene object
	
	if( mpScene )
	{
		[mpScene release];
		
		mpScene = nil;
	} // if
} // cleanUpOpenGLViewBase

//---------------------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpOpenGLViewBase];
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Animation Utilities

//---------------------------------------------------------------------------------------

- (BOOL) rotation
{
	return( [mpScene rotation] );
} // rotating

//---------------------------------------------------------------------------------------

- (void) rotationStop
{
	[mpScene stop];
} // rotationStop

//---------------------------------------------------------------------------------------

- (void) rotationStart
{
	[mpScene start];
} // rotationStart

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Context Utilities

//---------------------------------------------------------------------------------------

- (void) contextMakeCurrent
{
	// Get the current mpContext
	
	mpContext = [self openGLContext];
	
	// Make the OpenGL mpContext the current mpContext
	
	[mpContext makeCurrentContext];
} // contextMakeCurrent

//---------------------------------------------------------------------------------------

- (void) contextFlushBuffer
{
	[mpContext flushBuffer];
} // contextFlushBuffer

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark View Utilities

//---------------------------------------------------------------------------------------
//
// Handles resizing of OpenGL view; if the window dimensions change, window dimensions
// update, viewports reset, and projection matrix update.
//
//---------------------------------------------------------------------------------------

- (BOOL) viewUpdate
{
	m_Bounds = [self bounds];
	
	return( [mpScene updateView:&m_Bounds] );
} // viewUpdate

//---------------------------------------------------------------------------------------

- (NSRect) viewBounds
{
	return( m_Bounds );
} // viewBounds

//---------------------------------------------------------------------------------------
//
// Clear our drawable
//
//---------------------------------------------------------------------------------------

- (void) viewClear
{
	glClear( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT );
} // viewClear

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Full Screen Modes

//---------------------------------------------------------------------------------------

- (void) fullScreenEnable
{
	[self enterFullScreenMode:mpFullScreen
				  withOptions:mpFullScreenOptions];
} // enableFullScreen

//---------------------------------------------------------------------------------------

- (void) fullScreenDisable
{
	[self exitFullScreenModeWithOptions:mpFullScreenOptions];
} // disableFullScreen

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Delegates

//---------------------------------------------------------------------------------------

- (BOOL) acceptsFirstResponder
{
	return YES;
} // acceptsFirstResponder

//---------------------------------------------------------------------------------------

- (BOOL) becomeFirstResponder
{
	return  YES;
} // becomeFirstResponder

//---------------------------------------------------------------------------------------

- (BOOL) resignFirstResponder
{
	return YES;
} // resignFirstResponder

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Mouse Events

//---------------------------------------------------------------------------------------
//
// Trackball
//
//---------------------------------------------------------------------------------------

- (void) mouseDown:(NSEvent *)theEvent
{
	NSUInteger modifierFlags = [theEvent modifierFlags];
	
    if( modifierFlags & NSControlKeyMask )
	{
		// send to pan
		
		[self rightMouseDown:theEvent];
	} // if
	else if( modifierFlags & NSAlternateKeyMask )
	{
		// send to dolly
		
		[self otherMouseDown:theEvent];
	} // else if
	else
	{
		NSPoint location = [self convertPoint:[theEvent locationInWindow]
									 fromView:nil];
		
		[mpScene mouseIsDown:&location];
	} // else
} // mouseDown

//---------------------------------------------------------------------------------------
//
// Pan
//
//---------------------------------------------------------------------------------------

- (void) rightMouseDown:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow]
								 fromView:nil];
	
	[mpScene rightMouseIsDown:&location];
} // rightMouseDown

//---------------------------------------------------------------------------------------
//
// Dolly
//
//---------------------------------------------------------------------------------------

- (void) otherMouseDown:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow]
								 fromView:nil];
	
	[mpScene otherMouseIsDown:&location];
} // otherMouseDown

//---------------------------------------------------------------------------------------

- (void) mouseUp:(NSEvent *)theEvent
{
	[mpScene mouseIsUp];
} // mouseUp

//---------------------------------------------------------------------------------------

- (void) rightMouseUp:(NSEvent *)theEvent
{
	[self mouseUp:theEvent];
} // rightMouseUp

//---------------------------------------------------------------------------------------

- (void) otherMouseUp:(NSEvent *)theEvent
{
	[self mouseUp:theEvent];
} // otherMouseUp

//---------------------------------------------------------------------------------------

- (void) mouseDragged:(NSEvent *)theEvent
{
	NSPoint location = [self convertPoint:[theEvent locationInWindow]
								 fromView:nil];
	
	[mpScene mouseIsDragged:&location];
	
	[self setNeedsDisplay:YES];
} // mouseDragged

//---------------------------------------------------------------------------------------

- (void) scrollWheel:(NSEvent *)theEvent
{
	GLdouble wheelDelta = (GLdouble)([theEvent deltaX] + [theEvent deltaY] + [theEvent deltaZ]);
	
	if( [mpScene updateCameraAperture:wheelDelta] )
	{
		[self setNeedsDisplay:YES];
	} // if
} // scrollWheel

//---------------------------------------------------------------------------------------

- (void) rightMouseDragged:(NSEvent *)theEvent
{
	[self mouseDragged:theEvent];
} // rightMouseDragged

//---------------------------------------------------------------------------------------

- (void) otherMouseDragged:(NSEvent *)theEvent
{
	[self mouseDragged:theEvent];
} // otherMouseDragged

//---------------------------------------------------------------------------------------

- (void) keyDown:(NSEvent *)theEvent
{
    unichar keyPressed = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
	
    if( keyPressed == kESCKey )
	{
		if( [self isInFullScreenMode] )
		{
			[self fullScreenDisable];
		} // if
		else
		{
			[self fullScreenEnable];
		} // if
    } // if
} // keyDown

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Notification

//---------------------------------------------------------------------------------------
//
// It's important to clean up our rendering objects before we terminate -- Cocoa will
// not specifically release everything on application termination, so we explicitly
// call our clean up routine ourselves.
//
//---------------------------------------------------------------------------------------

- (void) viewBaseWillTerminate:(NSNotification *)notification
{
	[self cleanUpOpenGLViewBase];
} // viewBaseWillTerminate

//---------------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

