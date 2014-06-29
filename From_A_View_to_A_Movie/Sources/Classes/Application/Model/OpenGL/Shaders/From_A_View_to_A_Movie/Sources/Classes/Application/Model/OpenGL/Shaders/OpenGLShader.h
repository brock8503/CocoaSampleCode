/*
     File: OpenGLShader.h
 Abstract: 
 A utility toolkit for managing shaders along with their uniforms.
 
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

#import "OpenGLShaderBase.h"

//---------------------------------------------------------------------------
//
// OpenGL shader data opaque data reference
//
//---------------------------------------------------------------------------

typedef struct OpenGLShaderData *OpenGLShaderDataRef;

//---------------------------------------------------------------------------

@interface OpenGLShader : OpenGLShaderBase
{
@private
    OpenGLShaderDataRef mpShader;
} // OpenGLShader

//---------------------------------------------------------------------------
//
// Designated initializer
//
//---------------------------------------------------------------------------

- (id) initShaderWithSourcesInAppBundle:(NSString *)theShadersName
							   validate:(const BOOL)theShaderNeedsValidation;

- (id) initShaderWithSourcesInAppBundle:(NSString *)theShadersName
							   validate:(const BOOL)theShaderNeedsValidation
							   uniforms:(NSDictionary *)theUniformsDescription;

- (id) initShaderWithSourcesInAppBundle:(NSString *)theShadersName
							   validate:(const BOOL)theShaderNeedsValidation
							   textures:(NSDictionary *)theTexturesDescription
							   uniforms:(NSDictionary *)theUniformsDescription;

//---------------------------------------------------------------------------
//
// Accessors
//
//---------------------------------------------------------------------------

- (NSMutableDictionary *) textures;
- (NSMutableDictionary *) uniforms;

- (void) setTexturesDictionary:(NSDictionary *)theTextures;
- (void) setUniformsDictionary:(NSDictionary *)theUniforms;

//---------------------------------------------------------------------------
//
// Setting uniforms values in our stored dictionary of key-value pairs
//
//---------------------------------------------------------------------------

- (void) setUniformWithIntegers:(NSString *)theUniformName
						 scalar:(const GLint)theUniformScalar;

- (void) setUniformWithFloats:(NSString *)theUniformName
					   scalar:(const GLfloat)theUniformScalar;

- (void) setUniformWithFloatVectors3:(NSString *)theUniformName
							 vectors:(const GLfloat *)theUniformVectors
							   count:(const GLuint)theUniformCount;

- (void) setUniformWithFloatMatrices3x3:(NSString *)theUniformName
							   tanspose:(const GLboolean)theTransposeFlag
							   matrices:(const GLfloat *)theUniformMatrices
								  count:(const GLuint)theUniformCount;

//---------------------------------------------------------------------------
//
// A generic method to draw a 2D/3D object. Once subclassed, one must
// implement this method - so that a particular shader unit is bound to
// an actual 2D/3D object.
//
//---------------------------------------------------------------------------

- (BOOL) draw;

//---------------------------------------------------------------------------
//
// For setting the actual GLSL uniform values within a shader program object
//
//---------------------------------------------------------------------------

- (void) bindUniforms;

//---------------------------------------------------------------------------
//
// Shader Execution
//
//---------------------------------------------------------------------------

- (void) execute;

@end
