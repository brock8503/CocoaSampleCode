/*
     File: OpenGLViewTexture.m
 Abstract: 
 Utility toolkit for converting a back buffer to a texture.
 
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

#import "OpenGLViewTexture.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structures

//---------------------------------------------------------------------------

struct OpenGLViewTextureData
{
	GLuint   name;				// Texture name
	GLenum   target;			// Texture target
	GLenum   format;			// format
	GLenum   internalFormat;	// internal format
	GLenum   type;				// OpenGL specific type
	GLenum   buffer;			// OpenGL read buffer
	GLint    level;				// Texture level
	GLint    xoffset;			// X offset into the texture
	GLint    yoffset;			// Y offset into the texture
	GLint    border;			// Texture border
	GLsizei  width;				// Texture width
	GLsizei  height;			// Texture height
};

typedef struct OpenGLViewTextureData   OpenGLViewTextureData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLViewTexture

//---------------------------------------------------------------------------

- (void) newOpenGLTextureRange:(const GLenum)theReadBuffer
{
	NSDictionary *textureDictionary = [self dictionary];
	
	if( textureDictionary )
	{
		mpViewTexture->name           = [[textureDictionary objectForKey:@"name"] integerValue];
		mpViewTexture->target         = [[textureDictionary objectForKey:@"target"] integerValue];
		mpViewTexture->level          = [[textureDictionary objectForKey:@"level"] integerValue];
		mpViewTexture->format         = [[textureDictionary objectForKey:@"format"] integerValue];
		mpViewTexture->type           = [[textureDictionary objectForKey:@"type"] integerValue];
		mpViewTexture->internalFormat = [[textureDictionary objectForKey:@"internalformat"] integerValue];
		mpViewTexture->border         = [[textureDictionary objectForKey:@"border"] integerValue];
		mpViewTexture->xoffset        = [[textureDictionary objectForKey:@"xoffset"] integerValue];
		mpViewTexture->yoffset        = [[textureDictionary objectForKey:@"yoffset"] integerValue];
		mpViewTexture->width          = [[textureDictionary objectForKey:@"width"] integerValue];
		mpViewTexture->height         = [[textureDictionary objectForKey:@"height"] integerValue];
		mpViewTexture->buffer         = theReadBuffer;
	} // if
} // newOpenGLTextureRange

//---------------------------------------------------------------------------
//
// Initialize
//
//---------------------------------------------------------------------------

- (id) initViewTextureWithBounds:(const NSRect *)theBounds
							hint:(const GLint)theTextureHint
						  buffer:(const GLenum)theReadBuffer
{
	self = [super initTextureRangeWithBounds:theBounds
										hint:theTextureHint];

	if( self )
	{	
		mpViewTexture = (OpenGLViewTextureDataRef)malloc( sizeof(OpenGLViewTextureData) );
		
		if( mpViewTexture != NULL )
		{
			[self newOpenGLTextureRange:theReadBuffer];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL View Texture - Failure Allocating Memory For Attributes!" );
		} // else
	} // if
	
	return( self );
} // initViewRecorderBaseWithFrame

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Dealloc all the Resources

//---------------------------------------------------------------------------

- (void) dealloc 
{
	if( mpViewTexture != NULL )
	{
		free( mpViewTexture );
		
		mpViewTexture = NULL;
	} // if
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

//---------------------------------------------------------------------------

- (BOOL) setBounds:(const NSRect *)theTextureBounds
{
	GLuint width  = (GLuint)theTextureBounds->size.width;
	GLuint height = (GLuint)theTextureBounds->size.height;
	
	BOOL bSuccess = (width != mpViewTexture->width) || (height != mpViewTexture->height);
	
	if(	bSuccess )
	{
		bSuccess = bSuccess && [super setBounds:theTextureBounds];
		
		[self newOpenGLTextureRange:mpViewTexture->buffer];
	} // if
	
	return bSuccess;
} // setBounds

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Utilities

//---------------------------------------------------------------------------

- (void) readback
{
	// Read from a buffer
	
	glReadBuffer( mpViewTexture->buffer );
	
	// Enable the target texture
	
	glEnable(mpViewTexture->target);
	
	// Bind the texture for copying
	
	glBindTexture(mpViewTexture->target, 
				  mpViewTexture->name);
	
	// Copy from the back buffer to the bound texture
	
	glCopyTexImage2D(mpViewTexture->target, 
					 mpViewTexture->level,
					 mpViewTexture->internalFormat, 
					 mpViewTexture->xoffset, 
					 mpViewTexture->yoffset, 
					 mpViewTexture->width, 
					 mpViewTexture->height, 
					 mpViewTexture->border);
	
	// Unbind the texture that was used for copying
	
	glBindTexture(mpViewTexture->target, 0);
	
	// Disable the target texture
	
	glDisable(mpViewTexture->target);
} // readback

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
