//---------------------------------------------------------------------------
//
//	File: OpenGLPlasmaExhibitsPrefPanelUIController.m
//
//  Abstract: Preferences Controller class
// 			 
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
//  Computer, Inc. ("Apple") in consideration of your agreement to the
//  following terms, and your use, installation, modification or
//  redistribution of this Apple software constitutes acceptance of these
//  terms.  If you do not agree with these terms, please do not use,
//  install, modify or redistribute this Apple software.
//  
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software. 
//  Neither the name, trademarks, service marks or logos of Apple Computer,
//  Inc. may be used to endorse or promote products derived from the Apple
//  Software without specific prior written permission from Apple.  Except
//  as expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//  
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//  
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
// 
//  Copyright (c) 2008, 2012 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import "NSImageLoader.h"
#import "OpenGLImageView.h"
#import "OpenGLPlasmaExhibitsPrefPanelUIController.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

@implementation OpenGLPlasmaExhibitsPrefPanelUIController

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Post Notification

//---------------------------------------------------------------------------

- (void) postNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(plasmaExhibitsPrefsUIControllerWillTerminate:)
												 name:@"NSApplicationWillTerminateNotification"
											   object:NSApp];
} // postNotification

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Setting Images

//---------------------------------------------------------------------------

- (void) imageViewSet:(const NSUInteger)theImageIndex
{
	NSImage *image = [fileTypeImages imageAtIndex:theImageIndex];
	
	if( image )
	{
		[imageTypeIcons setImage:image];
	} // if
} // imageViewSet

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Application Startup

//---------------------------------------------------------------------------

- (void) initImages
{
	NSArray *imageFileNames = [NSArray arrayWithObjects:@"BMPFile",
							   @"GIFFile",
							   @"JP2File",
							   @"JPEGFile",
							   @"PDFFile",
							   @"PNGFile",
							   @"TIFFFile",
							   nil];
	
	fileTypeImages = [[NSImageLoader alloc] initWithImagesInAppBundle:imageFileNames 
																 type:@"tiff"];
} // initImages

//---------------------------------------------------------------------------

- (void) initOpenPanels
{
	snapshotOpenPanel = [[NSOpenPanel openPanel] retain];
	
    [snapshotOpenPanel setMessage:@"Choose destination folder for captured images"];
	[snapshotOpenPanel setCanChooseDirectories:YES];
	[snapshotOpenPanel setResolvesAliases:YES];
	[snapshotOpenPanel setCanChooseFiles:NO];
    [snapshotOpenPanel setAllowsMultipleSelection:NO];
	[snapshotOpenPanel setCanCreateDirectories:YES];
	[snapshotOpenPanel setPrompt:@"Select"];
	[snapshotOpenPanel setDirectoryURL:[NSURL fileURLWithPath:imageDirectory
												  isDirectory:YES]];
} // initOpenPanels

//---------------------------------------------------------------------------

- (void) initSaveLocationControls
{
	imageDirectory = [[plasmaExhibitsView preferenceGetObjectForKey:@"Image Directory"] retain];
	
	[snapshotLocationPath setStringValue:imageDirectory];
} // initSaveLocationControls

//---------------------------------------------------------------------------

- (void) initImageTypeControl
{
	NSNumber          *imageRowIndexNum = [plasmaExhibitsView preferenceGetObjectForKey:@"Image Type"];
	ImageFileFormats   imageRowIndex    = [imageRowIndexNum unsignedIntValue];
	
	[self imageViewSet:imageRowIndex];
	
	[imageTypes setState:YES 
				   atRow:imageRowIndex 
				  column:0]; 
} // initImageTypeControl

//---------------------------------------------------------------------------

- (void) initImageCompressionControls
{
	NSNumber *compressionNum        = [plasmaExhibitsView preferenceGetObjectForKey:@"Image Compression"];
	float     compressionScale      = [compressionNum floatValue];
	int       compressionPercentage = (int)( 100.0f * compressionScale );
	
	[compressionSlider setFloatValue:compressionScale];
	[compressionFactor setIntValue:compressionPercentage];
} // initImageCompressionControls

//---------------------------------------------------------------------------

- (void) initPDFOptionalInfoControls
{
	[optionalTitle   setStringValue:[plasmaExhibitsView preferenceGetObjectForKey:@"PDF Optional Title"]];
	[optionalAuthor  setStringValue:[plasmaExhibitsView preferenceGetObjectForKey:@"PDF Optional Author"]];
	[optionalSubject setStringValue:[plasmaExhibitsView preferenceGetObjectForKey:@"PDF Optional Subject"]];
	[optionalCreator setStringValue:[plasmaExhibitsView preferenceGetObjectForKey:@"PDF Optional Creator"]];
} // initPDFOptionalInfoControls

//---------------------------------------------------------------------------

- (void) initDisplayViewBoundsLabelControl
{
	NSNumber *displayViewBoundsLabelStateNum = [plasmaExhibitsView preferenceGetObjectForKey:@"Display View Bounds Label"];

	[displayViewBoundsLabelButton setState:[displayViewBoundsLabelStateNum boolValue]];
} // initDisplayViewBoundsLabelControl

//---------------------------------------------------------------------------

- (void) initDisplayPrefTimerLabelControls
{
	NSNumber *displayPrefTimerLabelStateNum = [plasmaExhibitsView preferenceGetObjectForKey:@"Display Pref Timer Label"];
	
	[displayPrefTimerLabelButton setState:[displayPrefTimerLabelStateNum boolValue]];
} // initDisplayPrefTimerLabelControls

//---------------------------------------------------------------------------

- (void) initDisplayRendererLabelControls
{
	NSNumber *displayRendererLabelStateNum = [plasmaExhibitsView preferenceGetObjectForKey:@"Display Renderer Label"];
	
	[displayRendererLabelButton setState:[displayRendererLabelStateNum boolValue]];
} // initDisplayRendererLabelControls

//---------------------------------------------------------------------------

- (void) initLabelControls
{
	[self initDisplayViewBoundsLabelControl];
	[self initDisplayPrefTimerLabelControls];
	[self initDisplayRendererLabelControls];
} // initLabelControls

//---------------------------------------------------------------------------

- (void) initControls
{
	[self initSaveLocationControls];
	[self initImageTypeControl];
	[self initImageCompressionControls];
	[self initPDFOptionalInfoControls];
	[self initLabelControls];
} // initControls

//---------------------------------------------------------------------------

- (void) initToolbarItems
{
	[toolbar setDelegate:(id<NSToolbarDelegate>)self];
	
	toolbarItemIds = [[NSArray alloc] initWithObjects:
					  [toolbarItemIsSaveLocation itemIdentifier],
					  [toolbarItemIsImageTypes itemIdentifier],
					  [toolbarItemIsImageCompression itemIdentifier],
					  [toolbarItemIsPDFOptionalInfo itemIdentifier],
					  [toolbarItemIsLabels itemIdentifier],
					  nil];
	
	[toolbar setSelectedItemIdentifier:[toolbarItemIsImageTypes itemIdentifier]];
	[tabViews selectTabViewItem:tabViewItemIsImageTypes];
} // initToolbarItems

//---------------------------------------------------------------------------

- (void) awakeFromNib
{
	[self postNotification];

	[self initImages];
	[self initControls];
	[self initOpenPanels];
	[self initToolbarItems];
} // awakeFromNib

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Releasing Objects

//---------------------------------------------------------------------------

- (void) cleanUpPrefsUIController
{
	if( fileTypeImages )
	{
		[fileTypeImages release];
		
		fileTypeImages = nil;
	} // if
	
	if( snapshotOpenPanel )
	{
		[snapshotOpenPanel release];
		
		snapshotOpenPanel = nil;
	} // if
	
	if( imageDirectory )
	{
		[imageDirectory release];
		
		imageDirectory = nil;
	} // if
	
	if( toolbarItemIds )
	{
		[toolbarItemIds  release];
		
		toolbarItemIds = nil;
	} // if
} // cleanUpPrefsUIController

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Preference Panel

//---------------------------------------------------------------------------

- (IBAction) preferencesMenuItemSelected:(id)sender
{
    if( !preferencesPanel )
	{
		[preferencesPanel setHidesOnDeactivate:YES];
		[preferencesPanel setExcludedFromWindowsMenu:YES];
		[preferencesPanel setMenu:nil];
        [preferencesPanel center];
    } // if
	
    [preferencesPanel makeKeyAndOrderFront:nil];
} // preferencesMenuItemSelected

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Toolbar Items

//---------------------------------------------------------------------------

- (IBAction) toolbarSelectedItemIsSaveLocation:(id)sender
{
	[tabViews selectTabViewItem:tabViewItemIsSaveLocation];
} // toolbarSelectedItemIsSaveLocation

//---------------------------------------------------------------------------

- (IBAction) toolbarSelectedItemIsImageTypes:(id)sender
{
	[tabViews selectTabViewItem:tabViewItemIsImageTypes];
} // toolbarSelectedItemIsImageTypes

//---------------------------------------------------------------------------

- (IBAction) toolbarSelectedItemIsImageCompression:(id)sender
{
	[tabViews selectTabViewItem:tabViewItemIsImageCompression];
} // toolbarSelectedItemIsImageCompression

//---------------------------------------------------------------------------

- (IBAction) toolbarSelectedItemIsPDFOptionalInfo:(id)sender
{
	[tabViews selectTabViewItem:tabViewItemIsPDFOptionalInfo];
} // toolbarSelectedItemIsPDFOptionalInfo

//---------------------------------------------------------------------------

- (IBAction) toolbarSelectedItemIsLabels:(id)sender
{
	[tabViews selectTabViewItem:tabViewItemIsLabels];
} // toolbarSelectedItemIsLabels

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Image Types

//---------------------------------------------------------------------------

- (IBAction) imageTypeIsSelected:(id)sender
{
	NSUInteger imageRowIndex = [sender selectedRow];
	
	[self imageViewSet:imageRowIndex];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithUnsignedInt:imageRowIndex] 
									 forKey:@"Image Type"];
}  // imageTypeIsSelected

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark PDF Optional Info

//---------------------------------------------------------------------------

- (IBAction) optionalTitleChanged:(id)sender
{
	NSString *pdfTitle = [sender stringValue];
	
	if( pdfTitle == nil )
	{
		[optionalTitle setStringValue:@"Title"];
		
		[plasmaExhibitsView preferenceSetObject:@"Title" 
										 forKey:@"PDF Optional Title"];
	} // if
	else
	{
		[optionalTitle setStringValue:pdfTitle];
		
		[plasmaExhibitsView preferenceSetObject:pdfTitle 
										 forKey:@"PDF Optional Title"];
	} // else
} // optionalTitleChanged

//---------------------------------------------------------------------------

- (IBAction) optionalAuthorChanged:(id)sender
{
	NSString *pdfAuthor = [sender stringValue];
	
	if( pdfAuthor == nil )
	{
		[optionalAuthor setStringValue:@"Author"];
		
		[plasmaExhibitsView preferenceSetObject:@"Author" 
										 forKey:@"PDF Optional Author"];
	} // if
	else
	{
		[plasmaExhibitsView preferenceSetObject:pdfAuthor 
										 forKey:@"PDF Optional Author"];
		
		[optionalAuthor setStringValue:pdfAuthor];
	} // else
} // optionalAuthorChanged

//---------------------------------------------------------------------------

- (IBAction) optionalSubjectChanged:(id)sender
{
	NSString *pdfSubject = [sender stringValue];
	
	if( pdfSubject == nil )
	{
		[optionalSubject setStringValue:@"Subject"];
		
		[plasmaExhibitsView preferenceSetObject:@"Subject" 
										 forKey:@"PDF Optional Subject"];
	} // if
	else
	{
		[plasmaExhibitsView preferenceSetObject:pdfSubject 
										 forKey:@"PDF Optional Subject"];
		
		[optionalSubject setStringValue:pdfSubject];
	} // else
} // optionalSubjectChanged

//---------------------------------------------------------------------------

- (IBAction) optionalCreatorChanged:(id)sender
{
	NSString *pdfCreator = [sender stringValue];
	
	if( pdfCreator == nil )
	{
		[optionalCreator setStringValue:@"Creator"];

		[plasmaExhibitsView preferenceSetObject:@"Creator" 
										 forKey:@"PDF Optional Creator"];
	} // if
	else
	{
		[optionalCreator setStringValue:pdfCreator];
		
		[plasmaExhibitsView preferenceSetObject:pdfCreator 
										 forKey:@"PDF Optional Creator"];
	} // else
} // optionalCreatorChanged

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark File Compression

//---------------------------------------------------------------------------

- (IBAction) compressionFactorChanged:(id)sender
{
	int    compressionPercentage = [sender intValue];
	float  compressionScale      = (float)compressionPercentage / 100.0f;
	
	[compressionSlider setFloatValue:compressionScale];

	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithFloat:compressionScale] 
									 forKey:@"Image Compression"];	
} // compressionFactorChanged

//---------------------------------------------------------------------------

- (IBAction) compressionSliderChanged:(id)sender
{
	float compressionScale      = [sender floatValue];
	int   compressionPercentage = (int)( 100.0f * compressionScale );
		
	[compressionFactor setIntValue:compressionPercentage];

	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithFloat:compressionScale] 
									 forKey:@"Image Compression"];	
} // compressionSliderChanged

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Label Selection

//---------------------------------------------------------------------------

- (IBAction) displayViewBoundsLabelSelected:(id)sender
{
	BOOL isSelected = [sender state];
	
	[plasmaExhibitsView viewBoundsDisplayLabel:isSelected];

	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithBool:isSelected] 
									 forKey:@"Display View Bounds Label"];	
} // displayViewBoundsLabelSelected

//---------------------------------------------------------------------------

- (IBAction) displayPrefTimerLabelSelected:(id)sender
{
	BOOL isSelected = [sender state];

	[plasmaExhibitsView prefTimerDisplayLabel:isSelected];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithBool:isSelected] 
									 forKey:@"Display Pref Timer Label"];	
} // displayPrefTimerLabelSelected

//---------------------------------------------------------------------------

- (IBAction) displayRendererLabelSelected:(id)sender
{
	BOOL isSelected = [sender state];
	
	[plasmaExhibitsView rendererDisplayLabel:isSelected];
	
	[plasmaExhibitsView preferenceSetObject:[NSNumber numberWithBool:isSelected] 
									 forKey:@"Display Renderer Label"];	
} // displayRendererLabelSelected

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Snapshot Location

//---------------------------------------------------------------------------

- (IBAction) snapshotLocationButtonPressed:(id)sender
{
	void (^snapshotOpenPanelHandler)(NSInteger) = ^( NSInteger result )
	{
		NSURL *imageDirectoryURL = [snapshotOpenPanel directoryURL];
		
		if( imageDirectoryURL )
		{
			NSString *imageDirectoryPath = [imageDirectoryURL path];
			
			if( imageDirectoryPath )
			{
				[imageDirectoryPath retain];
				[imageDirectory release];
				
				imageDirectory = imageDirectoryPath;
				
				[snapshotLocationPath setStringValue:imageDirectory];
				
				[plasmaExhibitsView preferenceSetObject:imageDirectory 
												 forKey:@"Image Directory"];	
			} // if
		} // if
	};
	
	[snapshotOpenPanel beginSheetModalForWindow:preferencesPanel 
							  completionHandler:snapshotOpenPanelHandler];
} // snapshotLocationButtonPressed

//---------------------------------------------------------------------------

- (IBAction) snapshotLocationPathChanged:(id)sender
{
	NSString *imageNewDirectory = [sender stringValue];

	[imageNewDirectory retain];
	[imageDirectory release];
	imageDirectory = imageNewDirectory;

	[plasmaExhibitsView preferenceSetObject:imageDirectory 
									 forKey:@"Image Directory"];	 
} // snapshotLocationPathChanged

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Notification

//---------------------------------------------------------------------------
//
// It's important to clean up our rendering objects before we terminate -- 
// Cocoa will not specifically release everything on application termination, 
// so we explicitly call our clean up routine ourselves.
//
//---------------------------------------------------------------------------

- (void) plasmaExhibitsPrefsUIControllerWillTerminate:(NSNotification *)notification
{
	[self cleanUpPrefsUIController];
} // plasmaExhibitsPrefsUIControllerWillTerminate

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Delegates

//---------------------------------------------------------------------------
// 
// Returns the identifiers of the toolbar items that are selectable.
//
//---------------------------------------------------------------------------

- (NSArray *) toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar;
{
    return( toolbarItemIds );
} // toolbarSelectableItemIdentifiers

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
