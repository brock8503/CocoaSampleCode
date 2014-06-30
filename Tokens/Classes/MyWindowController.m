/*
     File: MyWindowController.m
 Abstract: n/a
  Version: 1.0
 
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
#import "MyToken.h"

@interface MyWindowController ()

@property (strong) IBOutlet NSTokenField *tokensField;
@property (strong) IBOutlet NSPopUpButton *namesPopup;
@property (strong) IBOutlet	NSButton *tokenizeAllCheckbox;

@property (strong) IBOutlet NSMenu *sharedMenu; // menu used by the namesPopup and copied for tokenMenu

@property (strong) NSMenu *tokenMenu;   // the menu attached to each token

@property (strong) NSMutableArray *builtInKeywords;
@property (strong) NSArray *matches;
@property (strong) NSString	*tokenTitleToAdd;

@end

@implementation MyWindowController

// -------------------------------------------------------------------------------
//	awakeFromNib
// -------------------------------------------------------------------------------
- (void)awakeFromNib
{
	// the default tokenizing character is the comma; carriage return (or newline character)
    //
	/* example how to make the tokenize character with "/"
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"/"];
	[self.tokensField setTokenizingCharacterSet:set];
    */
    
	[self.tokensField setTokenStyle:NSPlainTextTokenStyle];
    [self.tokensField setDelegate:self];		// this can also be done in Interface Builder
	[self.tokensField setCompletionDelay:0.5];	// speed up auto completion a bit for type matching
    
	// share the menu of names between the popup control and the type completion list
	[self.namesPopup setMenu:self.sharedMenu];

    // create the token menu (to allow for the user to edit it)
    _tokenMenu = [[NSMenu alloc] initWithTitle:@""];
    [self.tokenMenu insertItem:[[NSMenuItem alloc] initWithTitle:@"Edit…"
                                                          action:@selector(editCellAction:)
                                                   keyEquivalent:@""] atIndex:0];
    
	// build our type completion list of names
    // (copy off the menu item title to a separate array for type completion matching)
    //
    _builtInKeywords = [[NSMutableArray alloc] init];
    for (NSMenuItem *menuItem in [self.sharedMenu itemArray])
    {
        [self.builtInKeywords addObject:[menuItem title]];
    }
}


#pragma mark - NSTokenFieldDelegate

// ---------------------------------------------------------------------------
//	styleForRepresentedObject:representedObject
//
//	Make sure our tokens are rounded.
//	The delegate should return:
//		NSDefaultTokenStyle, NSPlainTextTokenStyle or NSRoundedTokenStyle.
// ---------------------------------------------------------------------------
- (NSTokenStyle)tokenField:(NSTokenField *)tokenField styleForRepresentedObject:(id)representedObject
{
	NSTokenStyle returnStyle = NSPlainTextTokenStyle;
    
    if (self.tokenizeAllCheckbox.state)
    {
        returnStyle = NSRoundedTokenStyle;
    }
    else
    {
        if ([representedObject isKindOfClass:[MyToken class]])
            returnStyle = NSRoundedTokenStyle;
    }
    
    return returnStyle;
}

// ---------------------------------------------------------------------------
//	hasMenuForRepresentedObject:representedObject
//
//	Make sure our tokens have a menu. By default tokens have no menus.
// ---------------------------------------------------------------------------
- (BOOL)tokenField:(NSTokenField *)tokenField hasMenuForRepresentedObject:(id)representedObject
{
	BOOL hasMenu = NO;
    
    if (self.tokenizeAllCheckbox.state)
    {
        hasMenu = YES;
    }
    else
    {
        // is the incoming representedObject a MyToken class?
        if ([representedObject isKindOfClass:[MyToken class]])
            return YES;
    }
    
	return hasMenu;
}

// ---------------------------------------------------------------------------
//	menuForRepresentedObject:representedObject
//
//	User clicked on a token, return the menu we want to represent for our token.
//	By default tokens have no menus.
// ---------------------------------------------------------------------------
static MyToken *menuToken;

- (NSMenu *)tokenField:(NSTokenField *)tokenField menuForRepresentedObject:(id)representedObject
{
	NSMenu *returnMenu = nil;
    
    if (self.tokenizeAllCheckbox.state)
    {
        menuToken = representedObject;
        returnMenu = self.tokenMenu;
    }
    else
    {
        // note: representedObject is the actual NSToken
        //
        if ([representedObject isKindOfClass:[MyToken class]])
        {
            menuToken = representedObject;
            returnMenu = self.tokenMenu;
        }
    }
	
	return returnMenu;
}

// ---------------------------------------------------------------------------
//	shouldAddObjects:tokens:index
//
//	Delegate method to decide whether the given token list should be allowed,
//	we can selectively add/remove any token we want.
//
//	The delegate can return the array unchanged or return a modified array of tokens.
//	To reject the add completely, return an empty array.  Returning nil causes an error.
// ---------------------------------------------------------------------------
- (NSArray *)tokenField:(NSTokenField *)tokenField shouldAddObjects:(NSArray *)tokens atIndex:(NSUInteger)index
{
	NSMutableArray *newArray = [NSMutableArray arrayWithArray:tokens];
    
	id aToken;
	for (aToken in newArray)
	{
		if ([[aToken description] isEqualToString:self.tokenTitleToAdd])
		{
			MyToken *token = [[MyToken alloc] init];
			token.name = [aToken description];
			[newArray replaceObjectAtIndex:index withObject:token];
			break;
		}
	}
    
	return newArray;
}

// ---------------------------------------------------------------------------
//	completionsForSubstring:substring:tokenIndex:selectedIndex
//
//	Called 1st, and again every time a completion delay finishes.
//
//	substring =		the partial string that to be completed.
//	tokenIndex =	the index of the token being edited.
//	selectedIndex = allows you to return by-reference an index in the array
//					specifying which of the completions should be initially selected.
// ---------------------------------------------------------------------------
- (NSArray *)tokenField:(NSTokenField *)tokenField completionsForSubstring:(NSString *)substring indexOfToken:(NSInteger)tokenIndex
    indexOfSelectedItem:(NSInteger *)selectedIndex
{
	self.matches = [self.builtInKeywords filteredArrayUsingPredicate:
                    [NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", substring]];
    return self.matches;
}

// ---------------------------------------------------------------------------
//	representedObjectForEditingString:editingString
//
//	Called 2nd, after you choose a choice from the menu list and press return.
//
//	The represented object must implement the NSCoding protocol.
//	If your application uses some object other than an NSString for their represented objects,
//	you should return a new instance of that object from this method.
//
// ---------------------------------------------------------------------------
- (id)tokenField:(NSTokenField *)tokenField representedObjectForEditingString:(NSString *)editingString
{
    id returnRepresentedObject = nil;
    
    if (self.tokenizeAllCheckbox.state)
    {
        MyToken *token = [[MyToken alloc] init];
        token.name = editingString;
        returnRepresentedObject = token;
    }
    else
    {
        NSArray *foundItems = [self.matches filteredArrayUsingPredicate:
                               [NSPredicate predicateWithFormat:@"SELF beginswith[cd] %@", editingString]];
        if (foundItems.count > 0)
        {
            NSString *foundString = [foundItems objectAtIndex:0];
            if (foundString.length > 0)
            {
                MyToken *token = [[MyToken alloc] init];
                token.name = foundString;
                returnRepresentedObject = token;
            }
        }
    }
    
    return returnRepresentedObject;
}

// ---------------------------------------------------------------------------
//	displayStringForRepresentedObject:representedObject
//
//	Called 3rd, once the token is ready to be displayed.
//
//	If you return nil or do not implement this method, then representedObject
//	is displayed as the string. The represented object must implement the NSCoding protocol.
// ---------------------------------------------------------------------------
- (NSString *)tokenField:(NSTokenField *)tokenField displayStringForRepresentedObject:(id)representedObject
{
	NSString *string = nil;
    
	if ([representedObject isKindOfClass:[MyToken class]])	// check to see if the object is our token class
	{
		MyToken *token = representedObject;
		string = token.name;
	}
	else
	{
		string = representedObject;
	}
	return string;
}


#pragma mark - Actions

// ---------------------------------------------------------------------------
//	tokenFieldAction:sender
//
//	The action-message selector associated with this NSTokenField.
//	Called when the user commits an edit by pressing return key.
// ---------------------------------------------------------------------------
- (IBAction)tokenFieldAction:(id)sender
{
    NSText *fieldEditor = [self.tokensField currentEditor];
    
	NSRange textRange = [fieldEditor selectedRange];
    if (textRange.length > 0)
    {
        NSString *replacedString = [NSString stringWithString:menuToken.name];
        [fieldEditor replaceCharactersInRange:textRange withString:replacedString];
        [fieldEditor setSelectedRange:NSMakeRange(textRange.location, [replacedString length])];
    }
}

// ---------------------------------------------------------------------------
//	addTokenAction:sender
//
//	User wants to add a token (from the "Add" button)
// ---------------------------------------------------------------------------
- (IBAction)addTokenAction:(id)sender
{
	// first find the right name to apply to the token
    NSString *nameStr = [self.namesPopup titleOfSelectedItem];
	
	// get the array of tokens
    NSArray *array = [self.tokensField objectValue];
	
    // copy the array so we can modify and add a new one
    NSMutableArray *newArray = [NSMutableArray arrayWithArray:array];
	
	MyToken *token = [[MyToken alloc] init];
	token.name = nameStr;
	
    [newArray addObject:token];
	[self.tokensField setObjectValue:newArray]; // commit the edit change
	
	// force the insertion point after the added token
	NSText *fieldEditor = [self.tokensField currentEditor];
	[fieldEditor setSelectedRange:NSMakeRange([[fieldEditor string] length], 0)];
}

// ---------------------------------------------------------------------------
//	editCellAction:sender
//
//	The user chose "Edit…" from the token menu.
// ---------------------------------------------------------------------------
- (IBAction)editCellAction:(id)sender
{
	NSText *fieldEditor = [self.tokensField currentEditor];
	NSRange textRange = [fieldEditor selectedRange];
	
	NSString *replacedString = [NSString stringWithString:menuToken.name];
	[fieldEditor replaceCharactersInRange:textRange withString:replacedString];
	[fieldEditor setSelectedRange:NSMakeRange(textRange.location, [replacedString length])];
}

@end
