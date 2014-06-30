/*
     File: GLSLUnit.h
 Abstract: 
 A utility toolkit for managing shaders along with their uniforms.
 
  Version: 2.0
 
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

// Required Includes

#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

#import "GLSLProgram.h"

typedef struct GLSLUnitData *GLSLUnitDataRef;

// The OpenGL Shader Unit
@interface GLSLUnit : GLSLProgram
{
@private
    GLSLUnitDataRef mpShaderUnit;
} // GLSLProgram

// Designated initializers
- (id) initWithDictionary:(NSDictionary *)theDicitionary;

- (id) initWithShadersInAppBundle:(NSString *)theName;

// Setting samplers
- (void) sampler:(const NSString *)theSampler
           value:(const GLuint)theValue;

- (void) samplers:(NSDictionary *)theSamplers;

// Setting individual uniforms
- (void) uniform1i:(const GLint)theLocation
             value:(const GLint)theValue;

- (void) uniform2i:(const GLint)theLocation
			values:(const GLint *)theValues;

- (void) uniform3i:(const GLint)theLocation
			values:(const GLint *)theValues;

- (void) uniform4i:(const GLint)theLocation
			values:(const GLint *)theValues;

- (void) uniform1f:(const GLint)theLocation
             value:(const GLfloat)theValue;

- (void) uniform2f:(const GLint)theLocation
			values:(const GLfloat *)theValues;

- (void) uniform3f:(const GLint)theLocation
			values:(const GLfloat *)theValues;

- (void) uniform4f:(const GLint)theLocation
			values:(const GLfloat *)theValues;

- (void) uniform1iv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLint *)theValues;

- (void) uniform2iv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLint *)theValues;

- (void) uniform3iv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLint *)theValues;

- (void) uniform4iv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLint *)theValues;

- (void) uniform1fv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLfloat *)theValues;

- (void) uniform2fv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLfloat *)theValues;

- (void) uniform3fv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLfloat *)theValues;

- (void) uniform4fv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLfloat *)theValues;

- (void) uniform2x2fv:(const GLint)theLocation
                count:(const GLsizei)theCount
             tanspose:(const GLboolean)theFlag
               values:(const GLfloat *)theValues;

- (void) uniform3x3fv:(const GLint)theLocation
                count:(const GLsizei)theCount
             tanspose:(const GLboolean)theFlag
               values:(const GLfloat *)theValues;

- (void) uniform4x4fv:(const GLint)theLocation
                count:(const GLsizei)theCount
             tanspose:(const GLboolean)theFlag
               values:(const GLfloat *)theValues;

// Setting a group of uniforms stored in an array of dictionaries
- (void) uniforms:(NSDictionary *)theUniforms;

@end
