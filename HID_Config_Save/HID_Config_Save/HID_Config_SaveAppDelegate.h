//     File: HID_Config_SaveAppDelegate.h
// Abstract: Header file for HID_Config_SaveAppDelegate class of HID_Config_Save project
//  Version: 5.3
// 
// Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
// Inc. ("Apple") in consideration of your agreement to the following
// terms, and your use, installation, modification or redistribution of
// this Apple software constitutes acceptance of these terms.  If you do
// not agree with these terms, please do not use, install, modify or
// redistribute this Apple software.
// 
// In consideration of your agreement to abide by the following terms, and
// subject to these terms, Apple grants you a personal, non-exclusive
// license, under Apple's copyrights in this original Apple software (the
// "Apple Software"), to use, reproduce, modify and redistribute the Apple
// Software, with or without modifications, in source and/or binary forms;
// provided that if you redistribute the Apple Software in its entirety and
// without modifications, you must retain this notice and the following
// text and disclaimers in all such redistributions of the Apple Software.
// Neither the name, trademarks, service marks or logos of Apple Inc. may
// be used to endorse or promote products derived from the Apple Software
// without specific prior written permission from Apple.  Except as
// expressly stated in this notice, no other rights or licenses, express or
// implied, are granted by Apple herein, including but not limited to any
// patent rights that may be infringed by your derivative works or by other
// works in which the Apple Software may be incorporated.
// 
// The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
// MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
// THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
// OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
// 
// IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
// OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
// MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
// AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
// STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
// 
// Copyright (C) 2014 Apple Inc. All Rights Reserved.
// 
#import <Cocoa/Cocoa.h>

#include "HID_Utilities_External.h"

// ****************************************************
#pragma mark -
#pragma mark * typedef's, struct's, enums, defines, etc. *
// ----------------------------------------------------
#ifndef TRUE
#define FALSE                   0
#define TRUE                    !FALSE
#endif  // ifndef TRUE

#define USE_INPUT_VALUE_CALLBACK            TRUE    // set true to use IOHIDDeviceRegisterInputValueCallback
#define USE_QUEUE_VALUE_AVAILABLE_CALLBACK  TRUE    // set true to use IOHIDQueueRegisterValueAvailableCallback
// (USE_QUEUE_VALUE_AVAILABLE_CALLBACK overrides USE_INPUT_VALUE_CALLBACK)
// if both of the above are false then a timer is used to poll for element values (via IOHIDDeviceGetValue)

typedef struct action_struct {
	IOHIDDeviceRef fDeviceRef;
	IOHIDElementRef fElementRef;
	double fValue;
} action_rec,
*action_ptr;

enum {kActionXAxis,
	  kActionYAxis,
	  kActionThrust,
	  kActionFire};
#define kNumActions 4

// ****************************************************
#pragma mark -
#pragma mark * interfaces *
// ----------------------------------------------------

@class PlayView;

@interface HID_Config_SaveAppDelegate : NSObject <NSApplicationDelegate,
	                                              NSTabViewDelegate> {
	IBOutlet NSWindow *__strong window;
	IBOutlet NSTabView *__weak tabView;

	IBOutlet NSTextField *__weak xAxisTextField;
	IBOutlet NSTextField *__weak yAxisTextField;
	IBOutlet NSTextField *__weak thrustTextField;
	IBOutlet NSTextField *__weak fireTextField;

	IBOutlet PlayView *__weak playView;

#if USE_QUEUE_VALUE_AVAILABLE_CALLBACK
	CFMutableArrayRef ioHIDQueueRefsCFArrayRef;
#elif USE_INPUT_VALUE_CALLBACK
#else // if USE_QUEUE_VALUE_AVAILABLE_CALLBACK
	NSTimer *timer;
#endif  // USE_QUEUE_VALUE_AVAILABLE_CALLBACK
	action_rec actionRecs[4];
}

- (IBAction) configureXAxis:(id)sender;
- (IBAction) configureYAxis:(id)sender;
- (IBAction) configureThrust:(id)sender;
- (IBAction) configureFire:(id)sender;

- (IBAction) saveConfiguration:(id)sender;
- (IBAction) restoreConfiguration:(id)sender;

- (IBAction) rebuild:(id)sender;
- (IBAction) test:(id)sender;
- (IBAction) poll:(id)sender;
- (IBAction) ping:(id)sender;

@property (strong) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTabView *tabView;

@property (weak) IBOutlet NSTextField *xAxisTextField;
@property (weak) IBOutlet NSTextField *yAxisTextField;
@property (weak) IBOutlet NSTextField *thrustTextField;
@property (weak) IBOutlet NSTextField *fireTextField;

@property (weak) IBOutlet PlayView *playView;

@end
