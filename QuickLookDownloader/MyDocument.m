/*
     File: MyDocument.m
 Abstract: MyDocument manages a list of downloaded items.
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
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "MyDocument.h"
#import "DownloadItem.h"
#import "DownloadCell.h"
#import <Quartz/Quartz.h>   // Quartz framework provides the QLPreviewPanel public API

// DownloadItem will be used directlty as the items in preview panel
// The class just need to implement the QLPreviewItem protocol
//
@interface DownloadItem (QLPreviewItem) <QLPreviewItem>

@end

#pragma mark -

@implementation DownloadItem (QLPreviewItem)

- (NSURL *)previewItemURL
{
    return self.resolvedFileURL;
}

- (NSString *)previewItemTitle
{
    return [self.originalURL absoluteString];
}

@end


#pragma mark -

@interface MyDocument () <QLPreviewPanelDataSource, QLPreviewPanelDelegate, NSURLDownloadDelegate, NSTextFieldDelegate>
{
    BOOL downloading;
    long long expectedContentLength;
    long long downloadedSoFar;
    
    NSURLDownload *download;
    NSURL *originalURL;
    NSURL *fileURL;
}

@property (strong) NSMutableArray *downloads;

@property (getter=isDownloading, setter=setDownloading:) BOOL downloading;
@property CGFloat downloadProgress;
@property BOOL downloadIsIndeterminate;
@property (nonatomic, copy) NSArray *selectedDownloads;
@property (nonatomic, copy) NSIndexSet *selectedIndexes;

@property IBOutlet NSTextField *downloadURLField;
@property IBOutlet NSView *downloadsView;
@property IBOutlet NSTableView *downloadsTableView;
@property IBOutlet NSButton *downloadButton;
@property IBOutlet NSView *downloadProgressView;

@property (strong) QLPreviewPanel *previewPanel;

@end


#pragma mark -

@implementation MyDocument

- (id)init
{
    self = [super init];
    if (self != nil)
    {
        _downloads = [[NSMutableArray alloc] init];
        _selectedIndexes = [[NSIndexSet alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [download cancel];
}

- (NSString *)windowNibName
{
    return @"MyDocument";
}

// write method of NSDocument
//
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    NSMutableArray *propertyList = [[NSMutableArray alloc] initWithCapacity:self.downloads.count];
    
    for (DownloadItem *item in self.downloads)
    {
        id plistForItem = [item propertyListForSaving];
        if (plistForItem)
        {
            [propertyList addObject:plistForItem];
        }
    }
    
    NSData *result = [NSPropertyListSerialization dataWithPropertyList:propertyList
                                                                format:NSPropertyListBinaryFormat_v1_0
                                                               options:0
                                                                 error:NULL];
    assert(result);
    
    return result;
}

// read method of NSDocument
//
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    NSArray *propertyList = [NSPropertyListSerialization propertyListWithData:data
                                                                      options:NSPropertyListImmutable
                                                                       format:NULL
                                                                        error:outError];
    if (!propertyList)
    {
        return NO;
    }
    
    if (![propertyList isKindOfClass:[NSArray class]])
    {
        if (outError != NULL)
        {
            *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadCorruptFileError userInfo:NULL];
        }
        return NO;
    }
    
    NSMutableArray *observableDownloads = [self mutableArrayValueForKey:@"downloads"];
    [observableDownloads removeAllObjects];
    
    for (id plistItem in propertyList)
    {
        DownloadItem *item = [[DownloadItem alloc] initWithSavedPropertyList:plistItem];
        if (item)
        {
            [observableDownloads addObject:item];
        }
    }
    
    return YES;
}


#pragma mark - Downloading

// the URL field text has changed, update the enable state of our Download button
- (void)controlTextDidChange:(NSNotification *)obj
{
    NSTextField *textField = [obj object];
    [self.downloadButton setEnabled:(textField.stringValue.length > 0)];
}

// called when the user clicks the Download button
- (IBAction)startDownload:(id)sender
{
    assert(!download);
    
    [self.downloadButton setEnabled:NO]; // don't allow download button to work while downloading
    
    NSString *urlString = [self.downloadURLField stringValue];
    assert(urlString);
    
    urlString = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    NSURL *url = [NSURL URLWithString:urlString];
    originalURL = [url copy];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    self.downloadIsIndeterminate = YES;
    self.downloadProgress = 0.0f;
    self.downloading = YES;
    
    download = [[NSURLDownload alloc] initWithRequest:request delegate:self];
    
    [[self.downloadsTableView window] makeFirstResponder:self.downloadsTableView];
}

- (void)setSelectedIndexes:(NSIndexSet *)indexSet
{
    if (indexSet != _selectedIndexes)
    {
        indexSet = [indexSet copy];
        _selectedIndexes = indexSet;
        self.selectedDownloads = [self.downloads objectsAtIndexes:indexSet];
    }
}

- (void)setSelectedDownloads:(NSArray *)array
{
    if (array != _selectedDownloads)
    {
        array = [array copy];
        _selectedDownloads = array;
        [self.previewPanel reloadData];
    }
}


#pragma mark - Download support

- (void)displayDownloadProgressView
{
    if (downloading && [self.downloadProgressView superview] == nil)
    {
        // position and size downloadsProgressFrame appropriately
        NSRect downloadProgressFrame = self.downloadProgressView.frame;
        NSRect downloadsFrame = self.downloadsView.frame;
        downloadProgressFrame.size.width = CGRectGetWidth(downloadsFrame);
        downloadProgressFrame.origin.y = NSMaxY(downloadsFrame);
        [self.downloadProgressView setFrame:downloadProgressFrame];
        
        [[[self.downloadsView superview] animator] addSubview:self.downloadProgressView
                                              positioned:NSWindowBelow
                                              relativeTo:self.downloadsView];
    }
}

- (void)startDisplayingProgressView
{
    if (!downloading || [self.downloadProgressView superview])
    {
        return;
    }
    
    // we are starting a download, display the download progress view
    NSRect downloadProgressFrame = self.downloadProgressView.frame;
    NSRect downloadsFrame = self.downloadsView.frame;
    
    // reduce the size of the downloads view
    downloadsFrame.size.height -= CGRectGetHeight(downloadProgressFrame);
    
    [NSAnimationContext beginGrouping];
    
        [[NSAnimationContext currentContext] setDuration:0.2];
        [[self.downloadsView animator] setFrame:downloadsFrame];
    
    [NSAnimationContext endGrouping];
    
    [self performSelector:@selector(displayDownloadProgressView) withObject:nil afterDelay:0.2];
}

- (void)hideDownloadProgressView
{
    if (!downloading)
    {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(displayDownloadProgressView)
                                                   object:nil];
        
        // we are ending a download, remove the download progress view
        [self.downloadProgressView removeFromSuperview];

        [NSAnimationContext beginGrouping];
        
            [[NSAnimationContext currentContext] setDuration:0.5];
            [[self.downloadsView animator] setFrame:[[self.downloadsView superview] bounds]];
        
        [NSAnimationContext endGrouping];
    }
}

- (BOOL)isDownloading
{
    return downloading;
}

- (void)setDownloading:(BOOL)flag
{
    if (!flag != !downloading)
    {
        downloading = flag;
        
        if (downloading)
        {
            [self performSelector:@selector(startDisplayingProgressView) withObject:nil afterDelay:0.0];
        }
        else
        {
            [self performSelector:@selector(hideDownloadProgressView) withObject:nil afterDelay:0.1];
            originalURL = nil;
            fileURL = nil;
            download = nil;
        }
    }
}

- (void)download:(NSURLDownload *)download didReceiveResponse:(NSURLResponse *)response
{
    expectedContentLength = [response expectedContentLength];
    if (expectedContentLength > 0.0)
    {
        self.downloadIsIndeterminate = NO;
        downloadedSoFar = 0;
    }
}

- (void)download:(NSURLDownload *)download didReceiveDataOfLength:(NSUInteger)length
{
    downloadedSoFar += length;
    if (downloadedSoFar >= expectedContentLength)
    {
        // the expected content length was wrong as we downloaded more than expected
        // make the progress indeterminate
        //
        self.downloadIsIndeterminate = YES;
    }
    else
    {
        self.downloadProgress = (float)downloadedSoFar / (float)expectedContentLength;
    }
}

- (void)download:(NSURLDownload *)aDownload decideDestinationWithSuggestedFilename:(NSString *)filename
{
    // find the user's Downloads folder
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = paths[0];
    NSString *downloadPath = [documentsDirectory stringByAppendingPathComponent:filename];
    
    [aDownload setDestination:downloadPath allowOverwrite:NO];
}

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
    fileURL = [[NSURL alloc] initFileURLWithPath:path];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    if (originalURL && fileURL)
    {
        DownloadItem *item = [[DownloadItem alloc] initWithOriginalURL:originalURL fileURL:fileURL];
        if (item != nil)
        {
            [[self mutableArrayValueForKey:@"downloads"] addObject:item];
            [self updateChangeCount:NSChangeDone];
        }
        else
        {
            NSLog(@"Can't create download item at %@", fileURL);
        }
    }
    
    self.downloading = NO;
    
    [self.downloadButton setEnabled:YES];    // allow for downloads again
}

- (void)download:(NSURLDownload *)aDownload didFailWithError:(NSError *)error
{
    [self presentError:error modalForWindow:[self windowForSheet] delegate:nil didPresentSelector:NULL contextInfo:NULL];
    self.downloading = NO;
}


#pragma mark - NSTableViewDelegate

- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[tableColumn identifier] isEqual:@"Filename"])
    {
        ((DownloadCell *)cell).originalURL = ((DownloadItem *)self.downloads[row]).originalURL;
        [cell setFont:[NSFont systemFontOfSize:TEXT_SIZE]];
    }
}


#pragma mark - Quick Look panel support

- (BOOL)acceptsPreviewPanelControl:(QLPreviewPanel *)panel
{
    return YES;
}

- (void)beginPreviewPanelControl:(QLPreviewPanel *)panel
{
    // This document is now responsible of the preview panel
    // It is allowed to set the delegate, data source and refresh panel.
    //
    _previewPanel = panel;
    panel.delegate = self;
    panel.dataSource = self;
}

- (void)endPreviewPanelControl:(QLPreviewPanel *)panel
{
    // This document loses its responsisibility on the preview panel
    // Until the next call to -beginPreviewPanelControl: it must not
    // change the panel's delegate, data source or refresh it.
    //
    _previewPanel = nil;
}


#pragma mark - QLPreviewPanelDataSource

- (NSInteger)numberOfPreviewItemsInPreviewPanel:(QLPreviewPanel *)panel
{
    return self.selectedDownloads.count;
}

- (id <QLPreviewItem>)previewPanel:(QLPreviewPanel *)panel previewItemAtIndex:(NSInteger)index
{
    return (self.selectedDownloads)[index];
}


#pragma mark - QLPreviewPanelDelegate

- (BOOL)previewPanel:(QLPreviewPanel *)panel handleEvent:(NSEvent *)event
{
    // redirect all key down events to the table view
    if ([event type] == NSKeyDown)
    {
        [self.downloadsTableView keyDown:event];
        return YES;
    }
    return NO;
}

// This delegate method provides the rect on screen from which the panel will zoom.
- (NSRect)previewPanel:(QLPreviewPanel *)panel sourceFrameOnScreenForPreviewItem:(id <QLPreviewItem>)item
{
    NSInteger index = [self.downloads indexOfObject:item];
    if (index == NSNotFound)
    {
        return NSZeroRect;
    }
        
    NSRect iconRect = [self.downloadsTableView frameOfCellAtColumn:0 row:index];
    
    // check that the icon rect is visible on screen
    NSRect visibleRect = [self.downloadsTableView visibleRect];
    
    if (!NSIntersectsRect(visibleRect, iconRect))
    {
        return NSZeroRect;
    }
    
    // convert icon rect to screen coordinates
    iconRect = [self.downloadsTableView convertRectToBase:iconRect];
    iconRect.origin = [[self.downloadsTableView window] convertBaseToScreen:iconRect.origin];
    
    return iconRect;
}

// this delegate method provides a transition image between the table view and the preview panel
//
- (id)previewPanel:(QLPreviewPanel *)panel transitionImageForPreviewItem:(id <QLPreviewItem>)item contentRect:(NSRect *)contentRect
{
    DownloadItem *downloadItem = (DownloadItem *)item;

    return downloadItem.iconImage;
}

@end
