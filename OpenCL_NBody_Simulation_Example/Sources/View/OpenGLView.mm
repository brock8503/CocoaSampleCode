/*
     File: OpenGLView.mm
 Abstract: 
 OpenGL view class with idle timer and fullscreen mode support.
 
  Version: 3.1
 
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

#pragma mark -
#pragma mark Private - Headers

#import <iostream>
#import <vector>

#import <OpenGL/gl.h>

#import "NBodyConstants.h"

#import "GLcontainers.h"
#import "GLUQuery.h"

#import "OpenGLView.h"

#pragma mark -
#pragma mark Private - Interfaces

@interface OpenGLView(Private)

- (void) alert:(NSString *)pMessage;

- (void) savePrefs:(NSString *)pBundleID;

- (void) quit:(NSNotification *)notification;

- (BOOL) query;

- (void) cleanupEngine;
- (void) cleanupOptions;
- (void) cleanupTimer;
- (void) cleanup;

- (void) preparePrefs;
- (void) prepareNBody;
- (void) prepareRunLoop;

- (void) idle;

- (void) resize;

@end

#pragma mark -

@implementation OpenGLView

#pragma mark -
#pragma mark Private - Destructor

- (void) cleanupOptions
{
    if(mpOptions)
    {
        [mpOptions release];
    } // if
} // cleanupOptions

- (void) cleanupTimer
{
    if(mpTimer)
    {
        [mpTimer invalidate];
        [mpTimer release];
    } // if
} // cleanupTimer

- (void) cleanupEngine
{
    if(mpEngine != NULL)
    {
        delete mpEngine;
        
        mpEngine = NULL;
    } // if
} // cleanupEngine

// Tear-down objects
- (void) cleanup
{
    [self cleanupOptions];
    [self cleanupTimer];
    [self cleanupEngine];
} // cleanup

#pragma mark -
#pragma mark Private - Preferences

- (void) alert:(NSString *)pMessage
{
    if(pMessage)
    {
        NSAlert *pAlert = [NSAlert new];
        
        if(pAlert)
        {
            [pAlert addButtonWithTitle:@"OK"];
            [pAlert setMessageText:pMessage];
            [pAlert setAlertStyle:NSCriticalAlertStyle];
            
            NSModalResponse response = [pAlert runModal];
            
            if(response == NSAlertFirstButtonReturn)
            {
                NSLog(@">> MESSAGE: %@", pMessage);
            } // if
            
            [pAlert release];
        } // if
    } // if
} // alert

- (BOOL) query
{
    GLU::Query query;
    
    // NOTE: For OpenCL 1.2 support refer to <http://support.apple.com/kb/HT5942>
    GLstrings keys =
    {
         "120",   "130",  "285",  "320M",
        "330M", "X1800", "2400",  "2600",
        "3000",  "4670", "4800",  "4870",
        "5600",  "8600", "8800", "9600M"
    };
    
    std::cout << ">> N-body Simulation: Renderer = \"" << query.renderer() << "\"" << std::endl;
    std::cout << ">> N-body Simulation: Vendor   = \"" << query.vendor()   << "\"" << std::endl;
    std::cout << ">> N-body Simulation: Version  = \"" << query.version()  << "\"" << std::endl;
    
    return BOOL(query.match(keys));
} // query

- (void) savePrefs:(NSString *)pBundleID
{
    if(pBundleID)
    {
        NSDictionary *pPrefs =[[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSNumber numberWithBool:mbFullscreen],        @"fullscreen",
                               [NSNumber numberWithInt:mnInitDemo],           @"initDemo",
                               [NSNumber numberWithFloat:mnStarScale],        @"starScale",
                               [NSNumber numberWithBool:mbShowHUD],           @"showHUD",
                               [NSNumber numberWithBool:mbShowUpdatesMeter],  @"showUpdates",
                               [NSNumber numberWithBool:mbShowFramesMeter],   @"showFramerate",
                               [NSNumber numberWithBool:mbShowPerfMeter],     @"showPref",
                               [NSNumber numberWithBool:mbShowDock],          @"showDock",
                               nil];
        
        if(pPrefs)
        {
            [[NSUserDefaults standardUserDefaults]
             removePersistentDomainForName:pBundleID];
            
            [[NSUserDefaults standardUserDefaults] setPersistentDomain:pPrefs
                                                               forName:pBundleID];
            
            [pPrefs release];
        } // if
    } // if
} // savePrefs

#pragma mark -
#pragma mark Private - Prepare

- (void) preparePrefs
{
    NSString *pBundleID = nil;
    
    NSDictionary *pUserDefaults = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    
    if(pUserDefaults == nil)
    {
        pBundleID = [[NSBundle mainBundle] bundleIdentifier];
        
        if(pBundleID)
        {
            pUserDefaults = [[NSUserDefaults standardUserDefaults] persistentDomainForName:pBundleID];
        } // if
    } // if
    
    if(pUserDefaults)
    {
        id obj = [pUserDefaults objectForKey:@"fullscreen"];
        
        mbFullscreen = obj ? [obj boolValue] : YES;
        
        obj = [pUserDefaults objectForKey:@"initDemo"];
        
        mnInitDemo = obj ? [obj intValue] : 1;
        
        obj = [pUserDefaults objectForKey:@"starScale"];
        
        mnStarScale = obj ? [obj floatValue] : 1.0f;
        
        obj = [pUserDefaults objectForKey:@"showHUD"];
        
        mbShowHUD = obj ? [obj boolValue] : YES;
        
        obj = [pUserDefaults objectForKey:@"showUpdates"];
        
        mbShowUpdatesMeter = obj ? [obj boolValue] : NO;
        
        obj = [pUserDefaults objectForKey:@"showFramerate"];
        
        mbShowFramesMeter = obj ? [obj boolValue] : NO;
        
        obj = [pUserDefaults objectForKey:@"showPref"];
        
        mbShowPerfMeter = obj ? [obj boolValue] : YES;
        
        obj = [pUserDefaults objectForKey:@"showDock"];
        
        mbShowDock = obj ? [obj boolValue] : YES;
    } // if
    
    [self savePrefs:pBundleID];
    
    if(mnInitDemo < 0)
    {
        mnInitDemo = 0;
    } // if
    
    if(mnInitDemo > 6)
    {
        mnInitDemo = 6;
    } // if
} // preparePrefs

- (void) prepareNBody
{
    if([self query])
    {
        [self alert:@"Requires OpenCL 1.2!"];
        
        [self cleanupOptions];
        [self cleanupTimer];
        
        exit(-1);
    } // if
    else
    {
        NSRect frame = [[NSScreen mainScreen] frame];
        
        mpEngine = new NBody::Engine(mnStarScale, mnInitDemo);
        
        mpEngine->setFrame(frame);
        
        mpEngine->finalize();
    } // else
} // prepareNBody

- (void) prepareRunLoop
{
	mpTimer = [[NSTimer timerWithTimeInterval:0.0
                                       target:self
                                     selector:@selector(idle)
                                     userInfo:self
                                      repeats:true] retain];
    
	[[NSRunLoop currentRunLoop] addTimer:mpTimer
                                 forMode:NSRunLoopCommonModes];
} // prepareRunLoop

#pragma mark -
#pragma mark Private - Quitting

// When application is terminating cleanup the objects
- (void) quit:(NSNotification *)notification
{
	[self  cleanup];
} // quit

#pragma mark -
#pragma mark Private - Display

- (void)idle
{
    [self setNeedsDisplay:YES];
} // idle

#pragma mark -
#pragma mark Public - Designated Initializer

- (id) initWithFrame:(NSRect)frameRect
{
    BOOL bIsValid = NO;
    
	NSOpenGLPixelFormatAttribute attribs[] =
	{
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAAcceleratedCompute,
        NSOpenGLPFAAllowOfflineRenderers,   // NOTE: Needed to connect to compute-only gpus
        NSOpenGLPFADepthSize, 24,
        0
	};
	
	NSOpenGLPixelFormat *format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    
    if(!format)
    {
        NSLog(@">> WARNING: Failed to initialize an OpenGL context with the desired pixel format!");
        NSLog(@">> MESSAGE: Attempting to initialize with a fallback pixel format!");
        
        NSOpenGLPixelFormatAttribute attribs[] =
        {
            NSOpenGLPFADoubleBuffer,
            NSOpenGLPFADepthSize, 24,
            0
        };
        
        format = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    } // if
    
    if(format)
    {
        self = [super initWithFrame:frameRect
                        pixelFormat:format];
        
        if(self)
        {
            mpContext = [self openGLContext];
            bIsValid  = mpContext != nil;
            
            mpOptions = [[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES]
                                                     forKey:NSFullScreenModeSetting] retain];
            
            // It's important to clean up our rendering objects before we terminate -- Cocoa will
            // not specifically release everything on application termination, so we explicitly
            // call our cleanup (private object destructor) routines.
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(quit:)
                                                         name:@"NSApplicationWillTerminateNotification"
                                                       object:NSApp];
        } // if
        else
        {
            NSLog(@">> ERROR: Failed to initialize an OpenGL context with attributes!");
        } // else
        
        [format release];
	} // if
    else
    {
        NSLog(@">> ERROR: Failed to acquire a valid pixel format!");
    } // else
    
    if(!bIsValid)
    {
        exit( -1 );
    } // if
    
    return self;
} // initWithFrame

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
	[super dealloc];
    
	[self cleanup];
} // dealloc

#pragma mark -
#pragma mark Public - Prepare

- (void) prepareOpenGL
{
	[super prepareOpenGL];
	
    [self preparePrefs];
    [self prepareNBody];
    [self prepareRunLoop];
} // prepareOpenGL

#pragma mark -
#pragma mark Public - Delegates

- (BOOL) isOpaque
{
    return YES;
} // isOpaque

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

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication
{
    return YES;
} // applicationShouldTerminateAfterLastWindowClosed

#pragma mark -
#pragma mark Public - Updates

- (void) renewGState
{
    [super renewGState];
    
    [[self window] disableScreenUpdatesUntilFlush];
} // renewGState

#pragma mark -
#pragma mark Public - Display

- (void) resize
{
    if(mpEngine != NULL)
    {
        NSRect bounds = [self bounds];
        
        mpEngine->resize(bounds);
    } // if
} // resize

- (void) reshape
{
    [self resize];
} // reshape

- (void) drawRect:(NSRect)dirtyRect
{
    mpEngine->draw();
} // drawRect

#pragma mark -
#pragma mark Public - Fullscreen

- (IBAction) toggleHelp:(id)sender
{
    if([mpHUD isVisible])
    {
        [mpHUD orderOut:sender];
    } // if
    else
    {
        [mpHUD makeKeyAndOrderFront:sender];
    } // else
} // toggleHelp

- (IBAction) toggleFullscreen:(id)sender
{
    if([self isInFullScreenMode])
    {
        [self exitFullScreenModeWithOptions:mpOptions];
        
        [[self window] makeFirstResponder:self];
    } // if
    else
    {
        [self enterFullScreenMode:[NSScreen mainScreen]
                      withOptions:mpOptions];
    } // else
} // toggleFullscreen

#pragma mark -
#pragma mark Public - Keys

- (void) keyDown:(NSEvent *)event
{
    if(event)
    {
        NSString *pChars = [event characters];
        
        if([pChars length])
        {
            unichar key = [[event characters] characterAtIndex:0];
            
            if(key == 27)
            {
                [self toggleFullscreen:self];
            } // if
            else
            {
                mpEngine->run(key);
            } // else
        } // if
    } // if
} // keyDown

- (void) mouseDown:(NSEvent *)event
{
    if(event)
    {
        NSPoint where  = [event locationInWindow];
        NSRect  bounds = [self bounds];
        NSPoint point  = NSMakePoint(where.x, bounds.size.height - where.y);
        
        mpEngine->click(NBody::Mouse::Button::kDown, point);
    } // if
} // mouseDown

- (void) mouseUp:(NSEvent *)event
{
    if(event)
    {
        NSPoint where  = [event locationInWindow];
        NSRect  bounds = [self bounds];
        NSPoint point  = NSMakePoint(where.x, bounds.size.height - where.y);
        
        mpEngine->click(NBody::Mouse::Button::kUp, point);
    } // if
} // mouseUp

- (void) mouseDragged:(NSEvent *)event
{
    if(event)
    {
        NSPoint where = [event locationInWindow];
        
        where.y = 1080.0f - where.y;
        
        mpEngine->move(where);
    } // if
} // mouseDragged

- (void) scrollWheel:(NSEvent *)event
{
    if(event)
    {
        CGFloat dy = [event deltaY];
        
        mpEngine->scroll(dy);
    } // if
} // scrollWheel

@end
