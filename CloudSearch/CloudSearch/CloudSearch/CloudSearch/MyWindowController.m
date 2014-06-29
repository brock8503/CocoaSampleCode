/*
     File: MyWindowController.m
 Abstract: Primary NSWindowController for this sample, used to display search results.
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
#import "CloudDocumentsController.h"

// keys to our document data found in our table view search results
NSString *kItemURLKey           = @"itemURL";
NSString *kItemNameKey          = @"itemName";
NSString *kItemDisplayNameKey   = @"itemDisplayName";
NSString *kItemDateKey          = @"itemModDate";

// filter NSPopUpButton menu item indexes:
enum FilterMenuItems
{
    kTXTItem = 0,
    kJPGItem,
    kPDFItem,
    kHTMLItem,
    kNoneItem = 5
};

@interface MyWindowController ()

@property (nonatomic, strong) IBOutlet NSTableView *tableView;
@property (nonatomic, strong) IBOutlet NSArrayController *contentArray;
@property (nonatomic, strong) IBOutlet NSPopUpButton *filterPopup;

@end


#pragma mark -

@implementation MyWindowController

// -------------------------------------------------------------------------------
//  init
// -------------------------------------------------------------------------------
- (id)init
{
    if (self = [super initWithWindowNibName:@"MyWindowController"])
    {
        // more initialization here
    }
    return self;
}

// -------------------------------------------------------------------------------
//  windowDidLoad
// -------------------------------------------------------------------------------
- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // implement this method to handle any initialization after your window
    // controller's window has been loaded from its nib file.
    
    // Add any code here that need to be executed once the windowController has loaded the document's window.
    //
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kItemDisplayNameKey ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [self.contentArray setSortDescriptors:sortDescriptors];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

// -------------------------------------------------------------------------------
//	clearItems
// -------------------------------------------------------------------------------
- (void)clearDocuments
{
    NSArray *objs = [self.contentArray arrangedObjects];
    [self.contentArray removeObjects:objs];
}

// -------------------------------------------------------------------------------
//	addDocument:itemDisplayName:modificationDate
// -------------------------------------------------------------------------------
- (void)addDocument:(NSURL *)url withName:itemName displayName:itemDisplayName modificationDate:(NSDate *)modificationDate
{
    // modification date
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:kCFDateFormatterMediumStyle];
    NSString *dateStr = [dateFormat stringFromDate:modificationDate];
    
    // build all this info into a dictionary for later use (bindings in NSTableView)
    NSMutableDictionary *itemDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     url, kItemURLKey,
                                     itemName, kItemNameKey,
                                     itemDisplayName, kItemDisplayNameKey,
                                     dateStr, kItemDateKey,
                                     nil];
    [self.contentArray addObject:itemDict];
    
    [self.contentArray setSelectedObjects:nil];
}

// -------------------------------------------------------------------------------
//	shouldEditTableColumn:aTableColumn:rowIndex
// -------------------------------------------------------------------------------
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return NO;
}


#pragma mark - Actions

// -------------------------------------------------------------------------------
//	filterAction:sender
//
//  User chose an extension to filter the search.
// -------------------------------------------------------------------------------
- (IBAction)filterAction:(id)sender
{
    NSPopUpButton *popupButton = sender;
    CloudDocumentsController *docsController = [CloudDocumentsController sharedInstance];
    
    NSString *fileType = nil;
    switch ([popupButton indexOfSelectedItem])
    {
        case kTXTItem:
            fileType = @"txt";
            break;
        case kJPGItem:
            fileType = @"jpg";
            break;
        case kPDFItem:
            fileType = @"pdf";
            break;
        case kHTMLItem:
            fileType = @"html";
            break;
        case kNoneItem:
            fileType = @"";
            break;
    }
    
    docsController.fileType = fileType;
    [docsController restartScan];
}

@end
