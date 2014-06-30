/*
     File: MyWindowController.m 
 Abstract: main NSWindowController 
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
  
 Copyright (C) 2014 Apple Inc. All Rights Reserved. 
  
 */

#import "MyWindowController.h"
#import "CustomImageViewController.h"
#import "CustomTableViewController.h"
#import "CustomVideoViewController.h"

@implementation MyWindowController

enum // popup tag choices
{
	kImageView = 0,
	kTableView,
	kVideoView,
	kCameraView
};

NSString *const kViewTitle		= @"CustomImageView";
NSString *const kTableTitle		= @"CustomTableView";
NSString *const kVideoTitle		= @"CustomVideoView";
NSString *const kCameraTitle	= @"CustomCameraView";

@synthesize myCurrentViewController;

// -------------------------------------------------------------------------------
//	awakeFromNib
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
	// start by displaying the CustomImageViewController
    [self changeViewController:kImageView];
}

- (void)videoReady:(NSNotification *)notif
{
    // we have been notified by CustomVideoViewController that the video is ready to play
    [self.videoViewController start:YES];
}

// -------------------------------------------------------------------------------
//	changeViewController:whichViewTag
//
//	Change the current NSViewController to a new one based on a tag obtained from
//	the NSPopupButton control.
// -------------------------------------------------------------------------------
- (void)changeViewController:(NSInteger)whichViewTag
{
	// we are about to change the current view controller,
	// this prepares our title's valuer binding to change with it
    //
	[self willChangeValueForKey:@"viewController"];
	
	if ([self.myCurrentViewController view] != nil)
    {
		[[self.myCurrentViewController view] removeFromSuperview];	// remove the current view
        
        if ([self.myCurrentViewController isKindOfClass:[CustomVideoViewController class]])
        {
            // stop playing the video
            [(CustomVideoViewController *)self.myCurrentViewController start:NO];
            
            // no longer interested in this notification
            [[NSNotificationCenter defaultCenter] removeObserver:self name:kVideoReadyNotification object:nil];
        }
    }

	switch (whichViewTag)
	{
		case kImageView:	// swap in the "CustomImageViewController - NSImageView"
		{
			if (self.imageViewController == nil)
            {
                _imageViewController = [[CustomImageViewController alloc] initWithNibName:kViewTitle bundle:nil];
            }
            myCurrentViewController = self.imageViewController;	// keep track of the current view controller
            [self.myCurrentViewController setTitle:kViewTitle];
            
			break;
		}
		
		case kTableView:	// swap in the "CustomTableViewController - NSTableView"
		{
			if (self.tableViewController == nil)
            {
                _tableViewController = [[CustomTableViewController alloc] initWithNibName:kTableTitle bundle:nil];
            }
            myCurrentViewController = self.tableViewController;	// keep track of the current view controller
            [self.myCurrentViewController setTitle:kTableTitle];
			break;
		}
		
		case kVideoView:	// swap in the "CustomVideoViewController - QTMovieView"
		{
			if (self.videoViewController == nil)
            {
                _videoViewController = [[CustomVideoViewController alloc] initWithNibName:kVideoTitle bundle:nil];
            }
			
            // listen for when the video is ready to play (used for initial loading)
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(videoReady:)
                                                         name:kVideoReadyNotification
                                                       object:nil];
            
			myCurrentViewController = self.videoViewController;	// keep track of the current view controller
            [self.myCurrentViewController setTitle:kVideoTitle];
            
            // check if the video is loaded and ready
            if (self.videoViewController.videoIsReady)
            {
                [self.videoViewController start:YES];
            }
			break;
		}
		
		case kCameraView:	// swap in the "NSViewController - Quartz Composer iSight Camera"
		{
			if (self.cameraViewController == nil)
            {
                _cameraViewController = [[NSViewController alloc] initWithNibName:kCameraTitle bundle:nil];
            }
	
            myCurrentViewController = self.cameraViewController;	// keep track of the current view controller
            [self.myCurrentViewController setTitle:kCameraTitle];
			break;
		}
	}
	
	// embed the current view to our host view
	[myTargetView addSubview:[self.myCurrentViewController view]];
	
	// make sure we automatically resize the controller's view to the current window size
	[[self.myCurrentViewController view] setFrame:[myTargetView bounds]];
	
	// set the view controller's represented object to the number of subviews in that controller
	// (our NSTextField's value binding will reflect this value)
	[self.myCurrentViewController setRepresentedObject:[NSNumber numberWithUnsignedInteger:[[[self.myCurrentViewController view] subviews] count]]];
	
	[self didChangeValueForKey:@"viewController"];	// this will trigger the NSTextField's value binding to change
}

// -------------------------------------------------------------------------------
//	viewChoicePopupAction:sender
// -------------------------------------------------------------------------------
- (IBAction)viewChoicePopupAction:(id)sender
{
	[self changeViewController:[[sender selectedCell] tag]];
}

// -------------------------------------------------------------------------------
//	viewController
// -------------------------------------------------------------------------------
- (NSViewController *)viewController
{
	return self.myCurrentViewController;
}

// -------------------------------------------------------------------------------
//	dealloc
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [_videoViewController release];
    [_tableViewController release];
    [_cameraViewController release];
    [_imageViewController release];
    
    [super dealloc];
}

@end
