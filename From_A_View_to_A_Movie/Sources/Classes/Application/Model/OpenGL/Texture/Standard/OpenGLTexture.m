/*
     File: OpenGLTexture.m
 Abstract: 
 Utility toolkit for handling shader's texture.
 
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

#import "OpenGLTexture.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Private Data Structure

//---------------------------------------------------------------------------

struct OpenGLTextureData
{
	GLuint    name;				// texture id
	GLint     level;			// level-of-detail	number
	GLint     border;			// width of the border, either 0  or 1
	GLint     minFilter;		// texture min filter type
	GLint     magFilter;		// texture mag filter type
	GLint     wrapS;			// texture 3D wrap s parameter
	GLint	  wrapT;			// texture 3D wrap t parameter
	GLint     wrapR;			// texture 3D wrap r parameter
	GLint     xoffset;			// offset from x (used for 1D, 2D, 3D)
	GLint     yoffset;			// offset from y (used for 2D, 3D)
	GLint     zoffset;			// offset from z (used for 3D)
	GLsizei   count;			// texture count
	GLsizei   width;			// texture width (used for 1D, 2D, 3D)
	GLsizei   height;			// texture height (used for 2D, 3D)
	GLsizei   depth;			// texture depth (used for 3D)
	GLenum    active;			// Active texture
	GLenum    target;			// e.g., texture 2D or texture rectangle
	GLenum    format;			// format
	GLenum    internalFormat;	// internal format
	GLenum    type;				// OpenGL specific type
};

typedef struct OpenGLTextureData  OpenGLTextureData;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -

//---------------------------------------------------------------------------

@implementation OpenGLTexture

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Generating New Textures

//---------------------------------------------------------------------------

- (void) newTextureAttributesWithDictionary:(NSDictionary *)theTextureDict
{
	if( theTextureDict )
	{
		mpTexture->active         = [[theTextureDict objectForKey:@"active"] integerValue];
		mpTexture->count          = [[theTextureDict objectForKey:@"count"] integerValue];
		mpTexture->target         = [[theTextureDict objectForKey:@"target"] integerValue];
		mpTexture->level          = [[theTextureDict objectForKey:@"level"] integerValue];
		mpTexture->internalFormat = [[theTextureDict objectForKey:@"internalformat"] integerValue];
		mpTexture->width          = [[theTextureDict objectForKey:@"width"] integerValue];
		mpTexture->height         = [[theTextureDict objectForKey:@"height"] integerValue];
		mpTexture->depth          = [[theTextureDict objectForKey:@"depth"] integerValue];
		mpTexture->border         = [[theTextureDict objectForKey:@"border"] integerValue];
		mpTexture->format         = [[theTextureDict objectForKey:@"format"] integerValue];
		mpTexture->type           = [[theTextureDict objectForKey:@"type"] integerValue];
		mpTexture->wrapS          = [[theTextureDict objectForKey:@"wrapS"] integerValue];
		mpTexture->wrapT          = [[theTextureDict objectForKey:@"wrapT"] integerValue];
		mpTexture->wrapR          = [[theTextureDict objectForKey:@"wrapR"] integerValue];
		mpTexture->minFilter      = [[theTextureDict objectForKey:@"min"] integerValue];
		mpTexture->magFilter      = [[theTextureDict objectForKey:@"mag"] integerValue];
		mpTexture->xoffset        = 0;
		mpTexture->yoffset        = 0;
		mpTexture->zoffset        = 0;
		mpTexture->name           = 0;
	} // if
	else
	{
		NSLog( @">> ERROR: OpenGL Texture - Failure Allocating Texture Attributes due to an empty dictionary!" );
	}  // else
} // newTextureAttributesWithDictionary

//---------------------------------------------------------------------------

- (void) newTexture1D:(const GLvoid *)thePixels
{
	glTexImage1D(mpTexture->target,
				 mpTexture->level,
				 mpTexture->internalFormat,
				 mpTexture->width,
				 mpTexture->border,
				 mpTexture->format,
				 mpTexture->type,
				 thePixels);
} // newTexture1D

//---------------------------------------------------------------------------

- (void) newTexture2D:(const GLvoid *)thePixels
{
	glTexImage2D(mpTexture->target,
				 mpTexture->level,
				 mpTexture->internalFormat,
				 mpTexture->width,
				 mpTexture->height,
				 mpTexture->border,
				 mpTexture->format,
				 mpTexture->type,
				 thePixels);
} // newTexture2D

//---------------------------------------------------------------------------

- (void) newTexture3D:(const GLvoid *)thePixels
{
	glTexParameterf(mpTexture->target, GL_TEXTURE_WRAP_S, mpTexture->wrapS);
	glTexParameterf(mpTexture->target, GL_TEXTURE_WRAP_T, mpTexture->wrapT);
	glTexParameterf(mpTexture->target, GL_TEXTURE_WRAP_R, mpTexture->wrapR);
	
	glTexImage3D(mpTexture->target,
				 mpTexture->level,
				 mpTexture->internalFormat,
				 mpTexture->width,
				 mpTexture->height,
				 mpTexture->depth,
				 mpTexture->border,
				 mpTexture->format,
				 mpTexture->type,
				 thePixels);
} // newTexture3D

//---------------------------------------------------------------------------

- (void) newTexture:(const GLvoid *)thePixels
{
	glActiveTexture(mpTexture->active);
	glGenTextures(mpTexture->count, &mpTexture->name);
	
	if( mpTexture->name )
	{
		glEnable(mpTexture->target);
		{
			glTextureRangeAPPLE(mpTexture->target, 0, NULL);
			
			glTexParameteri(mpTexture->target,
							GL_TEXTURE_STORAGE_HINT_APPLE,
							GL_STORAGE_PRIVATE_APPLE);
			
			glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_FALSE);
			
			glBindTexture(mpTexture->target, mpTexture->name);
			
			glTexParameterf(mpTexture->target, GL_TEXTURE_MAG_FILTER, mpTexture->magFilter);
			glTexParameterf(mpTexture->target, GL_TEXTURE_MIN_FILTER, mpTexture->minFilter);
			
			switch( mpTexture->target )
			{
				case GL_TEXTURE_1D:
					[self newTexture1D:thePixels];
					break;
				case GL_TEXTURE_RECTANGLE_EXT:
				case GL_TEXTURE_2D:
					[self newTexture2D:thePixels];
					break;
				case GL_TEXTURE_3D:
					[self newTexture3D:thePixels];
					break;
			} // switch
		}
		glDisable(mpTexture->target);
	} // if
} // newTexture

//---------------------------------------------------------------------------

- (void) newTextureWithDictionary:(NSDictionary *)theTextureDict
{
	GLvoid *pixels = NULL;
	
	[self newTextureAttributesWithDictionary:theTextureDict];
	
	pixels = [self texturePixels:mpTexture->width
						  height:mpTexture->height
						   depth:mpTexture->depth];
	
	[self newTexture:pixels];
	
	if( pixels != NULL )
	{
		free( pixels );
		
		pixels = NULL;
	} // if
} // newTextureWithDictionary

//---------------------------------------------------------------------------

- (void) newTextureWithDictionary:(NSDictionary *)theTextureDict
						   pixels:(const GLvoid *)thePixels
{
	[self newTextureAttributesWithDictionary:theTextureDict];
	
	if( thePixels != NULL )
	{
		[self newTexture:thePixels];
	} // if
} // newTextureWithDictionary

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Designated Initializers

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
// Initialize
//
//---------------------------------------------------------------------------

- (id) initTextureWithDictionary:(NSDictionary *)theTextureDict
{
	self = [super init];
	
	if( self )
	{
		mpTexture = (OpenGLTextureDataRef)calloc(1, sizeof(OpenGLTextureData));
		
		if( mpTexture != NULL )
		{
			[self newTextureWithDictionary:theTextureDict];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL Texture - Failure Allocating Memory For Attributes!" );
			NSLog( @">>                         From the designated initializer using dictionary." );
		}  // else
	} // if
	
	return  self;
} // initTextureWithDictionary

//---------------------------------------------------------------------------

- (id) initTextureWithDictionary:(NSDictionary *)theTextureDict
						  pixels:(const GLvoid *)thePixels
{
	self = [super init];
	
	if( self )
	{
		mpTexture = (OpenGLTextureDataRef)calloc(1, sizeof(OpenGLTextureData));
		
		if( mpTexture != NULL )
		{
			[self newTextureWithDictionary:theTextureDict
									pixels:thePixels];
		} // if
		else
		{
			NSLog( @">> ERROR: OpenGL Texture - Failure Allocating Memory For Attributes!" );
			NSLog( @">>                         From the designated initializer using dictionary and pixels." );
		}  // else
	} // if
	
	return  self;
} // initTextureWithDictionary

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Delete Texture

//---------------------------------------------------------------------------

- (void) dealloc
{
	if( mpTexture != NULL )
	{
		if( mpTexture->name )
		{
			glDeleteTextures( 1, &mpTexture->name );
		} // if
		
		free( mpTexture );
		
		mpTexture = NULL;
	} // if
	
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Accessors

//---------------------------------------------------------------------------

- (BOOL) isValid
{
	return( mpTexture->name != 0 );
} // isValid

//---------------------------------------------------------------------------

- (GLenum) target
{
	return( mpTexture->target );
} // name

//---------------------------------------------------------------------------

- (GLuint) name
{
	return( mpTexture->name );
} // name

//---------------------------------------------------------------------------

- (GLenum) active
{
	return( mpTexture->active );
} // active

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Binding Texture

//---------------------------------------------------------------------------

- (void) bind
{
	glActiveTexture( mpTexture->active );
	glBindTexture( mpTexture->target, mpTexture->name );
} // bind

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Data Source for Pixels

//---------------------------------------------------------------------------

- (GLvoid *) texturePixels:(const NSInteger)theTextureWidth
					height:(const NSInteger)theTextureHeight
					 depth:(const NSInteger)theTextureDepth
{
	return( NULL );
} // texturePixels

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
