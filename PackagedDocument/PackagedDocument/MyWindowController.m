/*
     File: MyWindowController.m
 Abstract: NSWindowController controlling the behavior of our primary document window.
 It is the subclass for managing the "TextPictDocument" class
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

#import "MyWindowController.h"
#import "MyTextPictDocument.h"
#import "AttachmentView.h"

NSString *kClipImageName = @"clip";

@interface MyWindowController ()

@property (assign) NSInteger discloseDelta;

@property (readwrite, unsafe_unretained) IBOutlet NSTextView *textView;
@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSTextField *imageViewLabel;
@property (weak) IBOutlet AttachmentView *attachmentView;
@property (weak) IBOutlet NSImageView *attachedImageView;
@property (weak) IBOutlet NSButton *disclosureButton;

@end

@implementation MyWindowController

// -------------------------------------------------------------------------------
//  init
//
//  Called when MyTextPictDocument wants to create us (via addWindowController).
// -------------------------------------------------------------------------------
- (id)init
{
    return [super initWithWindowNibName:@"TextPictWindow"];
}

// -------------------------------------------------------------------------------
//  windowDidLoad
//
//  This is invoked immediately before and after this controller loads its nib.
//  Use this method to handle any initialization after your window controller's window has
//  been loaded from its nib file.
// -------------------------------------------------------------------------------
- (void)windowDidLoad
{
    [super windowDidLoad];
    
	NSWindow *theWindow = [self window];
	[theWindow makeKeyAndOrderFront:nil];
	[theWindow makeFirstResponder:self.textView];
    
    [self.textView setAllowsUndo:YES];
    
    MyTextPictDocument *document = (MyTextPictDocument *)[self document];
    
	// ask our document to update our text view and image view with it's model
    [document updateTextView:self.textView];
    [document updateImageView:self.imageView];
    
    // if we have an image, update our clip image indicator
    if ([document image] != nil)
    {
        [self.attachedImageView setImage:[NSImage imageNamed:kClipImageName]];
    }
    
    // hide the image label if we have an image
    [self.imageViewLabel setHidden:([document image] != nil)];
    
    // the entire attachment view determines the drag operation,
    // we don't want these image views to accept drags:
    [self.imageView unregisterDraggedTypes];
    [self.attachedImageView unregisterDraggedTypes];
}

// -------------------------------------------------------------------------------
//  imageDidChange:sender
//
//  User dragged an image to the imageView.
// -------------------------------------------------------------------------------
- (IBAction)imageDidChange:(id)sender
{
    // draw the paper clip image if we received a valid image
    [self.attachedImageView setImage:([self.imageView image] != nil) ? [NSImage imageNamed:kClipImageName] : nil];

    [(MyTextPictDocument *)[self document] updateImageModel:[self.imageView image]];
    
    // hide the image label if we have an image
    MyTextPictDocument *document = (MyTextPictDocument *)[self document];
    [self.imageViewLabel setHidden:([document image] != nil)];
}

// -------------------------------------------------------------------------------
//  textDidChange:aNotification
// -------------------------------------------------------------------------------
- (void)textDidChange:(NSNotification *)aNotification
{
    NSString *str = [[self.textView textStorage] string];
    [(MyTextPictDocument *)[self document] updateTextModel:str];
}

// -------------------------------------------------------------------------------
//  disclose
// -------------------------------------------------------------------------------
- (void)disclose
{
    // compute the resize delta
    NSRect scrollViewRect = [[self.textView enclosingScrollView] frame];
    NSRect textViewRect = [self.textView frame];
    NSInteger newDelta = [self.disclosureButton state] ? -self.discloseDelta : self.discloseDelta;
    scrollViewRect.size.height = scrollViewRect.size.height + newDelta;
    textViewRect.size.height = scrollViewRect.size.height + newDelta;
    
    // resize the attachment frame
    NSRect attachmentViewRect = [self.attachmentView frame];
    NSRect contentFrame = [[[self window] contentView] frame];
    NSInteger delta = contentFrame.size.height - scrollViewRect.size.height;
    attachmentViewRect.size.height = delta;
    attachmentViewRect.origin.y = scrollViewRect.size.height;
    [self.attachmentView setFrame:attachmentViewRect];
    
    // hide the image and its label
    [self.imageView setHidden:![self.disclosureButton state]];
    
    // animate both textView and it's enclosing scroll view frames to their new values
    NSMutableArray *animationList = [NSMutableArray array];
    
    [animationList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                [self.textView enclosingScrollView], NSViewAnimationTargetKey,
                                [NSValue valueWithRect:scrollViewRect], NSViewAnimationEndFrameKey,
                              nil]];
    [animationList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                self.textView, NSViewAnimationTargetKey,
                                [NSValue valueWithRect:textViewRect], NSViewAnimationEndFrameKey,
                              nil]];
    
    // execute the animation
    NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:animationList];
    [animation setAnimationBlockingMode:NSAnimationBlocking];
    [animation setDuration:0.25];
    [animation startAnimation];
    
    // call our delegate notifying the attachment view was disclosed
    if ((self.delegate != nil) && [self.delegate respondsToSelector:@selector(windowController:didDiscloseImage:)])
    {
        [self.delegate windowController:self didDiscloseImage:[self.disclosureButton state]];
    }
}

// -------------------------------------------------------------------------------
//  loadWindow
//
//  Used for setting up window state (disclosure), after the window has loaded
//  and it's paired NSDocument has already read its content.
// -------------------------------------------------------------------------------
- (void)loadWindow
{
    [super loadWindow];
    
    // compute the amount to disclose/hide when the disclosure control is clicked
    _discloseDelta = self.attachmentView.frame.size.height -
        (self.attachmentView.frame.size.height - [self.disclosureButton frame].origin.y) - 8;
    
    if (![self.disclosureButton state] == self.disclosed)
    {
        // disclose the attachment view only if our disclosure button is out of sync
        [self.disclosureButton setState:self.disclosed];
        [self disclose];
    }
}

// -------------------------------------------------------------------------------
//  discloseAction:sender
//
//  User clicked the disclosure control to expand/shrink the attachment view.
// -------------------------------------------------------------------------------
- (IBAction)discloseAction:(id)sender
{
    [self performSelector:@selector(disclose) withObject:nil afterDelay:0.05];
}

// -------------------------------------------------------------------------------
//  updateImage:image
//
//  Someone wants to set our image attachment.
// -------------------------------------------------------------------------------
- (void)updateImage:(NSImage *)image
{
    [self.imageView setImage:image];
    [self.imageViewLabel setHidden:YES];
    [self imageDidChange:self];
}


#pragma mark - Version browser support

// -------------------------------------------------------------------------------
//  windowWillEnterVersionBrowser
//
//  Use this method to customize this window for the versions browser.
// -------------------------------------------------------------------------------
- (void)windowWillEnterVersionBrowser:(NSNotification *)notification
{ }

// -------------------------------------------------------------------------------
//  windowDidExitVersionBrowser
//
//  Use this method to undo the customization of this window
//  (done in windowWillEnterVersionBrowser).
// -------------------------------------------------------------------------------
- (void)windowDidExitVersionBrowser:(NSNotification *)notification
{ }

// -------------------------------------------------------------------------------
//  willResizeForVersionBrowserWithMaxPreferredSize:maxPreferredFrameSize:maxAllowedFrameSize
//
//  Help determine the optimal size for the version browser.
//  Windows entering the version browser will be resized to the size returned by this method.
// -------------------------------------------------------------------------------
- (NSSize)window:(NSWindow *)window willResizeForVersionBrowserWithMaxPreferredSize:(NSSize)maxPreferredFrameSize maxAllowedSize:(NSSize)maxAllowedFrameSize
{
    NSSize contentSize = [[[self.textView enclosingScrollView] documentView] bounds].size;
    contentSize = [[[self.textView enclosingScrollView] documentView] convertSize:contentSize toView:[self.textView enclosingScrollView]];
    
    Class horizScrollerClass = [[[self.textView enclosingScrollView] horizontalScroller] class];
    Class vertScrollerClass = [[[self.textView enclosingScrollView] verticalScroller] class];
    
    NSSize windowContentSize = [NSScrollView frameSizeForContentSize:contentSize
                                             horizontalScrollerClass:horizScrollerClass
                                               verticalScrollerClass:vertScrollerClass
                                                          borderType:[[self.textView enclosingScrollView] borderType]
                                                         controlSize:NSRegularControlSize
                                                       scrollerStyle:NSScrollerStyleLegacy]; 
    NSRect frameRect = [window frameRectForContentRect:(NSRect){ NSZeroPoint, windowContentSize }];
    return frameRect.size;
}

@end
