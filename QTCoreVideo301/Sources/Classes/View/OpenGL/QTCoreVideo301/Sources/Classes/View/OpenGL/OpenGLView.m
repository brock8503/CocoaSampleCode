/*
     File: OpenGLView.m
 Abstract: 
 OpenGL view base custom class.
 
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

#import "OpenGLView.h"

#pragma mark -
#pragma mark Private - Constants

static const unichar kESCKey = 27;

#pragma mark -
#pragma mark Private - Data Structures

struct OpenGLViewFullScreen
{
	NSDictionary  *mpOptions;   // full screen dictionary options
	NSScreen      *mpScreen;    // full screen
};

typedef struct OpenGLViewFullScreen  OpenGLViewFullScreen;

struct OpenGLViewLocation
{
	NSPoint  m_Mouse;   // last place the mouse was
	NSPoint  m_Window;  // last place the mouse was
};

typedef struct OpenGLViewLocation  OpenGLViewLocation;

struct OpenGLViewMouseButton
{
	BOOL  mbIsLeft;     // was the left mouse button pressed?
	BOOL  mbIsRight;    // was the right mouse button pressed?
};

typedef struct OpenGLViewMouseButton  OpenGLViewMouseButton;

struct OpenGLViewRotation
{
    BOOL      mbRotate; // Set the flag to rotate
	GLdouble  mnPitch;  // pitch used for animation
	GLdouble  mnRoll;   // roll used for animation
	GLdouble  mnTime;   // used to compute change in time
    GLdouble  mnDPS;    // view degrees of rotation per second
};

typedef struct OpenGLViewRotation  OpenGLViewRotation;

struct OpenGLViewAttribs
{
    GLint     mnInterval;   // swap interval
    GLint     mnAlignment;  // unpack alignment
    CGLError  mnError;      // CGL errors
};

typedef struct OpenGLViewAttribs  OpenGLViewAttribs;

struct OpenGLViewport
{
	GLdouble  mnLeft;		// Coordinate for the left vertical clipping plane
	GLdouble  mnRight;		// Coordinate for the right vertical clipping plane
	GLdouble  mnBottom;     // Coordinate for the bottom horizontal clipping plane
	GLdouble  mnTop;		// Coordinate for the top horizontal clipping plane
	GLdouble  mnZNear;		// Distance to the near depth clipping plane
	GLdouble  mnZFar;		// Distance to the far depth clipping plane
    GLdouble  mnAspect;     // aspect ratio
	GLdouble  mnScale;      // view scale factor
	GLdouble  mnZoom;       // zoom factor
    NSRect    m_Bounds;     // view bounds
};

typedef struct OpenGLViewport  OpenGLViewport;

struct OpenGLViewData
{
    CGLContextObj          mpContextObj;    // CGL context object
    OpenGLView            *mpSelf;          // Referencing self
    OpenGLViewport         m_Viewport;      // View size and origins
    OpenGLViewRotation     m_Rotation;      // Rotation in a view
    OpenGLViewAttribs      m_Attribs;       // View attributes
    OpenGLViewMouseButton  m_Button;        // Mouse down
    OpenGLViewFullScreen   m_FullScreen;    // View full screen
    OpenGLViewLocation     m_Location;      // Locations in a view
};

typedef struct OpenGLViewData  OpenGLViewData;

#pragma mark -
#pragma mark Private - Utilties - Fullscreen

static void OpenGLViewExitFullScreen(OpenGLViewDataRef pGLView)
{
    if([pGLView->mpSelf isInFullScreenMode])
    {
        CGLContextObj pContextObj = (CGLContextObj)[[pGLView->mpSelf openGLContext] CGLContextObj];
        
        if(pContextObj != NULL)
        {
            CGLSetCurrentContext(pContextObj);
            
            CGLError nError = CGLLockContext(pContextObj);
            
            if(nError == kCGLNoError)
            {
                [pGLView->mpSelf exitFullScreenModeWithOptions:pGLView->m_FullScreen.mpOptions];
            } // if
            
            CGLUnlockContext(pContextObj);
        } // if
    } // if
} // OpenGLViewExitFullScreen

static BOOL OpenGLViewToggleFullScreen(OpenGLViewDataRef pGLView)
{
    CGLContextObj pContextObj = (CGLContextObj)[[pGLView->mpSelf openGLContext] CGLContextObj];
    
    BOOL bSuccess = pContextObj != NULL;
    
    if(bSuccess)
    {
        CGLSetCurrentContext(pContextObj);
        
        CGLError nError = CGLLockContext(pContextObj);
        
        bSuccess = nError == kCGLNoError;
        
        if(bSuccess)
        {
            bSuccess = [pGLView->mpSelf isInFullScreenMode];
            
            if(bSuccess)
            {
                [pGLView->mpSelf exitFullScreenModeWithOptions:pGLView->m_FullScreen.mpOptions];
            } // if
            else
            {
                [pGLView->mpSelf enterFullScreenMode:pGLView->m_FullScreen.mpScreen
                                         withOptions:pGLView->m_FullScreen.mpOptions];
            } // else
        } // if
        
        CGLUnlockContext(pContextObj);
    } // if
    
    return(bSuccess);
} // OpenGLViewToggleFullScreen

#pragma mark -
#pragma mark Private - Utilties - Mouse Location

static inline void OpenGLViewSetMouseUpdate(NSEvent *pEvent,
                                            OpenGLViewDataRef pGLView)
{
    NSPoint window = [pEvent locationInWindow];
    NSPoint mouse  = [pGLView->mpSelf convertPoint:window
                                          fromView:nil];
    
    if(pGLView->m_Rotation.mbRotate)
    {
        pGLView->m_Rotation.mnRoll  += pGLView->m_Location.m_Mouse.y - mouse.y;
        pGLView->m_Rotation.mnPitch -= pGLView->m_Location.m_Mouse.x - mouse.x;
    } // if
    
    pGLView->m_Location.m_Mouse  = mouse;
    pGLView->m_Location.m_Window = window;
} // OpenGLViewSetMouseUpdate

static inline void OpenGLViewSetMouseLocation(NSEvent *pEvent,
                                              OpenGLViewDataRef pGLView)
{
    if(pEvent)
    {
        pGLView->m_Location.m_Window = [pEvent locationInWindow];
        pGLView->m_Location.m_Mouse  = [pGLView->mpSelf convertPoint:pGLView->m_Location.m_Window
                                                            fromView:nil];
    } // if
} // OpenGLViewSetMouseLocation

#pragma mark -
#pragma mark Private - Utilties - Prepare

static BOOL OpenGLViewSetMTEngine(OpenGLViewDataRef pGLView)
{
	CGLContextObj  pContext = CGLGetCurrentContext();
    
    if(pContext != NULL)
    {
        // Enable the multi-threaded OpenGL engine
        pGLView->m_Attribs.mnError = CGLEnable(pContext, kCGLCEMPEngine);
        
        if(pGLView->m_Attribs.mnError != kCGLNoError)
        {
            // Multi-threaded execution is possibly not available
            // so what was the returned CGL error?
            
            NSLog(@">> [OpenGL View] ERROR: Initializing multi-threaded OpenGL Engine!");
        } // if
    } // if
    
    return pGLView->m_Attribs.mnError == kCGLNoError;
} // OpenGLViewSetMTEngine

static void OpenGLViewSetStates(OpenGLViewDataRef pGLView)
{
	// shading mathod: GL_SMOOTH or GL_FLAT
    glShadeModel(GL_SMOOTH);
	
	// 4-byte pixel alignment
    glPixelStorei(GL_UNPACK_ALIGNMENT, pGLView->m_Attribs.mnAlignment);
	
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
	
	glTranslated(0.0, 0.0f, -2.0);
	
	// Turn on depth test
    glEnable(GL_DEPTH_TEST);
	
	// track material ambient and diffuse from surface color,
	// call it before glEnable(GL_COLOR_MATERIAL)
    glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE);
    glEnable(GL_COLOR_MATERIAL);
	
	// Clear to black nothing fancy.
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	
	// clear stencil buffer
    glClearStencil(0);
	
	// 0 is near, 1 is far
    glClearDepth(1.0f);
    
    glDepthFunc(GL_LEQUAL);
	
	// Setup blending function
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    // Enable client states
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnableClientState(GL_VERTEX_ARRAY);
} // OpenGLViewSetStates

// Set up the GL contexts swap interval -- passing 1 means that the buffers
// are swapped only during the vertical retrace of the monitor.
static inline void OpenGLViewSetSwapInterval(OpenGLViewDataRef pGLView)
{
	[[pGLView->mpSelf openGLContext] setValues:&pGLView->m_Attribs.mnInterval
                                  forParameter:NSOpenGLCPSwapInterval];
} // OpenGLViewSetSwapInterval

static inline void OpenGLViewSetFullScreen(OpenGLViewDataRef pGLView)
{
	pGLView->m_FullScreen.mpOptions = [[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                                   forKey:NSFullScreenModeSetting] retain];
	
	pGLView->m_FullScreen.mpScreen = [[NSScreen mainScreen] retain];
} // OpenGLViewSetFullScreen

static inline void OpenGLViewSetDefaults(OpenGLView *pSelf,
                                         OpenGLViewDataRef pGLView)
{
    pGLView->mpSelf                =  pSelf;
    pGLView->m_Viewport.mnZoom     =  1.0;
    pGLView->m_Viewport.mnScale    =  0.5;
	pGLView->m_Viewport.mnZNear    =  1.0;
	pGLView->m_Viewport.mnZFar     =  10.0;
    pGLView->m_Rotation.mnTime     = -1.0;
    pGLView->m_Rotation.mnDPS      =  30.0;
    pGLView->m_Attribs.mnAlignment =  4;
    pGLView->m_Attribs.mnInterval  =  1;
    pGLView->m_Attribs.mnError     =  kCGLBadContext;
} // OpenGLViewSetDefaults

#pragma mark -
#pragma mark Private - Utilties - Constructor

static OpenGLViewDataRef OpenGLViewCreate(OpenGLView *pSelf)
{
    OpenGLViewDataRef pGLView = NULL;
    
    if(pSelf)
    {
        pGLView = (OpenGLViewDataRef)calloc(1, sizeof(OpenGLViewData));
        
        if(pGLView != NULL)
        {
            OpenGLViewSetDefaults(pSelf, pGLView);
            
            OpenGLViewSetSwapInterval(pGLView);
            OpenGLViewSetMTEngine(pGLView);
            OpenGLViewSetStates(pGLView);
            
            OpenGLViewSetFullScreen(pGLView);
        } // if
        else
        {
            NSLog(@">> [OpenGL View] ERROR: Failure Allocating Memory For OpenGL View Attributes!");
        } // else
    } // if
    
    return pGLView;
} // OpenGLViewCreate

#pragma mark -
#pragma mark Private - Utilties - Destructor

static inline void OpenGLViewDeleteOptions(OpenGLViewDataRef pGLView)
{
    if(pGLView->m_FullScreen.mpOptions)
    {
        [pGLView->m_FullScreen.mpOptions release];
        
        pGLView->m_FullScreen.mpOptions = nil;
    } // if
} // OpenGLViewDeleteOptions

static inline void OpenGLViewDeleteScreen(OpenGLViewDataRef pGLView)
{
    if(pGLView->m_FullScreen.mpScreen)
    {
        [pGLView->m_FullScreen.mpScreen release];
        
        pGLView->m_FullScreen.mpScreen = nil;
    } // if
} // OpenGLViewDeleteScreen

static void OpenGLViewDelete(OpenGLViewDataRef pGLView)
{
    if(pGLView != NULL)
    {
        OpenGLViewExitFullScreen(pGLView);
        
        OpenGLViewDeleteScreen(pGLView);
        OpenGLViewDeleteOptions(pGLView);
        
        free(pGLView);
        
        pGLView = NULL;
    } // if
} // OpenGLViewDelete

#pragma mark -
#pragma mark Private - Utilties - Rotation

static inline GLdouble OpenGLViewUpdateTime(OpenGLViewDataRef pGLView)
{
	GLdouble  nDelta = 0.0;
	GLdouble  nTime  = (GLdouble)[NSDate timeIntervalSinceReferenceDate];
    
	if(pGLView->m_Rotation.mnTime < 0.0)
	{
		nDelta = 0.0;
	} // if
	else
	{
		nDelta = nTime - pGLView->m_Rotation.mnTime;
	} // else
    
	pGLView->m_Rotation.mnTime = nTime;
	
	return  nDelta;
} // OpenGLViewUpdateTime

static inline void OpenGLViewUpdateRoll(OpenGLViewDataRef pGLView)
{
	if(pGLView->m_Rotation.mnRoll < -45.0)
	{
		pGLView->m_Rotation.mnRoll = -45.0;
	} // if
	else if(pGLView->m_Rotation.mnRoll > 90.0)
	{
		pGLView->m_Rotation.mnRoll = 90.0;
	} // else if
    
	glRotated(pGLView->m_Rotation.mnRoll, 1.0, 0.0, 0.0);
} // OpenGLViewUpdateRoll

static inline void OpenGLViewUpdatePitch(OpenGLViewDataRef pGLView)
{
	if(!pGLView->m_Button.mbIsLeft || !pGLView->m_Button.mbIsRight)
	{
		GLdouble timeDelta = OpenGLViewUpdateTime(pGLView);
        
		pGLView->m_Rotation.mnPitch += pGLView->m_Rotation.mnDPS * timeDelta;
		
		if (pGLView->m_Rotation.mnPitch >= 360.0f)
		{
			pGLView->m_Rotation.mnPitch -= 360.0f;
		} // if
	} // if
	
	glRotated(pGLView->m_Rotation.mnPitch, 0.0, 1.0, 0.0);
	
	pGLView->m_Rotation.mnPitch += 0.2;
} // OpenGLViewUpdatePitch

// Constant rotation in the view
static void OpenGLViewUpdateRotation(OpenGLViewDataRef pGLView)
{
    if(pGLView->m_Rotation.mbRotate)
    {
        OpenGLViewUpdatePitch(pGLView);
        OpenGLViewUpdateRoll(pGLView);
    } // if
    else
    {
		pGLView->m_Rotation.mnRoll  = 0.0;
		pGLView->m_Rotation.mnPitch = 0.0;
    } // else
} // OpenGLViewUpdateRotation

#pragma mark -
#pragma mark Private - Utilties - Viewport

static inline BOOL OpenGLViewLock(OpenGLViewDataRef pGLView)
{
    BOOL bSuccess = pGLView->mpSelf != nil;
    
    if(bSuccess)
    {
        NSOpenGLContext *pContext = [pGLView->mpSelf openGLContext];
        
        bSuccess = pContext != nil;
        
        if(bSuccess)
        {
            pGLView->mpContextObj = (CGLContextObj)[pContext CGLContextObj];
            
            bSuccess = pGLView->mpContextObj != NULL;
            
            if(bSuccess)
            {
                CGLSetCurrentContext(pGLView->mpContextObj);
                
                CGLError nError = CGLLockContext(pGLView->mpContextObj);
                
                bSuccess = nError == kCGLNoError;
            } // if
        } // if
    } // if
    
    return  bSuccess;
} // OpenGLViewLock

static inline void OpenGLViewUnlock(OpenGLViewDataRef pGLView)
{
    CGLUnlockContext(pGLView->mpContextObj);
} // OpenGLViewUnlock

static void OpenGLViewSetPrespective(OpenGLViewDataRef pGLView)
{
    // Compute viewport properties
    pGLView->m_Viewport.m_Bounds =  [pGLView->mpSelf bounds];
    pGLView->m_Viewport.mnAspect =  pGLView->m_Viewport.m_Bounds.size.width / pGLView->m_Viewport.m_Bounds.size.height;
    pGLView->m_Viewport.mnTop    =  pGLView->m_Viewport.mnScale * pGLView->m_Viewport.mnZoom;
    pGLView->m_Viewport.mnBottom = -pGLView->m_Viewport.mnTop;
    pGLView->m_Viewport.mnRight  =  pGLView->m_Viewport.mnAspect * pGLView->m_Viewport.mnTop;
    pGLView->m_Viewport.mnLeft   = -pGLView->m_Viewport.mnRight;
    
    // Set to use projection matrix
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    // Set the transformation matrix
    glFrustum(pGLView->m_Viewport.mnLeft,
              pGLView->m_Viewport.mnRight,
              pGLView->m_Viewport.mnBottom,
              pGLView->m_Viewport.mnTop,
              pGLView->m_Viewport.mnZNear,
              pGLView->m_Viewport.mnZFar);
    
    // Set to use model-view matrix
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
} // OpenGLViewSetPrespective

static inline void OpenGLViewSetPrespectiveBlocking(OpenGLViewDataRef pGLView)
{
    if(OpenGLViewLock(pGLView))
    {
        OpenGLViewSetPrespective(pGLView);
        
        OpenGLViewUnlock(pGLView);
    } // if
} // OpenGLViewSetPrespectiveBlocking

static void OpenGLViewSetPort(OpenGLViewDataRef pGLView)
{
	GLint    x      = (GLint)(pGLView->m_Viewport.m_Bounds.origin.x);
	GLint    y      = (GLint)(pGLView->m_Viewport.m_Bounds.origin.y);
	GLsizei  width  = (GLsizei)(pGLView->m_Viewport.m_Bounds.size.width);
	GLsizei  height = (GLsizei)(pGLView->m_Viewport.m_Bounds.size.height);
	
	glViewport(x, y, width, height);
	
	glTranslated(0.0f, 0.0, -3.0);
} // OpenGLViewSetPort

static inline void OpenGLViewUpdatePort(OpenGLViewDataRef pGLView)
{
    // Set our viewport with correct prespective
    OpenGLViewSetPrespective(pGLView);
    OpenGLViewSetPort(pGLView);
    
    // Constant rotation in the view
    OpenGLViewUpdateRotation(pGLView);
} // OpenGLViewUpdatePort

static inline void OpenGLViewUpdatePortBlocking(OpenGLViewDataRef pGLView)
{
    if(OpenGLViewLock(pGLView))
    {
        OpenGLViewUpdatePort(pGLView);
        
        OpenGLViewUnlock(pGLView);
    } // if
} // OpenGLViewUpdatePortBlocking

#pragma mark -
#pragma mark Private - Utilties - Keyboard

static void OpenGLViewKeyDown(NSEvent *pEvent,
                              OpenGLViewDataRef pGLView)
{
    if(pEvent)
    {
        NSString *pCharacters = [pEvent charactersIgnoringModifiers];
        
        if(pCharacters)
        {
            unichar keyPressed = [pCharacters characterAtIndex:0];
            
            if(keyPressed == kESCKey)
            {
                OpenGLViewToggleFullScreen(pGLView);
            } // if
        } // if
    } // if
} // OpenGLViewKeyDown

#pragma mark -
#pragma mark Private - Utilties - Mouse

static inline void OpenGLViewMouseDown(NSEvent *pEvent,
                                       OpenGLViewDataRef pGLView)
{
    OpenGLViewSetMouseLocation(pEvent, pGLView);
    
    pGLView->m_Button.mbIsLeft = YES;
} // OpenGLViewMouseDown

static inline void OpenGLViewRightMouseDown(NSEvent *pEvent,
                                            OpenGLViewDataRef pGLView)
{
    OpenGLViewSetMouseLocation(pEvent, pGLView);
    
    pGLView->m_Button.mbIsRight = YES;
} // OpenGLViewRightMouseDown

static inline void OpenGLViewMouseDragged(NSEvent *pEvent,
                                          OpenGLViewDataRef pGLView)
{
    if(pEvent)
    {
        if([pEvent modifierFlags] & NSRightMouseDown)
        {
            [pGLView->mpSelf rightMouseDragged:pEvent];
        } // if
        else
        {
            OpenGLViewSetMouseUpdate(pEvent, pGLView);
        } // else
    } // if
} // OpenGLViewMouseDragged

static inline void OpenGLViewRightMouseDragged(NSEvent *pEvent,
                                               OpenGLViewDataRef pGLView)
{
    if(pEvent)
    {
        NSPoint window = [pEvent locationInWindow];
        NSPoint mouse  = [pGLView->mpSelf convertPoint:window
                                              fromView:nil];
        
        pGLView->m_Viewport.mnZoom += 0.01f * (pGLView->m_Location.m_Mouse.y - mouse.y);
        
        if (pGLView->m_Viewport.mnZoom < 0.05f)
        {
            pGLView->m_Viewport.mnZoom = 0.05f;
        } // if
        else if (pGLView->m_Viewport.mnZoom > 2.0f)
        {
            pGLView->m_Viewport.mnZoom = 2.0f;
        } // else if
        
        pGLView->m_Location.m_Mouse  = mouse;
        pGLView->m_Location.m_Window = window;
        
        OpenGLViewSetPrespectiveBlocking(pGLView);
    } // if
} // OpenGLViewRightMouseDragged

#pragma mark -
#pragma mark Private - Utilties - Pixel Format

static NSOpenGLPixelFormat *OpenGLViewCreatePixelFormat(const GLuint nColorBits)
{
	NSOpenGLPixelFormatAttribute attribs[] =
	{
		NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAAllowOfflineRenderers,
		NSOpenGLPFAColorSize, nColorBits,
		0
	};
	
	return [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
} // OpenGLViewCreatePixelFormat

#pragma mark -

@implementation OpenGLView

#pragma mark -
#pragma mark Public - Prepare

- (id) initWithFrame:(NSRect)frame
{
	NSOpenGLPixelFormat *pFormat = OpenGLViewCreatePixelFormat(24);
    
    if( pFormat )
    {
        self = [super initWithFrame:frame
                        pixelFormat:pFormat];
        
        if( self )
        {
            mpGLView = OpenGLViewCreate(self);
        } // if
        
        // Pixel format is not needed beyond this point
        [pFormat release];
    } // if
    
	return self;
} // initWithFrame

#pragma mark -
#pragma mark Public - Destructors

- (void) cleanUp
{
    OpenGLViewDelete(mpGLView);
} // cleanUp

- (void) dealloc
{
    OpenGLViewDelete(mpGLView);
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Delegates

- (BOOL) acceptsFirstResponder
{
	return YES;
} // acceptsFirstResponder

- (BOOL) becomeFirstResponder
{
	return  YES;
} // becomeFirstResponder

- (BOOL) resignFirstResponder
{
	return YES;
} // resignFirstResponder

#pragma mark -
#pragma mark Public - Utilites - Full Screen Mode

- (BOOL) toggleFullscreen
{
	return OpenGLViewToggleFullScreen(mpGLView);
} // toggleFullscreen

#pragma mark -
#pragma mark Public - Utilites - Updates

- (void) transform:(const bool)doBlock
{
    if(doBlock)
    {
        OpenGLViewUpdatePortBlocking(mpGLView);
    } // if
    else
    {
        OpenGLViewUpdatePort(mpGLView);
    } // else
} // transform

- (void) update
{
    OpenGLViewUpdatePortBlocking(mpGLView);
    
    [super update];
} // update

- (void) reshape
{
    OpenGLViewUpdatePortBlocking(mpGLView);
    
    [super reshape];
} // reshape

- (void) renewGState
{
    [[self window] disableScreenUpdatesUntilFlush];
    
    [super renewGState];
} // renewGState

#pragma mark -
#pragma mark Public - Utilites - Rotation

- (void) rotate:(const BOOL)doRotate
{
    mpGLView->m_Rotation.mbRotate = doRotate;
} // rotate

#pragma mark -
#pragma mark Public - Utilites - Mouse

- (void) mouseDown:(NSEvent *)theEvent
{
    OpenGLViewMouseDown(theEvent, mpGLView);
} // mouseDown

- (void) rightMouseDown:(NSEvent *)theEvent
{
    OpenGLViewRightMouseDown(theEvent, mpGLView);
} // rightMouseDown

- (void)mouseUp:(NSEvent *)theEvent
{
	mpGLView->m_Button.mbIsLeft = NO;
} // mouseUp

- (void) rightMouseUp:(NSEvent *)theEvent
{
	mpGLView->m_Button.mbIsRight = NO;
} // rightMouseUp

- (void)mouseDragged:(NSEvent *)theEvent
{
    OpenGLViewMouseDragged(theEvent, mpGLView);
} // mouseDragged

- (void)rightMouseDragged:(NSEvent *)theEvent
{
    OpenGLViewRightMouseDragged(theEvent, mpGLView);
} // rightMouseDragged

#pragma mark -
#pragma mark Public - Utilites - Keydown

- (void) keyDown:(NSEvent *)theEvent
{
	OpenGLViewKeyDown(theEvent, mpGLView);
} // keyDown

@end
