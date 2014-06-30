/*
     File: AttachmentView.m
 Abstract: Custom view holding the image to attach to our document.
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

#import "AttachmentView.h"
#import "MyWindowController.h"

@interface AttachmentView ()
@property BOOL highlightForDragAcceptence;
@end

@implementation AttachmentView

- (void)commonInit
{
    // register for all the image types we can display -- include NSFilenamesPboardType for Finder drags.
    NSMutableArray *dragTypes = [[NSImage imagePasteboardTypes] mutableCopy];
    [dragTypes addObject:NSFilenamesPboardType];
    [self registerForDraggedTypes:dragTypes];
    
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    
    self.highlightForDragAcceptence = NO;
}

- (id)initWithCoder:(NSCoder *)coder
{
    // init method called for Interface Builder objects
    self = [super initWithCoder:coder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];

    // draw the focus frame if necessary
    if (self.highlightForDragAcceptence)
    {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [[NSBezierPath bezierPathWithRect: NSInsetRect(self.bounds,3,3)] fill];
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (void)dealloc
{
    [self unregisterDraggedTypes];
    // since we are using ARC no need to call super
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationCopy & [sender draggingSourceOperationMask]) == NSDragOperationCopy)
    {
        self.highlightForDragAcceptence = YES;
        [self setNeedsDisplay:YES];
        
        // the sender is offering the type of operation we want,
        // return that we want the NSDragOperationCopy (cursor has a + image)
        //
        return NSDragOperationCopy;
    }
    else
    {
        // we aren't interested in this drag
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    // user has left our drag area, erase our focus frame
    self.highlightForDragAcceptence = NO;
    [self setNeedsDisplay:YES];
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationCopy & [sender draggingSourceOperationMask]) == NSDragOperationCopy)
    {
        // the sender is offering the type of operation we want,
        // return that we want the NSDragOperationCopy (cursor has a + image)
        //
        return NSDragOperationCopy;
    }
    else
    {
        // we aren't interested in this drag
        return NSDragOperationNone;
    }
}

- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
    //..
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *paste = [sender draggingPasteboard];
    
    // gets the dragging-specific pasteboard from the sender
    NSArray *types = [NSArray arrayWithObjects:NSTIFFPboardType, NSFilenamesPboardType, nil];
    
    // a list of types that we can accept
    NSString *desiredType = [paste availableTypeFromArray:types];
    NSData *carriedData = [paste dataForType:desiredType];
    
    if (carriedData == nil)
    {
        // the drag operation failed
        return NO;
    }
    else
    {
        // the pasteboard was able to give us some meaningful data
        if ([desiredType isEqualToString:NSTIFFPboardType])
        {
            // We have TIFF bitmap data in the NSData object.
            // Keep a reference to the image for drawing
            self.image = [[NSImage alloc] initWithData:carriedData];
            
        }
        else if ([desiredType isEqualToString:NSFilenamesPboardType])
        {
            // we have a list of file names in an NSData object
            NSArray *fileArray = [paste propertyListForType:@"NSFilenamesPboardType"];

            NSString *path = [fileArray objectAtIndex:0];
            
            // assume that we can ignore all but the first path in the list
            NSImage *newImage = [[NSImage alloc] initWithContentsOfFile:path];
            if (newImage == nil)
            {
                // failed to open the file
                return NO;
            }
            else
            {
                // Keep a reference to the image for drawing
                self.image = newImage;
                
                // tell our window controller that a new image was dragged in by the user
                MyWindowController *windowController = (MyWindowController *)[[self window] windowController];
                [windowController updateImage:newImage];
            }
        }
        else
        {
            return NO;
        }
    }
    
    // erase the drag acceptance highlight, and draws the new image
    self.highlightForDragAcceptence = NO;
    [self setNeedsDisplay:YES];

    return YES;
}

@end
