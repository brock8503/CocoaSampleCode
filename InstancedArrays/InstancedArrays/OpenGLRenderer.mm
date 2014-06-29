/*
     File: OpenGLRenderer.mm
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

#import "OpenGLRenderer.h"
#import "TriToothedGearFlatModel.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>

#define glError() { \
GLenum err = glGetError(); \
while (err != GL_NO_ERROR) { \
__builtin_printf("glError: %s caught at %s:%u\n", (char *)gluErrorString(err), __FILE__, __LINE__); \
err = glGetError(); \
exit(-1); \
} \
}

#define VS_NAME "vertexShaderFlat.vs"
#define FS_NAME "fragmentShaderFlat.fs"

GLboolean loadShader(GLenum shaderType, const GLchar** shaderText, GLint* shaderID);
GLboolean linkShaders(GLint* program, GLint vertShaderID, GLint fragShaderID);

@implementation OpenGLRenderer

- (void)loadTriangleToothedGearFlat
{
    triToothedGearFlat = (quadric*) malloc(sizeof(quadric));
    triToothedGearFlat->vertCount = VERTEX_COUNT;
    triToothedGearFlat->indexCount = INDEX_COUNT;
    
	glGenBuffers(4, &triToothedGearFlat->vertsID);
    
    glBindBuffer(GL_ARRAY_BUFFER, triToothedGearFlat->vertsID);
	glBufferData(GL_ARRAY_BUFFER, triToothedGearFlat->vertCount*3*sizeof(GLfloat), vertices, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, triToothedGearFlat->colorsID);
	glBufferData(GL_ARRAY_BUFFER, triToothedGearFlat->vertCount*3*sizeof(GLfloat), colors, GL_STATIC_DRAW);
	glBindBuffer(GL_ARRAY_BUFFER, triToothedGearFlat->normalsID);
	glBufferData(GL_ARRAY_BUFFER, triToothedGearFlat->vertCount*3*sizeof(GLfloat), normals, GL_STATIC_DRAW);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, triToothedGearFlat->indicesID);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, triToothedGearFlat->indexCount*sizeof(GLuint), indices, GL_STATIC_DRAW);
}

- (id)init
{
    if (self = [super init])
    {
        [self loadTriangleToothedGearFlat];
    
        animationDelta = 1.5;
        animationStep = 0.0;
        kAnimationLoopValue = 360.0 / animationDelta;
        animate = YES;
        xAxisAngle = 0.0;
        zAxisAngle = 0.0;
    }
    return self;
}

- (void)dealloc
{
	glFinish();
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glDeleteBuffers(4, &triToothedGearFlat->vertsID);
	free(triToothedGearFlat);
	glDeleteBuffers(1, &scaleBufferID);
    glDeleteBuffers(1, &orientationMatID);
	glUseProgram(0);
	int i = 0;
	for (; i < kProgramCount; i++) {
		glDeleteProgram(programs[i]);
	}
	for (; i < kShaderCount; i++) {
		glDeleteShader(shaders[i]);
	}
    [super dealloc];
}

#pragma mark General Setup

- (BOOL)setupScene
{
    int nRows = 8;
    int nCols = 9;
    numGears = nRows * nCols;
    
    // create scaling factor and orientation per gear
	GLfloat* scaleBuffer = (GLfloat*) malloc(sizeof(GLfloat)*numGears);
    
    GLKMatrix4* orientationMat = (GLKMatrix4*) malloc(sizeof(GLKMatrix4)*numGears);
	GLKMatrix4 temp;
	float initialx = -2.0;
	float initialy = -2.0;
	
    int ndx = 0;
	for (int j = 0; j < nRows; j++) {
		for (int i = 0; i < nCols; i++)
		{
            // scaling per gear
            scaleBuffer[ndx] = 1.0/10.0 * ((j%2) ? 1.0 : 0.8);
            
            // orientation per gear
            temp = GLKMatrix4MakeTranslation(initialx+i*0.5, initialy+j*0.5, 3.0);
            if (i%2)
                temp = GLKMatrix4Rotate(temp, M_PI, 1.0, 0.0, 0.0);
            orientationMat[ndx] = temp;
            
            ndx ++;
		}
	}
    
    glGenBuffers(1, &scaleBufferID);
    glGenBuffers(1, &orientationMatID);
    
    // buffer all the scaling data into one VBO
    glBindBuffer(GL_ARRAY_BUFFER, scaleBufferID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(GLfloat)*numGears, scaleBuffer, GL_STATIC_DRAW);
	glError();
	
    // buffer all the orientation matrices into one VBO
	glBindBuffer(GL_ARRAY_BUFFER, orientationMatID);
	glBufferData(GL_ARRAY_BUFFER, sizeof(GLKMatrix4)*numGears, orientationMat, GL_STATIC_DRAW);
	glError();
	
    free(scaleBuffer);
	free(orientationMat);
	
	lightPos.x = 0.0; lightPos.y = 5.0; lightPos.z = 0.0; lightPos.w = 1.0;
	lightColor.x = 0.15; lightColor.y = 0.15; lightColor.z = 0.15; lightColor.w = 1.0;
	
	return YES;
}

- (BOOL)setupGL
{
    // create a VAO (vertex array object)
	glGenVertexArrays(1, &gearVAOId);
	glBindVertexArray(gearVAOId);
    
	if([self loadShaders])
	{
		return NO;
	}
	
	if(![self setupScene])
	{
		return NO;
	}
	
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_CULL_FACE);
	glViewport(0, 0, width, height);
    
    // set up the projection matrix uniform
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(75.0 * (M_PI/180.0), ((GLdouble) width) / ((GLdouble) height), 0.1, 35.0);
    glUseProgram(programs[0]);
	glUniformMatrix4fv(projectionMatrixLocation, 1, GL_FALSE, (const GLfloat*) &projectionMatrix);
    
	// the gear's normals are with the first vertex
	glProvokingVertexEXT(GL_FIRST_VERTEX_CONVENTION_EXT);
	
    // set up vertex attributes
	// one scale and one matrix *per instance*
	glBindBuffer(GL_ARRAY_BUFFER, scaleBufferID);
	glVertexAttribPointer(attribScale, 1, GL_FLOAT, GL_FALSE, 0, NULL);
    // glVertexAttribDivisor modifies the rate at which generic vertex attributes advance during instanced rendering
    // here we specify that we want to advance the attribute once per instance
	glVertexAttribDivisorARB(attribScale, 1);
	
    // all matrix data is in one VBO. Set appropriate offsets
	glBindBuffer(GL_ARRAY_BUFFER, orientationMatID);
	glVertexAttribPointer(attribOrientationMatrix0, 4, GL_FLOAT, GL_FALSE, sizeof(GLKMatrix4), NULL);
	glVertexAttribDivisorARB(attribOrientationMatrix0, 1);
	
	glVertexAttribPointer(attribOrientationMatrix1, 4, GL_FLOAT, GL_FALSE, sizeof(GLKMatrix4), (const GLvoid*) (sizeof(GLKVector4)));
	glVertexAttribDivisorARB(attribOrientationMatrix1, 1);
	
	glVertexAttribPointer(attribOrientationMatrix2, 4, GL_FLOAT, GL_FALSE, sizeof(GLKMatrix4), (const GLvoid*) (2*sizeof(GLKVector4)));
	glVertexAttribDivisorARB(attribOrientationMatrix2, 1);
	
	glVertexAttribPointer(attribOrientationMatrix3, 4, GL_FLOAT, GL_FALSE, sizeof(GLKMatrix4), (const GLvoid*) (3*sizeof(GLKVector4)));
	glVertexAttribDivisorARB(attribOrientationMatrix3, 1);
	
	// position, color and normal *per vertex*
	glBindBuffer(GL_ARRAY_BUFFER, triToothedGearFlat->vertsID);
    glVertexAttribPointer(attribPosition, 3, GL_FLOAT, GL_FALSE, 0, NULL);
	glBindBuffer(GL_ARRAY_BUFFER, triToothedGearFlat->colorsID);
    glVertexAttribPointer(attribColor, 3, GL_FLOAT, GL_FALSE, 0, NULL);
	glBindBuffer(GL_ARRAY_BUFFER, triToothedGearFlat->normalsID);
	glVertexAttribPointer(attribNormal, 3, GL_FLOAT, GL_FALSE, 0, NULL);
    
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, triToothedGearFlat->indicesID);
	
	[self regenCameraMatrix];
	
	return YES;
}

- (void)reshapeToWidth:(GLsizei)w height:(GLsizei)h
{
	width = w;
	height = h;
	glViewport(0, 0, width, height);
}

#pragma mark Rendering

- (void)draw
{
	if(animate)
	{
		animationStep = (animationStep+1) % kAnimationLoopValue;
	}
    
	GLKMatrix4 rotMatrix = GLKMatrix4MakeRotation(animationStep*animationDelta, 0.0, 0.0, 1.0);
	GLKVector4 lightPosition = GLKMatrix4MultiplyVector4(cameraMatrix, lightPos);
	
	glClearColor(1.0, 1.0, 1.0, 1.0);
	glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
	
    glBindVertexArray(gearVAOId);
    
	// enable all our attribs
    glEnableVertexAttribArray(attribPosition);
    glEnableVertexAttribArray(attribColor);
	glEnableVertexAttribArray(attribNormal);
	glEnableVertexAttribArray(attribScale);
    // matrices are 4 sequential attribs, each is a column
	glEnableVertexAttribArray(attribOrientationMatrix0);
	glEnableVertexAttribArray(attribOrientationMatrix1);
	glEnableVertexAttribArray(attribOrientationMatrix2);
	glEnableVertexAttribArray(attribOrientationMatrix3);
    
    // update uniform vals
	glUseProgram(programs[0]);
	glUniformMatrix4fv(cameraTransformLocation, 1, GL_FALSE, (const GLfloat*) &cameraMatrix);
	glUniformMatrix4fv(rotationAnimationMatrixLocation, 1, GL_FALSE, (const GLfloat*) &rotMatrix);
	glUniform3fv(lightPosLocation, 1, (const GLfloat*) &lightPosition);
	glUniform3fv(lightColorLocation, 1, (const GLfloat*) &lightColor);
	
    // call glDrawElementsInstanced to render multiple instances of primitives in a single draw call
	glDrawElementsInstancedARB(GL_TRIANGLES, triToothedGearFlat->indexCount, GL_UNSIGNED_INT, NULL, numGears);
	
	glUseProgram(0);
    glBindVertexArray(0);
}

- (void)toggleAnimation
{
    animate = !animate;
}

#pragma mark Camera Utility

- (void)regenCameraMatrix
{
	// set up a default camera matrix
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, -6.0);
    modelView = GLKMatrix4Rotate(modelView, xAxisAngle, 1, 0, 0);
    cameraMatrix = GLKMatrix4Rotate(modelView, zAxisAngle, 0, 0, 1);
}

- (void)applyCameraMovementWdx:(float)dx dy:(float)dy
{
	xAxisAngle += dy/3 * (M_PI/180.0);
	zAxisAngle += dx/3 * (M_PI/180.0);
	[self regenCameraMatrix];
}

#pragma mark Shader Loading

- (GLchar*)loadShaderFromFile:(const char*)shaderName
{
    const char* resourcePath = [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding:NSASCIIStringEncoding];
	char pathToShader[255];
	sprintf(&pathToShader[0], "%s/%s", resourcePath, shaderName);
    
	FILE* f = fopen(pathToShader, "rb");
	if(!f)
	{
		return NULL;
	}
	fseek(f, 0, SEEK_END);
	size_t shaderLen = ftell(f);
	fseek(f, 0, SEEK_SET);
	GLchar* code = (GLchar*) malloc(shaderLen+1);
	fread(code, sizeof(char), shaderLen, f);
	fclose(f);
	code[shaderLen] = '\0';
	return code;
}

- (GLshort)loadShaders
{
	GLchar* shader = [self loadShaderFromFile:VS_NAME];
	if (!shader) {
		return 1;
	}
	
	if(!loadShader(GL_VERTEX_SHADER, (const GLchar**) &shader, &shaders[0]))
		return 1;
	free(shader);
	
	shader = [self loadShaderFromFile:FS_NAME];
	if(!loadShader(GL_FRAGMENT_SHADER, (const GLchar**) &shader, &shaders[1]))
		return 2;
	free(shader);
	
	if(!linkShaders(&programs[0], shaders[0], shaders[1]))
	{
		return 3;
	}
	
    attribPosition = glGetAttribLocation(programs[0], "attribPosition");
    attribColor = glGetAttribLocation(programs[0], "attribColor");
	attribNormal = glGetAttribLocation(programs[0], "attribNormal");
	attribScale = glGetAttribLocation(programs[0], "attribScale");
	attribOrientationMatrix0 = glGetAttribLocation(programs[0], "attribOrientationMatrix");
	attribOrientationMatrix1 = attribOrientationMatrix0+1;
	attribOrientationMatrix2 = attribOrientationMatrix1+1;
	attribOrientationMatrix3 = attribOrientationMatrix2+1;
	rotationAnimationMatrixLocation = glGetUniformLocation(programs[0], "rotationAnimationMatrix");
	cameraTransformLocation = glGetUniformLocation(programs[0], "cameraMatrix");
    projectionMatrixLocation = glGetUniformLocation(programs[0], "projectionMatrix");
	lightPosLocation = glGetUniformLocation(programs[0], "lightPos");
	lightColorLocation = glGetUniformLocation(programs[0], "lightColor");
	
	glError();
    
	return 0;
}

GLboolean loadShader(GLenum shaderType, const GLchar** shaderText, GLint* shaderID)
{
	GLint status = 0;
	
	*shaderID = glCreateShader(shaderType);
	glShaderSource(*shaderID, 1, shaderText, NULL);
	glCompileShader(*shaderID);
	glGetShaderiv(*shaderID, GL_COMPILE_STATUS, &status);
	if(status == GL_FALSE)
	{
		GLint logLength = 0;
		glGetShaderiv(*shaderID, GL_INFO_LOG_LENGTH, &logLength);
		GLcharARB *log = (GLcharARB*) malloc(logLength);
		glGetShaderInfoLog(*shaderID, logLength, &logLength, log);
		printf("Shader compile log\n %s", log);
		free(log);
		return GL_FALSE;
	}
	return GL_TRUE;
}

GLboolean linkShaders(GLint* program, GLint vertShaderID, GLint fragShaderID)
{
	GLint status = 0;
	*program = glCreateProgram();
	glAttachShader(*program, vertShaderID);
	glAttachShader(*program, fragShaderID);
	
	GLint logLength;
	
	glLinkProgram(*program);
	glGetProgramiv(*program, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar*) malloc(logLength);
		glGetProgramInfoLog(*program, logLength, &logLength, log);
		printf("Program link log:\n%s\n", log);
		free(log);
		glDeleteShader(vertShaderID);
		glDeleteShader(fragShaderID);
		return GL_FALSE;
	}
	glValidateProgram(*program);
	glGetProgramiv(*program, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar*)malloc(logLength);
		glGetProgramInfoLog(*program, logLength, &logLength, log);
		printf("Program validate log:\n%s\n", log);
		free(log);
        return GL_FALSE;
	}
	
	glGetProgramiv(*program, GL_VALIDATE_STATUS, &status);
	if (status == 0)
    {
		printf("Failed to validate program %d\n", *program);
        return GL_FALSE;
    }
	return GL_TRUE;
}


@end
