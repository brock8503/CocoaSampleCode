/*
     File: ImageBrowserBackgroundLayer.m
 Abstract: 
 Abstract:	IKImageBrowserView is a view that can display and browse a
 large amount of images and movies. This sample code demonstrates
 how to use the view in a Cocoa Application.
 
  Version: 1.1
 
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


#import "ImageBrowserBackgroundLayer.h"

@implementation ImageBrowserBackgroundLayer

@synthesize owner;

// -------------------------------------------------------------------------
//	init
// -------------------------------------------------------------------------
- (id) init
{
	if((self = [super init])){
		//needs to redraw when bounds change
		[self setNeedsDisplayOnBoundsChange:YES];
	}
	
	return self;
}

// -------------------------------------------------------------------------
//	actionForKey:
//
// always return nil, to never animate
// -------------------------------------------------------------------------
- (id<CAAction>)actionForKey:(NSString *)event
{
	return nil;
}

// -------------------------------------------------------------------------
//	drawInContext:
//
// draw a metal background that scrolls when the image browser scroll
// -------------------------------------------------------------------------
- (void)drawInContext:(CGContextRef)context
{
	//retreive bounds and visible rect
	NSRect visibleRect = [owner visibleRect];
	NSRect bounds = [owner bounds];
	
	//retreive background image
    CGImageRef image = NULL;
    NSString *path = [[NSBundle mainBundle] pathForResource:[@"metal_background.tif" stringByDeletingPathExtension] ofType:[@"metal_background.tif" pathExtension]];
    if (!path) {
        return;
    }

    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], NULL);
    if (!imageSource) {
        return;
    }
        
    image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    if (!image) {
        CFRelease(imageSource);
        return;
    }

	float width = (float) CGImageGetWidth(image);
	float height = (float) CGImageGetHeight(image);
	
	//compute coordinates to fill the view
	float left, top, right, bottom;
	
	top = bounds.size.height - NSMaxY(visibleRect);
	top = fmod(top, height);
	top = height - top;
	
	right = NSMaxX(visibleRect);
	bottom = -height;
	
	// tile the image and take in account the offset to 'emulate' a scrolling background
	for (top = visibleRect.size.height-top; top>bottom; top -= height){
		for(left=0; left<right; left+=width){
			CGContextDrawImage(context, CGRectMake(left, top, width, height), image);
		}
	}
    
    CFRelease(imageSource);
    CFRelease(image);
}

@end
