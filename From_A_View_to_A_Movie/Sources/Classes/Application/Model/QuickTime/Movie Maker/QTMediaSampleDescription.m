/*
     File: QTMediaSampleDescription.m
 Abstract: 
 Base utility toolkit for creating core data types associated with a movie description.
 
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
#import "QTMediaSampleDescription.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Macro Constants

//---------------------------------------------------------------------------

#define DEFAULT_SCALE	600		// Default time scale to produce 1 FPS generated movies.
#define DEFAULT_FPS		30		// Default FPS to produce 29.97 FPS generated movies.

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Constants

//---------------------------------------------------------------------------

static const int kDefaultFlag = 0;

//---------------------------------------------------------------------------
//
// Default frame duration to produce 1 FPS generated movies.
//
//---------------------------------------------------------------------------

static const TimeValue kDefaultFrameDuration = DEFAULT_SCALE / DEFAULT_FPS;

//---------------------------------------------------------------------------
//
// Defines how a chroma subsampled YCbCr buffer was created.
//
// In the case where the chroma location information is also stored in the
// encoded bitstream (e.g., H.264), the information returned by the codec
// takes precedence.
//
//---------------------------------------------------------------------------
//
// Chroma Location Image Description Extension, Read/Write
//
//---------------------------------------------------------------------------

static const OSType kICMImageDescriptionPropertyIDChromaLocation = 'chrm';

//---------------------------------------------------------------------------

static const OSType kQTMoviePlayerCreator = 'TVOD';

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structure

//---------------------------------------------------------------------------

struct QTMediaSampleDescriptionData
{
	BOOL                    mediaSampleAdded;
	short                   trackVolume;
	short                   sampleFlags;
	unsigned long           sampleWidth;
	unsigned long           sampleHeight;
	unsigned long           sampleSize;
	unsigned long           numberOfSamples;
	CFStringRef             path;
	CFURLRef                url;
	OSType                  mediaType;
	OSType                  dataRefType;
	OSErr                   err;
	Handle                  dataRef;
	Movie                   movie;
	Track	                track;
	Media	                media;
	DataReferenceRecord     outputDataRef;
	ComponentInstance	    outputDataHandler;
	ImageDescriptionHandle  hImage;
	TimeScale               scale;
	TimeValue               sampleTime;
	TimeValue               durationPerSample;
}; // QTMediaSampleDescriptionData

typedef struct QTMediaSampleDescriptionData   QTMediaSampleDescriptionData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Create Media Sample

//---------------------------------------------------------------------------
//
// Image initializations
//
//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionInitImageAttribs(const NSSize *size,
													  QTMediaSampleDescriptionDataRef mpDescription)
{
	mpDescription->sampleWidth  = (long)size->width;
	mpDescription->sampleHeight = (long)size->height;
	mpDescription->sampleSize   = kTextureMaxSPP * mpDescription->sampleWidth * mpDescription->sampleHeight;
	
	return( mpDescription->sampleSize > 0 );
} // QTMediaDescriptionInitImageAttribs

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionFileCreateWithSystemPath(QTMediaSampleDescriptionDataRef mpDescription)
{
	mpDescription->url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
													   mpDescription->path,
													   kCFURLPOSIXPathStyle,
													   NO);
	
	return( mpDescription->url != NULL );
} // QTMediaDescriptionFileCreateWithSystemPath

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionCreateDataRefFromFile(QTMediaSampleDescriptionDataRef mpDescription)
{
	UInt32 flags = 0;
	
	mpDescription->err = QTNewDataReferenceFromCFURL(mpDescription->url,
													 flags,
													 &mpDescription->outputDataRef.dataRef,
													 &mpDescription->outputDataRef.dataRefType);
	
	return( mpDescription->err == noErr );
} // QTMediaDescriptionCreateDataRefFromFile

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionCreateMovieStorage(QTMediaSampleDescriptionDataRef mpDescription)
{
	mpDescription->err = CreateMovieStorage(mpDescription->outputDataRef.dataRef,
											mpDescription->outputDataRef.dataRefType,
											kQTMoviePlayerCreator,
											smCurrentScript,
											createMovieFileDeleteCurFile | createMovieFileDontCreateResFile,
											&mpDescription->outputDataHandler,
											&mpDescription->movie);
	
	return( mpDescription->err == noErr );
} // QTMediaDescriptionCreateMovieStorage

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionCreateImageHandle(const NSSize *size,
													   QTMediaSampleDescriptionDataRef mpDescription)
{
	BOOL hImgDescIsValid = NO;
	
	mpDescription->hImage = (ImageDescriptionHandle)NewHandleClear(sizeof(ImageDescription));
	
	hImgDescIsValid =  ( mpDescription->hImage != NULL ) && ( *mpDescription->hImage != NULL );
	
	if( hImgDescIsValid )
	{
		HLock((Handle)mpDescription->hImage);
		
		(*mpDescription->hImage)->cType          = k32BGRAPixelFormat;			// From QuickDraw Types
		(*mpDescription->hImage)->width          = (short)size->width;
		(*mpDescription->hImage)->height         = (short)size->height;
		(*mpDescription->hImage)->idSize         = sizeof(ImageDescription);
		(*mpDescription->hImage)->spatialQuality = codecLosslessQuality;
		(*mpDescription->hImage)->hRes           = 72 << 16;
		(*mpDescription->hImage)->vRes           = 72 << 16;
		(*mpDescription->hImage)->depth          = 32;
		(*mpDescription->hImage)->clutID         = -1;
		
		HUnlock((Handle)mpDescription->hImage);
	} // if
	
	return( hImgDescIsValid );
} // QTMediaDescriptionCreateImageHandle

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionSetNCLCColorInfo(QTMediaSampleDescriptionDataRef mpDescription)
{
	// Set the primaries, matrix, and transfer function
	
	NCLCColorInfoImageDescriptionExtension nclc;
	
	nclc.colorParamType   = kVideoColorInfoImageDescriptionExtensionType;
	nclc.primaries        = kQTPrimaries_ITU_R709_2;
	nclc.transferFunction = kQTTransferFunction_ITU_R709_2;
	nclc.matrix           = kQTMatrix_ITU_R_709_2;
	
	mpDescription->err = ICMImageDescriptionSetProperty(mpDescription->hImage,
														kQTPropertyClass_ImageDescription,
														kICMImageDescriptionPropertyID_NCLCColorInfo,
														sizeof(NCLCColorInfoImageDescriptionExtension),
														&nclc);
	
	return( mpDescription->err == noErr );
} // QTMediaDescriptionSetNCLCColorInfo

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionSetFieldInfo(QTMediaSampleDescriptionDataRef mpDescription)
{
	// Field count/detail
	
	// assume progressive unless otherwise stated
	
	FieldInfoImageDescriptionExtension2 fieldInfo = { 0, 0 };
	
	// Values found in the doc:
	//
	// http://developer.apple.com/quicktime/icefloe/dispatch019.html#fiel
	
	fieldInfo.fields = kQTFieldsProgressiveScan;
	fieldInfo.detail = kQTFieldDetailUnknown;
	
	mpDescription->err = ICMImageDescriptionSetProperty(mpDescription->hImage,
														kQTPropertyClass_ImageDescription,
														kICMImageDescriptionPropertyID_FieldInfo,
														sizeof(FieldInfoImageDescriptionExtension2),
														&fieldInfo);
	
	return( mpDescription->err == noErr );
} // QTMediaDescriptionSetFieldInfo

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionSetMovieTimeScale(QTMediaSampleDescriptionDataRef mpDescription)
{
	// Media Edit
	
	mpDescription->scale = DEFAULT_SCALE;
	
	SetMovieTimeScale(mpDescription->movie,
					  mpDescription->scale);
	
	OSErr error = GetMoviesError();
	
	return( error == noErr );
} // QTMediaDescriptionSetMovieTimeScale

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionCreateMovieTrack(QTMediaSampleDescriptionDataRef mpDescription)
{
	mpDescription->trackVolume = 0;
	
	mpDescription->track = NewMovieTrack(mpDescription->movie,
										 Long2Fix(mpDescription->sampleWidth),
										 Long2Fix(mpDescription->sampleHeight),
										 mpDescription->trackVolume);
	
	OSErr error = GetMoviesError();
	
	return( error == noErr );
} // QTMediaDescriptionCreateMovieTrack

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionCreateTrackMedia(QTMediaSampleDescriptionDataRef mpDescription)
{
	mpDescription->mediaType   = VIDEO_TYPE;
	mpDescription->dataRef     = NULL;
	mpDescription->dataRefType = 0;
	
	mpDescription->media = NewTrackMedia(mpDescription->track,
										 mpDescription->mediaType,
										 mpDescription->scale,
										 mpDescription->dataRef,
										 mpDescription->dataRefType);
	
	OSErr error = GetMoviesError();
	
	return( error == noErr );
} // QTMediaDescriptionCreateTrackMedia

//---------------------------------------------------------------------------
//
// Add Media sample initializations
//
//---------------------------------------------------------------------------

static inline void QTMediaDescriptionInitSampleAttribs(QTMediaSampleDescriptionDataRef mpDescription)
{
	mpDescription->numberOfSamples = 1;
	mpDescription->sampleFlags     = kDefaultFlag;
	mpDescription->sampleTime      = 0;
} // QTMediaDescriptionInitSampleAttribs

//---------------------------------------------------------------------------

static inline void QTMediaDescriptionSetFrameDuration(const TimeValue fps,
													  QTMediaSampleDescriptionDataRef mpDescription)
{
	if( ( fps > 0 ) && ( fps < 30 ) )
	{
		mpDescription->durationPerSample = DEFAULT_SCALE / fps;
	} // if
	else
	{
		mpDescription->durationPerSample = kDefaultFrameDuration;
	} // else
} // QTMediaDescriptionSetFrameDuration

//---------------------------------------------------------------------------

static BOOL QTMediaDescriptionCreate(const NSSize *size,
									 const TimeValue fps,
									 QTMediaSampleDescriptionDataRef mpDescription)
{
	if( !QTMediaDescriptionInitImageAttribs(size,mpDescription) )
	{
		return( NO );
	} // if
	
	if( !QTMediaDescriptionFileCreateWithSystemPath(mpDescription) )
	{
		return( NO );
	} // if
	
	if( !QTMediaDescriptionCreateDataRefFromFile(mpDescription) )
	{
		return( NO );
	} // if
	
	if( !QTMediaDescriptionCreateMovieStorage(mpDescription) )
	{
		return( NO );
	} // if
	
	if( !QTMediaDescriptionCreateImageHandle(size, mpDescription) )
	{
		return( NO );
	} // if
	
	if( !QTMediaDescriptionSetNCLCColorInfo(mpDescription) )
	{
		return( NO );
	} // if
	
	if( !QTMediaDescriptionSetFieldInfo(mpDescription) )
	{
		return( NO );
	} // if
	
	if( !QTMediaDescriptionSetMovieTimeScale(mpDescription) )
	{
		return( NO );
	} // if
	
	if( !QTMediaDescriptionCreateMovieTrack(mpDescription) )
	{
		return( NO );
	} // if
	
	if( !QTMediaDescriptionCreateTrackMedia(mpDescription) )
	{
		return( NO );
	} // if
	
	QTMediaDescriptionInitSampleAttribs(mpDescription);
	QTMediaDescriptionSetFrameDuration(fps, mpDescription);
	
	return( YES );
} // QTMediaDescriptionCreate

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Release Media Sample

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionReleaseURL(QTMediaSampleDescriptionDataRef mpDescription)
{
	BOOL released = NO;
	
	if( mpDescription->url != NULL )
	{
		CFRelease(mpDescription->url);
		
		released = YES;
	} // if
	
	return( released );
} // QTMediaDescriptionReleaseURL

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionCloseMovieStorage(QTMediaSampleDescriptionDataRef mpDescription)
{
	BOOL closed = NO;
	
	if( mpDescription->outputDataHandler )
	{
		CloseMovieStorage( mpDescription->outputDataHandler );
		
		closed = YES;
	} // if
	
	return( closed );
} // QTMediaDescriptionCloseMovieStorage

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionDisposeDataHandler(QTMediaSampleDescriptionDataRef mpDescription)
{
	BOOL disposed = NO;
	
	if( mpDescription->outputDataRef.dataRef )
	{
		DisposeHandle(mpDescription->outputDataRef.dataRef);
		
		disposed = YES;
	} // if
	
	return( disposed );
} // QTMediaDescriptionDisposeDataHandler

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionDisposeImageHandle(QTMediaSampleDescriptionDataRef mpDescription)
{
	BOOL disposed = NO;
	
	if( mpDescription->hImage )
	{
		DisposeHandle((Handle)mpDescription->hImage);
		
		disposed = YES;
	} // if
	
	return( disposed );
} // QTMediaDescriptionDisposeImageHandle

//---------------------------------------------------------------------------

static inline BOOL QTMediaDescriptionDisposeMovie(QTMediaSampleDescriptionDataRef mpDescription)
{
	BOOL disposed = NO;
	
	if( mpDescription->movie )
	{
		DisposeMovie(mpDescription->movie);
		
		disposed = YES;
	} // if
	
	return( disposed );
} // QTMediaDescriptionDisposeMovie

//---------------------------------------------------------------------------

static BOOL QTMediaDescriptionRelease(QTMediaSampleDescriptionDataRef mpDescription)
{
	BOOL released = NO;
	
	if( mpDescription != NULL )
	{
		released = QTMediaDescriptionReleaseURL(mpDescription);
		released = released && QTMediaDescriptionCloseMovieStorage(mpDescription);
		released = released && QTMediaDescriptionDisposeDataHandler(mpDescription);
		released = released && QTMediaDescriptionDisposeImageHandle(mpDescription);
		released = released && QTMediaDescriptionDisposeMovie(mpDescription);
		
		mpDescription->movie             = NULL;
		mpDescription->outputDataHandler = NULL;
		mpDescription->track             = NULL;
		mpDescription->media             = NULL;
		mpDescription->url               = NULL;
	} // if
	
	return( released );
} // QTMediaDescriptionRelease

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

@implementation QTMediaSampleDescription

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Initialization

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
// Initialize a frame compressor object with the specified codec,
// bounds, compressor options and timescale
//
//---------------------------------------------------------------------------

- (id) initMediaSampleDescriptionWithMoviePath:(NSString *)theMoviePath
									 frameSize:(const NSSize *)theSize
								  framesPerSec:(const TimeValue)theFPS
{
	self = [super init];
	
	if( self )
	{
		mpDescription = (QTMediaSampleDescriptionDataRef)calloc(1, sizeof(QTMediaSampleDescriptionData));
		
		if( mpDescription != NULL )
		{
			mpDescription->path = CFStringCreateCopy(kCFAllocatorDefault,
													 (CFStringRef)theMoviePath);
			
			if( mpDescription->path != NULL )
			{
				QTMediaDescriptionCreate(theSize,
										 theFPS,
										 mpDescription);
			} // if
		} // if
		else
		{
			NSLog( @">> ERROR: QT Media Sample Description - Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return( self );
} // initMediaSampleDescriptionWithMoviePath

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Dealloc

//---------------------------------------------------------------------------

- (void) cleanUpDescription
{
	if( mpDescription != NULL )
	{
		QTMediaDescriptionRelease( mpDescription );
		
		if( mpDescription->path != NULL )
		{
			CFRelease(mpDescription->path);
		} // if
		
		free( mpDescription );
		
		mpDescription = NULL;
	} // if
} // cleanUpDescription

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpDescription];
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

//---------------------------------------------------------------------------

- (Media) media
{
	return( mpDescription->media );
} // media

//---------------------------------------------------------------------------

- (Track) track
{
	return( mpDescription->track );
} // track

//---------------------------------------------------------------------------

- (Movie) movie
{
	return( mpDescription->movie );
} // movie

//---------------------------------------------------------------------------

- (DataHandler) dataHandler
{
	return( mpDescription->outputDataHandler );
} // dataHandler

//---------------------------------------------------------------------------

- (TimeValue) durationPerSample
{
	return( mpDescription->durationPerSample );
} // durationPerSample

//---------------------------------------------------------------------------

- (TimeValue) sampleTime
{
	return( mpDescription->sampleTime );
} // sampleTime

//---------------------------------------------------------------------------

- (SampleDescriptionHandle) sampleDescriptionHandle
{
	return( (SampleDescriptionHandle)mpDescription->hImage );
} // sampleDescriptionHandle

//---------------------------------------------------------------------------

- (unsigned long) sampleSize
{
	return( mpDescription->sampleSize );
} // sampleSize

//---------------------------------------------------------------------------

- (unsigned long) numberOfSamples
{
	return( mpDescription->numberOfSamples );
} // numberOfSamples

//---------------------------------------------------------------------------

- (short) sampleFlags
{
	return( mpDescription->sampleFlags );
} // sampleFlags

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
