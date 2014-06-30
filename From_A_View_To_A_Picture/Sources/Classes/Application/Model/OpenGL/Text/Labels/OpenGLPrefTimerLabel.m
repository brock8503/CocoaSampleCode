//---------------------------------------------------------------------------------------
//
//	File: OpenGLPrefTimerLabel.m
//
//  Abstract: Utility class for displaying a pref timer
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
//  Copyright (c) 2008-2009, 2012 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#import "OpenGLPrefTimerLabel.h"

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------------------

struct OpenGLPrefTimerLabelData
{
	BOOL        mbUpdateDisplay;
	BOOL        mbUpdateLabel;
	GLdouble    mnFPS;
	NSString   *mpFormat;
	NSString   *mpLabel;
	PrefTimer  *mpTimer;
};

typedef struct	OpenGLPrefTimerLabelData OpenGLPrefTimerLabelData;

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------------------

@implementation OpenGLPrefTimerLabel

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated Initializer

//---------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------

- (id) initWithString:(NSString *)theTextString
			 fontName:(NSString *)theFontName
			 fontSize:(const CGFloat)theFontSize
			textColor:(NSColor *)theTextColor
			 boxColor:(NSColor *)theBoxColor
		  borderColor:(NSColor *)theBorderColor
		  coordinates:(const NSPoint *)theCoordinates
			   bounds:(const NSRect *)theBounds
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // initWithString

//---------------------------------------------------------------------------------------

- (id) initLabelWithFormat:(NSString *)theFormatString
				  fontName:(NSString *)theFontName
				  fontSize:(const CGFloat)theFontSize
				 textColor:(NSColor *)theTextColor
				  boxColor:(NSColor *)theBoxColor
			   borderColor:(NSColor *)theBorderColor
			   coordinates:(const NSPoint *)theCoordinates
					bounds:(const NSRect *)theBounds
{
	PrefTimer *pTimer = [PrefTimer prefTimer];
	
	if( pTimer )
	{
		NSString  *pFormat = nil;
		
		if( theFormatString )
		{
			pFormat = [NSString stringWithString:theFormatString];
		} // if
		else
		{
			pFormat = @"FPS: %5.2f";
		} // else
		
		if( pFormat )
		{
			double fps = [pTimer perfTick];
			
			NSString  *pLabel = [NSString stringWithFormat:pFormat,fps];
			
			if( pLabel )
			{
				self = [super initWithString:pLabel
									fontName:theFontName
									fontSize:theFontSize
								   textColor:theTextColor
									boxColor:theBoxColor
								 borderColor:theBorderColor
								 coordinates:theCoordinates
									  bounds:theBounds];
				
				if( self )
				{
					[self setUsage:kOpenGLTextureUsePBODynamicDraw];
					
					mpLabelPrefTimer = (OpenGLPrefTimerLabelDataRef)calloc(1, sizeof(OpenGLPrefTimerLabelData));
					
					if( mpLabelPrefTimer != NULL )
					{
						mpLabelPrefTimer->mpTimer         = [pTimer retain];
						mpLabelPrefTimer->mpFormat        = [pFormat retain];
						mpLabelPrefTimer->mpLabel         = [pLabel retain];
						mpLabelPrefTimer->mnFPS           = fps;
						mpLabelPrefTimer->mbUpdateDisplay = YES;
						mpLabelPrefTimer->mbUpdateLabel   = YES;
					} // if
					else
					{
						NSLog( @">> ERROR: OpenGL Pref Timer Label - Failure Allocating Memory For Attributes!" );
					}  // else
				} // if
			} // if
		} // if
	} // if
	
	return self;
} // initWithFrame

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//---------------------------------------------------------------------------------------

- (void) dealloc
{
	// View's memory container isn't needed
	
	if( mpLabelPrefTimer != NULL )
	{
		// Release the performance timer
		
		if( mpLabelPrefTimer->mpTimer )
		{
			[mpLabelPrefTimer->mpTimer release];
			
			mpLabelPrefTimer->mpTimer = nil;
		} // if
		
		// Release perf timer's string objects
		
		if( mpLabelPrefTimer->mpLabel )
		{
			[mpLabelPrefTimer->mpLabel release];
			
			mpLabelPrefTimer->mpLabel = nil;
		} // if
		
		if( mpLabelPrefTimer->mpFormat )
		{
			[mpLabelPrefTimer->mpFormat release];
			
			mpLabelPrefTimer->mpFormat = nil;
		} // if
		
		free( mpLabelPrefTimer );
		
		mpLabelPrefTimer = NULL;
	} //if
	
	// Dealloc the superclass
	
	[super dealloc];
} // dealloc

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Preformance Timer Setters

//---------------------------------------------------------------------------------------

- (void) labelSetNeedsDisplay:(const BOOL)theLabelNeedsDisplay
{
	mpLabelPrefTimer->mbUpdateDisplay = theLabelNeedsDisplay;
} // labelSetNeedsDisplay

//---------------------------------------------------------------------------------------

- (void) labelSetNeedsUpdate:(const BOOL)theLabelNeedsUpdate
{
	mpLabelPrefTimer->mbUpdateLabel = theLabelNeedsUpdate;
} // labelSetNeedsUpdate

//---------------------------------------------------------------------------------------

- (void) labelSetFormatString:(NSString *)theFormatString
{
	if( theFormatString )
	{
		[theFormatString retain];
		
		[mpLabelPrefTimer->mpFormat release];
		
		mpLabelPrefTimer->mpFormat = theFormatString;
	} //if
} // labelSetFormatString

//---------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Pref Timer View Updates

//---------------------------------------------------------------------------------------

- (void) labelUpdatePrefTimerString
{
	NSString *pLabel = [[NSString alloc] initWithFormat:mpLabelPrefTimer->mpFormat,mpLabelPrefTimer->mnFPS];
	
	if( pLabel )
	{
		[mpLabelPrefTimer->mpLabel release];
		
		mpLabelPrefTimer->mpLabel = pLabel;
		
		[self setText:mpLabelPrefTimer->mpLabel];
	} // if
} // labelUpdatePrefTimerString

//---------------------------------------------------------------------------------------

- (void) labelDraw
{
	if( mpLabelPrefTimer->mbUpdateDisplay )
	{
		// Preformance ticker text should update only if the
		// the geometry in the view is rotating.
		
		if( mpLabelPrefTimer->mbUpdateLabel )
		{
			double mnFPS = [mpLabelPrefTimer->mpTimer perfTick];
			
			if( mnFPS != mpLabelPrefTimer->mnFPS )
			{
				mpLabelPrefTimer->mnFPS = mnFPS;
				
				[self labelUpdatePrefTimerString];
			} // if
		} // if
		
		[self drawText];
	} // if
} // labelDraw

//---------------------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------

