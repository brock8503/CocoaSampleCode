/*
     File: Document.m
 Abstract: Header file for the saved text document.
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

#import "Document.h"

@implementation Document

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports
    // multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    //
    return @"Document";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    [super windowControllerDidLoadNib:aController];
    
    // add any code here that needs to be executed once the windowController has loaded the document's window
    
    [self.textView setString:[[NSString alloc] initWithData:self.docData encoding:NSASCIIStringEncoding]];
}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type.
    // If the given outError != NULL, ensure that you set *outError when returning nil.
    //
    NSString *testStr = [self.textView string];
    return [testStr dataUsingEncoding:NSASCIIStringEncoding];
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.
    // If the given outError != NULL, ensure that you set *outError when returning NO.
    //
    self.docData = data;
    
    return YES;
}


#pragma mark - Save panel

// -------------------------------------------------------------------------------
// prepareSavePanel:inSavePanel:
// -------------------------------------------------------------------------------
// Invoked by runModalSavePanel to do any customization of the Save panel savePanel.
//
- (BOOL)prepareSavePanel:(NSSavePanel *)inSavePanel
{
	[inSavePanel setDelegate:self];	// allows us to be notified of save panel events
    
    // here we explicitly want to always start in the user's home directory,
	// If we don't set this, then the save panel will remember the last visited
	// directory, which is generally preferred.
	//
	[inSavePanel setDirectoryURL:[NSURL URLWithString:NSHomeDirectory()]];
	
	[inSavePanel setMessage:@"This is a customized save dialog for saving text files:"];
	[inSavePanel setAccessoryView:saveDialogCustomView];	// add our custom view
	[inSavePanel setAllowedFileTypes:@[@"txt"]];            // save files with 'txt' extension only
	[inSavePanel setNameFieldLabel:@"FILE NAME:"];			// override the file name label
	
	_savePanel = inSavePanel;	// keep track of the save panel for later
	
    return YES;
}

// -------------------------------------------------------------------------------
// isValidFilename:filename:
// -------------------------------------------------------------------------------
// Gives the delegate the opportunity to validate selected items.
//
// The NSSavePanel object sender sends this message just before the end of a modal session for each filename
// displayed or selected (including filenames in multiple selections). The delegate determines whether it
// wants the file identified by filename; it returns YES if the filename is valid, or NO if the save panel
// should stay in its modal loop and wait for the user to type in or select a different filename or names.
// If the delegate refuses a filename in a multiple selection, none of the filenames in the selection is accepted.
//
// In this particular case: we arbitrary make sure the save dialog does not allow files named as "text"
//
- (BOOL)panel:(id)sender isValidFilename:(NSString *)filename
{
	BOOL result = YES;
	
	NSURL *url = [NSURL fileURLWithPath: filename];
	if (url && [url isFileURL])
	{
		NSArray *pathPieces = [[url path] pathComponents];
		NSString *actualFilename = [pathPieces objectAtIndex:[pathPieces count]-1]; //•• redo
		if ([actualFilename isEqual:@"text.txt"])
		{
			NSAlert *alert = [NSAlert alertWithMessageText:@"Cannot save a file name titled \"text\"."
                                             defaultButton:@"OK"
                                           alternateButton:nil
                                               otherButton:nil
                                 informativeTextWithFormat:@"Please pick a new name."];
			[alert runModal];
			result = NO;
		}
	}
    
	return result;
}

// -------------------------------------------------------------------------------
// userEnteredFilename:filename:confirmed:okFlag
// -------------------------------------------------------------------------------
// Sent when the user confirms a filename choice by hitting OK or Return in the NSSavePanel object sender.
//
// You can either leave the filename alone, return a new filename, or return nil to cancel the save
// (and leave the Save panel as is). This method is sent before any required extension is appended to the
// filename and before the Save panel asks the user whether to replace an existing file.
//
// In this particular case, we arbitrarily add a "!" to the end of the file name.
//
// IMPORTANT NOTE:
// Certain NSOpenPanel and NSSavePanel methods behave differently when App Sandbox is enabled for your app.
// This particular delegate is one of them. So for sandboxed apps, you cannot rewrite the
// user’s selection using this method. For more information see App Sandbox Guide on developer.apple.com.
//
- (NSString *)panel:(id)sender userEnteredFilename:(NSString *)filename confirmed:(BOOL)okFlag
{
	NSMutableString *returnFileName = [NSMutableString stringWithString:filename];
    
    if (okFlag && [appendCheck state])
	{
		NSRange searchRange = [returnFileName rangeOfString:@"."];
		if (searchRange.length)
        {
			[returnFileName insertString:@"!" atIndex:searchRange.location];
        }
		else
        {
			[returnFileName appendString:@"!"];
        }
	}
    
	return returnFileName;
}

// -------------------------------------------------------------------------------
// willExpand:expanding
// -------------------------------------------------------------------------------
// Sent when the NSSavePanel object sender is about to expand or collapse because the user clicked the
// disclosure triangle that displays or hides the file browser.
//
// In this particular case, we have sound feedback for expand/shrink of the save dialog.
//
- (void)panel:(id)sender willExpand:(BOOL)expanding
{
	if ([soundOnCheck state])
	{
		if (expanding)
			[[NSSound soundNamed:@"Pop"] play];
		else
			[[NSSound soundNamed:@"Blow"] play];
	}
	
	// package navigation doesn't apply for the shrunk/simple dialog
	[navigatePackages setHidden:!expanding];
}

// -------------------------------------------------------------------------------
// directoryDidChange:path
// -------------------------------------------------------------------------------
// Sent when the user has changed the selected directory in the NSSavePanel object sender.
//
// In this particular case, we have sound feedback for directory changes.
//
- (void)panel:(id)sender directoryDidChange:(NSString *)path
{
	if ([soundOnCheck state])
    {
		[[NSSound soundNamed:@"Frog"] play];
    }
}

// -------------------------------------------------------------------------------
// panelSelectionDidChange:sender
// -------------------------------------------------------------------------------
// Sent when the user has changed the selection in the NSSavePanel object sender.
//
// In this particular case, we have sound feedback for selection changes.
//
- (void)panelSelectionDidChange:(id)sender
{
	if ([soundOnCheck state])
    {
		[[NSSound soundNamed:@"Hero"] play];
    }
}

// -------------------------------------------------------------------------------
// filePackagesAsDirAction:sender
// -------------------------------------------------------------------------------
// toggles flag via custom checkbox to view packages
//
- (IBAction)filePackagesAsDirAction:(id)sender
{
	[self.savePanel setTreatsFilePackagesAsDirectories:[sender state]];
}

@end
