/*
     File: FileViewController.m 
 Abstract: Controller object for our file view.
  
  Version: 1.5 
  
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

#import "FileViewController.h"

@interface FileViewController ()

@property (nonatomic, strong) IBOutlet NSImageView *fileIcon;
@property (nonatomic, strong) IBOutlet NSTextField *fileName;
@property (nonatomic, strong) IBOutlet NSTextField *fileSize;
@property (nonatomic, strong) IBOutlet NSTextField *modDate;
@property (nonatomic, strong) IBOutlet NSTextField *creationDate;
@property (nonatomic, strong) IBOutlet NSTextField *fileKindString;

@end

#pragma mark -

@implementation FileViewController

// -------------------------------------------------------------------------------
//	awakeFromNib
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
	// listen for changes in the url for this view
	[self addObserver:	self
						forKeyPath:@"url"
						options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) 
						context:NULL];
}

// -------------------------------------------------------------------------------
//	dealloc
// -------------------------------------------------------------------------------
- (void)dealloc
{
	[self removeObserver:self forKeyPath:@"url"];
}

// -------------------------------------------------------------------------------
//	observeValueForKeyPath:ofObject:change:context
//
//	Listen for changes in the file url.
// -------------------------------------------------------------------------------
- (void)observeValueForKeyPath:	(NSString *)keyPath
								ofObject:(id)object 
								change:(NSDictionary *)change 
								context:(void *)context
{
	// name
	[self.fileName setStringValue:[[NSFileManager defaultManager] displayNameAtPath:[self.url path]]];
	
	// icon
	NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFile:[self.url path]];
	[iconImage setSize:NSMakeSize(64,64)];
	[self.fileIcon setImage:iconImage];
	
	NSDictionary *attr = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.url path] error:nil];
	if (attr)
	{
		// file size
		NSNumber *theFileSize = [attr objectForKey:NSFileSize];
        [self.fileSize setStringValue:[NSString stringWithFormat:@"%@ KB on disk", [theFileSize stringValue]]];
		
		// creation date
		NSDate *fileCreationDate = [attr objectForKey:NSFileCreationDate];
        [self.creationDate setStringValue:[fileCreationDate description]];
				
		// mod date
		NSDate *fileModDate = [attr objectForKey:NSFileModificationDate];
        [self.modDate setStringValue:[fileModDate description]];	
	}

	// kind string
	CFStringRef kindStr = nil;
	LSCopyKindStringForURL((__bridge CFURLRef)self.url, &kindStr);
	if (kindStr !=  nil)
	{
		[self.fileKindString setStringValue:(__bridge NSString *)kindStr];
		CFRelease(kindStr);
	}
}

@end
