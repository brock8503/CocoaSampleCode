/*
     File: QTCVOpenGLView.m
 Abstract: 
 QT Core Video rendering class.
 
  Version: 2.0
 
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

#pragma mark -
#pragma mark Private - Headers

#import "QTVisualContext.h"
#import "QTCVOpenGLView.h"

#pragma mark -
#pragma mark Private - Data Structures

struct CVOpenGLViewPlayback
{
	NSSize              m_Size;             // Frame size
	CFAllocatorRef      mpAllocator;		// CF allocator used throughout
	CGDirectDisplayID   mnDisplayId;		// Display used by CoreVideo
    CVDisplayLinkRef    mpDisplayLink;      // Display link maintained by CV
	CVOptionFlags       mnLockFlags;		// Flags used for locking the base address
	CVImageBufferRef    mpVideoFrame;		// The current frame from CV
};

typedef struct CVOpenGLViewPlayback   CVOpenGLViewPlayback;

struct QTCVOpenGLViewData
{
    BOOL                   mbDisplay;
	CVOpenGLViewPlayback   m_Playback;
    QTVisualContext       *mpVisualContext;
    QTCVOpenGLView        *mpSelf;
    CGLContextObj          mpContextObj;
    NSOpenGLContext       *mpContext;
    QTMovie               *mpMovie;
};

typedef struct QTCVOpenGLViewData   QTQTCVOpenGLViewData;

#pragma mark -
#pragma mark Private - Utilties - Constructors

// Constructor for CoreVideo OpenGL view
static QTCVOpenGLViewDataRef CVOpenGLViewCreate(QTCVOpenGLView *pBase)
{
    QTCVOpenGLViewDataRef pView = (QTCVOpenGLViewDataRef)calloc(1, sizeof(QTQTCVOpenGLViewData));
    
    if(pView != NULL)
    {
        pView->mpSelf = pBase;
        
        pView->m_Playback.m_Size.width  = 1920.0f;
        pView->m_Playback.m_Size.height = 1080.0f;
        pView->m_Playback.mpAllocator   = kCFAllocatorDefault;
        pView->m_Playback.mnDisplayId   = kCGDirectMainDisplay;
    } // if
    else
    {
        NSLog(@">> [QTCoreVideo OpenGL View] ERROR: Failure Allocating Memory For View Attributes!");
    } // else
    
    return pView;
} // CVOpenGLViewCreate

#pragma mark -
#pragma mark Private - Utilties - Destructors

// Stop and release the mpMovie
static inline void CVOpenGLViewDeleteMovie(QTCVOpenGLViewDataRef pView)
{
    if(pView->mpMovie)
	{
    	[pView->mpMovie setRate:0.0];
		
        SetMovieVisualContext([pView->mpMovie quickTimeMovie], NULL);
		
        [pView->mpMovie release];
		
        pView->mpMovie = nil;
    } // if
} // CVOpenGLViewDeleteMovie

// It is critical to dispose of the display link
static inline void CVOpenGLViewDeleteDisplayLink(QTCVOpenGLViewDataRef pView)
{
    if(pView->m_Playback.mpDisplayLink)
	{
    	CVDisplayLinkStop(pView->m_Playback.mpDisplayLink);
        CVDisplayLinkRelease(pView->m_Playback.mpDisplayLink);
		
        pView->m_Playback.mpDisplayLink = NULL;
    } // if
} // CVOpenGLViewDeleteDisplayLink

static inline void CVOpenGLViewDeleteTexture(QTCVOpenGLViewDataRef pView)
{
	if(pView->m_Playback.mpVideoFrame != NULL)
	{
        CVOpenGLTextureRelease(pView->m_Playback.mpVideoFrame);
        
        pView->m_Playback.mpVideoFrame = NULL;
	} // if
} // CVOpenGLViewDeleteTexture

// Don't leak Core Video OpenGL textures
static inline void CVOpenGLViewDeleteTextureBlocking(QTCVOpenGLViewDataRef pView)
{
    CGLContextObj pContextObj = (CGLContextObj)[[pView->mpSelf openGLContext] CGLContextObj];
    
    if(pContextObj != NULL)
    {
        CGLLockContext(pContextObj);
        {
            CVOpenGLViewDeleteTexture(pView);
        }
        CGLUnlockContext(pContextObj);
    } // if
} // CVOpenGLViewDeleteTextureBlocking

// Release the pixel image context
static inline void CVOpenGLViewDeleteContext(QTCVOpenGLViewDataRef pView)
{
	if(pView->mpVisualContext)
	{
		[pView->mpVisualContext release];
		
		pView->mpVisualContext = nil;
	} // if
} // CVOpenGLViewDeleteContext

// Delete the object
static void CVOpenGLViewDelete(QTCVOpenGLViewDataRef pView)
{
    if(pView != NULL)
    {
        CVOpenGLViewDeleteTextureBlocking(pView);
        
        CVOpenGLViewDeleteDisplayLink(pView);
        CVOpenGLViewDeleteContext(pView);
        CVOpenGLViewDeleteMovie(pView);
        
        free(pView);
        
        pView = NULL;
    } // if
} // CVOpenGLViewDelete

#pragma mark -
#pragma mark Private - Utilties - Draw

static CVReturn CVOpenGLViewDisplayBegin(QTCVOpenGLViewDataRef pView)
{
    // Current OpenGL context
    pView->mpContext = [pView->mpSelf openGLContext];
    
    if(pView->mpContext != NULL)
    {
        // Get the current CGL context
        pView->mpContextObj = (CGLContextObj)[pView->mpContext CGLContextObj];
        
        if(pView->mpContextObj != NULL)
        {
            // Make the GL context the current context
            CGLSetCurrentContext(pView->mpContextObj);
            
            // Lock the CGL context
            CGLError nError = CGLLockContext(pView->mpContextObj);
            
            // Update view transformations, but don't block
            [pView->mpSelf transform:NO];
            
            // Clear color, stencil, and depth buffers
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
            
            // Return the result
            pView->mbDisplay = nError == kCGLNoError;
        } // if
    } // if
    
    return  pView->mbDisplay ? kCVReturnSuccess : kCVReturnInvalidDisplay;
} // CVOpenGLViewDisplayBegin

static void CVOpenGLViewDisplayEnd(QTCVOpenGLViewDataRef pView)
{
    if(pView->mbDisplay)
    {
        // Give time to the Visual Context so it can release internally held
        // resources for later re-use this function should be called in every
        // rendering pass, after old images have been released, new images
        // have been used and all rendering has been flushed to the screen.
        [pView->mpVisualContext task];
        
        // For double-buffering, perform a flush
        CGLFlushDrawable(pView->mpContextObj);
        
        // Unlock the CG context
        CGLUnlockContext(pView->mpContextObj);
        
        // Reset the display flag
        pView->mbDisplay = NO;
    } // if
} // CVOpenGLViewDisplayEnd

#pragma mark -
#pragma mark Private - Callbacks - Render

static inline BOOL CVOpenGLViewIsValidVisualContext(const CVTimeStamp  *pTimeStampOut,
                                                    QTCVOpenGLViewDataRef pView)
{
    return ([pView->mpVisualContext isValid] && [pView->mpVisualContext isImageAvailable:pTimeStampOut]);
} // CVOpenGLViewIsValidVisualContext

static inline BOOL CVOpenGLViewCopyImageForTime(const CVTimeStamp  *pTimeStampOut,
                                                QTCVOpenGLViewDataRef pView)
{
    // Delete the old video frame
    CVOpenGLViewDeleteTexture(pView);
    
    // Get an image frame from the Visual Context, indexed by the provided time
    // Make the GL context the current context
    pView->m_Playback.mpVideoFrame = [pView->mpVisualContext copyImageForTime:pTimeStampOut];
    
    return pView->m_Playback.mpVideoFrame != NULL;
} // CVOpenGLViewCopyImageForTime

// This is the CoreVideo DisplayLink callback notifying the application when
// the display will need each m_Size and is called when the DisplayLink is
// running -- in response, we call our getFrameForTime method.
static CVReturn CVOpenGLViewGetFrameForTime(CVDisplayLinkRef    pDisplayLink,
                                            const CVTimeStamp  *pTimeStampNow,
                                            const CVTimeStamp  *pTimeStampOut,
                                            CVOptionFlags       nFlagsIn,
                                            CVOptionFlags      *pFlagsOut,
                                            void               *pDisplayLinkCtx)
{
    CVReturn nResult = kCVReturnError;
    
    QTCVOpenGLViewDataRef pView = pDisplayLinkCtx;
    
    if(pView != NULL)
    {
        // There is no autorelease pool when this method is called because it will
        // be called from another thread it's important to create one or you will
        // leak objects
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        
        if(pool)
        {
            // Do we have a valid visual context?
            BOOL bSuccess = CVOpenGLViewIsValidVisualContext(pTimeStampOut, pView);
            
            // Check for new frame
            if(bSuccess)
            {
                // Get an image frame from the Visual Context
                bSuccess = CVOpenGLViewCopyImageForTime(pTimeStampOut, pView);
                
                if(bSuccess)
                {
                    // Display video frame
                    nResult = CVOpenGLViewDisplayBegin(pView);
                    
                    if(nResult == kCVReturnSuccess)
                    {
                        [pView->mpSelf display];
                    } // if
                    
                    // Flush buffer and end display
                    CVOpenGLViewDisplayEnd(pView);
                } // if
                else
                {
                    NSLog(@">> WARNING: QT Visual Context Copy Image for Time Error!");
                } // else
            } // if
            
            [pool release];
        } // if
    } // if
	
	return nResult;
} // CVOpenGLViewGetFrameForTime

#pragma mark -
#pragma mark Private - Utilities - Acquire

static BOOL CVOpenGLViewAcquireDisplayLink(QTCVOpenGLViewDataRef pView)
{
	CVOpenGLViewDeleteDisplayLink(pView);
	
    // Create display link for the main display
    CVDisplayLinkCreateWithCGDisplay(pView->m_Playback.mnDisplayId,
                                     &pView->m_Playback.mpDisplayLink);
	
    BOOL bSuccess = pView->m_Playback.mpDisplayLink != NULL;
    
    if(bSuccess)
	{
    	// Set the current display of a display link.
    	CVDisplayLinkSetCurrentCGDisplay(pView->m_Playback.mpDisplayLink,
                                         pView->m_Playback.mnDisplayId);
        
        // Set the renderer output callback function
    	CVDisplayLinkSetOutputCallback(pView->m_Playback.mpDisplayLink,
                                       &CVOpenGLViewGetFrameForTime,
                                       pView);
        
        // Activates a display link
    	CVDisplayLinkStart(pView->m_Playback.mpDisplayLink);
    } // if
    
    return bSuccess;
} // CVOpenGLViewAcquireDisplayLink

static BOOL CVOpenGLViewAcquireVisualContext(QTCVOpenGLViewDataRef pView)
{
	// Delete the old qt visual context
	CVOpenGLViewDeleteContext(pView);
	
	// Instantiate a new qt visual context object
	pView->mpVisualContext = [[QTVisualContext alloc] initVisualContextWithSize:&pView->m_Playback.m_Size
                                                                           type:kQTVisualContextOpenGLTexture
                                                                        context:[pView->mpSelf openGLContext]
                                                                         format:[pView->mpSelf pixelFormat]];
    
    BOOL bSuccess = pView->mpVisualContext != nil;
    
    if(bSuccess)
    {
        // Targets a movie to render into a visual context
        [pView->mpVisualContext setMovie:pView->mpMovie];
    } // if
    
    return bSuccess;
} // CVOpenGLViewAcquireVisualContext

static BOOL CVOpenGLViewAcquireMovieAttributes(NSString *pMoviePath,
                                               QTCVOpenGLViewDataRef pView)
{
    BOOL bSuccess = pMoviePath != nil;
    
    if(pMoviePath)
    {
        // If we already have a movie release it
        CVOpenGLViewDeleteMovie(pView);
        
        // Instantiate a movie object
        pView->mpMovie = [[QTMovie alloc] initWithFile:pMoviePath
                                                 error:nil];
        
        // Is a valid movie
        bSuccess = pView->mpMovie != nil;
        
        // Get the movie size
        if(bSuccess)
        {
            // Get the movie width & height
            [[pView->mpMovie attributeForKey:QTMovieNaturalSizeAttribute] getValue:&pView->m_Playback.m_Size];
            
            // Set movie to loop
            [pView->mpMovie setAttribute:[NSNumber numberWithBool:YES]
                                  forKey:QTMovieLoopsAttribute];
            
            // Play the Movie
            [pView->mpMovie setRate:1.0];
        } // if
    } // if
    
    return bSuccess;
} // CVOpenGLViewAcquireMovieAttributes

// New QT & CV resources for a movie
static inline BOOL CVOpenGLViewAcquireResourceForMovie(NSString *pMoviePath,
                                                       QTCVOpenGLViewDataRef pView)
{
    BOOL bSuccess = CVOpenGLViewAcquireMovieAttributes(pMoviePath, pView);
    
    if(bSuccess)
    {
        bSuccess =             CVOpenGLViewAcquireDisplayLink(pView);
        bSuccess = bSuccess && CVOpenGLViewAcquireVisualContext(pView);
    } // if
    
    return bSuccess;
} // CVOpenGLViewAcquireResourceForMovie

// Open a Movie File and instantiate a QTMovie object
static inline BOOL CVOpenGLViewOpenMovie(NSString *pMoviePath,
                                         QTCVOpenGLViewDataRef pView)
{
    BOOL bSuccess = CVOpenGLViewAcquireResourceForMovie(pMoviePath, pView);
    
    // New movie resources
    if(bSuccess)
    {
        // Set the window title from the Movie if it has a name associated with it
        [[pView->mpSelf window] setTitle:[pView->mpMovie attributeForKey:QTMovieDisplayNameAttribute]];
    } // if
    
    return bSuccess;
} // CVOpenGLViewOpenMovie

#pragma mark -
#pragma mark Private - Utilties - Display Link

static inline BOOL CVOpenGLViewStartDisplayLink(QTCVOpenGLViewDataRef pView)
{
    BOOL bSuccess = pView->m_Playback.mpDisplayLink != NULL;
    
    if(bSuccess)
    {
        bSuccess = !CVDisplayLinkIsRunning(pView->m_Playback.mpDisplayLink);
        
        if(bSuccess)
        {
            CVDisplayLinkStart(pView->m_Playback.mpDisplayLink);
        } // if
    } // if
    
    return bSuccess;
} // CVOpenGLViewStartDisplayLink

static inline BOOL CVOpenGLViewStopDisplayLink(QTCVOpenGLViewDataRef pView)
{
    BOOL bSuccess = pView->m_Playback.mpDisplayLink != NULL;
    
    if(bSuccess)
    {
        bSuccess = CVDisplayLinkIsRunning(pView->m_Playback.mpDisplayLink);
        
        if(bSuccess)
        {
            CVDisplayLinkStop(pView->m_Playback.mpDisplayLink);
        } // if
    } // if
    
    return bSuccess;
} // CVOpenGLViewStopDisplayLink

#pragma mark -

@implementation QTCVOpenGLView

#pragma mark -
#pragma mark Public - Awake From Nib

- (id) initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        mpView = CVOpenGLViewCreate(self);
    } // if
    
    return self;
} // initWithFrame

#pragma mark -
#pragma mark Public - Destructors

// It is very important that we clean up the rendering objects before the
// view is disposed, remember that with the display link running you're
// applications render callback may be called at any time including when
// the application is quitting or the view is being disposed, additionally
// you need to make sure you're not consuming OpenGL resources or leaking
// textures -- this clean up routine makes sure to stop and release
// everything.
- (void) cleanUp
{
    CVOpenGLViewDelete(mpView);
    
    [super cleanUp];
} // cleanUp

- (void) dealloc
{
    CVOpenGLViewDelete(mpView);
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Accessors

// Video pixel buffer
- (CVPixelBufferRef) buffer
{
	return mpView->m_Playback.mpVideoFrame;
} // buffer

// Video frame size
- (NSSize) size
{
    return mpView->m_Playback.m_Size;
} // frame

#pragma mark -
#pragma mark Public - Utilities - Display Link

// Start display link
- (BOOL) start
{
    return CVOpenGLViewStartDisplayLink(mpView);
} // start

// Stop display link
- (BOOL) stop
{
    return CVOpenGLViewStopDisplayLink(mpView);
} // start

// Display the video
- (void) display
{
    return;
} // display

#pragma mark -
#pragma mark Public - Utilities - Movie

// Open a Movie File and instantiate a QTMovie object
- (BOOL) openMovie:(NSString *)theMoviePath
{
    return CVOpenGLViewOpenMovie(theMoviePath, mpView);
} // openMovie

@end
