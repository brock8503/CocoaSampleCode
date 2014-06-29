/*
     File: OpenGLPlasmaExhibitsUIController.m
 Abstract: 
 View Controller class.
 
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

#import "NSImageLoader.h"
#import "QTMediaSampleNotifications.h"
#import "OpenGLImageView.h"
#import "OpenGLPlasmaExhibitsUIController.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Enumerated Types

//---------------------------------------------------------------------------

enum LightPosition
{
	kLightPosX = 0,
	kLightPosY,
	kLightPosZ
};

typedef enum LightPosition LightPosition;

//---------------------------------------------------------------------------

enum RecorderPanelButtonImageStates
{
	kImageRecordingButtonOff = 0,
	kImageRecordingButtonOn,
	kImagePauseButtonOff,
	kImagePauseButtonOn,
	kImageStopButtonOff,
	kImageStopButtonOn,
	kImageColorCorrectionButtonOff,
	kImageColorCorrectionButtonOn
};

typedef enum RecorderPanelButtonImageStates RecorderPanelButton;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

@implementation OpenGLPlasmaExhibitsUIController

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Post Notifications

//---------------------------------------------------------------------------

- (void) postPlasmaExhibitsAppTerminationNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(plasmaExhibitsUIControllerWillTerminate:)
												 name:@"NSApplicationWillTerminateNotification"
											   object:NSApp];
} // postPlasmaExhibitsAppTerminationNotification

//---------------------------------------------------------------------------

- (void) postPlasmaExhibitsAppWindowDidResizeNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(plasmaExhibitsAppWindowDidResize:)
												 name:@"NSWindowDidResizeNotification"
											   object:appMainWindow];
} // postPlasmaExhibitsAppWindowDidResizeNotification

//---------------------------------------------------------------------------

- (void) postPlasmaExibitsRecorderPanelWillCloseNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(plasmaExhibitsAppWindowWillClose:)
												 name:@"NSWindowWillCloseNotification"
											   object:viewCapturePanel];
} // postPlasmaExibitsRecorderPanelWillCloseNotification

//---------------------------------------------------------------------------

- (void) postPlasmaExibitsCaptureIsSuspendedNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(plasmaExibitsCaptureIsSuspended:)
												 name:QTMediaSampleAuthorIsSuspended
											   object:nil];
} // postPlasmaExibitsCaptureIsSuspendedNotification

//---------------------------------------------------------------------------

- (void) postPlasmaExibitsCaptureIsResumedNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(plasmaExibitsCaptureIsResumed:)
												 name:QTMediaSampleAuthorIsResumed
											   object:nil];
} // postPlasmaExibitsCaptureIsResumedNotification

//---------------------------------------------------------------------------

- (void) postPlasmaExibitsCaptureIsFinalizedNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(plasmaExibitsCaptureIsFinalized:)
												 name:QTMediaSampleAuthorIsFinalized
											   object:nil];
} // postPlasmaExibitsCaptureIsFinalizedNotification

//---------------------------------------------------------------------------

- (void) postNotifications
{
	[self postPlasmaExhibitsAppTerminationNotification];
	[self postPlasmaExhibitsAppWindowDidResizeNotification];
	[self postPlasmaExibitsRecorderPanelWillCloseNotification];
	[self postPlasmaExibitsCaptureIsSuspendedNotification];
	[self postPlasmaExibitsCaptureIsResumedNotification];
	[self postPlasmaExibitsCaptureIsFinalizedNotification];
} // postNotifications

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Application Startup

//---------------------------------------------------------------------------

- (void) initImages
{
	NSArray *recordButtonStateFileNames = [NSArray arrayWithObjects:@"RecordButtonOff",
										   @"RecordButtonOn",
										   @"PauseButtonOff",
										   @"PauseButtonOn",
										   @"StopButtonOff",
										   @"StopButtonOn",
										   @"ColorCorrectionButtonOff",
										   @"ColorCorrectionButtonOn",
										   nil];
	
	viewCaptureButtonStateImages = [[NSImageLoader alloc] initWithImagesInAppBundle:recordButtonStateFileNames
																			   type:@"tiff"];
} // initImages

//---------------------------------------------------------------------------

- (void) initLightXPositionControl
{
	NSNumber *lightPosNum    = [plasmaExhibitsView preferenceGetObjectForKey:@"Light X Position"];
	float     lightPosFValue = [lightPosNum floatValue];
	int       lightPosIValue = (int)lightPosFValue;
	
	[lightPosXTextField setIntValue:lightPosIValue];
	[lightPosXSlider    setFloatValue:lightPosFValue];
} // initLightXPositionControl

//---------------------------------------------------------------------------

- (void) initLightYPositionControl
{
	NSNumber *lightPosNum    = [plasmaExhibitsView preferenceGetObjectForKey:@"Light Y Position"];
	float     lightPosFValue = [lightPosNum floatValue];
	int       lightPosIValue = (int)lightPosFValue;
	
	[lightPosYTextField setIntValue:lightPosIValue];
	[lightPosYSlider    setFloatValue:lightPosFValue];
} // initLightYPositionControl

//---------------------------------------------------------------------------

- (void) initLightZYPositionControl
{
	NSNumber *lightPosNum    = [plasmaExhibitsView preferenceGetObjectForKey:@"Light Z Position"];
	float     lightPosFValue = [lightPosNum floatValue];
	int       lightPosIValue = (int)lightPosFValue;
	
	[lightPosZTextField setIntValue:lightPosIValue];
	[lightPosZSlider    setFloatValue:lightPosFValue];
} // initLightZYPositionControl

//---------------------------------------------------------------------------

- (void) initLightPositions
{
	[self initLightXPositionControl];
	[self initLightYPositionControl];
	[self initLightZYPositionControl];
} // initLightPositions

//---------------------------------------------------------------------------

- (void) initExhibitType
{
	NSNumber   *exhibitTypeNum   = [plasmaExhibitsView preferenceGetObjectForKey:@"Exhibit Type"];
	NSUInteger  exhibitTypeValue = [exhibitTypeNum unsignedIntValue] - 1;
	
	[exhibitButton selectItemAtIndex:exhibitTypeValue];
} // initExhibitType

//---------------------------------------------------------------------------

- (void) initViewCaptureButtons
{
	[viewCaptureStartButton  setState:NSOffState];
	[viewCapturePauseButton  setState:NSOffState];
	[viewCaptureStopButton   setState:NSOffState];
	[viewCaptureCCButton     setState:NSOffState];
} // initViewCaptureButtons

//---------------------------------------------------------------------------

- (void) initViewAuthoringPanelAnimations
{
	viewAuthoringPanelFadeIn = [[ViewAnimation alloc] initViewAnimation:viewAuthoringQueuePanel
																 effect:NSViewAnimationFadeInEffect
															   duration:1.0
																  curve:NSAnimationEaseIn
																   mode:NSAnimationNonblockingThreaded];
	
	viewAuthoringPanelFadeOut = [[ViewAnimation alloc] initViewAnimation:viewAuthoringQueuePanel
																  effect:NSViewAnimationFadeOutEffect
																duration:1.5
																   curve:NSAnimationEaseIn
																	mode:NSAnimationNonblockingThreaded];
	
	viewAuthoringFinalizeFadeOut = [[ViewAnimation alloc] initViewAnimation:viewAuthoringFinalizePanel
																	 effect:NSViewAnimationFadeOutEffect
																   duration:1.5
																	  curve:NSAnimationEaseIn
																	   mode:NSAnimationNonblockingThreaded];
} // initViewAuthoringPanelAnimations

//---------------------------------------------------------------------------

- (void) awakeFromNib
{
	[self postNotifications];
	
	[self initImages];
	[self initLightPositions];
	[self initExhibitType];
	[self initViewCaptureButtons];
	[self initViewAuthoringPanelAnimations];
	
	viewCaptureIsAnimated = NO;
} // awakeFromNib

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Releasing Objects

//---------------------------------------------------------------------------

- (void) cleanUpExhibitsUIController
{
	if( viewCaptureButtonStateImages )
	{
		[viewCaptureButtonStateImages release];
		
		viewCaptureButtonStateImages = nil;
	} // if
	
	if( viewAuthoringPanelFadeIn )
	{
		[viewAuthoringPanelFadeIn release];
		
		viewAuthoringPanelFadeIn = nil;
	} // if
	
	if( viewAuthoringPanelFadeOut )
	{
		[viewAuthoringPanelFadeOut release];
		
		viewAuthoringPanelFadeOut = nil;
	} // if
	
	if( viewAuthoringFinalizeFadeOut )
	{
		[viewAuthoringFinalizeFadeOut release];
		
		viewAuthoringFinalizeFadeOut = nil;
	} // if
} // cleanUpExhibitsUIController

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Printing

//---------------------------------------------------------------------------

- (void) pageLayoutDidEnd:(NSPageLayout *)pageLayout
			   returnCode:(int)returnCode
			  contextInfo:(id)printInfo
{
    if( returnCode == NSOKButton )
	{
        [NSPrintInfo setSharedPrintInfo:printInfo];
    } // if
} // pageLayoutDidEnd

//---------------------------------------------------------------------------

- (IBAction) runPageLayout:(id)sender
{
	NSPageLayout  *pageLayout = [NSPageLayout pageLayout];
	NSPrintInfo   *printInfo  = [NSPrintInfo sharedPrintInfo];
	
	[pageLayout beginSheetWithPrintInfo:printInfo
						 modalForWindow:[plasmaExhibitsView window]
							   delegate:self
						 didEndSelector:@selector(pageLayoutDidEnd:returnCode:contextInfo:)
							contextInfo:printInfo];
} // runPageLayout

//---------------------------------------------------------------------------

- (IBAction) print:(id)sender
{
	NSRect imageFrame = [plasmaExhibitsView viewBounds];
	
	NSImageView *imageView = [[OpenGLImageView imageViewWithFrame:&imageFrame
																view:plasmaExhibitsView] imageView];
	
	if( imageView )
	{
		GLfloat  imageViewWidth  = imageFrame.size.width;
		GLfloat  imageViewHeight = imageFrame.size.height;
		
		// setup some reasonable state for GL printing. To get better output results,
		// fine tune this section of the code for better scaling.
		
		NSPrintInfo *printinfo = [NSPrintInfo sharedPrintInfo];
		
		if( printinfo )
		{
			[printinfo setHorizontalPagination:NSAutoPagination];
			[printinfo setVerticalPagination:NSAutoPagination];
			[printinfo setTopMargin:0.0f];
			[printinfo setBottomMargin:0.0f];
			[printinfo setRightMargin:7.0f];
			[printinfo setLeftMargin:7.0f];
			
			if( imageViewHeight < imageViewWidth )
			{
				[printinfo setOrientation:NSLandscapeOrientation];
			} // if
			else
			{
				[printinfo setOrientation:NSPortraitOrientation];
			} // else
			
			// print image view
			
			NSPrintOperation *printOperation = [NSPrintOperation printOperationWithView:imageView
																			  printInfo:printinfo];
			
			[printOperation	runOperationModalForWindow:[plasmaExhibitsView window]
											  delegate:nil
										didRunSelector:nil
										   contextInfo:nil];
		} // if
	} // if
} // print

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Text Field Actions

//---------------------------------------------------------------------------

- (IBAction) lightPosXTextFieldChanged:(id)sender
{
	int    uniformIntValue   = [sender intValue];
	float  uniformFloatValue = (float)uniformIntValue;
	
    [plasmaExhibitsView setUniformUsingControls:uniformFloatValue
							 coordinatePosition:kLightPosX];
	
	[lightPosXSlider setFloatValue:uniformFloatValue];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithFloat:uniformFloatValue]
									 forKey:@"Light X Position"];
} // lightPosXTextField

//---------------------------------------------------------------------------

- (IBAction) lightPosYTextFieldChanged:(id)sender
{
	int    uniformIntValue   = [sender intValue];
	float  uniformFloatValue = (float)uniformIntValue;
	
    [plasmaExhibitsView setUniformUsingControls:uniformFloatValue
							 coordinatePosition:kLightPosY];
	
	[lightPosYSlider setFloatValue:uniformFloatValue];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithFloat:uniformFloatValue]
									 forKey:@"Light Y Position"];
} // lightPosYTextField

//---------------------------------------------------------------------------

- (IBAction) lightPosZTextFieldChanged:(id)sender
{
	int    uniformIntValue   = [sender intValue];
	float  uniformFloatValue = (float)uniformIntValue;
	
    [plasmaExhibitsView setUniformUsingControls:uniformFloatValue
							 coordinatePosition:kLightPosZ];
	
	[lightPosZSlider setFloatValue:uniformFloatValue];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithFloat:uniformFloatValue]
									 forKey:@"Light Z Position"];
} // lightPosZTextField

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Slider Actions

//---------------------------------------------------------------------------

- (IBAction) lightPosXSliderChanged:(id)sender
{
	float uniformFloatValue = [sender floatValue];
	int   uniformIntValue   = (int)uniformFloatValue;
	
    [plasmaExhibitsView setUniformUsingControls:uniformFloatValue
							 coordinatePosition:kLightPosX];
	
	[lightPosXTextField setIntValue:uniformIntValue];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithFloat:uniformFloatValue]
									 forKey:@"Light X Position"];
} // lightPosXSliderChanged

//---------------------------------------------------------------------------

- (IBAction) lightPosYSliderChanged:(id)sender
{
	float uniformFloatValue = [sender floatValue];
	int   uniformIntValue   = (int)uniformFloatValue;
	
    [plasmaExhibitsView setUniformUsingControls:uniformFloatValue
							 coordinatePosition:kLightPosY];
	
	[lightPosYTextField setIntValue:uniformIntValue];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithFloat:uniformFloatValue]
									 forKey:@"Light Y Position"];
} // lightPosYSliderChanged

//---------------------------------------------------------------------------

- (IBAction) lightPosZSliderChanged:(id)sender
{
	float uniformFloatValue = [sender floatValue];
	int   uniformIntValue   = (int)uniformFloatValue;
	
    [plasmaExhibitsView setUniformUsingControls:uniformFloatValue
							 coordinatePosition:kLightPosZ];
	
	[lightPosZTextField setIntValue:uniformIntValue];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithFloat:uniformFloatValue]
									 forKey:@"Light Z Position"];
} // lightPosZSliderChanged

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Enable/Disable Rotation

//---------------------------------------------------------------------------
//
// Thes methods are called when the button is pressed
//
//---------------------------------------------------------------------------

- (IBAction) rotation:(id)sender
{
	NSUInteger rotate = [sender state];
	
	if( !rotate )
	{
		[plasmaExhibitsView rotationStop];
		
		[rotationButton setTitle:@"Start"];
	} // if
	else
	{
		[plasmaExhibitsView rotationStart];
		
		[rotationButton setTitle:@"Stop"];
	} // else
} // rotation

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Enable/Disable Fullscreen

//---------------------------------------------------------------------------

- (IBAction) enableFullScreen:(id)sender
{
	if( ![plasmaExhibitsView isInFullScreenMode] )
	{
		[plasmaExhibitsView fullScreenEnable];
	} // if
} // enableFullScreen

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark View Snapshot

//---------------------------------------------------------------------------

- (IBAction) viewSnapshot:(id)sender
{
	[plasmaExhibitsView viewSnapshot];
} // viewSnapshot

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark View Capture

//---------------------------------------------------------------------------

- (void) vieCaptureBegin
{
	if( !viewCaptureIsStarted )
	{
		[viewCaptureStartButton setImage:[viewCaptureButtonStateImages imageAtIndex:kImageRecordingButtonOn]];
		
		[plasmaExhibitsView viewCaptureStart];
		
		viewCaptureIsStarted = YES;
		viewCaptureIsStopped = NO;
	} // if
} // vieCaptureBegin

//---------------------------------------------------------------------------

- (void) viewCaptureEnd
{
	if( !viewCaptureIsStopped )
	{
		[plasmaExhibitsView viewCaptureStop];
	} // if
	
	[viewCaptureStopButton  setState:NSOffState];
	[viewCapturePauseButton setState:NSOffState];
	[viewCaptureStartButton setState:NSOffState];
	[viewCaptureCCButton    setState:NSOffState];
	
	[viewCaptureStartButton setImage:[viewCaptureButtonStateImages imageAtIndex:kImageRecordingButtonOff]];
	
	viewCaptureIsStarted = NO;
	viewCaptureIsStopped = YES;
} // viewCaptureEnd

//---------------------------------------------------------------------------

- (IBAction) viewCaptureStart:(id)sender
{
	[self vieCaptureBegin];
} // viewCaptureStart

//---------------------------------------------------------------------------

- (IBAction) viewCaptureStop:(id)sender
{
	[self viewCaptureEnd];
} // viewCaptureStop

//---------------------------------------------------------------------------

- (IBAction) viewCapturePause:(id)sender
{
	NSInteger state = [sender state];
	
	if( state == NSOnState )
	{
		[viewCaptureStopButton setState:NSOffState];
		
		[plasmaExhibitsView viewCapturePause];
	} // if
	else
	{
		if( !viewCaptureIsStopped )
		{
			[plasmaExhibitsView viewCapturePause];
		} // if
	} // if
} // viewCapturePause

//---------------------------------------------------------------------------

- (IBAction) viewCaptureCorrectColor:(id)sender
{
	NSInteger state = [sender state];
	
	if( state == NSOnState )
	{
		[plasmaExhibitsView viewCaptureEnableColorCorrection];
	} // if
	else
	{
		[plasmaExhibitsView viewCaptureDisableColorCorrection];
	} // else
} // viewCaptureCorrectColor

//---------------------------------------------------------------------------

- (IBAction) viewCapture:(id)sender
{
	NSInteger state = [sender state];
	
	if( state == NSOnState )
	{
		viewCaptureIsStarted = NO;
		viewCaptureIsStopped = NO;
		
		[viewCapturePanel makeKeyAndOrderFront:nil];
		[plasmaExhibitsView viewCaptureEnable];
	} // if
	else
	{
		[plasmaExhibitsView viewCaptureDisable];
		[viewCapturePanel close];
	} // else
} // viewCapture

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Select an Exhibit

//---------------------------------------------------------------------------
//
// This method is called when the user picks a different effect to
// receive messages using the pop-up menu
//
//---------------------------------------------------------------------------

- (IBAction) switchExhibits:(id)sender
{
	// sender is the NSPopUpMenu containing shader exhibits' choices.
	// We ask the sender which popup menu item is selected and add
	// one to compensate for counting from zero.
	
	NSInteger exhibitSelected = [sender indexOfSelectedItem] + 1;
	
	// Based on selected shader effect, we set the target to the
	// selected shader.
	
	[plasmaExhibitsView setExhibitItem:exhibitSelected];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithUnsignedInt:exhibitSelected]
									 forKey:@"Exhibit Type"];
} // switchExhibits

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Notifications

//---------------------------------------------------------------------------
//
// It's important to clean up our rendering objects before we terminate --
// Cocoa will not specifically release everything on application termination,
// so we explicitly call our clean up routine ourselves.
//
//---------------------------------------------------------------------------

- (void) plasmaExhibitsUIControllerWillTerminate:(NSNotification *)notification
{
	[self cleanUpExhibitsUIController];
} // plasmaExhibitsUIControllerWillTerminate

//---------------------------------------------------------------------------
//
// Once the window has been resized, and the view recording stopped, if
// the view recorder panel is still up, reset the pause and the record
// buttons.
//
//---------------------------------------------------------------------------

- (void) plasmaExhibitsAppWindowDidResize:(NSNotification *)notification
{
	[self viewCaptureEnd];
} // plasmaExhibitsAppWindowDidResize

//---------------------------------------------------------------------------
//
// Once you close the recording panel set the view recorder button in the
// main application window to off.
//
//---------------------------------------------------------------------------

- (void) plasmaExhibitsAppWindowWillClose:(NSNotification *)notification
{
	[viewCaptureButton  setState:NSOffState];
} // plasmaExhibitsAppWindowWillClose

//---------------------------------------------------------------------------
//
// The view capture may be suspended if the authoring queue reaches the
// preset limit.
//
//---------------------------------------------------------------------------

- (void) plasmaExibitsCaptureIsSuspended:(NSNotification *)notification
{
	NSInteger currentItem = [plasmaExhibitsView viewCaptureCount];
	
	if( currentItem > 1 )
	{
		NSInteger previousItem = currentItem;
		
		double currentValue  = (double)currentItem;
		double criticalValue = (2.0 * currentValue)/3.0;
		double warningValue  = currentValue/3.0;
		
		[viewAuthoringQueueLevel setMinValue:0.0];
		[viewAuthoringQueueLevel setMaxValue:currentValue];
		[viewAuthoringQueueLevel setCriticalValue:criticalValue];
		[viewAuthoringQueueLevel setWarningValue:warningValue];
		
		if( viewCaptureIsAnimated )
		{
			[viewAuthoringPanelFadeIn start];
			
			viewCaptureIsAnimated = [viewAuthoringPanelFadeIn isStarted];
		} // if
		else
		{
			[viewAuthoringQueuePanel makeKeyAndOrderFront:nil];
		} // else
		
		while( currentItem )
		{
			if( currentItem != previousItem )
			{
				[viewAuthoringQueueLevel setDoubleValue:(double)currentItem];
				[viewAuthoringQueueLevel display];
				
				previousItem = currentItem;
			} // if
			
			currentItem = [plasmaExhibitsView viewCaptureCount];
		} // while
		
		[viewAuthoringQueueLevel setDoubleValue:0.0];
		[viewAuthoringQueueLevel display];
	} // if
} // plasmaExibitsCaptureIsSuspended

//---------------------------------------------------------------------------

- (void) plasmaExibitsCaptureIsResumed:(NSNotification *)notification
{
	[viewAuthoringPanelFadeOut start];
	
	viewCaptureIsAnimated = [viewAuthoringPanelFadeOut isStarted];
} // plasmaExibitsCaptureIsResumed

//---------------------------------------------------------------------------

- (void) plasmaExibitsCaptureIsFinalized:(NSNotification *)notification
{
	NSInteger maxItems = [plasmaExhibitsView viewCaptureCount];
	
	if( maxItems > 5 )
	{
		NSInteger  currentItem   = maxItems;
		double     maxValue      = (double)(maxItems-1);
		double     currentValue  = 0.0;
		double     previousValue = currentValue;
		
		[viewAuthoringFinalizeProgress setMinValue:0.0];
		[viewAuthoringFinalizeProgress setMaxValue:maxValue];
		
		[viewAuthoringFinalizePanel makeKeyAndOrderFront:nil];
		
		while( currentItem )
		{
			currentValue = (double)(maxItems - currentItem);
			
			if( currentValue != previousValue )
			{
				[viewAuthoringFinalizeProgress setDoubleValue:(double)currentValue];
				[viewAuthoringFinalizeProgress display];
				
				previousValue = currentValue;
			} // if
			
			currentItem = [plasmaExhibitsView viewCaptureCount];
		} // while
		
		[viewAuthoringFinalizeProgress setDoubleValue:currentValue];
		[viewAuthoringFinalizeProgress display];
		
		[viewAuthoringFinalizeFadeOut start];
	} // if
} // plasmaExibitsCaptureIsFinalized

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
