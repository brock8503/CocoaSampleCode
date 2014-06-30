
/*
     File: APLAppDelegate.m 
 Abstract: The application delegate. This object also manages the main window.
  
  Version: 2.2 
  
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

#import "APLAppDelegate.h"


@interface APLAppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NSPathControl *pathControl;
@property (weak) IBOutlet NSTextField *explanationText;
@property (weak) IBOutlet NSButton *pathSetButton;

@property BOOL useCustomPath;	// Value is bound to the check box in the xib.

@end



@implementation APLAppDelegate


- (void)awakeFromNib
{
    /*
     Configure the double action for the path control. (There's no need to set the target because it's already set for the single-click action in the nib file.)
     */
    [self.pathControl setDoubleAction:@selector(pathControlDoubleClick:)];

    // Clear the explanation text.
    [self.explanationText setStringValue:@""];
}


- (IBAction)showPathOpenPanel:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setResolvesAliases:YES];

    NSString *panelTitle = NSLocalizedString(@"Choose a file", @"Title for the open panel");
    [panel setTitle:panelTitle];

    NSString *promptString = NSLocalizedString(@"Choose", @"Prompt for the open panel prompt");
    [panel setPrompt:promptString];
    
    APLAppDelegate * __weak weakSelf = self;
    
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result){
        
        // Hide the open panel.
        [panel orderOut:self];
        
        // If the return code wasn't OK, don't do anything.
        if (result != NSOKButton) {
            return;
        }
        // Get the first URL returned from the Open Panel and set it at the first path component of the control.
        NSURL *url = [[panel URLs] objectAtIndex:0];
        [weakSelf.pathControl setURL:url];

        // Update the explanation text to show the user how they can reveal the path component.
        [weakSelf updateExplainText];
    }];
}

/*
 Update the path control and explanation text based on the path style selected in the radio button matrix.
 */
- (IBAction)takeStyleFrom:(NSMatrix *)sender
{
    NSInteger tag = [[sender selectedCell] tag];
    [self.pathControl setPathStyle:tag];
    
    [self updateExplainText];
}


- (IBAction)pathControlSingleClick:(id)sender
{
    // Select that chosen component of the path.
	[self.pathControl setURL:[[self.pathControl clickedPathComponentCell] URL]];
}


/*
 This method is the "double-click" action for the control. Because we are using a standard style or navigation style control we ask for the  path component that was clicked.
 */
- (void)pathControlDoubleClick:(id)sender
{
    if ([self.pathControl clickedPathComponentCell] != nil) {

        [[NSWorkspace sharedWorkspace] openURL:[self.pathControl URL]];
    }
}

/*
 The action method from the custom menu item, "Reveal in Finder". Because we are a popup, we ask for the control's URL (not one of the path components).
*/
- (void)menuItemAction:(id)sender
{
    NSURL *URL = [[self.pathControl clickedPathComponentCell] URL];
    NSArray *URLArray = [NSArray arrayWithObject:URL];
    [[NSWorkspace sharedWorkspace] openURLs:URLArray withAppBundleIdentifier:@"com.apple.Finder" options:NSWorkspaceLaunchWithoutActivation additionalEventParamDescriptor:nil launchIdentifiers:NULL];
}


#pragma mark - NSPathControl delegate methods

/*
 Delegate method of NSPathControl to determine how the NSOpenPanel will look/behave.
 */
- (void)pathControl:(NSPathControl *)pathControl willDisplayOpenPanel:(NSOpenPanel *)openPanel
{
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseDirectories:YES];
    [openPanel setCanChooseFiles:YES];
    [openPanel setResolvesAliases:YES];
    [openPanel setTitle:NSLocalizedString(@"Choose a file", @"Open panel title")];
    [openPanel setPrompt:NSLocalizedString(@"Choose", @"Open panel prompt for 'Choose a file'")];
}


/*
 Delegate method on NSPathControl (as NSPathStylePopUp) that determines what popup menu will look like.  In our case we add "Reveal in Finder".
 */
- (void)pathControl:(NSPathControl *)pathControl willPopUpMenu:(NSMenu *)menu
{
    if (self.useCustomPath)
    {
        // Because we have a custom path, remove the "Choose..." and separator menu items.
        [menu removeItemAtIndex:0];
        [menu removeItemAtIndex:0];
    }
    else
    {
        // For file system paths, add the "Reveal in Finder" menu item.
        NSString *title = NSLocalizedString(@"Reveal in Finder", @"Used in dynamic popup menu");

        NSMenuItem *newItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(menuItemAction:) keyEquivalent:@""];
        [newItem setTarget:self];
        
        [menu addItem:[NSMenuItem separatorItem]];
        [menu addItem:newItem];
    }
}

#pragma mark - Custom path support

/*
 Shows how to create a custom generated path for NSPathControl.
 */
- (IBAction)toggleUseCustomPath:(id)sender
{
    if (self.useCustomPath)
    {
        // User checked the "Custom Path" checkbox: create an array of custom cells and pass to the path control.
        NSArray * pathComponentArray = [self pathComponentArray];
        [self.pathControl setPathComponentCells:pathComponentArray];
    }
    else
    {
        // User unchecked the "Custom Path" checkbox: remove the custom path items (if any) by setting an empty array.
        NSArray *emptyArray = [[NSMutableArray alloc] init];
        [self.pathControl setPathComponentCells:emptyArray];
    }

    // Update the user interface.
    [self.pathSetButton setEnabled:!self.useCustomPath];
    [self updateExplainText]; // Update the explanation text to show the user how they can reveal the path component.
}


/*
 Assemble a set of custom cells to display into an array to pass to the path control.
 */
- (NSArray *)pathComponentArray
{
    NSMutableArray *pathComponentArray = [[NSMutableArray alloc] init];

    NSURL *URL;
    NSPathComponentCell *componentCell;
    
    // Use utility method to obtain a NSPathComponentCell based on icon, title and URL.
    URL = [NSURL URLWithString:@"http://www.apple.com"];
    componentCell = [self componentCellForType:kAppleLogoIcon withTitle:@"Apple" URL:URL];
    [pathComponentArray addObject:componentCell];

    URL = [NSURL URLWithString:@"http://www.apple.com/macosx/"];
    componentCell = [self componentCellForType:kInternetLocationNewsIcon withTitle:@"OS X" URL:URL];
    [pathComponentArray addObject:componentCell];

    URL = [NSURL URLWithString:@"http://developer.apple.com/macosx/"];
    componentCell = [self componentCellForType:kGenericURLIcon withTitle:@"Developer" URL:URL];
    [pathComponentArray addObject:componentCell];

    URL = [NSURL URLWithString:@"http://developer.apple.com/cocoa/"];
    componentCell = [self componentCellForType:kHelpIcon withTitle:@"Cocoa" URL:URL];
    [pathComponentArray addObject:componentCell];

    return pathComponentArray;
}


/*
 This method is used by pathComponentArray to create a NSPathComponent cell based on icon, title and URL information. Each path component needs an icon, URL and title.
 */
- (NSPathComponentCell *)componentCellForType:(OSType)withIconType withTitle:(NSString *)title URL:(NSURL *)url
{
    NSPathComponentCell *componentCell = [[NSPathComponentCell alloc] init];

    NSImage *iconImage = [[NSWorkspace sharedWorkspace] iconForFileType:NSFileTypeForHFSTypeCode(withIconType)];
    [componentCell setImage:iconImage];
    [componentCell setURL:url];
    [componentCell setTitle:title];

    return componentCell;
}


#pragma mark - Drag and drop

/*
 This method is called when an item is dragged over the control. Return NSDragOperationNone to refuse the drop, or anything else to accept it.
 */
- (NSDragOperation)pathControl:(NSPathControl *)pathControl validateDrop:(id <NSDraggingInfo>)info
{
    return NSDragOperationCopy;
}


/*
 Implement this method to accept the dropped contents previously accepted from validateDrop:.  Get the new URL from the pasteboard and set it to the path control.
 */
-(BOOL)pathControl:(NSPathControl *)pathControl acceptDrop:(id <NSDraggingInfo>)info
{
    BOOL result = NO;
    
    NSURL *URL = [NSURL URLFromPasteboard:[info draggingPasteboard]];
    if (URL != nil)
    {
        [self.pathControl setURL:URL];
        
        // If appropriate, tell the user how they can reveal the path component.
        [self updateExplainText];
        result = YES;
    }
    
    return result;
}


/*
 This method is called when a drag is about to begin. It shows how to customize dragging by preventing "volumes" from being dragged.
 */
- (BOOL)pathControl:(NSPathControl *)pathControl shouldDragPathComponentCell:(NSPathComponentCell *)pathComponentCell withPasteboard:(NSPasteboard *)pasteboard
{
    BOOL result = YES;
    NSURL *URL = [pathComponentCell URL];

    if ([URL isFileURL])
    {
        NSArray* pathPieces = [[URL path] pathComponents];
        if ([pathPieces count] < 4) {
            result = NO;	// Don't allow dragging volumes.
        }
    }
    
    return result;
}


/*
 This method updates the explanation string that instructs the user how they can reveal the path component.
 */
- (void)updateExplainText
{
    NSUInteger numItems = [[self.pathControl pathComponentCells] count];


    // If there are no path components, there is no explanatory text.
    if (numItems == 0) {
        [self.explanationText setStringValue:@""];
        return;
    }

    if ([self.pathControl pathStyle] == NSPathStyleStandard || [self.pathControl pathStyle] == NSPathStyleNavigationBar)
    {
        if (self.useCustomPath) {
            NSString *explanationString = NSLocalizedString(@"Double-click a path component to reveal it on the web.", @"");
            [self.explanationText setStringValue:explanationString];
        }
        else {
            NSString *explanationString = NSLocalizedString(@"Double-click a path component to reveal it in the Finder.", @"");
            [self.explanationText setStringValue:explanationString];
        }
    }
    else
    {
        // Other path styles have no explanatory text.
        [self.explanationText setStringValue:@""];
    }
}


@end
