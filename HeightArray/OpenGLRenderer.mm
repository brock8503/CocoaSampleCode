/*
     File: OpenGLRenderer.mm
 Abstract: The renderer class creates and draws the OpenGL shaders. Here we provide an example of two-dimensional texture array. It visualizes a terrain by using terrain's Z-coordinate to index into a texture array and applies the correct image for that point's elevation.
  Version: 1.3
 
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
 
 Copyright (C) 2014 Apple Inc. All Rights Reserved.
 
 */

#import "OpenGLRenderer.h"
#include "GeoUtils.h"
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

#define VS_NAME "HeightArray.vs"
#define FS_NAME "HeightArray.fs"

#define TEXTURE0 "rock.jpg"
#define TEXTURE1 "grass.jpg"
#define TEXTURE2 "dirt.jpg"
#define TEXTURE3 "snow.jpg"

const uint32_t kHeightMapDefaultSize = 64;

typedef struct {
	uint32_t wide;
    uint32_t high;
    GLenum format;
    GLenum type;
    void* data;
} textureInfo_t;

GLboolean loadShader(GLenum shaderType, const GLchar** shaderText, GLint* shaderID);
GLboolean linkShaders(GLint* program, GLint vertShaderID, GLint fragShaderID);


@implementation OpenGLRenderer

#pragma mark General Setup

- (id)init
{
    if (self = [super init])
    {
        xAxisAngle = -45.0 * (M_PI/180.0);
        zAxisAngle = 43.0 * (M_PI/180.0);
        iHeightMapSize = kHeightMapDefaultSize;
    }
    return self;
}

- (void)dealloc
{
    glFinish();
    glBindVertexArray(0);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    
	glDeleteBuffers(iHeightMapSize, terrain);
	glDeleteVertexArrays(1, &vaoId);
    glDeleteTextures(1, &texId);
    
	glUseProgram(0);
	int i = 0;
	for (; i < kProgramCount; i++) {
		glDeleteProgram(programs[i]);
	}
	for (; i < kShaderCount; i++) {
		glDeleteShader(shaders[i]);
	}
	free(map);
	free(terrain);
    [super dealloc];
}

- (BOOL)setupScene
{
    glGenVertexArrays(1, &vaoId);
	glBindVertexArray(vaoId);
	
	//You can play around with the terrain generation here...
    map = GenHeightMap(iHeightMapSize, iHeightMapSize, 0xDEADBEEF);
    //map = GenHeightMap(iHeightMapSize, iHeightMapSize, 0xBEEFBEEF);
	
	terrain = (GLuint*) malloc(sizeof(GLuint)*iHeightMapSize);
	
	size_t bufsize = iHeightMapSize*12*sizeof(GLfloat);
	
	glGenBuffers(iHeightMapSize-1, terrain);
	//now let's load this heightmap into buffer objects
	int i, j;
	for (j = 0; j < iHeightMapSize-1; j++)
	{
		glBindBuffer(GL_ARRAY_BUFFER, terrain[j]);
		//allocate enough space in VRAM
		glBufferData(GL_ARRAY_BUFFER, bufsize, NULL, GL_STATIC_DRAW);
		//map the VBO into client memory and fill it
		float* buf = (float*) glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
		/*
         NOTE:
         The map buffer has 6 floats per vertex, position and normal
         This loads the terrain in, as vertical slices (think a cross section)
         We load from the current row and row+1 to fill out the tristrips
		 */
		for (i = 0; i < iHeightMapSize; i++)
		{
			int ndx = i*12;
			memcpy(&buf[ndx]  , &map[( j   *iHeightMapSize + i)*6]  , sizeof(GLfloat)*6);
			memcpy(&buf[ndx+6], &map[( (j+1) *iHeightMapSize + i)*6]  , sizeof(GLfloat)*6);
		}
		glUnmapBuffer(GL_ARRAY_BUFFER);
	}
	
	return YES;
}

- (BOOL)loadTextureArray
{
    textureInfo_t tex0, tex1, tex2, tex3;
    
	if(![self loadTexture:&tex0 fromFile:TEXTURE0])
	{
		return NO;
	}
	if(![self loadTexture:&tex1 fromFile:TEXTURE1])
	{
		return NO;
	}
	if(![self loadTexture:&tex2 fromFile:TEXTURE2])
	{
		return NO;
	}
	if(![self loadTexture:&tex3 fromFile:TEXTURE3])
	{
		return NO;
	}
	glError();
	
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glPixelStorei(GL_PACK_ALIGNMENT, 1);
    
	//send textures to GPU
	glGenTextures(1, &texId);
	glBindTexture(GL_TEXTURE_2D_ARRAY, texId);
    
	glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	glTexParameteri(GL_TEXTURE_2D_ARRAY, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
	glTexImage3D(GL_TEXTURE_2D_ARRAY, 0, GL_RGB8, tex0.wide, tex0.high, 4, 0, tex0.format, tex0.type, NULL);
    glGenerateMipmap(GL_TEXTURE_2D_ARRAY);
    
    // Note: these images must have the same size and format to be able to loaded into a texture array
	glTexSubImage3D(GL_TEXTURE_2D_ARRAY, 0, 0, 0, 0, tex0.wide, tex0.high, 1, tex0.format, tex0.type, tex0.data);
	glTexSubImage3D(GL_TEXTURE_2D_ARRAY, 0, 0, 0, 1, tex0.wide, tex0.high, 1, tex0.format, tex0.type, tex1.data);
	glTexSubImage3D(GL_TEXTURE_2D_ARRAY, 0, 0, 0, 2, tex0.wide, tex0.high, 1, tex0.format, tex0.type, tex2.data);
	glTexSubImage3D(GL_TEXTURE_2D_ARRAY, 0, 0, 0, 3, tex0.wide, tex0.high, 1, tex0.format, tex0.type, tex3.data);
	
	free(tex0.data);
	free(tex1.data);
	free(tex2.data);
	free(tex3.data);
    
    glError();
    
    return YES;
}

- (BOOL)setupGL
{
    if(![self setupScene])
	{
		return NO;
	}
    
	if([self loadShaders])
	{
		return NO;
	}
	
    if (![self loadTextureArray])
    {
        return NO;
    }
	
	glViewport(0, 0, width, height);
	glClearColor(0.3, 0.4, 0.5, 1.0);
	glEnable(GL_DEPTH_TEST);
	
    //set up a default camera matrix
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
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // compute an appropriate projection matrix
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(60.0 * (M_PI/180.0), ((GLdouble) width) / ((GLdouble) height), 1.0, 100.0);
    // and texture matrix
    GLKMatrix4 m = GLKMatrix4MakeTranslation(0.0, 0.0, -0.5);
    m = GLKMatrix4Scale(m, 1.0, 1.0, 4.0);
    m = GLKMatrix4Scale(m, 1.0/iHeightMapSize, 1.0/iHeightMapSize, 1.0/16.0);
    GLKMatrix4 textureMatrix = GLKMatrix4Translate(m, 0.0, 0.0, 8.0);
	
    // draw simple 3D terrain
	glUseProgram(programs[0]);
	glActiveTexture(GL_TEXTURE0);
	glBindTexture(GL_TEXTURE_2D_ARRAY, texId);
    
    glUniformMatrix4fv(projectionMatrixLocation, 1, GL_FALSE, (const GLfloat*) &projectionMatrix);
	glUniformMatrix4fv(cameraMatrixLocation, 1, GL_FALSE, (const GLfloat*) &cameraMatrix);
	glUniformMatrix4fv(textureMatrixLocation, 1, GL_FALSE, (const GLfloat*) &textureMatrix);
	glUniform1i(samplerLocation, 0);
	
	/*
     NOTE:
     For optimal performance, you probably want Frustum-culled patches or something similar, instead of always
     drawing strips of terrain as this sample does.
	 */
    glEnableVertexAttribArray(attribPosition);
    glEnableVertexAttribArray(attribTexCoord);
    glEnableVertexAttribArray(attribNormal);
    
	int j;
	for (j = 0; j < iHeightMapSize-1; j++)
	{
		glBindBuffer(GL_ARRAY_BUFFER, terrain[j]);
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        
        glVertexAttribPointer(attribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, NULL);
        // we use the vertex positions as 3D texture coordinates too to index into the 2D texture array
        glVertexAttribPointer(attribTexCoord, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, NULL);
        glVertexAttribPointer(attribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat)*6, (const GLvoid*) (sizeof(GLfloat)*3));
		
		glDrawArrays(GL_TRIANGLE_STRIP, 0, iHeightMapSize*2);
	}
    
	glUseProgram(0);
}

#pragma mark Camera Utility

- (void)regenCameraMatrix
{
	// set up a default camera matrix
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, -2.25);
    modelView = GLKMatrix4Rotate(modelView, xAxisAngle, 1, 0, 0);
    modelView = GLKMatrix4Rotate(modelView, zAxisAngle, 0, 0, 1);
    cameraMatrix = GLKMatrix4Scale(modelView, 2.0/iHeightMapSize, 2.0/iHeightMapSize, 4.0/iHeightMapSize);
}

- (void)applyCameraMovementWdx:(float)dx dy:(float)dy
{
	xAxisAngle += dy/3 * (M_PI/180.0);
	zAxisAngle += dx/3 * (M_PI/180.0);
	[self regenCameraMatrix];
}

#pragma mark Texture Loading

- (BOOL)loadTexture:(textureInfo_t*)texture fromFile:(const char*) filename
{
    const char* resourcePath = [[[NSBundle mainBundle] resourcePath] cStringUsingEncoding:NSASCIIStringEncoding];
	CFStringRef string = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("%s/%s"), resourcePath, filename);
	CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, string, kCFURLPOSIXPathStyle, false);
	CGImageSourceRef imageSource = CGImageSourceCreateWithURL(url, nil);
	CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, nil);
	CFRelease(string);
	CFRelease(url);
	
	texture->wide = CGImageGetWidth(image);
	texture->high = CGImageGetHeight(image);
	GLint bpr = CGImageGetBytesPerRow(image);
	
	//if you want more info about the texture, look at these values
    //	CGBitmapInfo info = CGImageGetBitmapInfo(image);
    //	GLint bpp = CGImageGetBitsPerPixel(image);
	
	size_t numBytes = bpr * (texture->high);
	
	texture->format = GL_RGBA;
	texture->type = GL_UNSIGNED_BYTE;
	
	// get copy of raw uncompressed data
	CGDataProviderRef provider = CGImageGetDataProvider(image);
	CFDataRef dataref = CGDataProviderCopyData(provider);
	texture->data = malloc(numBytes);
	memcpy(texture->data, CFDataGetBytePtr(dataref), numBytes);
	CFRelease(dataref);
    
    CGImageRelease(image);
    CFRelease(imageSource);
    
	return YES;
}

#pragma mark Shader Loading

- (GLshort)loadShaders
{

    // vertex shader
    GLchar* shader = [self loadShaderFromFile:VS_NAME];
    if (!shader) {
        return 1;
    }
    if(!loadShader(GL_VERTEX_SHADER, (const GLchar**) &shader, &shaders[0])) {
        return 1;
    }
    free(shader);
        
    // fragment shader
    shader = [self loadShaderFromFile:FS_NAME];
    if (!shader) {
        return 2;
    }
    if(!loadShader(GL_FRAGMENT_SHADER, (const GLchar**) &shader, &shaders[1])) {
            return 2;
    }
    free(shader);
        
    if(!linkShaders(&programs[0], shaders[0], shaders[1]))
    {
        return 3;
    }
	
	cameraMatrixLocation = glGetUniformLocation(programs[0], "cameraMatrix");
	textureMatrixLocation = glGetUniformLocation(programs[0], "textureMatrix");
    projectionMatrixLocation = glGetUniformLocation(programs[0], "projectionMatrix");
	samplerLocation = glGetUniformLocation(programs[0], "sampler");
    attribPosition = glGetAttribLocation(programs[0], "attribPosition");
    attribTexCoord = glGetAttribLocation(programs[0], "attribTexCoord");
    attribNormal = glGetAttribLocation(programs[0], "attribNormal");
	
	glError();
	
	return 0;
}

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
