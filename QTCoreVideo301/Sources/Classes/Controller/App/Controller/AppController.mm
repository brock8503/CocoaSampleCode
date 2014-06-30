/*
     File: AppController.mm
 Abstract: 
 Controller class that includes view animation.
 
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

#import "AppController.h"

#pragma mark -

@implementation AppController

#pragma mark -
#pragma mark Public - Initializers

 - (id) init
{
    self = [super init];
    
    if(self)
    {
        mpOpenPanel = [[NSOpenPanel openPanel] retain];
        
        if(mpOpenPanel)
        {
            [mpOpenPanel setMessage:@"Choose A Movie"];
            [mpOpenPanel setResolvesAliases:YES];
            [mpOpenPanel setAllowsMultipleSelection:NO];
        } // if
    } // if
    
    return self;
} // init

#pragma mark -
#pragma mark Private - Utilities - View Animation - Panels

// Since all controls are derived from a view, for animation, return a view.
// This method must be implemented in the derived class
- (NSView *) view:(NSString *)theControl
{
    App::Animator::Value::Type nType = m_Map.value(theControl);
    
	switch(nType)
	{
		case App::Animator::Value::kTopSlider:
			return topSlider;
            
		case App::Animator::Value::kTopTextField:
			return topTextField;
			
		case App::Animator::Value::kTopStaticTextField:
			return topStaticTextField;
            
		case App::Animator::Value::kColorWell:
			return colorWell;
			
		case App::Animator::Value::kBottomSlider:
			return bottomSlider;
			
		case App::Animator::Value::kBottomTextField:
			return bottomTextField;
			
		case App::Animator::Value::kBottomStaticTextField:
			return bottomStaticTextField;
			
		case App::Animator::Value::kPushButton:
			return pushButton;
            
        default:
            break;
	} // switch
	
	return nil;
} // view

#pragma mark -
#pragma mark Public - Action - Open Sheet

- (IBAction) open:(id)sender
{
	void (^movieOpenPanelHandler)(NSInteger) = ^(NSInteger result)
	{
		NSAutoreleasePool *pool = [NSAutoreleasePool new];
        
        if(pool)
        {
            if(result)
            {
                NSURL *pURL = [mpOpenPanel URL];
                
                if(pURL)
                {
                    NSString *pPath = [pURL path];
                    
                    if(pPath)
                    {
                        [appView openMovie:pPath];
                    } // if
                } // if
            } // if
            
            [appView start];
            
            [pool drain];
        } // if
	};
	
    [appView stop];
    
    [mpOpenPanel beginSheetModalForWindow:appWindow
                        completionHandler:movieOpenPanelHandler];
} // open

#pragma mark -
#pragma mark Public - Action - Push Button

- (IBAction) buttonPushed:(id)sender
{
	NSInteger buttonPushed = [sender state];
	
	if(buttonPushed == NSOffState)
	{
        [pushButton setTitle:@"Default"];
        
		[appView setUniformWithPushButtonState:NO];
	} // if
	else if(buttonPushed == NSOnState)
	{
        [pushButton setTitle:@"Saturate"];
        
		[appView setUniformWithPushButtonState:YES];
	} // else if
} // buttonPushed

#pragma mark -
#pragma mark Public - Action - Text Fields

- (IBAction) bottomTextFieldChanged:(id)sender
{
	int    uniformIntValue   = [sender intValue];
	float  uniformFloatValue = (float)uniformIntValue / 100.0f;
	
    [appView setUniformWithBottomPanelControls:uniformFloatValue];
	
	[bottomSlider setFloatValue:uniformFloatValue];
} // bottomTextFieldChanged

- (IBAction) topTextFieldChanged:(id)sender
{
	int    uniformIntValue   = [sender intValue];
	float  uniformFloatValue = (float)uniformIntValue / 100.0f;
	
    [appView setUniformWithTopPanelControls:uniformFloatValue];
	
	[topSlider setFloatValue:uniformFloatValue];
} // topTextFieldChanged

#pragma mark -
#pragma mark Public - Action - Sliders

- (IBAction) topSliderChanged:(id)sender
{
	float uniformFloatValue = [sender floatValue];
	int   uniformIntValue   = (int)(uniformFloatValue * 100.0f);
	
    [appView setUniformWithTopPanelControls:uniformFloatValue];
	
	[topTextField setIntValue:uniformIntValue];
} // topSliderChanged

- (IBAction) bottomSliderChanged:(id)sender
{
	float uniformFloatValue = [sender floatValue];
	int   uniformIntValue   = (int)(uniformFloatValue * 100.0f);
	
    [appView setUniformWithBottomPanelControls:uniformFloatValue];
	
	[bottomTextField setIntValue:uniformIntValue];
} // bottomSliderChanged

#pragma mark -
#pragma mark Public - Action - Color Well

- (IBAction) colorWellChanged:(id)sender
{
	NSColor *color = [sender color];
	
    [appView setUniformWithColorWell:color];
} // colorWellChanged

#pragma mark -
#pragma mark Public - Action - Accessory Views

- (IBAction) colorMatchSliderChanged:(id)sender
{
	float uniformFloatValue = [sender floatValue];
	int   uniformIntValue   = (int)(uniformFloatValue * 100.0f);
	
    [appView setUniformWithColorPanelSlider:uniformFloatValue];
	
	[colorMatchAccessoryTextField setIntValue:uniformIntValue];
} // colorMatchSliderChanged

- (IBAction) colorMatchTextFieldChanged:(id)sender
{
	int    uniformIntValue   = [sender intValue];
	float  uniformFloatValue = (float)uniformIntValue / 100.0f;
	
    [appView setUniformWithColorPanelSlider:uniformFloatValue];
	
	[colorMatchAccessorySlider setFloatValue:uniformFloatValue];
} // colorMatchTextFieldChanged

#pragma mark -
#pragma mark Public - Action - Pop-Up Buttons

// If a shared color panel is open then close it
- (void) sharedColorPanelClose
{
	if ([NSColorPanel sharedColorPanelExists])
	{
		[[NSColorPanel sharedColorPanel] close];
	} // if
} // sharedColorPanelClose

// Add the accessory view to the shared color panel if the selcted
// effect is the color extraction shader.
- (void) sharedColorPanelAddAccessoryView:(const CVGLSLUnitTypes)theShaderUnitSelected
{
	if (theShaderUnitSelected == kCVGLSLUnitExtractColor)
	{
		[[NSColorPanel sharedColorPanel] setAccessoryView:colorMatchAccessory];
	} // if
} // sharedColorPanelAddAccessoryView

// This method is called when the user picks a different effect to
// receive messages using the pop-up menu
- (IBAction) switchEffects:(id)sender
{
	// sender is the NSPopUpMenu containing shader effects' choices.
	// We ask the sender which popup menu item is selected and add
	// one to compensate for counting from zero.
	
	CVGLSLUnitTypes effectSelected = CVGLSLUnitTypes([sender indexOfSelectedItem] + 1);
    
	// Based of the selected effect animate the views
	
	[self sharedColorPanelClose];
	[self sharedColorPanelAddAccessoryView:effectSelected];

	[self animate:effectSelected];
	
	// Based on selected shader effect, we set the target to the
	// selected shader.
	
	[appView setShaderItem:effectSelected];
} // switchEffects

#pragma mark -
#pragma mark Public - Action - Fullscreen

- (IBAction) toggleFullscreen:(id)sender
{
	[appView toggleFullscreen];
} // toggleFullscreen

- (IBAction) rotate:(id)sender
{
	[appView rotate:[sender state]];
} // rotate

#pragma mark -
#pragma mark Public - Delagates

- (void) applicationDidFinishLaunching:(NSNotification *)notification
{
	[self open:self];
} // applicationDidFinishLaunching

// It's important to clean up our rendering objects before we terminate --
// cocoa will not specifically release everything on application termination,
// so we explicitly call our clean up routine ourselves
- (void) applicationWillTerminate:(NSNotification *)notification
{
    [mpOpenPanel release];
    
	[appView cleanUp];
    [super   cleanUp];
} // applicationWillTerminate

@end
