/*
     File: OpenGLPlasmaPaletteTexture.m
 Abstract: 
 Utility toolkit for handling plasma shader's color palette.
 
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

#import "OpenGLPlasmaPaletteTexture.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

static const GLfloat kPi = 3.1415927f; // IEEE-754 single precision

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLPlasmaPaletteTexture

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark OpenGL Plasma Shader Texture Initializations

//---------------------------------------------------------------------------
//
// Initialize
//
//---------------------------------------------------------------------------

- (id) initPlasmaShaderPaletteWithSize:(const GLuint)thePlasmaPaletteSize
{
	self = [super initPaletteWithSize:thePlasmaPaletteSize
						activeTexture:GL_TEXTURE1];
	
	if( self )
	{
		mnSize = thePlasmaPaletteSize;
	} // if
	else
	{
		NSLog( @">> ERROR: OpenGL Plasma Texture Palette - Failure Allocating Plasma palette for the requested size!" );
	} // else
	
	return( self );
} // initPlasmaShaderPaletteWithSize

//---------------------------------------------------------------------------

+ (id) plasmaShaderPaletteWithSize:(const GLuint)thePlasmaPaletteSize
{
	return  [[[OpenGLPlasmaPaletteTexture allocWithZone:[self zone]] initPlasmaShaderPaletteWithSize:thePlasmaPaletteSize] autorelease];
} // plasmaShaderPaletteWithSize

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Delete Plasma Palette

//---------------------------------------------------------------------------

- (void) dealloc
{
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Plasma Palette Pixels

//---------------------------------------------------------------------------
//
// This is the data source for the plasma palette.
//
//---------------------------------------------------------------------------

- (GLvoid *) texturePixels:(const NSInteger)theTextureWidth
					height:(const NSInteger)theTextureHeight
					 depth:(const NSInteger)theTextureDepth
{
	GLuint    rowbytes = 3 * sizeof(GLfloat) * theTextureWidth;
	GLfloat  *palette  = (GLfloat *)calloc(1, rowbytes);
	
	if ( palette != NULL )
	{
		GLfloat   a = (GLfloat)theTextureWidth;
		GLfloat   b = 0.5f * a;
		GLfloat   c = 1.5f * a;
		GLfloat   d = 2.0f / a;
		GLfloat   x[2];
		GLfloat   n;
		GLint     i;
		GLint     j;
		
		a = 1.0f / a;
		c = 1.0f / c;
		
		for( i = 0; i < theTextureWidth; i++ )
		{
			n = (GLfloat)i;
			
			x[0] = n * kPi;
			x[1] = sinf( a * x[0] );
			
			j = 3 * i;
			
			palette[j]   = 1.0f - x[1];
			palette[j+1] = b * c * ( 1.0f + sinf( d * x[0] ) );
			palette[j+2] = x[1];
		} // for
	} // if
	
	return (GLvoid *)palette;
} // texturePixels

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
