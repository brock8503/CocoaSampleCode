/*
     File: OpenGLRenderer.h
 Abstract: The renderer class creates and draws the OpenGL shaders. This is where we set up instancing and draw the set of gears with one single instancing draw call.
  Version: 1.1
 
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

#import <OpenGL/OpenGL.h>
#import <OpenGL/gl3.h>
#import <OpenGL/glext.h>
#import <OpenGL/glu.h>
#import <GLKit/GLKMath.h>
#include <stdint.h>
#include <stdio.h>

typedef struct _QuadricStruct
{
	GLuint vertCount;
	GLuint indexCount;
	GLuint vertsID;
	GLuint normalsID;
	GLuint colorsID;
	GLuint indicesID;
} quadric;

const uint32_t kShaderCount = 2;
const uint32_t kProgramCount = 1;

@interface OpenGLRenderer : NSObject
{
	GLsizei width, height;
    
	GLint shaders[kShaderCount];
	GLint programs[kProgramCount];
    // attributes
	GLint attribPosition, attribColor, attribNormal, attribScale,
        attribOrientationMatrix0, attribOrientationMatrix1, attribOrientationMatrix2, attribOrientationMatrix3,
        lightPosLocation, lightColorLocation;
    // uniforms
    GLuint rotationAnimationMatrixLocation, cameraTransformLocation, projectionMatrixLocation;
    
    // buffer objects
	GLuint scaleBufferID,orientationMatID;
    GLuint gearVAOId;
    
	quadric* triToothedGearFlat;
    GLKMatrix4 cameraMatrix;
	GLKVector4 lightPos, lightColor;
	int numGears;
    
	float animationDelta;
	uint32_t kAnimationLoopValue, animationStep;
	BOOL animate;
	float xAxisAngle, zAxisAngle;
}

- (void)draw;
- (void)toggleAnimation;
- (BOOL)setupGL;
- (void)reshapeToWidth:(GLsizei)w height:(GLsizei)h;
- (void)applyCameraMovementWdx:(float)dx dy:(float)dy;

@end

