/*
     File: AppView.m
 Abstract: 
 View class implementation for the application.
 
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

#import "CVGLSLUnitMediator.h"

#import "AppView.h"

#pragma mark -
#pragma mark Private - Data Structures

struct AppViewUniforms
{    
	BOOL     mbStyle;       // The shader style (if more than one)
	GLfloat  m_Value[5];    // Uniform values
};

typedef struct AppViewUniforms   AppViewUniforms;

struct AppViewData
{
	AppViewUniforms     m_Uniforms;         // Uniform values
	CVGLSLUnitTypes     mnShaderType;       // Shader selection
    CVGLSLUnitMediator *mpUnitMediator;
};

typedef struct AppViewData  AppViewData;

#pragma mark -
#pragma mark Private - Utilties - Accessors

// Setting uniform values for color well
static inline void AppViewSetColorWell(const NSColor *pColor,
                                       AppViewDataRef pAppView)
{
    if(pColor)
    {
        pAppView->m_Uniforms.m_Value[2] = [pColor redComponent];
        pAppView->m_Uniforms.m_Value[3] = [pColor greenComponent];
        pAppView->m_Uniforms.m_Value[4] = [pColor blueComponent];
    } // if
} //  setUniformColorWell

static inline void AppViewSetDefaults(AppViewDataRef pAppView)
{
	// Default shader type
	
	pAppView->mnShaderType = kCVGLSLUnitBlur;
	
	// Default uniform values for the shader(s)
	
	pAppView->m_Uniforms.m_Value[0] = 0.5f;
	pAppView->m_Uniforms.m_Value[1] = 0.5f;
	pAppView->m_Uniforms.m_Value[2] = 0.5f;
	pAppView->m_Uniforms.m_Value[3] = 0.5f;
	pAppView->m_Uniforms.m_Value[4] = 0.5f;
    
} // AppViewSetDefaults

#pragma mark -
#pragma mark Private - Utilties - Constructors

// Constructor for CoreVideo OpenGL view
static AppViewDataRef AppViewCreate(const NSColor *pColor)
{
    AppViewDataRef pAppView = (AppViewDataRef)calloc(1, sizeof(AppViewData));
    
    if(pAppView != NULL)
    {        
        AppViewSetDefaults(pAppView);
        AppViewSetColorWell(pColor, pAppView);
    } // if
    else
    {
        NSLog(@">> [App View] ERROR: Failure Allocating Memory For View Attributes!");
    } // else
    
    return pAppView;
} // AppViewCreate

#pragma mark -
#pragma mark Private - Utilties - Destructors

static inline void AppViewDeleteMediator(AppViewDataRef pAppView)
{
	if(pAppView->mpUnitMediator)
	{
		[pAppView->mpUnitMediator release];
		
		pAppView->mpUnitMediator = nil;
	} // if
} // AppViewDeleteMediator

// Delete the object
static void AppViewDelete(AppViewDataRef pAppView)
{
    if(pAppView != NULL)
    {
        AppViewDeleteMediator(pAppView);
        
        free(pAppView);
        
        pAppView = NULL;
    } // if
} // AppViewDelete

#pragma mark -

@implementation AppView

#pragma mark -
#pragma mark Public - Awake From Nib

- (id) initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
    if(self)
    {
        mpAppView = AppViewCreate(NULL);
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
    AppViewDelete(mpAppView);

    [super cleanUp];
} // cleanUp

- (void) dealloc
{
    AppViewDelete(mpAppView);
    
    [super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Display

- (void) display
{
    // Draw into the view
    [mpAppView->mpUnitMediator execute:[self buffer]
                                  type:mpAppView->mnShaderType
                                  flag:mpAppView->m_Uniforms.mbStyle
                                 value:mpAppView->m_Uniforms.m_Value];
} // display

#pragma mark -
#pragma mark Public - Accessors - Setters

// Shader selection from popup button
- (void) setShaderItem:(const CVGLSLUnitTypes)theShader
{
	mpAppView->mnShaderType = theShader;
} // setShaderItem

// Setting uniform value for top slider
- (void)  setUniformWithTopPanelControls:(const float)theValue
{
	mpAppView->m_Uniforms.m_Value[0] = theValue;
} //  setUniformWithTopPanelControls

// Setting uniform value for bottom slider
- (void)  setUniformWithBottomPanelControls:(const float)theValue
{
	mpAppView->m_Uniforms.m_Value[1] = theValue;
} //  setUniformWithBottomPanelControls

// Setting uniform value for color match accessory slider
- (void)  setUniformWithColorPanelSlider:(const float)theValue
{
	mpAppView->m_Uniforms.m_Value[1] = theValue;
} //  setUniformWithColorPanelSlider

// Setting uniform values for color well
- (void)  setUniformWithColorWell:(const NSColor *)theColor
{
    AppViewSetColorWell(theColor, mpAppView);
} //  setUniformWithColorWell

// The flag for style
- (void)  setUniformWithPushButtonState:(const BOOL)theFlag
{
	mpAppView->m_Uniforms.mbStyle = theFlag;
} //  setUniformWithPushButtonState

#pragma mark -
#pragma mark Public - Utilities - Movie

// Open a Movie File and instantiate a QTMovie object
- (BOOL) openMovie:(NSString *)thePath
{
    BOOL bSuccess = [super openMovie:thePath];
    
    if(bSuccess)
    {
        NSSize size = [self size];
        
        if(!mpAppView->mpUnitMediator)
        {
            mpAppView->mpUnitMediator = [CVGLSLUnitMediator new];
        } // if
        
        [mpAppView->mpUnitMediator setSize:&size];
    } // if
    
    return bSuccess;
} // openMovie

@end
