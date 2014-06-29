//---------------------------------------------------------------------------------------
//
//	File: OpenGLView.m
//
//  Abstract: OpenGL view class with text labels and added utility methods
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

#import "OpenGLView.h"

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

enum OpenGLViewFlags
{
	kOpenGLViewResized = 0,
	kOpenGLViewStopRotation,
	kOpenGLViewDisplayCounter,
	kOpenGLViewDisplayPrefTimer,
	kOpenGLViewDisplayRenderer,
	kOpenGLViewDisplayBounds
};

typedef enum OpenGLViewFlags OpenGLViewFlags;

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------------------

@implementation OpenGLView

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Post Notification

//---------------------------------------------------------------------------------------

- (void) postOpenGLViewNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(viewWillTerminate:)
												 name:@"NSApplicationWillTerminateNotification"
											   object:NSApp];
} // postOpenGLViewNotifications

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Labels Initialization

//---------------------------------------------------------------------------------------

- (void) initPrefTimerLabel:(const NSRect *)theBounds
				  textColor:(NSColor *)theTextColor
				   boxColor:(NSColor *)theBoxColor
				borderColor:(NSColor *)theBorderColor
{
	NSPoint prefTimerInfoCoordinates = NSMakePoint(10.0f, 32.0f);
	
	mpLabelPrefTimer = [[OpenGLPrefTimerLabel alloc] initLabelWithFormat:nil
																fontName:@"Helvetica"
																fontSize:20.0f
															   textColor:theTextColor
																boxColor:theBoxColor
															 borderColor:theBorderColor
															 coordinates:&prefTimerInfoCoordinates
																  bounds:theBounds];
} // initPrefTimerLabel

//---------------------------------------------------------------------------------------

- (void) initRendererLabel:(const NSRect *)theBounds
				 textColor:(NSColor *)theTextColor
				  boxColor:(NSColor *)theBoxColor
			   borderColor:(NSColor *)theBorderColor
{
	NSRect bounds = [self bounds];
	
	NSPoint infoCoordinates = NSMakePoint(10.0f, bounds.size.height - 52.0f);
	
	mpLabelRenderer = [[OpenGLRendererLabel alloc] initLabelWithFontName:@"Helvetica"
																fontSize:12.0
															   textColor:theTextColor
																boxColor:theBoxColor
															 borderColor:theBorderColor
															 coordinates:&infoCoordinates
																  bounds:theBounds];
} // initRendererLabel

//---------------------------------------------------------------------------------------

- (void) initViewBoundsLabel:(const NSRect *)theBounds
				   textColor:(NSColor *)theTextColor
					boxColor:(NSColor *)theBoxColor
				 borderColor:(NSColor *)theBorderColor
{
	NSPoint infoCoordinates = NSMakePoint(10.0f, 10.0f);
	
	mpLabelViewBounds = [[OpenGLViewBoundsLabel alloc] initLabelWithFormat:nil
																  fontName:@"Helvetica"
																  fontSize:12.0
																 textColor:theTextColor
																  boxColor:theBoxColor
															   borderColor:theBorderColor
															   coordinates:&infoCoordinates
																	bounds:theBounds];
} // initViewBoundsLabel

//---------------------------------------------------------------------------------------

- (void) initLabels:(const NSRect *)theBounds
{
	NSColor *textColor = [NSColor colorWithDeviceRed:1.0f
											   green:1.0f
												blue:1.0f
											   alpha:1.0f];
	
	NSColor *boxColor = [NSColor colorWithDeviceRed:0.5f
											  green:0.5f
											   blue:0.5f
											  alpha:0.5f];
	
	NSColor *borderColor = [NSColor colorWithDeviceRed:0.8f
												 green:0.8f
												  blue:0.8f
												 alpha:0.8f];
	
	[self initPrefTimerLabel:theBounds
				   textColor:textColor
					boxColor:boxColor
				 borderColor:borderColor];
	
	[self initRendererLabel:theBounds
				  textColor:textColor
				   boxColor:boxColor
				borderColor:borderColor];
	
	[self initViewBoundsLabel:theBounds
					textColor:textColor
					 boxColor:boxColor
				  borderColor:borderColor];
} // initLabels

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated initializer

//---------------------------------------------------------------------------------------
//
// Create an OpenGL Context to use - i.e. init the animated view superclass
//
//---------------------------------------------------------------------------------------

- (id) initWithFrame:(NSRect)theFrame
		 pixelFormat:(NSOpenGLPixelFormat *)thePixelFormat
{
	self = [super initWithFrame:theFrame
					pixelFormat:thePixelFormat];
	
	if( self )
	{
		// Instantiate label objects for displaying
		// performance timer and view bounds
		
		[self initLabels:&theFrame];
		
		mpSnapshot  = nil;
		mpDirectory = nil;
		
		m_ViewFlags[kOpenGLViewResized]          = NO;
		m_ViewFlags[kOpenGLViewStopRotation]     = NO;
		m_ViewFlags[kOpenGLViewDisplayPrefTimer] = YES;
		m_ViewFlags[kOpenGLViewDisplayRenderer]  = YES;
		m_ViewFlags[kOpenGLViewDisplayBounds]    = YES;
		
		[self postOpenGLViewNotifications];
	} // if
	
	return( self );
} // initWithFrame

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//---------------------------------------------------------------------------------------

- (void) releaseOpenGLViewSnapshot
{
	if( mpSnapshot )
	{
		[mpSnapshot release];
		
		mpSnapshot = nil;
	} // if
} // releaseOpenGLViewSnapshot

//---------------------------------------------------------------------------------------

- (void) releaseOpenGLPrefTimerLabel
{
	if( mpLabelPrefTimer )
	{
		[mpLabelPrefTimer release];
		
		mpLabelPrefTimer = nil;
	} // if
} // releaseOpenGLPrefTimerLabel

//---------------------------------------------------------------------------------------

- (void) releaseOpenGLRendererLabel
{
	if( mpLabelRenderer )
	{
		[mpLabelRenderer release];
		
		mpLabelRenderer = nil;
	} // if
} // releaseOpenGLRendererLabel

//---------------------------------------------------------------------------------------

- (void) releaseOpenGLViewBoundsLabel
{
	if( mpLabelViewBounds )
	{
		[mpLabelViewBounds release];
		
		mpLabelViewBounds = nil;
	} // if
} // releaseOpenGLViewBoundsLabel

//---------------------------------------------------------------------------------------

- (void) releaseMovieDirectoryPathname
{
	if( mpDirectory )
	{
		[mpDirectory release];
		
		mpDirectory = nil;
	} // if
} // releaseMovieDirectoryPathname

//---------------------------------------------------------------------------------------

- (void) cleanUpOpenGLView
{
	// Release the renderer's label
	
	[self releaseOpenGLRendererLabel];
	
	// Release the view bounds' label
	
	[self releaseOpenGLViewBoundsLabel];
	
	// Release perf timer's label
	
	[self releaseOpenGLPrefTimerLabel];
	
	// Release the view snapshot object
	
	[self releaseOpenGLViewSnapshot];
	
	// Release the directory pathname string
	
	[self releaseMovieDirectoryPathname];
} // cleanUpOpenGLView

//---------------------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpOpenGLView];
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessor

//---------------------------------------------------------------------------------------

- (BOOL) viewResized
{
	return( m_ViewFlags[kOpenGLViewResized] );
} // viewResized

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Capturing from a View

//---------------------------------------------------------------------------------------

- (void) viewSnapshot:(NSString *)theDocPath
				 type:(NSNumber *)theDocFormat
		  compression:(NSNumber *)theDocCompression
				title:(NSString *)theDocTitle
			   author:(NSString *)theDocAuthor
			  subject:(NSString *)theDocSubject
			  creator:(NSString *)theDocCreator
{
	if( mpSnapshot == nil )
	{
		NSRect frame = [self bounds];
		
		mpSnapshot = [[OpenGLViewSnapshot alloc] initViewSnapshotWithFrame:&frame
                                                                      view:self];
	} // if
	
	[mpSnapshot setDocumentTitle:theDocTitle];
	[mpSnapshot setDocumentAuthor:theDocAuthor];
	[mpSnapshot setDocumentSubject:theDocSubject];
	[mpSnapshot setDocumentCreator:theDocCreator];
	
	if( theDocFormat )
	{
		[mpSnapshot setFormat:[theDocFormat unsignedIntValue]];
	} // if
	
	if( theDocCompression )
	{
		[mpSnapshot setCompression:[theDocCompression floatValue]];
	} // if
	
	[mpSnapshot saveAs:theDocPath];
} // viewSnapshot

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Showing/Hiding Labels

//---------------------------------------------------------------------------------------

- (void) prefTimerDisplayLabel:(const BOOL)theDisplayFlag
{
	m_ViewFlags[kOpenGLViewDisplayPrefTimer] = theDisplayFlag;
} // prefTimerLabelSetDisplay

//---------------------------------------------------------------------------------------

- (void) rendererDisplayLabel:(const BOOL)theDisplayFlag
{
	m_ViewFlags[kOpenGLViewDisplayRenderer] = theDisplayFlag;
} // rendererLabelSetDisplay

//---------------------------------------------------------------------------------------

- (void) viewBoundsDisplayLabel:(const BOOL)theDisplayFlag
{
	m_ViewFlags[kOpenGLViewDisplayBounds] = theDisplayFlag;
} // viewBoundsSetDisplay

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Preformance Timer Utilities

//---------------------------------------------------------------------------------------

- (void) prefTimerEnable
{
	[mpLabelPrefTimer labelSetNeedsDisplay:YES];
} // prefTimerEnable

//---------------------------------------------------------------------------------------

- (void) prefTimerDisable
{
	[mpLabelPrefTimer labelSetNeedsDisplay:NO];
} // prefTimerDisable

//---------------------------------------------------------------------------------------

- (void) prefTimerMoveTo:(const NSPoint *)thePoint
{
	[mpLabelPrefTimer moveTo:thePoint];
} // prefTimerMoveTo

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark View Updates

//---------------------------------------------------------------------------------------
//
// Handles resizing of OpenGL view, if the window dimensions change, window dimensions
// update, viewports reset, and projection matrix update.
//
//---------------------------------------------------------------------------------------

- (void) viewResize
{
	m_ViewFlags[kOpenGLViewResized] = [self viewUpdate];
	
	if( m_ViewFlags[kOpenGLViewResized] )
	{
		// OpenGL text objects needs to know the view bounds
		// have changed as well.
		
		NSRect viewBounds = [self viewBounds];
		
		// Get a new backing store for our view's snapshot
		
		[mpSnapshot setFrame:&viewBounds];
		
		// Notify all labels that their bounds have changed
		
		[mpLabelViewBounds viewSetBounds:&viewBounds];
		[mpLabelRenderer   viewSetBounds:&viewBounds];
		[mpLabelPrefTimer  viewSetBounds:&viewBounds];
	} // if
} // viewResize

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Draw Utilities

//---------------------------------------------------------------------------------------

- (void) drawBegin
{
	// Make the OpenGL context the current context
	
	[self contextMakeCurrent];
	
	// Forces projection matrix update (does test for size changes)
	
	[self viewResize];
	
	// Clear our drawable
	
	[self viewClear];
} // drawBegin

//---------------------------------------------------------------------------------------
//
// Display the view bounds label
//
//---------------------------------------------------------------------------------------

- (void) drawViewBoundsLabel
{
	if( m_ViewFlags[kOpenGLViewDisplayBounds] )
	{
		[mpLabelViewBounds labelDraw];
	} // if
} // drawViewBoundsLabel

//---------------------------------------------------------------------------------------
//
// Display the pref timer label
//
//---------------------------------------------------------------------------------------

- (void) drawPrefTimerLabel
{
	if( m_ViewFlags[kOpenGLViewDisplayPrefTimer] )
	{
		[mpLabelPrefTimer labelSetNeedsUpdate:[self rotation]];
		[mpLabelPrefTimer labelDraw];
	} // if
} // drawPrefTimerLabel

//---------------------------------------------------------------------------------------
//
// Display the renderer label
//
//---------------------------------------------------------------------------------------

- (void) drawRendererLabel
{
	if( m_ViewFlags[kOpenGLViewDisplayRenderer] )
	{
		[mpLabelRenderer labelDraw];
	} // if
} // drawRendererLabel

//---------------------------------------------------------------------------------------

- (void) drawEnd
{
	// Take a snapshot of the view
	
	[mpSnapshot snapshot];
	
	// Draw the view bounds
	
	[self drawViewBoundsLabel];
	
	// Draw the pref timer
	
	[self drawPrefTimerLabel];
	
	// Draw the renderer's info
	
	[self drawRendererLabel];
	
	// Flush the current context
	
	[self contextFlushBuffer];
} // drawEnd

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

- (void) viewWillTerminate:(NSNotification *)notification
{
	[self cleanUpOpenGLView];
} // viewWillTerminate

//---------------------------------------------------------------------------------------
//
// When flushing media author queue one needs to stop object rotation.
//
//---------------------------------------------------------------------------------------

- (void) suspendObjectRotation:(NSNotification *)notification
{
	if( !m_ViewFlags[kOpenGLViewStopRotation] )
	{
		[self rotationStop];
		
		m_ViewFlags[kOpenGLViewStopRotation] = YES;
	} // if
} // suspendObjectRotation

//---------------------------------------------------------------------------------------
//
// When media sample authoring is restarted, one needs to restart object rotation.
//
//---------------------------------------------------------------------------------------

- (void) resumeObjectRotation:(NSNotification *)notification
{
	if( m_ViewFlags[kOpenGLViewStopRotation] )
	{
        [self rotationStart];
		
		m_ViewFlags[kOpenGLViewStopRotation] = NO;
	} // if
} // resumeObjectRotation

//---------------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

