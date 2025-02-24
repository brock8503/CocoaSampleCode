/*
     File: ImageBrowserController.m
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


#import "ImageBrowserController.h"
#import "ImageBrowserBackgroundLayer.h"


// -------------------------------------------------------------------------
//	openFiles
//
//	A simple C function that opens NSOpenPanel and returns an array of file paths.
//	It uses uniform type identifiers (UTIs) for proper filtering of image files.
// -------------------------------------------------------------------------
static NSArray* openFiles()
{ 
	// Get a list of extensions to filter in our NSOpenPanel.
	NSOpenPanel* panel = [NSOpenPanel openPanel];

    [panel setCanChooseDirectories:YES];	// The user can choose a folder; images in the folder are added recursively.
    [panel setCanChooseFiles:YES];
	[panel setAllowsMultipleSelection:YES];

    [panel setAllowedFileTypes:[NSImage imageUnfilteredTypes]];
    NSInteger result = [panel runModal];
    if (result == NSFileHandlingPanelOKButton)
		return [panel URLs];

    return nil;
} 


//==============================================================================
// This is the data source object.
@interface myImageObject : NSObject
{
    NSString* path; 
}
@end

@implementation myImageObject

// -------------------------------------------------------------------------
//	dealloc
// -------------------------------------------------------------------------
- (void)dealloc
{
    [path release];
    [super dealloc];
}

// -------------------------------------------------------------------------
//	setPath:path
//
//	The data source object is just a file path representation
// -------------------------------------------------------------------------
- (void)setPath:(NSString*)inPath
{
    if (path != inPath)
	{
        [path release];
        path = [inPath retain];
    }
}

// The required methods of the IKImageBrowserItem protocol.
#pragma mark -
#pragma mark item data source protocol

// -------------------------------------------------------------------------
//	imageRepresentationType:
//
//	Set up the image browser to use a path representation.
// -------------------------------------------------------------------------
- (NSString*)imageRepresentationType
{
	return IKImageBrowserPathRepresentationType;
}

// -------------------------------------------------------------------------
//	imageRepresentation:
//
//	Give the path representation to the image browser.
// -------------------------------------------------------------------------
- (id)imageRepresentation
{
	return path;
}

// -------------------------------------------------------------------------
//	imageUID:
//
//	Use the absolute file path as the identifier.
// -------------------------------------------------------------------------
- (NSString*)imageUID
{
    return path;
}

// -------------------------------------------------------------------------
//	imageTitle:
//
//	Use the last path component as the title.
// -------------------------------------------------------------------------
- (NSString*)imageTitle
{
    return [[path lastPathComponent] stringByDeletingPathExtension];
}

// -------------------------------------------------------------------------
//	imageSubtitle:
//
//	Use the file extension as the subtitle.
// -------------------------------------------------------------------------
- (NSString*)imageSubtitle
{
    return [path pathExtension];
}

@end

//==============================================================================
@implementation ImageBrowserController

// -------------------------------------------------------------------------
//	dealloc:
// -------------------------------------------------------------------------
- (void)dealloc
{
    [images release];
    [importedImages release];
    [super dealloc];
}

// -------------------------------------------------------------------------
//	awakeFromNib:
// -------------------------------------------------------------------------
- (void)awakeFromNib
{
	// Create two arrays : The first is for the data source representation.
	// The second one contains temporary imported images  for thread safeness.
    images = [[NSMutableArray alloc] init];
    importedImages = [[NSMutableArray alloc] init];
    
    // Allow reordering, animations and set the dragging destination delegate.
    [imageBrowser setAllowsReordering:YES];
    [imageBrowser setAnimates:YES];
    [imageBrowser setDraggingDestinationDelegate:self];
	
	// customize the appearance
	[imageBrowser setCellsStyleMask:IKCellsStyleTitled | IKCellsStyleOutlined];
	
	// background layer
	ImageBrowserBackgroundLayer *backgroundLayer = [[[ImageBrowserBackgroundLayer alloc] init] autorelease];
	[imageBrowser setBackgroundLayer:backgroundLayer];
	backgroundLayer.owner = imageBrowser;
	
	//-- change default font 
	// create a centered paragraph style
	NSMutableParagraphStyle *paraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
	[paraphStyle setAlignment:NSCenterTextAlignment];
	
	NSMutableDictionary *attributes = [[[NSMutableDictionary alloc] init] autorelease];	
	[attributes setObject:[NSFont systemFontOfSize:12] forKey:NSFontAttributeName]; 
	[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];	
	[attributes setObject:[NSColor blackColor] forKey:NSForegroundColorAttributeName];
	[imageBrowser setValue:attributes forKey:IKImageBrowserCellsTitleAttributesKey];
	
	attributes = [[[NSMutableDictionary alloc] init] autorelease];	
	[attributes setObject:[NSFont boldSystemFontOfSize:12] forKey:NSFontAttributeName]; 
	[attributes setObject:paraphStyle forKey:NSParagraphStyleAttributeName];	
	[attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	
	[imageBrowser setValue:attributes forKey:IKImageBrowserCellsHighlightedTitleAttributesKey];	
	
	//change intercell spacing
	[imageBrowser setIntercellSpacing:NSMakeSize(10, 80)];
	
	//change selection color
	[imageBrowser setValue:[NSColor colorWithCalibratedRed:1 green:0 blue:0.5 alpha:1.0] forKey:IKImageBrowserSelectionColorKey];
	
	//set initial zoom value
	[imageBrowser setZoomValue:0.5];
}

// -------------------------------------------------------------------------
//	updateDatasource:
//
//	This is the entry point for reloading image browser data and triggering setNeedsDisplay.
// -------------------------------------------------------------------------
- (void)updateDatasource
{
    // Update the datasource, add recently imported items.
    [images addObjectsFromArray:importedImages];
	
	// Empty the temporary array.
    [importedImages removeAllObjects];
    
    // Reload the image browser, which triggers setNeedsDisplay.
    [imageBrowser reloadData];
}


#pragma mark -
#pragma mark import images from file system

// -------------------------------------------------------------------------
//	isImageFile:filePath
//
//	This utility method indicates if the file located at 'filePath' is
//	an image file based on the UTI. It relies on the ImageIO framework for the
//	supported type identifiers.
//
// -------------------------------------------------------------------------
- (BOOL)isImageFile:(NSString*)filePath
{
	BOOL				isImageFile = NO;
	LSItemInfoRecord	info;
	CFStringRef			uti = NULL;
	
	CFURLRef url = CFURLCreateWithFileSystemPath(NULL, (CFStringRef)filePath, kCFURLPOSIXPathStyle, FALSE);
	
	if (LSCopyItemInfoForURL(url, kLSRequestExtension | kLSRequestTypeCreator, &info) == noErr)
	{
		// Obtain the UTI using the file information.
		
		// If there is a file extension, get the UTI.
		if (info.extension != NULL)
		{
			uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, info.extension, kUTTypeData);
			CFRelease(info.extension);
		}

		// No UTI yet
		if (uti == NULL)
		{
			// If there is an OSType, get the UTI.
			CFStringRef typeString = UTCreateStringForOSType(info.filetype);
			if ( typeString != NULL)
			{
				uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassOSType, typeString, kUTTypeData);
				CFRelease(typeString);
			}
		}
		
		// Verify that this is a file that the ImageIO framework supports.
		if (uti != NULL)
		{
			CFArrayRef  supportedTypes = CGImageSourceCopyTypeIdentifiers();
			CFIndex		i, typeCount = CFArrayGetCount(supportedTypes);

			for (i = 0; i < typeCount; i++)
			{
				if (UTTypeConformsTo(uti, (CFStringRef)CFArrayGetValueAtIndex(supportedTypes, i)))
				{
					isImageFile = YES;
					break;
				}
			}
            
            CFRelease(supportedTypes);
            CFRelease(uti);
		}
	}
    
    CFRelease(url);
	
	return isImageFile;
}

// -------------------------------------------------------------------------
//	addAnImageWithPath:path
// -------------------------------------------------------------------------
- (void)addAnImageWithPath:(NSString*)path
{   
	BOOL addObject = NO;
	
	NSDictionary* fileAttribs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
	if (fileAttribs)
	{
		// Check for packages.
		if ([NSFileTypeDirectory isEqualTo:[fileAttribs objectForKey:NSFileType]])
		{
			if ([[NSWorkspace sharedWorkspace] isFilePackageAtPath:path] == NO)
				addObject = YES;	// If it is a file, it's OK to add.
		}
		else
		{
			addObject = YES;	// It is a file, so it's OK to add.
		}
	}
	
	if (addObject && [self isImageFile:path])
	{
		// Add a path to the temporary images array.
		myImageObject* p = [[myImageObject alloc] init];
		[p setPath:path];
		[importedImages addObject:p];
		[p release];
	}
}

// -------------------------------------------------------------------------
//	addImagesWithPath:path:recursive
// -------------------------------------------------------------------------
- (void)addImagesWithPath:(NSString*)path
{
    BOOL dir;
    [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&dir];
    
    if (dir)
	{
		NSInteger i, n;
		
		NSArray* content = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        n = [content count];

		// Parse the directory content.
        for (i = 0; i < n; i++)
		{
			[self addAnImageWithPath:[path stringByAppendingPathComponent:[content objectAtIndex:i]]];
        }
    }
    else
	{
		[self addAnImageWithPath:path];
	}
}

// -------------------------------------------------------------------------
//	addImagesWithPaths:paths
//
//	Performed in an independent thread, parse all paths in "paths" and
//	add these paths in the temporary images array.
// -------------------------------------------------------------------------
- (void)addImagesWithPaths:(NSArray*)paths
{   
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    [paths retain];

    NSInteger i, n;
	n = [paths count];
    for (i = 0; i < n; i++)
	{
        NSURL *url = [paths objectAtIndex:i];
		[self addImagesWithPath:[url path]];
    }

	// Update the data source in the main thread.
    [self performSelectorOnMainThread:@selector(updateDatasource) withObject:nil waitUntilDone:YES];

    [paths release];
    [pool release];
}


#pragma mark -
#pragma mark actions

// -------------------------------------------------------------------------
//	addImageButtonClicked:sender
//
//	The user clicked the Add button.d
// -------------------------------------------------------------------------
- (IBAction)addImageButtonClicked:(id)sender
{
    NSArray* path = openFiles();
    if (path)
	{ 
        // launch import in an independent thread
		[NSThread detachNewThreadSelector:@selector(addImagesWithPaths:) toTarget:self withObject:path];
	}
}

// -------------------------------------------------------------------------
//	addImageButtonClicked:sender
//
//	Action called when the zoom slider changes.
// ------------------------------------------------------------------------- 
- (IBAction)zoomSliderDidChange:(id)sender
{
	// update the zoom value to scale images
    [imageBrowser setZoomValue:[sender floatValue]];
	
	// redisplay
    [imageBrowser setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark IKImageBrowserDataSource

// Implement the image browser  data source protocol .
// The data source representation is a simple mutable array.

// -------------------------------------------------------------------------
//	numberOfItemsInImageBrowser:view
// ------------------------------------------------------------------------- 
- (NSUInteger)numberOfItemsInImageBrowser:(IKImageBrowserView*)view
{
	// The item count to display is the datadsource item count.
    return [images count];
}

// -------------------------------------------------------------------------
//	imageBrowser:view:index:
// ------------------------------------------------------------------------- 
- (id)imageBrowser:(IKImageBrowserView *) view itemAtIndex:(NSUInteger) index
{
    return [images objectAtIndex:index];
}


// Implement some optional methods of the image browser  datasource protocol to allow for removing and reodering items.

// -------------------------------------------------------------------------
//	removeItemsAtIndexes:
//
//	The user wants to delete images, so remove these entries from the data source.	
// ------------------------------------------------------------------------- 
- (void)imageBrowser:(IKImageBrowserView*)view removeItemsAtIndexes: (NSIndexSet*)indexes
{
	[images removeObjectsAtIndexes:indexes];
}

// -------------------------------------------------------------------------
//	moveItemsAtIndexes:
//
//	The user wants to reorder images, update the datadsource and the browser
//	will reflect our changes.
// ------------------------------------------------------------------------- 
- (BOOL)imageBrowser:(IKImageBrowserView*)view moveItemsAtIndexes: (NSIndexSet*)indexes toIndex:(unsigned int)destinationIndex
{
	NSUInteger		index;
	NSMutableArray*	temporaryArray;

	temporaryArray = [[[NSMutableArray alloc] init] autorelease];

	// First remove items from the data source and keep them in a temporary array.
	for (index = [indexes lastIndex]; index != NSNotFound; index = [indexes indexLessThanIndex:index])
	{
		if (index < destinationIndex)
		  destinationIndex --;

		id obj = [images objectAtIndex:index];
		[temporaryArray addObject:obj];
		[images removeObjectAtIndex:index];
	}

	// Then insert the removed items at the appropriate location.
	NSUInteger n = [temporaryArray count];
	for (index = 0; index < n; index++)
	{
		[images insertObject:[temporaryArray objectAtIndex:index] atIndex:destinationIndex];
	}

	return YES;
}


#pragma mark -
#pragma mark drag n drop 

// -------------------------------------------------------------------------
//	draggingEntered:sender
// ------------------------------------------------------------------------- 
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

// -------------------------------------------------------------------------
//	draggingUpdated:sender
// ------------------------------------------------------------------------- 
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    return NSDragOperationCopy;
}

// -------------------------------------------------------------------------
//	performDragOperation:sender
// ------------------------------------------------------------------------- 
- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSData*			data = nil;
    NSPasteboard*	pasteboard = [sender draggingPasteboard];

	// Look for paths on the pasteboard.
    if ([[pasteboard types] containsObject:NSFilenamesPboardType]) 
        data = [pasteboard dataForType:NSFilenamesPboardType];

    if (data)
	{
		NSString* errorDescription;
		
		// Retrieve  paths.
        NSArray* filenames = [NSPropertyListSerialization propertyListFromData:data 
								mutabilityOption:kCFPropertyListImmutable 
								format:nil 
								errorDescription:&errorDescription];

		// Add paths to the data source.
		[self addImagesWithPaths:filenames];
		
		// Make the image browser reload the data source.
        [self updateDatasource];
    }

	// Accept the drag operation.
	return YES;
}

@end
