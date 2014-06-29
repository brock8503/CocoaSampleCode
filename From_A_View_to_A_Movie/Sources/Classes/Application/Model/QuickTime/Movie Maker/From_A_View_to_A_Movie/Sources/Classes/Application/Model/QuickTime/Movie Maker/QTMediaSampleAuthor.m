/*
     File: QTMediaSampleAuthor.m
 Abstract: 
 Utility class for writing raw media samples to a file.
 
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

#import <libkern/OSAtomic.h>

//---------------------------------------------------------------------------

#import "QTMediaSampleNotifications.h"
#import "QTMediaSampleAuthor.h"
#import "QTMediaSampleAuthorOperation.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#define FILE_PERMS  0666
#define OPEN_PERMS  O_CREAT | O_WRONLY

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structure

//---------------------------------------------------------------------------

struct QTMediaSampleAuthorData
{
	BOOL                mbIsClosed;
	BOOL                mbIsSuspended;
	volatile int32_t    mnEnqueued;
	volatile int32_t    mnAdded;
	NSOperationQueue   *mpQueue;
	QTMediaSampleFile  *mpMedia;
}; // QTMediaSampleAuthorData

typedef struct QTMediaSampleAuthorData   QTMediaSampleAuthorData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation QTMediaSampleAuthor

//---------------------------------------------------------------------------

- (void) newOperationQueue
{
	mpAuthor->mpQueue = [NSOperationQueue new];
	
	[mpAuthor->mpQueue setMaxConcurrentOperationCount:1];
} // newOperationQueue

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

- (id) initMediaSampleAuthorWithPathName:(NSString *)thePathname
						 mediaSampleSize:(const NSSize *)theMediaSampleSize
{
	self = [super init];
	
	if( self )
	{
		mpAuthor = (QTMediaSampleAuthorDataRef)calloc(1, sizeof(QTMediaSampleAuthorData));
		
		if( mpAuthor != NULL )
		{
			mpAuthor->mpMedia = [[QTMediaSampleFile alloc] initWithPathname:thePathname
																	 access:FILE_PERMS
																	 create:OPEN_PERMS];
			
			if( mpAuthor->mpMedia )
			{
				if( [mpAuthor->mpMedia open] )
				{
					mpAuthor->mbIsClosed = NO;
				} // if
				
				mpAuthor->mbIsSuspended = NO;
				
				mpAuthor->mnAdded    = 0;
				mpAuthor->mnEnqueued = 0;
				
				[self newOperationQueue];
			} // if
		} // if
		else
		{
			NSLog( @">> ERROR: QT Media Sample Author - Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return( self );
} // initMediaSampleAuthorWithPathName

//---------------------------------------------------------------------------

- (void) flushOperationQueue
{
	if( !mpAuthor->mbIsClosed )
	{
		[mpAuthor->mpQueue waitUntilAllOperationsAreFinished];
		
		if( mpAuthor->mpQueue )
		{
			[mpAuthor->mpQueue release];
			
			mpAuthor->mpQueue = nil;
		} // if
	} // if
} // flushOperationQueue

//---------------------------------------------------------------------------

- (void) closeMediaSampleFile
{
	if( !mpAuthor->mbIsClosed )
	{
		[mpAuthor->mpMedia close];
	} // if
	
	if( mpAuthor->mpMedia )
	{
		[mpAuthor->mpMedia release];
		
		mpAuthor->mpMedia = nil;
	} // if
} // closeMediaSampleFile

//---------------------------------------------------------------------------

- (void) releaseMediaSampleAuthorDataStore
{
	if( mpAuthor != NULL )
	{
		free( mpAuthor );
		
		mpAuthor = NULL;
	} // if
} // releaseMediaSampleAuthorDataStore

//---------------------------------------------------------------------------

- (void) cleanUpAuthor
{
	[self flushOperationQueue];
	[self closeMediaSampleFile];
	[self releaseMediaSampleAuthorDataStore];
} // cleanUpAuthor

//---------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpAuthor];
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------

- (BOOL) isSuspended
{
	register uint32_t  value = (uint32_t)mpAuthor->mnEnqueued;
	register uint32_t  mask   = 150;
	register uint32_t  result = value ^ mask;
	
	return( !result );
} // isSuspended

//---------------------------------------------------------------------------

- (int32_t) count
{
	int32_t value = mpAuthor->mnEnqueued;
	
	return( value );
} // authoring

//---------------------------------------------------------------------------

- (int32_t) samples
{
	int32_t value = mpAuthor->mnAdded;
	
	return( value );
} // samples

//---------------------------------------------------------------------------

- (void) addMediaSampleToQueue:(QTMediaSample *)theMediaSample
{
	QTMediaSampleAuthorOperation *mediaSampleAuthorOp = [[QTMediaSampleAuthorOperation alloc] initMediaSampleAuthorOperation:theMediaSample
																														file:mpAuthor->mpMedia
																													enqueued:&mpAuthor->mnEnqueued
																													 samples:&mpAuthor->mnAdded];
	
	if( mediaSampleAuthorOp )
	{
		[mpAuthor->mpQueue addOperation:mediaSampleAuthorOp];
		
		OSAtomicIncrement32Barrier( &mpAuthor->mnEnqueued );
		
		[mediaSampleAuthorOp release];
	} // if
} // addMediaSampleToQueue

//---------------------------------------------------------------------------

- (void) writeMediaSampleAsync:(QTMediaSample *)theMediaSample
{
	if( mpAuthor->mpQueue == nil )
	{
		[self newOperationQueue];
	} // if
	
	[self addMediaSampleToQueue:theMediaSample];
} // writeAsync

//---------------------------------------------------------------------------

- (void) writeFlushQueue
{
    mpAuthor->mbIsSuspended = [self isSuspended];
    
	if( mpAuthor->mbIsSuspended )
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:QTMediaSampleAuthorIsSuspended
															object:self];
		
		[self flushOperationQueue];
	} // if
} // writeFlushQueue

//---------------------------------------------------------------------------

- (BOOL) writeCanResume
{
	if( mpAuthor->mbIsSuspended )
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:QTMediaSampleAuthorIsResumed
															object:self];
		
		mpAuthor->mbIsSuspended = NO;
	} // if
    
    return mpAuthor->mbIsSuspended;
} // writeCanResume

//---------------------------------------------------------------------------

- (BOOL) writeAsync:(QTMediaSample *)theMediaSample
{
	[self writeFlushQueue];
	[self writeMediaSampleAsync:theMediaSample];
    
	return [self writeCanResume];
} // writeAsync

//---------------------------------------------------------------------------

- (BOOL) close
{
	[mpAuthor->mpQueue waitUntilAllOperationsAreFinished];
	
	mpAuthor->mbIsClosed = [mpAuthor->mpMedia close];
	
	return( mpAuthor->mbIsClosed );
} // close

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

