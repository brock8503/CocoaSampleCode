//---------------------------------------------------------------------------------------
//
//	File: OpenGLQuery.h
//
//  Abstract: Utility class for discovering the OpenGL vendor and renderor
// 			 
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Inc. ("Apple") in consideration of your agreement to the following terms, 
//  and your use, installation, modification or redistribution of this Apple 
//  software constitutes acceptance of these terms.  If you do not agree with 
//  these terms, please do not use, install, modify or redistribute this 
//  Apple software.
//  
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software. 
//  Neither the name, trademarks, service marks or logos of Apple Inc. may 
//  be used to endorse or promote products derived from the Apple Software 
//  without specific prior written permission from Apple.  Except as 
//  expressly stated in this notice, no other rights or licenses, express
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
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#import "OpenGLQuery.h"

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------------------

struct OpenGLQueryData
{
	BOOL mbIsATI;
	BOOL mbIsIntel;
	BOOL mbIsNVIDIA;

	NSMutableString *mpInfo;

	NSString *mpRenderer;
	NSString *mpVendor;
	NSString *mpVersion;
};

typedef struct OpenGLQueryData  OpenGLQueryData;

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

static NSString *OpenGLGetNSString( const GLenum theName )
{
	const char *pString = (const char *)glGetString( theName );
	
	return( [[NSString alloc] initWithCString:pString 
									 encoding:NSUTF8StringEncoding] );
} // OpenGLGetNSString

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------------------

@implementation OpenGLQuery

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated Initializer

//---------------------------------------------------------------------------------------

- (id) init
{
	self = [super init];
	
	if( self )
	{
		mpQuery = (OpenGLQueryDataRef)calloc(1, sizeof(OpenGLQueryData));
		
		if( mpQuery != NULL )
		{
			mpQuery->mpRenderer = OpenGLGetNSString( GL_RENDERER );
			mpQuery->mpVendor   = OpenGLGetNSString( GL_VENDOR );
			mpQuery->mpVersion  = OpenGLGetNSString( GL_VERSION );
			
			mpQuery->mpInfo = [[NSMutableString alloc] initWithCapacity:0];
			
			if( mpQuery->mpInfo )
			{
				if( mpQuery->mpVendor )
				{
					[mpQuery->mpInfo appendFormat:@"%@\n",mpQuery->mpVendor];
				} // if
				
				if( mpQuery->mpRenderer )
				{
					[mpQuery->mpInfo appendFormat:@"%@\n",mpQuery->mpRenderer];
				} // if
				
				if( mpQuery->mpVersion )
				{
					[mpQuery->mpInfo appendString:mpQuery->mpVersion];
				} // if
			} // if
			
			NSPredicate *pPredicateATI = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] 'ati'"];
			
			if( pPredicateATI )
			{
				mpQuery->mbIsATI = [pPredicateATI  evaluateWithObject:mpQuery->mpVendor];
			} // if
			
			NSPredicate *pPredicateINTEL = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] 'intel'"];
			
			if( pPredicateINTEL )
			{
				mpQuery->mbIsIntel = [pPredicateINTEL evaluateWithObject:mpQuery->mpVendor];
			} // if
			
			NSPredicate *pPredicateNV = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH[c] 'nvidia'"];
			
			if( pPredicateNV )
			{
				mpQuery->mbIsNVIDIA = [pPredicateNV   evaluateWithObject:mpQuery->mpVendor];
			} // if
		} // if
	} // if
	
	return( self );
} // init

//---------------------------------------------------------------------------------------

+ (id) query
{
	return( [[[OpenGLQuery allocWithZone:[self zone]] init] autorelease] );
} // query

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//---------------------------------------------------------------------------------------

- (void) cleanUpQuery
{
	if( mpQuery != NULL )
	{
		// Info isn't needed
		
		if( mpQuery->mpInfo )
		{
			[mpQuery->mpInfo release];
			
			mpQuery->mpInfo = nil;
		} //if
		
		// Renderer's name isn't needed
		
		if( mpQuery->mpRenderer )
		{
			[mpQuery->mpRenderer release];
			
			mpQuery->mpRenderer = nil;
		} //if
		
		// Renderer's vendor isn't needed
		
		if( mpQuery->mpVendor )
		{
			[mpQuery->mpVendor release];
			
			mpQuery->mpVendor = nil;
		} // if
		
		// Renderer's version isn't needed
		
		if( mpQuery->mpVersion )
		{
			[mpQuery->mpVersion release];
			
			mpQuery->mpVersion = nil;
		} // if
		
		free(mpQuery);
		
		mpQuery = NULL;
	} // if
} // cleanUpQuery

//---------------------------------------------------------------------------------------

- (void) dealloc
{
	// Release strings
	
	[self cleanUpQuery];
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

//---------------------------------------------------------------------------------------

- (NSString *) renderer
{
	return( mpQuery->mpRenderer );
} // renderer

//---------------------------------------------------------------------------------------

- (NSString *) vendor
{
	return( mpQuery->mpVendor );
} // vendor

//---------------------------------------------------------------------------------------

- (NSString *) version
{
	return( mpQuery->mpVersion );
} // version

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Utilities

//---------------------------------------------------------------------------------------

- (NSString *) info
{
	return mpQuery->mpInfo;
} // info

//---------------------------------------------------------------------------------------

- (BOOL) ati
{
	return( mpQuery->mbIsATI );
} // ati

//---------------------------------------------------------------------------------------

- (BOOL) intel
{
	return( mpQuery->mbIsIntel );
} // intel

//---------------------------------------------------------------------------------------

- (BOOL) nvidia
{
	return( mpQuery->mbIsNVIDIA );
} // nvidia

//---------------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

