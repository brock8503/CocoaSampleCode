/*
     File: MyTextPictDocument.m
 Abstract: The NSDocument subclass for reading/writing it data and connecting with iCloud.
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

#import "MyTextPictDocument.h"
#import "MyAppDelegate.h"

// The name of the documents directory in the ubiquity container.
NSString *UbiquityDirectoryComponentForDocuments = @"Documents";

// the file names for the package content
NSString *ImageFileName = @"Image.png";
NSString *TextFileName = @"Text.txt";
NSString *MetaDataFileName = @"MetaData.plist";
    NSString *MetaDataDisclosedKey = @"disclosedKey";   // view disclosed state in MetaData.plist
    NSString *MetaDataValue2Key = @"value2";            // special string value in MetaData.plist

// the encoding used to encode the notes text file
NSStringEncoding kTextFileEncoding = NSUTF8StringEncoding;


@interface MyTextPictDocument ()

@property (copy) NSString *notes;                       // the text content for this document
@property (strong) NSMutableDictionary *metaDataDict;   // the meta data for this document (disclosure state)

@property (strong) NSFileWrapper *documentFileWrapper;  // the document's main file wrapper (to contain subcontent for image, text and metadata)

@end


@implementation MyTextPictDocument

// -------------------------------------------------------------------------------
//  autosavesInPlace
// -------------------------------------------------------------------------------
+ (BOOL)autosavesInPlace
{
    // this gives us autosave and versioning for free in 10.7 and later
    return YES;
}

// -------------------------------------------------------------------------------
//  canAsynchronouslyWriteToURL:url:typeName:saveOperation
//
//  Turn this on for async saving allowing saving to be asynchronous, making all our
//  save methods (dataOfType, saveToURL) to be called on a background thread.
// -------------------------------------------------------------------------------
- (BOOL)canAsynchronouslyWriteToURL:(NSURL *)url ofType:(NSString *)typeName forSaveOperation:(NSSaveOperationType)saveOperation
{
    return YES;
}

// -------------------------------------------------------------------------------
//  init
// -------------------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self != nil)
    {
        // setup our internal default metaData dictionary
        // (used to illustrate reading/writing plist data to our file package)
        //
        // Note: these are the default values,
        // if a document was previously saved to disk "readFromFileWrapper" will load the
        // real metadata
        //
        self.metaDataDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [NSNumber numberWithBool:YES], MetaDataDisclosedKey,
                                            @"someText", MetaDataValue2Key,
                                            nil];
    }
    return self;
}

// -------------------------------------------------------------------------------
//  ourWindowController
//
//  convenience method, we have only one window controller
// -------------------------------------------------------------------------------
- (MyWindowController *)ourWindowController
{
    return [[self windowControllers] objectAtIndex:0];
}

// -------------------------------------------------------------------------------
//  makeWindowControllers
//
//  NSDocumentController invokes this method when creating or opening new documents.
//  We override it to use our own custom subclass of NSWindowController.
// -------------------------------------------------------------------------------
- (void)makeWindowControllers
{
    // we use one subclass of NSWindowController
    [self addWindowController:[[MyWindowController allocWithZone:nil] init]];
    
    // as a delegate we want to be notified when the user discloses the attachment
    // view holding/displayig our image
    [self ourWindowController].delegate = self;
    
    // notify our window controller to set its disclosure state for the attachmentView,
    // this will make sure the disclosure state in our window matches what's stored in this document.
    //
    BOOL disclosed = [[self.metaDataDict valueForKey:MetaDataDisclosedKey] boolValue];
    [self ourWindowController].disclosed = disclosed;
}

// -------------------------------------------------------------------------------
//  setDisplayName
// -------------------------------------------------------------------------------
- (void)setDisplayName:(NSString *)displayNameOrNil
{
    // trim off the extension when used for displaying in the window title
    [super setDisplayName:[displayNameOrNil stringByDeletingPathExtension]];
}


#pragma mark - Package Support

// -------------------------------------------------------------------------------
//  fileWrapperOfType:typeName:error
//
//  Called when the user saves this document or when autosave is performed.
//  Create and return a file wrapper that contains the contents of this document,
//  formatted for our specified type.
// -------------------------------------------------------------------------------
- (NSFileWrapper *)fileWrapperOfType:(NSString *)typeName error:(NSError **)outError
{
    // If the document was not read from file or has not previously been saved,
    // it doesn't have a file wrapper, so create one.
    //
    if ([self documentFileWrapper] == nil)
    {
        NSFileWrapper *docfileWrapper = [[NSFileWrapper alloc] initDirectoryWithFileWrappers:nil];
        [self setDocumentFileWrapper:docfileWrapper];
    }
    
    NSDictionary *fileWrappers = [[self documentFileWrapper] fileWrappers];
    
    // if there isn't a wrapper for the text file, create one too
    if ([fileWrappers objectForKey:TextFileName] != nil)
    {
        NSFileWrapper *textWrapper = [fileWrappers objectForKey:TextFileName];
        [[self documentFileWrapper] removeFileWrapper:textWrapper];
    }
    NSData *textData = [[[[self ourWindowController] textView] string] dataUsingEncoding:kTextFileEncoding];
    NSFileWrapper *textFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:textData];
    [textFileWrapper setPreferredFilename:TextFileName];
    
    [[self documentFileWrapper] addFileWrapper:textFileWrapper];
    
    // If the document file wrapper doesn't contain a file wrapper for an image and the image is not nil,
    // then create a file wrapper for the image and add it to the document file wrapper.
    //
    if (([[[self documentFileWrapper] fileWrappers] objectForKey:ImageFileName] == nil) && ([self image] != nil))
    {
        NSArray *imageRepresentations = [self.image representations];
        NSData *imageData = [NSBitmapImageRep representationOfImageRepsInArray:imageRepresentations
                                                                     usingType:NSPNGFileType
                                                                    properties:nil];
        if (imageData == nil)
        {
            NSBitmapImageRep *imageRep = nil;
            @autoreleasepool
            {
                imageData = [self.image TIFFRepresentation];
                imageRep = [[NSBitmapImageRep alloc] initWithData:imageData];
            }
            imageData = [imageRep representationUsingType:NSPNGFileType properties:nil];
        }
        
        NSFileWrapper *imageFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:imageData];
        [imageFileWrapper setPreferredFilename:ImageFileName];
        
        [[self documentFileWrapper] addFileWrapper:imageFileWrapper];
    }
    
    // check if we already have a meta data file wrapper, first remove the old one if it exists
    NSFileWrapper *metaDataFileWrapper = [[[self documentFileWrapper] fileWrappers] objectForKey:MetaDataFileName];
    if (metaDataFileWrapper != nil)
        [[self documentFileWrapper] removeFileWrapper:metaDataFileWrapper];
    
    // write the new file wrapper for our meta data
    NSError *plistError = nil;
    NSData *propertyListData = [NSPropertyListSerialization dataWithPropertyList:self.metaDataDict format:NSPropertyListXMLFormat_v1_0 options:0 error:&plistError];
    if (propertyListData == nil || plistError != nil)
    {
        NSLog(@"Could not create metadata plist data: %@", [plistError localizedDescription]);
        return nil;
    }
    
    NSFileWrapper *newMetaDataFileWrapper = [[NSFileWrapper alloc] initRegularFileWithContents:propertyListData];
    [newMetaDataFileWrapper setPreferredFilename:MetaDataFileName];
    
    [[self documentFileWrapper] addFileWrapper:newMetaDataFileWrapper];

    return [self documentFileWrapper];
}

// -------------------------------------------------------------------------------
//  readFromFileWrapper:fileWrapper:typeName:outError
//
//  Set the contents of this document by reading from a file wrapper of a specified type,
//  and return YES if successful.
// -------------------------------------------------------------------------------
- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
    /*
     When opening a document, look for the image and text file wrappers. For each wrapper,
     extract the data from it and keep the file wrapper itself. The file wrappers are kept
     so that, if the corresponding data hasn't been changed, they can be resused during a
     save and thus the source file itself can be reused rather than rewritten. This avoids
     the overhead of syncing data unnecessarily. If the data related to a file wrapper changes
     (a new image is added or the text is edited), the corresponding file wrapper object is
     disposed of and a new file wrapper created on save (see fileWrapperOfType:error:).
     */
    NSDictionary *fileWrappers = [fileWrapper fileWrappers];
    
    // load the text file from it's wrapper
    NSFileWrapper *imageFileWrapper = [fileWrappers objectForKey:ImageFileName];
    if (imageFileWrapper != nil)
    {
        NSData *imageData = [imageFileWrapper regularFileContents];
        NSImage *targetImage = [[NSImage alloc] initWithData:imageData];
        [self setImage:targetImage];
    }
    
    // load the image file from it's wrapper
    NSFileWrapper *textFileWrapper = [fileWrappers objectForKey:TextFileName];
    if (textFileWrapper != nil)
    {
        NSData *textData = [textFileWrapper regularFileContents];
        NSString *targetNotes = [[NSString alloc] initWithData:textData encoding:kTextFileEncoding];
        [self setNotes:targetNotes];
    }
    
    // load the metaData file from it's wrapper
    NSFileWrapper *metaDataFileWrapper = [fileWrappers objectForKey:MetaDataFileName];
    if (metaDataFileWrapper != nil)
    {
        // we have meta data in this document
        //
        NSData *metaData = [metaDataFileWrapper regularFileContents];
        NSMutableDictionary *finalMetadata = [NSPropertyListSerialization propertyListWithData:metaData options:NSPropertyListImmutable format:NULL error:outError];
        self.metaDataDict = finalMetadata;
    }
    
    [self setDocumentFileWrapper:fileWrapper];
    
    return YES;
}


#pragma mark - Model Support

// -------------------------------------------------------------------------------
// entireRange
// -------------------------------------------------------------------------------
- (NSRange)entireRange
{
    MyWindowController *windController = [self ourWindowController];
    NSTextView *targetTextView = [windController textView];

    return NSMakeRange(0, [[targetTextView string] length]);
}

// -------------------------------------------------------------------------------
//  updateTextView:textView
//
//  Called by our window controller to update our text view after a read operation.
// -------------------------------------------------------------------------------
- (void)updateTextView:(NSTextView *)inTextView
{
    // take our model data and apply it to the textView
    if (_notes != nil)
    {
        [inTextView replaceCharactersInRange:[self entireRange] withString:_notes];
    }
}

// -------------------------------------------------------------------------------
//  updateImage:image
//
//  Called by our window controller to update our image view after a read operation.
// -------------------------------------------------------------------------------
- (void)updateImageView:(NSImageView *)inImageView
{
    // take our model data and apply it to the textView
    [inImageView setImage:self.image];
}

// -------------------------------------------------------------------------------
//  updateImageModel:image
//
//  This is called from our NSWindowController when an new image is dragged in.
// -------------------------------------------------------------------------------
- (void)updateImageModel:(NSImage *)inImage
{
     [self setImage:inImage];
     
     // remove the image file wrapper, if it exists
     NSFileWrapper *imageFileWrapper = [[[self documentFileWrapper] fileWrappers] objectForKey:ImageFileName];
     if (imageFileWrapper != nil)
     {
         [[self documentFileWrapper] removeFileWrapper:imageFileWrapper];
     }
     [self updateChangeCount:NSChangeDone];
}

// -------------------------------------------------------------------------------
//  updateTextModel:text
//
//  This is called from our NSWindowController when the text has changed.
// -------------------------------------------------------------------------------
- (void)updateTextModel:(NSString *)text
{
    // remove the text file wrapper, if it exists
    NSFileWrapper *textFileWrapper = [[[self documentFileWrapper] fileWrappers] objectForKey:TextFileName];
    if (textFileWrapper != nil)
    {
        [[self documentFileWrapper] removeFileWrapper:textFileWrapper];
    }
    
    [self updateChangeCount:NSChangeDone];
}

// -------------------------------------------------------------------------------
// updateChangeCount:change
// -------------------------------------------------------------------------------
- (void)updateChangeCount:(NSDocumentChangeType)change
{
    // keeping track of changes are handled automatically by NSDocument,
    // but in case we want to track these changes independently of the built in NSUndoManager, we do it here
    //
    [super updateChangeCount:change];
    
    if (change == NSChangeDone)
    { }
}


#pragma mark - MyWindowControllerDelegate

- (void)windowController:(MyWindowController *)windowController didDiscloseImage:(BOOL)disclosedImage
{
    // as a delegate we are notified by our NSWindowController subclass that the user disclosed
    // the attachmentView (holding/displaying the image)
    //
    [self.metaDataDict setValue:[NSNumber numberWithBool:disclosedImage] forKey:MetaDataDisclosedKey];
}

@end
