/*
     File: OpenGLViewSnapshot.m
 Abstract: 
 Utility class for capturing a snapshot of an OpenGL view and then generating a CGImage supported file format.
 
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

//-------------------------------------------------------------------------

//------------------------------------------------------------------------

#import "OpenGLViewSnapshot.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

struct CGImageOptions
{
	CFMutableDictionaryRef mpFile;
	CFMutableDictionaryRef mpImage;
};

typedef struct CGImageOptions CGImageOptions;

//------------------------------------------------------------------------

struct CGFileDescription
{
	CFIndex                 mnIndex;
	CFStringRef             mpUTI;
	CFMutableDictionaryRef  mpAuxInfo;
	CGImageOptions          m_Options;
};

typedef struct CGFileDescription CGFileDescription;

//------------------------------------------------------------------------

struct CGFile
{
	ImageFileFormats   m_Format;
	CGFileDescription  m_Description;
};

typedef struct CGFile   CGFile;
typedef struct CGFile  *CGFileRef;

//------------------------------------------------------------------------

struct OpenGLViewSnapshotData
{
	CGImageRef mpImage;
	NSRect     m_Frame;
	CGFile     m_File;
};

typedef struct OpenGLViewSnapshotData   OpenGLViewSnapshotData;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

static const int kTiffCompressionIsLZW = 5;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

@implementation OpenGLViewSnapshot

//------------------------------------------------------------------------

- (id) initViewSnapshotWithFrame:(const NSRect *)theFrame
							   view:(NSOpenGLView *)theBaseView
{
	self = [super initViewImageBaseWithFrame:theFrame
										 view:theBaseView];
	
	if( self )
	{
		mpSnapshot = (OpenGLViewSnapshotDataRef)calloc(1, sizeof(OpenGLViewSnapshotData));
		
		if( mpSnapshot != NULL )
		{
			CFIndex auxInfoCount   = 2;
			CFIndex imageInfoCount = 1;
			
			mpSnapshot->mpImage = NULL;
			mpSnapshot->m_Frame = *theFrame;
			
			mpSnapshot->m_File.m_Format = kFileFormatIsJPEG;
			
			mpSnapshot->m_File.m_Description.mnIndex = 1;
			mpSnapshot->m_File.m_Description.mpUTI   = 0;
			
			mpSnapshot->m_File.m_Description.m_Options.mpFile = NULL;
			
			mpSnapshot->m_File.m_Description.m_Options.mpImage = CFDictionaryCreateMutable(kCFAllocatorDefault,
																						   imageInfoCount,
																						   &kCFTypeDictionaryKeyCallBacks,
																						   &kCFTypeDictionaryValueCallBacks);
			
			mpSnapshot->m_File.m_Description.mpAuxInfo = CFDictionaryCreateMutable(kCFAllocatorDefault,
																				   auxInfoCount,
																				   &kCFTypeDictionaryKeyCallBacks,
																				   &kCFTypeDictionaryValueCallBacks);
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL View Snapshot - Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return( self );
} // initViewSnapshotWithFrame

//------------------------------------------------------------------------

- (void) cleanUpViewSnapshot
{
	if( mpSnapshot != NULL )
	{
		if( mpSnapshot->m_File.m_Description.m_Options.mpFile != NULL )
		{
			CFRelease( mpSnapshot->m_File.m_Description.m_Options.mpFile ) ;
		} // if
		
		if( mpSnapshot->m_File.m_Description.m_Options.mpImage != NULL )
		{
			CFRelease( mpSnapshot->m_File.m_Description.m_Options.mpImage );
		} // if
		
		if( mpSnapshot->m_File.m_Description.mpAuxInfo != NULL )
		{
			CFRelease( mpSnapshot->m_File.m_Description.mpAuxInfo );
		} // if
		
		free( mpSnapshot );
		
		mpSnapshot = NULL;
	} // if
} // cleanUpViewSnapshot

//------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpViewSnapshot];
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

+ (id) viewSnapshotWithFrame:(const NSRect *)theFrame
						   view:(NSOpenGLView *)theBaseView
{
	return( [[[OpenGLViewSnapshot allocWithZone:[self zone]] initViewSnapshotWithFrame:theFrame
																					 view:theBaseView] autorelease] );
} // viewSnapshotWithFrame

//------------------------------------------------------------------------

- (void) saveAs:(NSString *)theFilePath
		   file:(CGFileRef)theFile
{
	Boolean  isDirectory = false;
	
	CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
													 (CFStringRef)theFilePath,
													 kCFURLPOSIXPathStyle,
													 isDirectory);
	
	if( fileURL != NULL )
	{
		CGImageDestinationRef imageDestRef = CGImageDestinationCreateWithURL(fileURL,
																			 theFile->m_Description.mpUTI,
																			 theFile->m_Description.mnIndex,
																			 theFile->m_Description.m_Options.mpFile);
		if( imageDestRef != NULL )
		{
			mpSnapshot->mpImage = [self imageRef];
			
			CGImageDestinationAddImage(imageDestRef,
									   mpSnapshot->mpImage,
									   theFile->m_Description.m_Options.mpImage);
			
			CGImageDestinationFinalize( imageDestRef ) ;
			
			CFRelease( imageDestRef );
		} // if
		
		CFRelease( fileURL );
	} // if
} // saveAs

//------------------------------------------------------------------------

- (void) saveAsBMP:(NSString *)theBMPFilePath
{
	mpSnapshot->m_File.m_Format = kFileFormatIsBMP;
	
	mpSnapshot->m_File.m_Description.mpUTI = kUTTypeBMP;
	
	[self saveAs:theBMPFilePath
			file:&mpSnapshot->m_File];
} // saveAsBMP

//------------------------------------------------------------------------

- (void) saveAsGIF:(NSString *)theGIFFilePath
{
	mpSnapshot->m_File.m_Format = kFileFormatIsGIF;
	
	mpSnapshot->m_File.m_Description.mpUTI = kUTTypeGIF;
	
	[self saveAs:theGIFFilePath
			file:&mpSnapshot->m_File];
} // saveAsGIF

//------------------------------------------------------------------------

- (void) saveAsJP2:(NSString *)theJP2FilePath
{
	mpSnapshot->m_File.m_Format = kFileFormatIsJP2;
	
	mpSnapshot->m_File.m_Description.mpUTI = kUTTypeJPEG2000;
	
	[self saveAs:theJP2FilePath
			file:&mpSnapshot->m_File];
} // saveAsJP2

//------------------------------------------------------------------------

- (void) saveAsJPEG:(NSString *)theJPEGFilePath
{
	mpSnapshot->m_File.m_Format = kFileFormatIsJPEG;
	
	mpSnapshot->m_File.m_Description.mpUTI = kUTTypeJPEG;
	
	[self saveAs:theJPEGFilePath
			file:&mpSnapshot->m_File];
} // saveAsJPEG

//------------------------------------------------------------------------

- (void) saveAsPNG:(NSString *)thePNGFilePath
{
	mpSnapshot->m_File.m_Format = kFileFormatIsPNG;
	
	mpSnapshot->m_File.m_Description.mpUTI = kUTTypePNG;
	
	[self saveAs:thePNGFilePath
			file:&mpSnapshot->m_File];
} // saveAsPNG

//------------------------------------------------------------------------

- (void) saveAsTiff:(NSString *)theTiffFilePath
{
	mpSnapshot->m_File.m_Format = kFileFormatIsTiff;
	
	mpSnapshot->m_File.m_Description.mpUTI = kUTTypeTIFF;
	
	if( CFDictionaryContainsKey(mpSnapshot->m_File.m_Description.m_Options.mpImage,
								kCGImageDestinationLossyCompressionQuality) )
	{
		int tiffCompression = kTiffCompressionIsLZW;
		
		CFNumberRef tiffCompressionNum = CFNumberCreate(kCFAllocatorDefault,
														kCFNumberIntType,
														&tiffCompression);
		
		if( tiffCompressionNum != NULL )
		{
			CFIndex tiffInfoCount = 1;
			
			CFMutableDictionaryRef tiffCompressionDict = CFDictionaryCreateMutable(kCFAllocatorDefault,
																				   tiffInfoCount,
																				   &kCFTypeDictionaryKeyCallBacks,
																				   &kCFTypeDictionaryValueCallBacks);
			
			if( tiffCompressionDict != NULL )
			{
				CFDictionarySetValue(tiffCompressionDict,
									 kCGImagePropertyTIFFCompression,
									 tiffCompressionNum);
				
				CFDictionarySetValue(mpSnapshot->m_File.m_Description.m_Options.mpImage,
									 kCGImagePropertyTIFFDictionary,
									 tiffCompressionDict);
				
				CFRelease( tiffCompressionDict );
			} // if
			
			CFRelease( tiffCompressionNum );
		} // if
	} // if
	
	[self saveAs:theTiffFilePath
			file:&mpSnapshot->m_File];
} // saveAsTiff

//------------------------------------------------------------------------

- (void) saveAsPDF:(NSString *)thePDFDocPathname
{
	Boolean isDirectory = false;
	
	CFURLRef pdfFileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
														(CFStringRef)thePDFDocPathname,
														kCFURLPOSIXPathStyle,
														isDirectory);
	
	if( pdfFileURL != NULL )
	{
		CGRect        pdfPageFrame = NSRectToCGRect([self frame]);
		CGContextRef  pdfContext   = CGPDFContextCreateWithURL(pdfFileURL,
															   &pdfPageFrame,
															   mpSnapshot->m_File.m_Description.mpAuxInfo);
		
		if( pdfContext != NULL )
		{
			CGContextBeginPage(pdfContext, &pdfPageFrame);
			
			CGContextDrawImage(pdfContext,
							   pdfPageFrame,
							   [self imageRef]);
			
			CGContextEndPage(pdfContext);
			
			CGContextRelease(pdfContext);
		} // if
		
		CFRelease(pdfFileURL);
	} // if
	
	mpSnapshot->m_File.m_Format = kFileFormatIsPDF;
} // saveAsPDF

//------------------------------------------------------------------------

- (void) setFormat:(const ImageFileFormats)theFileFormat
{
	mpSnapshot->m_File.m_Format = theFileFormat;
} // setFormat

//------------------------------------------------------------------------

- (void) setDocumentTitle:(NSString *)theDocTitle
{
	if( mpSnapshot->m_File.m_Description.mpAuxInfo != NULL )
	{
		CFStringRef docTitle = NULL;
		
		if( theDocTitle )
		{
			docTitle = (CFStringRef)theDocTitle;
		} // if
		else
		{
			docTitle = CFSTR( "Title" );
		} // else
		
		CFDictionarySetValue(mpSnapshot->m_File.m_Description.mpAuxInfo,
							 kCGPDFContextTitle,
							 docTitle);
	} // if
} // setDocumentTitle

//------------------------------------------------------------------------

- (void) setDocumentAuthor:(NSString *)theDocAuthor
{
	if( mpSnapshot->m_File.m_Description.mpAuxInfo != NULL )
	{
		CFStringRef docAuthor = NULL;
		
		if( theDocAuthor )
		{
			docAuthor = (CFStringRef)theDocAuthor;
		} // if
		else
		{
			docAuthor = CFSTR( "Author" );
		} // else
		
		CFDictionarySetValue(mpSnapshot->m_File.m_Description.mpAuxInfo,
							 kCGPDFContextAuthor,
							 docAuthor);
	} // if
} // setDocumentAuthor

//------------------------------------------------------------------------

- (void) setDocumentSubject:(NSString *)theDocSubject
{
	if( mpSnapshot->m_File.m_Description.mpAuxInfo != NULL )
	{
		CFStringRef docSubject= NULL;
		
		if( theDocSubject )
		{
			docSubject = (CFStringRef)theDocSubject;
		} // if
		else
		{
			docSubject = CFSTR( "Subject" );
		} // else
		
		CFDictionarySetValue(mpSnapshot->m_File.m_Description.mpAuxInfo,
							 kCGPDFContextSubject,
							 docSubject);
	} // if
} // setDocumentSubject

//------------------------------------------------------------------------

- (void) setDocumentCreator:(NSString *)theDocCreator
{
	if( mpSnapshot->m_File.m_Description.mpAuxInfo != NULL )
	{
		CFStringRef docCreator = NULL;
		
		if( theDocCreator )
		{
			docCreator = (CFStringRef)theDocCreator;
		} // if
		else
		{
			docCreator = CFSTR( "Creator" );
		} // else
		
		CFDictionarySetValue(mpSnapshot->m_File.m_Description.mpAuxInfo,
							 kCGPDFContextCreator,
							 docCreator);
	} // if
} // setDocumentCreator

//------------------------------------------------------------------------

- (void) setCompression:(const CGFloat)theCompression
{
	if( theCompression < 1.0f )
	{
		CGFloat compression = theCompression;
		
		CFNumberRef compressionNum = CFNumberCreate(kCFAllocatorDefault,
													kCFNumberFloatType,
													&compression);
		
		if( compressionNum != NULL )
		{
			CFDictionarySetValue(mpSnapshot->m_File.m_Description.m_Options.mpImage,
								 kCGImageDestinationLossyCompressionQuality,
								 compressionNum);
			
			CFRelease(compressionNum);
		} // if
	} // if
} // setCompression

//------------------------------------------------------------------------

- (void) snapshot
{
	[self invalidate:YES];
} // snapshot

//------------------------------------------------------------------------

- (void) saveAs:(NSString *)theFilePathname
{
	NSString *filePathname = nil;
	
	switch( mpSnapshot->m_File.m_Format )
	{
		case kFileFormatIsBMP:
			filePathname = [NSString stringWithFormat:@"%@.bmp",theFilePathname];
			[self saveAsBMP:filePathname];
			break;
			
		case kFileFormatIsGIF:
			filePathname = [NSString stringWithFormat:@"%@.gif",theFilePathname];
			[self saveAsGIF:filePathname];
			break;
			
		case kFileFormatIsJP2:
			filePathname = [NSString stringWithFormat:@"%@.jp2",theFilePathname];
			[self saveAsJP2:filePathname];
			break;
			
		case kFileFormatIsPDF:
			filePathname = [NSString stringWithFormat:@"%@.pdf",theFilePathname];
			[self saveAsPDF:filePathname];
			break;
			
		case kFileFormatIsPNG:
			filePathname = [NSString stringWithFormat:@"%@.png",theFilePathname];
			[self saveAsPNG:filePathname];
			break;
			
		case kFileFormatIsTiff:
			filePathname = [NSString stringWithFormat:@"%@.tiff",theFilePathname];
			[self saveAsTiff:filePathname];
			break;
			
		case kFileFormatIsJPEG:
		default:
			filePathname = [NSString stringWithFormat:@"%@.jpeg",theFilePathname];
			[self saveAsJPEG:filePathname];
			break;
	} // switch
} // saveAs

//------------------------------------------------------------------------

@end

//------------------------------------------------------------------------

//------------------------------------------------------------------------

