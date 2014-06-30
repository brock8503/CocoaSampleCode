/*
     File: OpenGLPlasmaExhibitsPrefsMediator.m
 Abstract: 
 Utility class for managing application preferences and miscellaneous application settings on startup.
 
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
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 */

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#import "OpenGLPlasmaExhibitsPrefsMediator.h"

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------------------

@implementation OpenGLPlasmaExhibitsPrefsMediator

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Default Directories Check

//---------------------------------------------------------------------------------------

- (void) createDirectoryAtPath:(NSString *)theDirPath
				   fileManager:(NSFileManager *)theDefaultManager
{
	NSError *dirError = nil;
	
	BOOL dirCreated = [theDefaultManager createDirectoryAtPath:theDirPath
								   withIntermediateDirectories:YES
													attributes:nil
														 error:&dirError];
	if( !dirCreated )
	{
		NSLog( @">> ERROR: Preferences Mediator - Creating directory \"%@\" failed!", theDirPath );
		NSLog( @"                                 with error: %@", dirError );
		
		[dirError release];
	} // if
} // createDirectory

//---------------------------------------------------------------------------------------

- (void) checkDirectories
{
	BOOL directoryExists = NO;
	
	NSFileManager  *defaultManager = [NSFileManager defaultManager];
	
	NSArray   *picturePaths = NSSearchPathForDirectoriesInDomains(NSPicturesDirectory, NSUserDomainMask, YES);
	NSString  *picturePath  = [picturePaths objectAtIndex:0];
	
	mpDirectoryImage = [[picturePath stringByAppendingPathComponent:@"SnapShots"] retain];
	
	directoryExists = [defaultManager fileExistsAtPath:mpDirectoryImage
										   isDirectory:NULL];
	
	if( !directoryExists )
	{
		[self createDirectoryAtPath:mpDirectoryImage
						fileManager:defaultManager];
	} // if
	
	NSArray   *moviePaths = NSSearchPathForDirectoriesInDomains(NSMoviesDirectory, NSUserDomainMask, YES);
	NSString  *moviePath  = [moviePaths objectAtIndex:0];
	
	mpDirectoryMovie = [[moviePath stringByAppendingPathComponent:@"Captures"] retain];
	
	directoryExists = [defaultManager fileExistsAtPath:mpDirectoryMovie
										   isDirectory:NULL];
	
	if( !directoryExists )
	{
		[self createDirectoryAtPath:mpDirectoryMovie
						fileManager:defaultManager];
	} // if
} // checkDirectories

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Preference File Reader

//---------------------------------------------------------------------------------------

- (void) readPreferences
{
	mbIsRead = [self read];
	
	if( !mbIsRead )
	{
		NSArray *preferencesObjects = [NSArray arrayWithObjects:mpDirectoryImage,
									   mpDirectoryMovie,
									   [NSNumber numberWithUnsignedInt:kFileFormatIsJPEG],
									   [NSNumber numberWithFloat:0.5f],
									   @"Title",
									   @"Author",
									   @"Subject",
									   @"Creator",
									   [NSNumber numberWithBool:YES],
									   [NSNumber numberWithBool:YES],
									   [NSNumber numberWithBool:YES],
									   [NSNumber numberWithUnsignedInt:kPlasmaExhibitIsTranguloidTrefoilSurface],
									   [NSNumber numberWithFloat:0.0f],
									   [NSNumber numberWithFloat:0.0f],
									   [NSNumber numberWithFloat:0.0f],
									   nil];
		
		NSArray *preferencesKeys = [NSArray arrayWithObjects:@"Image Directory",
									@"Movie Directory",
									@"Image Type",
									@"Image Compression",
									@"PDF Optional Title",
									@"PDF Optional Author",
									@"PDF Optional Subject",
									@"PDF Optional Creator",
									@"Display View Bounds Label",
									@"Display Pref Timer Label",
									@"Display Renderer Label",
									@"Exhibit Type",
									@"Light X Position",
									@"Light Y Position",
									@"Light Z Position",
									nil];
		
		[self setObjects:preferencesObjects
				 forKeys:preferencesKeys];
	} // if
} // readPreferences

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Validate Preferences

//---------------------------------------------------------------------------------------

- (void) checkSnapshotSaveLocationPreference
{
	NSString *imageDefaultDirectory = [self objectForKey:@"Image Directory"];
	
	if( !imageDefaultDirectory )
	{
		[self setObject:mpDirectoryImage
				 forKey:@"Image Directory"];
	} // else
} // checkSnapshotSaveLocationPreference

//---------------------------------------------------------------------------------------

- (void) checkMovieSaveLocationPreference
{
	NSString *movieDefaultDirectory = [self objectForKey:@"Movie Directory"];
	
	if( !movieDefaultDirectory )
	{
		[self setObject:mpDirectoryMovie
				 forKey:@"Movie Directory"];
	} // else
} // checkMovieSaveLocationPreference

//---------------------------------------------------------------------------------------

- (void) checkSaveLocationPreferences
{
	[self checkSnapshotSaveLocationPreference];
	[self checkMovieSaveLocationPreference];
} // checkSaveLocationPreferences

//---------------------------------------------------------------------------------------

- (void) checkImageTypePreference
{
	BOOL       imageTypeResetPref = NO;
	NSNumber  *imageRowIndexNum   = [self objectForKey:@"Image Type"];
	
	if( imageRowIndexNum )
	{
		NSUInteger imageRowIndex = [imageRowIndexNum unsignedIntValue];
		
		if( imageRowIndex > kImageFileFormats )
		{
			imageTypeResetPref = YES;
		} // if
	} // if
	else
	{
		imageTypeResetPref = YES;
	} // else
	
	if( imageTypeResetPref )
	{
		[self setObject:[NSNumber numberWithUnsignedInt:kFileFormatIsJPEG]
				 forKey:@"Image Type"];
	} // if
} // checkImageTypePreference

//---------------------------------------------------------------------------------------

- (void) checkImageCompressionPreferences
{
	BOOL       compressionResetPref = NO;
	NSNumber  *compressionScaleNum  = [self objectForKey:@"Image Compression"];
	
	if( compressionScaleNum )
	{
		float compressionScale = [compressionScaleNum floatValue];
		
		if( compressionScale > 1.0f )
		{
			compressionResetPref = YES;
		} // if
	} // if
	else
	{
		compressionResetPref = YES;
	} // else
	
	if( compressionResetPref )
	{
		[self setObject:[NSNumber numberWithFloat:0.5f]
				 forKey:@"Image Compression"];
	} // if
} // checkImageCompressionPreferences

//---------------------------------------------------------------------------------------

- (void) checkPDFOptionalTitleInfoPreference
{
	NSString *pdfTitle = [self objectForKey:@"PDF Optional Title"];
	
	if( !pdfTitle )
	{
		[self setObject:@"Title"
				 forKey:@"PDF Optional Title"];
	} // else
} // checkPDFOptionalTitleInfoPreference

//---------------------------------------------------------------------------------------

- (void) checkPDFOptionalAuthorInfoPreference
{
	NSString *pdfAuthor = [self objectForKey:@"PDF Optional Author"];
	
	if( !pdfAuthor )
	{
		[self setObject:@"Author"
				 forKey:@"PDF Optional Author"];
	} // else
} // checkPDFOptionalAuthorInfoPreference

//---------------------------------------------------------------------------------------

- (void) checkPDFOptionalSubjectInfoPreference
{
	NSString *pdfSubject = [self objectForKey:@"PDF Optional Subject"];
	
	if( !pdfSubject )
	{
		[self setObject:@"Subject"
				 forKey:@"PDF Optional Subject"];
	} // else
} // checkPDFOptionalSubjectInfoPreference

//---------------------------------------------------------------------------------------

- (void) checkPDFOptionalCreatorlInfoPreference
{
	NSString *pdfCreator = [self objectForKey:@"PDF Optional Creator"];
	
	if( !pdfCreator )
	{
		[self setObject:@"Creator"
				 forKey:@"PDF Optional Creator"];
	} // else
} // checkPDFOptionalCreatorlInfoPreference

//---------------------------------------------------------------------------------------

- (void) checkPDFOptionalInfoPreferences
{
	[self checkPDFOptionalTitleInfoPreference];
	[self checkPDFOptionalAuthorInfoPreference];
	[self checkPDFOptionalSubjectInfoPreference];
	[self checkPDFOptionalCreatorlInfoPreference];
} // checkPDFOptionalInfoPreferences

//---------------------------------------------------------------------------------------

- (void) checkViewBoundsLabelPreferences
{
	NSNumber *displayViewBoundsLabelNum = [self objectForKey:@"Display View Bounds Label"];
	
	if( !displayViewBoundsLabelNum )
	{
		[self setObject:[NSNumber numberWithBool:YES]
				 forKey:@"Display View Bounds Label"];
	} // else
} // checkViewBoundsLabelPreferences

//---------------------------------------------------------------------------------------

- (void) checkPrefTimerLabelPreferences
{
	NSNumber *displayPrefTimerLabelNum = [self objectForKey:@"Display Pref Timer Label"];
	
	if( !displayPrefTimerLabelNum )
	{
		[self setObject:[NSNumber numberWithBool:YES]
				 forKey:@"Display Pref Timer Label"];
	} // else
} // checkPrefTimerLabelPreferences

//---------------------------------------------------------------------------------------

- (void) checkRendererLabelLabelPreferences
{
	NSNumber *displayRendererLabelNum = [self objectForKey:@"Display Renderer Label"];
	
	if( !displayRendererLabelNum )
	{
		[self setObject:[NSNumber numberWithBool:YES]
				 forKey:@"Display Renderer Label"];
	} // else
} // checkRendererLabelLabelPreferences

//---------------------------------------------------------------------------------------

- (void) checkLabelsPreferences
{
	[self checkViewBoundsLabelPreferences];
	[self checkPrefTimerLabelPreferences];
	[self checkRendererLabelLabelPreferences];
} // checkLabelsPreferences

//---------------------------------------------------------------------------------------

- (void) checkLightPositionPreferenceWithKey:(NSString *)theLightPositionKey
{
	BOOL      lightPosResetPref = NO;
	NSNumber *lightPositionNum  = [self objectForKey:theLightPositionKey];
	
	if( lightPositionNum )
	{
		float lightPosFValue = [lightPositionNum floatValue];
		
		if( lightPosFValue > 20.0f )
		{
			lightPosResetPref = YES;
		} // if
	} // if
	else
	{
		lightPosResetPref = YES;
	} // else
	
	if( lightPosResetPref )
	{
		[self setObject:[NSNumber numberWithFloat:0.0f]
				 forKey:theLightPositionKey];
	} // if
} // checkLightPositionPreferenceWithKey

//---------------------------------------------------------------------------------------

- (void) checkLightPositionsPreferences
{
	[self checkLightPositionPreferenceWithKey:@"Light X Position"];
	[self checkLightPositionPreferenceWithKey:@"Light Y Position"];
	[self checkLightPositionPreferenceWithKey:@"Light Z Position"];
} // checkLightPositionsPreferences

//---------------------------------------------------------------------------------------

- (void) checkExhibitTypePreferences
{
	BOOL      exibitResetPref = NO;
	NSNumber *exibitTypeNum   = [self objectForKey:@"Exhibit Type"];
	
	if( exibitTypeNum )
	{
		NSUInteger exibitItemIndex = [exibitTypeNum unsignedIntValue] - 1;
		
		if( exibitItemIndex > 4 )
		{
			exibitResetPref = YES;
		} // if
	} // if
	else
	{
		exibitResetPref = YES;
	} // else
	
	if( exibitResetPref )
	{
		[self setObject:[NSNumber numberWithUnsignedInt:kPlasmaExhibitIsTranguloidTrefoilSurface]
				 forKey:@"Exhibit Type"];
	} // if
} // checkExhibitTypePreferences

//---------------------------------------------------------------------------------------

- (void) checkPreferences
{
	[self checkSaveLocationPreferences];
	[self checkImageTypePreference];
	[self checkImageCompressionPreferences];
	[self checkPDFOptionalInfoPreferences];
	[self checkLabelsPreferences];
	[self checkLightPositionsPreferences];
	[self checkExhibitTypePreferences];
} // checkPreferences

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Default Initializer

//---------------------------------------------------------------------------------------

- (id) init
{
	self = [super initPreferencesWithName:@"com.apple.PlasmaExhibitsII.plist"];
	
	if( self )
	{
		[self checkDirectories];
		[self readPreferences];
		
		if( mbIsRead )
		{
			[self checkPreferences];
		} // if
	} // if
	
	return( self );
} // init

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Dealloc Resources

//---------------------------------------------------------------------------------------

- (void) cleanUpExhibitsPrefs
{
	if( mpDirectoryImage )
	{
		[mpDirectoryImage release];
		
		mpDirectoryImage = nil;
	} // if
	
	if( mpDirectoryMovie )
	{
		[mpDirectoryMovie release];
		
		mpDirectoryMovie = nil;
	} // if
} // cleanUpExhibitsPrefs

//---------------------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpExhibitsPrefs];
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

//---------------------------------------------------------------------------------------

- (BOOL) isRead
{
	return( mbIsRead );
} // isRead

//---------------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
