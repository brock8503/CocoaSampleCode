/*
     File: CloudDocumentsController.m
 Abstract: Utility class used to keep track of known documents in the cloud.
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

#import "CloudDocumentsController.h"

@interface CloudDocumentsController ()

- (void)removeQueryObservers;
- (void)addQueryObservers;

@property (nonatomic, strong) NSMetadataQuery *ubiquitousQuery;
@property (nonatomic, strong) NSMutableArray *foundDocuments;

@end


#pragma mark -

@implementation CloudDocumentsController

static CloudDocumentsController *cloudDocumentsController;

// -------------------------------------------------------------------------------
//  singleton class
// -------------------------------------------------------------------------------
+ (CloudDocumentsController *)sharedInstance
{
    if (cloudDocumentsController == nil)
    {
        // note: an empty file type means find all types documents
        cloudDocumentsController = [[CloudDocumentsController alloc] initWithType:@""];
    }
    return cloudDocumentsController;
}

// -------------------------------------------------------------------------------
//  setupQuery
// -------------------------------------------------------------------------------
- (void)setupQuery
{
    _ubiquitousQuery = [[NSMetadataQuery alloc] init];
    _ubiquitousQuery.notificationBatchingInterval = 15;
    _ubiquitousQuery.searchScopes = [NSArray arrayWithObject:NSMetadataQueryUbiquitousDocumentsScope];
    
    NSString *filePattern = nil;
    if ([self.fileType isEqualToString:@""])
    {
        filePattern = [NSString stringWithFormat:@"*.*"];
    }
    else
    {
        filePattern = [NSString stringWithFormat:@"*.%@", self.fileType];
    }
    
    _ubiquitousQuery.predicate = [NSPredicate predicateWithFormat:@"%K LIKE %@", NSMetadataItemFSNameKey, filePattern]; 
    // or 
    // _ubiquitousQuery.predicate = [NSPredicate predicateWithFormat:@"%K ENDSWITH %@", NSMetadataItemFSNameKey, self.fileType];
}

// -------------------------------------------------------------------------------
//  initWithType:fileType
// -------------------------------------------------------------------------------
- (id)initWithType:(NSString *)fileType
{
    self = [super init];
    
    _fileType = fileType;
    
    self.foundDocuments = [NSMutableArray array];
    
    [self setupQuery];
    
    return self;
}

// -------------------------------------------------------------------------------
//  initWithType:fileType
//
//  Our client is explicty setting the file type, so we need to re-setup the query.
// -------------------------------------------------------------------------------
- (void)setFileType:(NSString *)fileType
{
    _fileType = fileType;
    [self setupQuery];
}


#pragma mark - Exported APIs

// -------------------------------------------------------------------------------
//  numberOfDocuments
// -------------------------------------------------------------------------------
- (NSUInteger)numberOfDocuments
{
    return _foundDocuments.count;
}

// -------------------------------------------------------------------------------
//  startScanning
// -------------------------------------------------------------------------------
- (BOOL)startScanning
{
    [self addQueryObservers];
    
    BOOL started = [_ubiquitousQuery startQuery];
    if (!started)
    {
        self.ubiquitousQuery = nil;
    }

    return started;
}

// -------------------------------------------------------------------------------
//  stopScanning
// -------------------------------------------------------------------------------
- (void)stopScanning
{
    [self.ubiquitousQuery stopQuery];
    [self removeQueryObservers];
    
    self.ubiquitousQuery = nil;
}

// -------------------------------------------------------------------------------
//  restartScan
// -------------------------------------------------------------------------------
- (void)restartScan
{
    [self.ubiquitousQuery stopQuery];
    
    self.ubiquitousQuery = nil;
    
    [self setupQuery];
    [self startScanning];
}

// -------------------------------------------------------------------------------
//  urlForDocumentAtIndex:index
// -------------------------------------------------------------------------------
- (NSURL *)urlForDocumentAtIndex:(NSInteger)index
{
    return [_foundDocuments objectAtIndex:index];
}

// -------------------------------------------------------------------------------
//  titleForDocumentAtIndex:index
// -------------------------------------------------------------------------------
- (NSString *)titleForDocumentAtIndex:(NSInteger)index
{
    NSURL *url = [_foundDocuments objectAtIndex:index];
    NSURL *urlWithoutExtension = [url URLByDeletingPathExtension];
    return [urlWithoutExtension lastPathComponent];
}

// -------------------------------------------------------------------------------
//  iconForDocumentAtIndex:index
// -------------------------------------------------------------------------------
- (NSImage *)iconForDocumentAtIndex:(NSInteger)index
{
    NSImage *icon = nil;
    
    NSURL *url = [_foundDocuments objectAtIndex:index];
    [url getResourceValue:&icon forKey:NSURLEffectiveIconKey error:nil];
    
    return icon;
}

// -------------------------------------------------------------------------------
//  modDateForDocumentAtIndex:index
// -------------------------------------------------------------------------------
- (NSDate *)modDateForDocumentAtIndex:(NSInteger)index
{
    NSDate *modDate = nil;
    
    NSURL *url = [_foundDocuments objectAtIndex:index];
    [url getResourceValue:&modDate forKey:NSURLContentModificationDateKey error:nil];
    
    return modDate;
}

// -------------------------------------------------------------------------------
//  documentIsUploadedAtIndex:index
// -------------------------------------------------------------------------------
- (BOOL)documentIsUploadedAtIndex:(NSInteger)index
{
    NSURL *url = [_foundDocuments objectAtIndex:index];
    
    // get uploaded state: true if there is data present in the cloud for this item
    NSNumber *isUploaded = nil;
    [url getResourceValue:&isUploaded forKey:NSURLUbiquitousItemIsUploadedKey error:nil];
    return [isUploaded boolValue];
}

// -------------------------------------------------------------------------------
//  documentIsDownloadedAtIndex:index
// -------------------------------------------------------------------------------
- (BOOL)documentIsDownloadedAtIndex:(NSInteger)index
{
    NSURL *url = [_foundDocuments objectAtIndex:index];
    
    // get uploaded state: true if there is data present in the cloud for this item
    NSNumber *isDownloaded = nil;
    [url getResourceValue:&isDownloaded forKey:NSURLUbiquitousItemIsUploadedKey error:nil];
    return [isDownloaded boolValue];
}

// -------------------------------------------------------------------------------
//  sortDocuments
// -------------------------------------------------------------------------------
- (void)sortDocuments
{
    NSArray *sortedResults = [_foundDocuments sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [[obj1 lastPathComponent] caseInsensitiveCompare:[obj2 lastPathComponent]];
    }];
    self.foundDocuments = [NSMutableArray arrayWithArray:sortedResults];
}

// -------------------------------------------------------------------------------
//  addCloudDocumentWithURL:cloudDocumentURL
// -------------------------------------------------------------------------------
- (void)addCloudDocumentWithURL:(NSURL *)cloudDocumentURL
{
    [_foundDocuments addObject:cloudDocumentURL];
    
    // sort the list of documents by name    
    [self sortDocuments];
}


#pragma mark -

// -------------------------------------------------------------------------------
//  addQueryObservers
// -------------------------------------------------------------------------------
- (void)addQueryObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStart:)
                                                 name:NSMetadataQueryDidStartGatheringNotification
                                               object:_ubiquitousQuery];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gathering:)
                                                 name:NSMetadataQueryGatheringProgressNotification
                                               object:_ubiquitousQuery];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishGathering:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification
                                               object:_ubiquitousQuery];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didUpdate:)
                                                 name:NSMetadataQueryDidUpdateNotification
                                               object:_ubiquitousQuery];
}

// -------------------------------------------------------------------------------
//  removeQueryObservers
// -------------------------------------------------------------------------------
- (void)removeQueryObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidStartGatheringNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryGatheringProgressNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidFinishGatheringNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSMetadataQueryDidUpdateNotification
                                                  object:nil];
}

// -------------------------------------------------------------------------------
//  dealloc
// -------------------------------------------------------------------------------
- (void)dealloc
{
    [self removeQueryObservers];
}

// -------------------------------------------------------------------------------
//  didStart:note
//
//  NSMetadataQuery has started.
// -------------------------------------------------------------------------------
- (void)didStart:(NSNotification *)note
{
    NSLog(@"didStart...");
    
    // call our delegate that we started scanning out ubiquitous container
    if ([self.delegate respondsToSelector:@selector(didStartRetrievingCloudDocuments)])
    {
        [self.delegate didStartRetrievingCloudDocuments];
    }
}

// -------------------------------------------------------------------------------
//  gathering:note
//
//  NSMetadataQuery is gathering the results.
// -------------------------------------------------------------------------------
- (void)gathering:(NSNotification *)note
{
    NSLog(@"gathering...");
    //.. do what ever you need to do while gathering results
}

// -------------------------------------------------------------------------------
//  handleQueryUpdates:ubiquitousQuery
//
//  Used for examining what new results came from our NSMetadataQuery.
//  This method is shared between "finishGathering" and "didUpdate" methods.
// -------------------------------------------------------------------------------
- (void)handleQueryUpdates:(NSMetadataQuery *)ubiquitousQuery
{
    // we should invoke this method before iterating over query results that could
    // change due to live updates
    [self.ubiquitousQuery disableUpdates];
    
    // load the new array of NSMetadataItems from 'ubiquitousQuery',
    // store the NSURL for each, sort the list
    //
    [self.foundDocuments removeAllObjects];
    NSMetadataItem *item = nil;
    for (item in [self.ubiquitousQuery results])
    {
        NSURL *itemURL = [item valueForAttribute:NSMetadataItemURLKey];
        
        NSNumber *isInvisible = nil;
        [itemURL getResourceValue:&isInvisible forKey:NSURLIsHiddenKey error:nil];
        if (isInvisible && ![isInvisible boolValue])
        {
            [self.foundDocuments addObject:itemURL];
        }
    }
    [self sortDocuments];
    
    // notify our delegate we received an update
    if ([self.delegate respondsToSelector:@selector(didRetrieveCloudDocuments)])
    {
        [self.delegate didRetrieveCloudDocuments];
    }
    
    // enable updates again
    [self.ubiquitousQuery enableUpdates];
}

// -------------------------------------------------------------------------------
//  finishGathering:note
// -------------------------------------------------------------------------------
- (void)finishGathering:(NSNotification *)note
{
    NSLog(@"finishGathering...");
    [self handleQueryUpdates:self.ubiquitousQuery];
}

// -------------------------------------------------------------------------------
//  didUpdate:note
// -------------------------------------------------------------------------------
- (void)didUpdate:(NSNotification *)note
{
    NSLog(@"didUpdate...");
    [self handleQueryUpdates:self.ubiquitousQuery];
}

@end
