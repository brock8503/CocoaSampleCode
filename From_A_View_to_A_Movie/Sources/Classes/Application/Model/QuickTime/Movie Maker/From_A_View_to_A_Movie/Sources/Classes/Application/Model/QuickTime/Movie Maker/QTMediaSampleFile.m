/*
     File: QTMediaSampleFile.m
 Abstract: 
 Utility class for manging file operations using a file descriptor.
 
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

#import <errno.h>
#import <limits.h>
#import <unistd.h>

//---------------------------------------------------------------------------

#import "QTMediaSampleFile.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Macros

//---------------------------------------------------------------------------

#define QTMediaSampleWriteTypes  2

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Enumerated Types

//---------------------------------------------------------------------------

enum QTMediaSampleFileWriteType
{
	kQTMediaSampleFilePWrite = 0,
	kQTMediaSampleFileWrite
};

typedef enum QTMediaSampleFileWriteType QTMediaSampleFileWriteType;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Definitions - Function Pointers 

//---------------------------------------------------------------------------

typedef ssize_t (*QTMediaSampleWriteFuncPtr)
(
    int         fileDesc,
    const void *buffer,
    size_t      bufferSize,
    off_t       fileOffset
);

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Implementations - Function Pointers

//---------------------------------------------------------------------------

static ssize_t QTMediaSamplePWrite(int fileDesc,
                                   const void *buffer,
                                   size_t bufferSize,
                                   off_t fileOffset)
{
	return( pwrite(fileDesc, buffer, bufferSize, fileOffset) );
} // QTMediaSamplePWrite

//---------------------------------------------------------------------------

static ssize_t QTMediaSampleWrite(int fileDesc,
                                  const void *buffer,
                                  size_t bufferSize,
                                  off_t fileOffset)
{
	return( write(fileDesc, buffer, bufferSize) );
} // QTMediaSampleWrite


//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structures

//---------------------------------------------------------------------------

struct QTMediaSampleFileData
{
	NSInteger   descriptor;
	NSInteger   access;
	NSInteger   create;
	int64_t     offset;
	int64_t     size;
	char       *pathname;
	BOOL        closed;
    
    QTMediaSampleWriteFuncPtr  QTMediaSampleWrite[QTMediaSampleWriteTypes];
};

typedef struct QTMediaSampleFileData   QTMediaSampleFileData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities

//---------------------------------------------------------------------------
//
// Create a file and release its file descriptor.
//
//---------------------------------------------------------------------------

static BOOL QTMediaSampleFileOpen(QTMediaSampleFileDataRef pMediaSampleFile)
{
	BOOL isOpen = NO;
	
	pMediaSampleFile->descriptor = open(pMediaSampleFile->pathname,
										pMediaSampleFile->create,
										pMediaSampleFile->access);
	
	isOpen = pMediaSampleFile->descriptor == -1;
	
	if( isOpen )
	{
		NSLog(@">> ERROR[%d]: Creating a QT media file for write failed!", errno);
	} // if
	
	return( isOpen );
} // QTMediaSampleFileOpen

//---------------------------------------------------------------------------
//
// Close a file a release its file descriptor.
//
//---------------------------------------------------------------------------

static BOOL QTMediaSampleFileClose(QTMediaSampleFileDataRef pMediaSampleFile)
{
	if( pMediaSampleFile->descriptor )
	{
		int closed = close( pMediaSampleFile->descriptor );
		
		pMediaSampleFile->closed = closed == 0;
	} // if
	
	return( pMediaSampleFile->closed );
} // QTMediaSampleFileClose

//---------------------------------------------------------------------------
//
// Move the file pointer.  This method can be used with the write method.
//
//---------------------------------------------------------------------------

static BOOL QTMediaSampleFileSeek(const int64_t nFileOffset,
								  const int nFileSeekPos,
								  QTMediaSampleFileDataRef pMediaSampleFile)
{
	int64_t nOffsetResult = -1;
	
	if( pMediaSampleFile->descriptor && ( nFileOffset > 0 ) )
	{
		nOffsetResult = lseek(pMediaSampleFile->descriptor,
							  nFileOffset,
							  nFileSeekPos);
		
		if( nOffsetResult )
		{
			pMediaSampleFile->offset = nOffsetResult;
		} // if
		else
		{
			NSLog(@">> ERROR[%d]: QT media sample file seek failed!", errno );
		} // else
	} // if
	
	return( nOffsetResult > 0 );
} // QTMediaSampleFileSeek

//---------------------------------------------------------------------------
//
// Write a media sample to a file and update the file pointer.
//
//---------------------------------------------------------------------------

static BOOL QTMediaSampleFileWrite(QTMediaSample *pMediaSample,
								   const QTMediaSampleFileWriteType nWriteType,
								   int64_t *pFileOffset,
								   QTMediaSampleFileDataRef pMediaSampleFile)
{
	BOOL wrote = NO;
	
	if( pMediaSample && pMediaSampleFile->descriptor )
	{
		GLvoid *mediaSampleBuffer = [pMediaSample buffer];
		
		if( mediaSampleBuffer != NULL )
		{
			GLuint   pixelBufferLen = [pMediaSample size];
			
			ssize_t byteCount = pMediaSampleFile->QTMediaSampleWrite[nWriteType](pMediaSampleFile->descriptor,
																				 mediaSampleBuffer,
																				 pixelBufferLen,
																				 *pFileOffset);
			
			if( byteCount == - 1 )
			{
				NSLog(@">> ERROR[%d]: QT media sample file write failed!", errno );
			} // if
			else if( byteCount != pixelBufferLen )
			{
				NSLog(@">> WARNING[%d]: Wrote fewer bytes than expected! Expected = %d, Actual = %ld!",
					  errno,
					  pixelBufferLen,
					  byteCount );
				
				long     offset      = *pFileOffset + byteCount;		// Current file offset
				long     bufferBytes = 0;								// Bytes written per write
				long     bufferCount = 0;								// Bytes written total
				long     bufferSize  = pixelBufferLen - byteCount;		// Remaining bytes that need to be written
				GLvoid  *buffer      = mediaSampleBuffer + byteCount;	// Advance buffer pointer to the new position
				
				while( bufferSize > 0 )
				{
					bufferBytes = pMediaSampleFile->QTMediaSampleWrite[nWriteType](pMediaSampleFile->descriptor,
																				   buffer,
																				   bufferSize,
																				   offset);
					
					bufferSize -= bufferBytes;
					
					if( bufferBytes )
					{
						buffer += bufferBytes;
						offset += bufferBytes;
						
						bufferCount += bufferBytes;
					} // if
					else
					{
						NSLog(@">> ERROR[%%ld: Failed to complete the write operation! Bytes remaining = ld",
							  errno,
							  bufferSize);
						
						break;
					} // else
				} // while
				
				*pFileOffset = offset;
				
				pMediaSampleFile->size += bufferCount;
				
				wrote = bufferSize == 0;
			} // if
			else
			{
				*pFileOffset += byteCount;
				
				pMediaSampleFile->size += byteCount;
				
				wrote = YES;
			} // if
		} // if
	} // if
	
	return( wrote );
} // writeMediaSample

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Constructor

//---------------------------------------------------------------------------

static QTMediaSampleFileDataRef QTMediaSampleFileCreate(NSString *pPathname,
														const NSInteger nFileAccess,
														const NSInteger nFileCreate)
{
	QTMediaSampleFileDataRef pMediaSampleFile =  NULL;
	
	if( pPathname )
	{
		pMediaSampleFile = (QTMediaSampleFileDataRef)calloc(1, sizeof(QTMediaSampleFileData));
		
		if( pMediaSampleFile != NULL )
		{
			pMediaSampleFile->access     = nFileAccess;
			pMediaSampleFile->create     = nFileCreate;
			pMediaSampleFile->descriptor = -1;
            
            pMediaSampleFile->QTMediaSampleWrite[0] = &QTMediaSamplePWrite;
            pMediaSampleFile->QTMediaSampleWrite[1] = &QTMediaSampleWrite;
			
			const char *pathname = (char *)[pPathname cStringUsingEncoding:NSASCIIStringEncoding];
			
			if( pathname != NULL )
			{
				size_t nSize = strlen(pathname) + 1;
				
				pMediaSampleFile->pathname = (char *)malloc(nSize);
				
				if( pMediaSampleFile->pathname != NULL )
				{
					strncpy(pMediaSampleFile->pathname,
							pathname,
							nSize);
				} // if
				else
				{
					NSLog( @">> ERROR: QT Media File - Pathname is NULL!" );
				} // else
			} // if
		} // if
		else
		{
			NSLog( @">> ERROR: QT Media File - Failure Allocating Memory For QT Media Sample File data reference!" );
		} // else
	} // if
	
	return pMediaSampleFile;
} // QTMediaSampleFileCreate

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Copy Constructor

//---------------------------------------------------------------------------

static QTMediaSampleFileDataRef QTMediaSampleFileCreateCopy(QTMediaSampleFile *pMediaSampleFileSrc)
{
	QTMediaSampleFileDataRef pMediaSampleFileDst =  NULL;
	
	if( pMediaSampleFileSrc )
	{
		pMediaSampleFileDst = (QTMediaSampleFileDataRef)calloc(1, sizeof(QTMediaSampleFileData));
		
		if( pMediaSampleFileDst != NULL )
		{
            pMediaSampleFileDst->QTMediaSampleWrite[0] = &QTMediaSamplePWrite;
            pMediaSampleFileDst->QTMediaSampleWrite[1] = &QTMediaSampleWrite;
			
			pMediaSampleFileDst->descriptor = [pMediaSampleFileSrc descriptor];
			pMediaSampleFileDst->access     = [pMediaSampleFileSrc access];
			pMediaSampleFileDst->create     = [pMediaSampleFileSrc create];
			pMediaSampleFileDst->offset     = [pMediaSampleFileSrc offset];
			pMediaSampleFileDst->size       = [pMediaSampleFileSrc size];
			pMediaSampleFileDst->closed     = [pMediaSampleFileSrc isClosed];
			
			const char *pPathnameSrc = [pMediaSampleFileSrc pathname];
			
			if( pPathnameSrc != NULL )
			{
				size_t nSizeSrc = strlen(pPathnameSrc) + 1;
				
				pMediaSampleFileDst->pathname = (char *)malloc(nSizeSrc);
				
				if( pMediaSampleFileDst->pathname != NULL )
				{
					strncpy(pMediaSampleFileDst->pathname,
							pPathnameSrc,
							nSizeSrc);
				} // if
			} // if
		} // if
		else
		{
			NSLog( @">> ERROR: QT Media File - Failure Allocating Memory For QT Media Sample File copy!" );
		} // else
	} // if
	
	return pMediaSampleFileDst;
} // QTMediaSampleFileCreate

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Destructor

//---------------------------------------------------------------------------

static void QTMediaSampleFileDelete(QTMediaSampleFileDataRef pMediaSampleFile)
{
	if( pMediaSampleFile != NULL )
	{
		if( !pMediaSampleFile->closed )
		{
			QTMediaSampleFileClose(pMediaSampleFile);
		} // if
		
		if( pMediaSampleFile->pathname != NULL )
		{
			free( pMediaSampleFile->pathname );
		} // if
		
		free( pMediaSampleFile );
		
		pMediaSampleFile = NULL;
	} // if
} // QTMediaSampleFileDelete

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

@implementation QTMediaSampleFile

//---------------------------------------------------------------------------

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // init

//---------------------------------------------------------------------------

- (id) initWithPathname:(NSString *)thePathname
				 access:(const NSInteger)theAccess
				 create:(const NSInteger)theCreate
{
	self = [super init];
	
	if( self )
	{
		mpMediaSampleFile = QTMediaSampleFileCreate(thePathname,
													theAccess,
													theCreate);
	} // if
	
	return( self );
} // initWithPathname

//---------------------------------------------------------------------------

- (id) initWithMediaSampleFile:(QTMediaSampleFile *)theMediaSampleFile
{
	self = [super init];
	
	if( self )
	{
		mpMediaSampleFile = QTMediaSampleFileCreateCopy(theMediaSampleFile);
	} // if
	
	return self;
} // initWithMediaSampleFile

//---------------------------------------------------------------------------

+ (id) mediaSampleFiletWithPathname:(NSString *)thePathname
							 access:(const NSInteger)theAccess
							 create:(const NSInteger)theCreate
{
	return( [[[QTMediaSampleFile allocWithZone:[self zone]] initWithPathname:thePathname
																	  access:theAccess
																	  create:theCreate] autorelease] );
} // mediaSampleFiletWithPathname

//---------------------------------------------------------------------------

- (id) copyWithZone:(NSZone *)zone
{
    return [[QTMediaSampleFile allocWithZone:zone] initWithMediaSampleFile:self];
} // copyWithZone

//---------------------------------------------------------------------------

- (void) dealloc
{
	QTMediaSampleFileDelete(mpMediaSampleFile);
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

- (BOOL) isClosed
{
	return( mpMediaSampleFile->closed );
} // isClosed

//---------------------------------------------------------------------------

- (const char *) pathname
{
	return( mpMediaSampleFile->pathname );
} // pathname

//---------------------------------------------------------------------------

- (NSInteger) descriptor
{
	return( mpMediaSampleFile->descriptor );
} // descriptor

//---------------------------------------------------------------------------

- (NSInteger) access
{
	return( mpMediaSampleFile->access );
} // access

//---------------------------------------------------------------------------

- (NSInteger) create
{
	return( mpMediaSampleFile->create );
} // create

//---------------------------------------------------------------------------

- (int64_t) offset
{
	return( mpMediaSampleFile->offset );
} // offset

//---------------------------------------------------------------------------

- (int64_t) size
{
	return( mpMediaSampleFile->size );
} // size

//---------------------------------------------------------------------------
//
// Move the file offset. Use in conjunction with -pwrite: method.
//
//---------------------------------------------------------------------------

- (void) setOffset:(const int64_t)theFileOffset
{
	mpMediaSampleFile->offset = theFileOffset;
} // setOffset

//---------------------------------------------------------------------------
//
// Create a file and release its file descriptor.
//
//---------------------------------------------------------------------------

- (BOOL) open
{
	return QTMediaSampleFileOpen(mpMediaSampleFile);
} // open

//---------------------------------------------------------------------------
//
// Close a file a release its file descriptor.
//
//---------------------------------------------------------------------------

- (BOOL) close
{
	return QTMediaSampleFileClose(mpMediaSampleFile);
} // close

//---------------------------------------------------------------------------
//
// Move the file pointer.  This method can be used with the write method.
//
//---------------------------------------------------------------------------

- (BOOL) seek:(const int64_t)theFileOffset
		 from:(const int)theFileSeekPos
{
	return QTMediaSampleFileSeek(theFileOffset, theFileSeekPos, mpMediaSampleFile);
} // seek

//---------------------------------------------------------------------------
//
// Write and move the file pointer.
//
//---------------------------------------------------------------------------

- (BOOL) write:(QTMediaSample *)theMediaSample
{
	return QTMediaSampleFileWrite(theMediaSample,
								  kQTMediaSampleFileWrite,
								  &mpMediaSampleFile->offset,
								  mpMediaSampleFile);
} // write

//---------------------------------------------------------------------------
//
// Use the pwrite UNIX system call to either write media sample using its
// current media sample file offset.
//
//---------------------------------------------------------------------------

- (BOOL) writeUsingOffset:(QTMediaSample *)theMediaSample
{
	int64_t mediaSampleFileOffset = mpMediaSampleFile->offset;
	
	return QTMediaSampleFileWrite(theMediaSample,
								  kQTMediaSampleFilePWrite,
								  &mediaSampleFileOffset,
								  mpMediaSampleFile);
} // writeUsingOffset

//---------------------------------------------------------------------------
//
// Use the pwrite UNIX system call to either write media sample using its
// frame index.
//
//---------------------------------------------------------------------------

- (BOOL) writeUsingIndex:(QTMediaSample *)theMediaSample
{
	int64_t mediaSampleFileOffset = [theMediaSample index] * [theMediaSample size];
	
	return QTMediaSampleFileWrite(theMediaSample,
								  kQTMediaSampleFilePWrite,
								  &mediaSampleFileOffset,
								  mpMediaSampleFile);
} // writeUsingIndex

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

