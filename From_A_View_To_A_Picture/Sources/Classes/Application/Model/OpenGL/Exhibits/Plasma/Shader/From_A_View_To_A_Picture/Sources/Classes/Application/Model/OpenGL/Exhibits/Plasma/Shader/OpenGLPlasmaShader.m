//---------------------------------------------------------------------------
//
//	File: OpenGLPlasmaShader.h
//
//  Abstract: Utility toolkit for GLSL plasma shader
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
//  Copyright (c) 2007-2008, 2012 Apple Inc., All rights reserved.
//
//---------------------------------------------------------------------------

//------------------------------------------------------------------------

#import "OpenGLShaderDictKeys.h"

#import "OpenGLPlasmaPaletteTexture.h"
#import "OpenGLPlasmaPatternTexture.h"

#import "OpenGLPlasmaShader.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

static const GLfloat kOffsetDelta = 0.00390625f; // offset delta = 1/256

static const GLint kUniform1f = 2;
static const GLint kUniform3fv = 3;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

@implementation OpenGLPlasmaShader

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Initializer

//------------------------------------------------------------------------

- (id) init
{
	// Initialize the assests
	
	// Describe the plasma textures
	
	OpenGLPlasmaPaletteTexture *palette = [OpenGLPlasmaPaletteTexture plasmaShaderPaletteWithSize:256];
	OpenGLPlasmaPatternTexture *pattern = [OpenGLPlasmaPatternTexture plasmaShaderPatternWithWidth:128
																							height:128];
	
	NSArray *textureObjects = [NSArray arrayWithObjects:
							   pattern,
							   palette,
							   nil];
	
	NSArray *textureKeys = [NSArray arrayWithObjects:
							@"pattern",
							@"palette",
							nil];
	
	NSDictionary *plasmaTextures = [NSDictionary dictionaryWithObjects:textureObjects
															   forKeys:textureKeys];
	
	// Describe the other plasma uniforms
	
	NSArray *uniformObjects = [NSArray arrayWithObjects:
							   [NSNumber numberWithInt:kUniform3fv],
							   [NSNumber numberWithInt:kUniform1f],
							   nil];
	
	NSArray *uniformKeys = [NSArray arrayWithObjects:
							@"LightPosition",
							@"offset",
							nil];
	
	NSDictionary *mpUniforms = [NSDictionary dictionaryWithObjects:uniformObjects
														   forKeys:uniformKeys];
	
	// Initialize plasma unit with the textures and uniforms
	
	self = [super initShaderWithSourcesInAppBundle:@"Plasma"
										  validate:NO
										  textures:plasmaTextures
										  uniforms:mpUniforms];
	
	if( self )
	{
		mnOffset = 0.0f;
	} // if
	
	return( self );
} // init

//------------------------------------------------------------------------

- (id) initWithTextures:(NSDictionary *)theTextures
			   uniforms:(NSDictionary *)theUniforms
{
	self = [super initShaderWithSourcesInAppBundle:@"Plasma"
										  validate:NO];
	
	if( self )
	{
		[self setTexturesDictionary:theTextures];
		[self setUniformsDictionary:theUniforms];
	} // if
	
	return self;
} // initWithTextures

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Deallocating Resources

//------------------------------------------------------------------------

- (void) dealloc
{
	//	Dealloc the superclass
	
	[super dealloc];
} // dealloc

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Utilities

//------------------------------------------------------------------------

- (void) updateOffset
{
	mnOffset += kOffsetDelta;
	
	if( mnOffset > 1.0f )
	{
		mnOffset = 0.0f;
	} // if
} // updateOffset

//------------------------------------------------------------------------

- (void) shaderExecuteWithFloatVector:(const GLfloat *)theVector
{
	[self setUniformWithFloats:@"offset"
                        scalar:mnOffset];
	
	[self setUniformWithFloatVectors3:@"LightPosition"
                              vectors:theVector
                                count:1];
	
	[self execute];
	
	[self updateOffset];
} // shaderExecuteWithFloatVector

//---------------------------------------------------------------------------

@end

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

