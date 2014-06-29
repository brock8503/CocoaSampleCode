/*
     File: OpenGLViewCapture.m
 Abstract: 
 Utility toolkit for capturing frames from a view.
 
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

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#import "DefaultPathname.h"

#import "QTMediaSample.h"
#import "QTMediaSampleExporter.h"

#import "OpenGLViewCaptureStates.h"
#import "OpenGLViewCapture.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------

struct OpenGLViewCaptureData
{
	BOOL                      mbIsExported;
	BOOL                      mbIsStopped;
	NSSize                    m_SampleSize;
	NSString                 *mpFileDirectory;
	NSString                 *mpFilePrefix;
	DefaultPathname          *mpPathname;
	QTMediaSampleExporter    *mpSampleExporter;
	OpenGLViewCaptureState    mnCaptureState;
};

typedef struct OpenGLViewCaptureData   OpenGLViewCaptureData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLViewCapture

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated Initializer

//---------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------

- (id) initViewCaptureBaseWithFrame:(const NSRect *)theFrame
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // initViewCaptureBaseWithFrame

//---------------------------------------------------------------------------
//
// Initialize
//
//---------------------------------------------------------------------------

- (id) initViewCaptureWithFrame:(const NSRect *)theFrame
                      directory:(NSString *)theMovieDirectory
                         prefix:(NSString *)theMoviePrefix
{
	self = [super initViewCaptureBaseWithFrame:theFrame];
	
	if( self )
	{
		mpViewCapture = (OpenGLViewCaptureDataRef)calloc(1, sizeof(OpenGLViewCaptureData));
		
		if( mpViewCapture != NULL )
		{
			mpViewCapture->m_SampleSize = NSMakeSize(theFrame->size.width - theFrame->origin.x,
													 theFrame->size.height - theFrame->origin.y);
			
			mpViewCapture->mpFileDirectory = [[NSString alloc] initWithString:theMovieDirectory];
			mpViewCapture->mpFilePrefix    = [[NSString alloc] initWithString:theMoviePrefix];
			mpViewCapture->mpPathname      = [DefaultPathname new];
			mpViewCapture->mbIsExported    = YES;
			mpViewCapture->mnCaptureState  = kOpenGLViewCaptureDefault;
		} // if
	} // if
	
	return( self );
} // initViewCaptureWithFrame

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Dealloc all the Resources

//---------------------------------------------------------------------------
//
// Since the processing of items in the queue is async, then waite here
// until all items are processed, before releasing the exporter object.
//
//---------------------------------------------------------------------------

- (void) exported
{
	mpViewCapture->mbIsExported = [mpViewCapture->mpSampleExporter exportEnded];
	
	while( !mpViewCapture->mbIsExported )
	{
		mpViewCapture->mbIsExported = [mpViewCapture->mpSampleExporter exportEnded];
	} // while
} // exported

//---------------------------------------------------------------------------
//
// If the export was not complete (i.e., stopped properly) then process
// remaining items in the export queue.
//
//---------------------------------------------------------------------------

- (void) finalized
{
	if( !mpViewCapture->mbIsExported )
	{
		[mpViewCapture->mpSampleExporter exportFinalize];
		
		[self exported];
	} // if
} // finalized

//---------------------------------------------------------------------------

- (void) releaseMediaPathname
{
	if( mpViewCapture->mpPathname )
	{
		[mpViewCapture->mpPathname release];
		
		mpViewCapture->mpPathname = nil;
	} // if
} // releaseMediaPathname

//---------------------------------------------------------------------------

- (void) releaseMediaPrefix
{
	if( mpViewCapture->mpFilePrefix )
	{
		[mpViewCapture->mpFilePrefix release];
		
		mpViewCapture->mpFilePrefix = nil;
	} // if
} // releaseMediaPrefix

//---------------------------------------------------------------------------

- (void) releaseMediaFileDirectory
{
	if( mpViewCapture->mpFileDirectory )
	{
		[mpViewCapture->mpFileDirectory release];
		
		mpViewCapture->mpFileDirectory = nil;
	} // if
} // releaseMediaFileDirectory

//---------------------------------------------------------------------------

- (void) releaseMediaSampleExporter
{
	[self finalized];
	
	if( mpViewCapture->mpSampleExporter )
	{
		[mpViewCapture->mpSampleExporter release];
		
		mpViewCapture->mpSampleExporter = nil;
	} // if
} // releaseMediaSampleExporter

//---------------------------------------------------------------------------

- (void) cleanUpCapture
{
	if( mpViewCapture != NULL )
	{
		[self releaseMediaPathname];
		[self releaseMediaPrefix];
		[self releaseMediaFileDirectory];
		[self releaseMediaSampleExporter];
		
		free(mpViewCapture);
		
		mpViewCapture = NULL;
	} // if
} // cleanUpCapture

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpCapture];
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Utilities

//---------------------------------------------------------------------------
//
// Capture from the view with a readback from the FBO using a PBO.
//
//---------------------------------------------------------------------------

- (BOOL) capture
{
    BOOL isExported = NO;
    
	if( mpViewCapture->mnCaptureState == kOpenGLViewCaptureStarted )
	{
		[self writeToBuffer:[mpViewCapture->mpSampleExporter pixelBuffer]];
		
		isExported = [mpViewCapture->mpSampleExporter exportAsync];
	} // if
    
    return isExported;
} // capture

//---------------------------------------------------------------------------

- (void) pause
{
	if( mpViewCapture->mnCaptureState == kOpenGLViewCaptureStarted )
	{
		mpViewCapture->mnCaptureState = kOpenGLViewCapturePaused;
	} // if
	else if( mpViewCapture->mnCaptureState == kOpenGLViewCapturePaused )
	{
		mpViewCapture->mnCaptureState = kOpenGLViewCaptureStarted;
	} // else
} // pause

//---------------------------------------------------------------------------

- (void) startMediaSampleExporter
{
	if( mpViewCapture->mpSampleExporter == nil )
	{
		NSString *mediaFilePathName = [mpViewCapture->mpPathname pathnameWithDirectory:mpViewCapture->mpFileDirectory
																				  name:mpViewCapture->mpFilePrefix
																			 extension:@"mov"];
		
		if( mediaFilePathName )
		{
			mpViewCapture->mpSampleExporter = [[QTMediaSampleExporter alloc] initMediaSampleExporterWithMoviePath:mediaFilePathName
																										frameSize:&mpViewCapture->m_SampleSize
																									 framesPerSec:30];
		} // if
	} // if
} // startMediaSampleExporter

//---------------------------------------------------------------------------

- (void) start
{
	[self releaseMediaSampleExporter];
	[self startMediaSampleExporter];
	
	mpViewCapture->mnCaptureState = kOpenGLViewCaptureStarted;
	mpViewCapture->mbIsExported   = NO;
} // start

//---------------------------------------------------------------------------

- (void) stop
{
	[mpViewCapture->mpSampleExporter exportFinalize];
	
	mpViewCapture->mbIsExported   = YES;
	mpViewCapture->mnCaptureState = kOpenGLViewCaptureStopped;
} // stop

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Level Indicators

//---------------------------------------------------------------------------

- (void) enableIndicator
{
	[mpViewCapture->mpSampleExporter enableIndicator];
} // enableIndicator

//---------------------------------------------------------------------------

- (void) disableIndicator
{
	[mpViewCapture->mpSampleExporter disableIndicator];
} // disableIndicator

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Getters

//---------------------------------------------------------------------------

- (NSUInteger) count
{
	return( [mpViewCapture->mpSampleExporter count] );
} // count

//---------------------------------------------------------------------------

- (BOOL) isSuspended
{
	return( [mpViewCapture->mpSampleExporter isSuspended] );
} // isSuspended

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Setters

//---------------------------------------------------------------------------

- (void) setMoviePrefix:(NSString *)theMoviePrefix
{
	[mpViewCapture->mpFilePrefix release];
	
	mpViewCapture->mpFilePrefix = [theMoviePrefix retain];
} // setMoviePrefix

//---------------------------------------------------------------------------

- (void) setMovieDirectory:(NSString *)theMovieDirectory
{
	[mpViewCapture->mpFileDirectory release];
	
	mpViewCapture->mpFileDirectory = [theMovieDirectory retain];
} // setMediaFileDirectory

//---------------------------------------------------------------------------

- (void) setBounds:(const NSRect *)theBounds
{
	if(		( theBounds->size.width  != mpViewCapture->m_SampleSize.width  )
	   ||	( theBounds->size.height != mpViewCapture->m_SampleSize.height ) )
	{
		mpViewCapture->m_SampleSize = NSMakeSize(theBounds->size.width - theBounds->origin.x,
												 theBounds->size.height - theBounds->origin.y);
		
		if( !mpViewCapture->mbIsExported )
		{
			[self stop];
		} // if
		
		[super setBounds:theBounds];
	} // if
} // setBounds

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
