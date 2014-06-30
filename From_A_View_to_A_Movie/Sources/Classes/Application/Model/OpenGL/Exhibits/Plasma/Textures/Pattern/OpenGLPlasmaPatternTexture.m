/*
     File: OpenGLPlasmaPatternTexture.m
 Abstract: 
 Utility toolkit for handling plasma shader's color pattern.
 
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

#import "OpenGLPlasmaPatternTexture.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

@implementation OpenGLPlasmaPatternTexture

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark OpenGL Plasma Shader Texture Initializations

//---------------------------------------------------------------------------
//
// Initialize
//
//---------------------------------------------------------------------------

- (id) initPlasmaShaderPatternWithWidth:(const NSInteger)thePatternWidth
								 height:(const NSInteger)thePatternHeight
{
	self = [super initPatternWithSize:thePatternWidth
							   height:thePatternHeight
						activeTexture:GL_TEXTURE0];
	
	if( self )
	{
		mnWidth  = thePatternWidth;
		mnHeight = thePatternHeight;
	} // if
	else
	{
		NSLog( @">> ERROR: OpenGL Plasma Texture Pattern - Failure Allocating Plasma pattern for the requested size!" );
	} // else
	
	return self;
} // initPlasmaShaderPatternWithWidth

//---------------------------------------------------------------------------

+ (id) plasmaShaderPatternWithWidth:(const NSInteger)thePatternWidth
							 height:(const NSInteger)thePatternHeight
{
	return  [[[OpenGLPlasmaPatternTexture allocWithZone:[self zone]] initPlasmaShaderPatternWithWidth:thePatternWidth
																							   height:thePatternHeight] autorelease];
} // plasmaShaderPatternWithWidth

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Delete Plasma Pattern

//---------------------------------------------------------------------------

- (void) dealloc
{
    [super dealloc];
} // dealloc

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Plasma Pattern Pixels

//---------------------------------------------------------------------------
//
// This is the data source for the plasma pattern.
//
//---------------------------------------------------------------------------

- (GLvoid *) texturePixels:(const NSInteger)theTextureWidth
					height:(const NSInteger)theTextureHeight
					 depth:(const NSInteger)theTextureDepth
{
	GLuint    rowBytes = 3 * sizeof(GLfloat) * theTextureWidth;
	GLfloat  *pattern  = (GLfloat *)calloc(theTextureHeight, rowBytes);
	
	if( pattern != NULL )
	{
		GLfloat   a = (GLfloat)theTextureWidth;
		GLfloat   b = 1.0f / ( 0.25f * a );
		GLfloat   c = 1.0f / ( 0.125f * a );
		GLfloat   f;
		GLfloat   x;
		GLfloat   y;
		GLint     i;
		GLint     iMax = theTextureWidth >> 1;
		GLint     j;
		GLint     jMax = theTextureHeight >> 1;
		GLint     k = theTextureWidth - 1;
		GLint     l;
		GLint     m;
		GLint     n;
		
		for( i = 0; i < iMax; i++ )
		{
			y = (GLfloat)i;
			
			for( j = 0; j < jMax; j++ )
			{
				x = (GLfloat)j;
				f = 0.25f*(sinf(b*x) + sinf(b*y) + sinf(b*(x+y)) + sinf(c*sqrtf(x*x+y*y)));
				
				l = i * theTextureWidth;
				m = k * theTextureWidth - l;
				n = k - j;
				
				pattern[l+j] = f;
				pattern[l+n] = f;
				pattern[m+j] = f;
				pattern[m+n] = f;
			} // for
		} // for
	} // if
	
	return (GLvoid *)pattern;
} // texturePixels

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
