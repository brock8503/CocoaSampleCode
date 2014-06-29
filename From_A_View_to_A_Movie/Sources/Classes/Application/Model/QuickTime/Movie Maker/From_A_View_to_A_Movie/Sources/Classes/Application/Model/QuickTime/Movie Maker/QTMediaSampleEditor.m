/*
     File: QTMediaSampleEditor.m
 Abstract: 
 Base utility toolkit for authoring a QT movie.
 
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

#import "OpenGLTextureSourceTypes.h"
#import "QTMediaSampleEditor.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Constants

//---------------------------------------------------------------------------

static const NSUInteger kSizeSampleRef64Rec = sizeof(SampleReference64Record);

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structure

//---------------------------------------------------------------------------

struct QTMediaSampleEditorData
{
	unsigned long   offset;
	unsigned long   dataSize;
	long            sampleOffset;
	long            numberOfSamples;
	OSErr           err;
	Fixed           mediaRate;
	TimeValue       mediaTime;
	TimeValue       mediaDuration;
	TimeValue       trackStart;
	TimeValue       sampleTime;
}; // QTMediaSampleEditorData

typedef struct QTMediaSampleEditorData   QTMediaSampleEditorData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

@implementation QTMediaSampleEditor

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

//---------------------------------------------------------------------------
//
// Make sure QuickTime is initialized
//
//---------------------------------------------------------------------------

+ (void) initialize
{
	EnterMovies();
} // initialize

//---------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // init

//---------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------

- (id) initMediaSampleDescriptionWithMoviePath:(NSString *)theMoviePath
									 frameSize:(const NSSize *)theSize
								  framesPerSec:(const TimeValue)theFPS
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // initMediaSampleDescriptionWithMoviePath

//---------------------------------------------------------------------------
//
// Initialize a frame compressor object with the specified codec,
// bounds, compressor options and timescale
//
//---------------------------------------------------------------------------

- (id) initMediaSampleEditorWithMoviePath:(NSString *)theMoviePath
								frameSize:(const NSSize *)theSize
							 framesPerSec:(const TimeValue)theFPS
{
	self = [super initMediaSampleDescriptionWithMoviePath:theMoviePath
												frameSize:theSize
											 framesPerSec:theFPS];
	
	if( self )
	{
		mpEditor = (QTMediaSampleEditorDataRef)calloc(1, sizeof(QTMediaSampleEditorData));
		
		if( mpEditor != NULL )
		{
			// Image initializations
			
			mpEditor->dataSize = [self sampleSize];
			
			// Insert media into track initializations
			
			mpEditor->mediaRate = 1 << 16;
		} // if
		else
		{
			NSLog( @">> ERROR: QT Media Sample Editor - Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return( self );
} // initMediaSampleEditorWithMoviePath

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Dealloc

//---------------------------------------------------------------------------

- (void) cleanUpEditor
{
	if( mpEditor != NULL )
	{
		free( mpEditor );
		
		mpEditor = NULL;
	} // if
} // cleanUpEditor

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpEditor];
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

//---------------------------------------------------------------------------

- (TimeValue) lastSampleTime
{
	return( mpEditor->sampleTime );
} // lastSampleTime

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Media Editor

//---------------------------------------------------------------------------

- (BOOL) editsBegin
{
	BOOL mediaEditsBegan = NO;
	
	mpEditor->err = BeginMediaEdits([self media]);
	
	if( mpEditor->err == noErr )
	{
		mediaEditsBegan = YES;
	} // if
	
	return( mediaEditsBegan );
} // editsBegin

//---------------------------------------------------------------------------

- (BOOL) editsEnd
{
	BOOL mediaEditsEnded = NO;
	
	mpEditor->err = EndMediaEdits([self media]);
	
	if( mpEditor->err == noErr )
	{
		mediaEditsEnded = YES;
	} // if
	
	return( mediaEditsEnded );
} // editsEnd

//---------------------------------------------------------------------------

- (BOOL) editsFinalize
{
	BOOL mediaEditsEnded = NO;
	
	mpEditor->mediaDuration = GetMediaDuration([self media]);
	
	mpEditor->err = InsertMediaIntoTrack([self track],
										 mpEditor->trackStart,
										 mpEditor->mediaTime,
										 mpEditor->mediaDuration,
										 mpEditor->mediaRate);
	
	if( mpEditor->err == noErr )
	{
		mpEditor->err = AddMovieToStorage([self movie],
										  [self dataHandler]);
		
		if( mpEditor->err == noErr )
		{
			mediaEditsEnded = YES;
		} // if
	} // if
	
	return( mediaEditsEnded );
} // editsFinalize

//---------------------------------------------------------------------------

- (BOOL) add:(QTMediaSample *)theMediaSample
{
	BOOL mediaSampleAdded = NO;
	
	if( theMediaSample )
	{
		Ptr mediaSamplePtr = (Ptr)[theMediaSample buffer];
		
		if( mediaSamplePtr != NULL )
		{
			mpEditor->err = AddMediaSample([self media],
										   &mediaSamplePtr,
										   mpEditor->sampleOffset,
										   mpEditor->dataSize,
										   [self durationPerSample],
										   [self sampleDescriptionHandle],
										   [self numberOfSamples],
										   [self sampleFlags],
										   &mpEditor->sampleTime);
			
			if( mpEditor->err == noErr )
			{
				mediaSampleAdded = YES;
			} // if
		} // if
	} // if
	
	return( mediaSampleAdded );
} // add

//---------------------------------------------------------------------------
//
// Add the sample -  AddMediaSampleReference does not add sample data to the
// file or device that contains a media.  Rather, it defines references to
// sample data contained elswhere. Note that one reference may refer to more
// than one sample--all the samples described by a reference must be the same
// size. This function does not update the movie data  as part of the add
// operation therefore you do not have to call BeginMediaEdits before calling
// AddMediaSampleReference.
//
//---------------------------------------------------------------------------

- (BOOL) addReference
{
	BOOL mediaSampleRefAdded = NO;
	
	mpEditor->err = AddMediaSampleReference([self media],
											mpEditor->offset,
											mpEditor->dataSize,
											[self durationPerSample],
											[self sampleDescriptionHandle],
											[self numberOfSamples],
											[self sampleFlags],
											&mpEditor->sampleTime);
	
	
	if( mpEditor->err == noErr )
	{
		mpEditor->offset += mpEditor->dataSize;
		
		mediaSampleRefAdded = YES;
	} // if
	
	return( mediaSampleRefAdded );
} // addReference

//---------------------------------------------------------------------------

- (SampleReference64Ptr) sampleReferencesPtrCreate:(const NSUInteger)theSampleCount
{
	SampleReference64Ptr  sampleRefs = NULL;
	
	if( theSampleCount > 0 )
	{
		mpEditor->numberOfSamples = theSampleCount;
		
		sampleRefs = (SampleReference64Ptr)malloc( mpEditor->numberOfSamples * kSizeSampleRef64Rec );
		
		if( sampleRefs != NULL )
		{
			unsigned long  sampleRefIndex    = 0;
			unsigned long  numberOfSamples   = [self numberOfSamples];
			short          sampleFlags       = [self sampleFlags];
			TimeValue      durationPerSample = [self durationPerSample];
			
			wide  dataOffset = { 0, 0 };
			wide  dataSize   = { 0, 0 };
			
			dataSize.lo = mpEditor->dataSize;
			
			for(sampleRefIndex = 0;
				sampleRefIndex < mpEditor->numberOfSamples;
				sampleRefIndex++)
			{
				sampleRefs[sampleRefIndex].dataOffset        = dataOffset;
				sampleRefs[sampleRefIndex].dataSize          = mpEditor->dataSize;
				sampleRefs[sampleRefIndex].durationPerSample = durationPerSample;
				sampleRefs[sampleRefIndex].numberOfSamples   = numberOfSamples;
				sampleRefs[sampleRefIndex].sampleFlags       = sampleFlags;
				
				WideAdd( &dataOffset, &dataSize );
			} // for
		} // if
	} // if
	
	return( sampleRefs );
} // sampleReferencesPtrCreate

//---------------------------------------------------------------------------
//
// Using this method instead of addReference can greatly improves the
// performance of operations that involve adding a large number of samples
// to a movie at one time.
//
//---------------------------------------------------------------------------

- (BOOL) addReferences:(const NSUInteger)theSampleCount
{
	BOOL mediaSampleRefsAdded = NO;
	
	SampleReference64Ptr  sampleRefs = [self sampleReferencesPtrCreate:theSampleCount];
	
	if( sampleRefs != NULL )
	{
		mpEditor->err = AddMediaSampleReferences64([self media],
												   [self sampleDescriptionHandle],
												   mpEditor->numberOfSamples,
												   sampleRefs,
												   &mpEditor->sampleTime);
		
		if( mpEditor->err == noErr )
		{
			mediaSampleRefsAdded = YES;
		} // if
		
		free(sampleRefs);
		
		mpEditor->numberOfSamples = 0;
	} // if
	
	return( mediaSampleRefsAdded );
} // addReferences

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
