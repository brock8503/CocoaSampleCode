/*
     File: GLSLProgram.m
 Abstract: 
 Utility toolkit for creating a program object from fragment & vertex shaders.
 
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

#pragma mark -
#pragma mark Private - Headers

#import "GLShaderListConstants.h"
#import "GLSLProgram.h"

#pragma mark -
#pragma mark Private - Data Structure

struct GLShader
{
	const GLchar  *mpSource;
    GLuint         mnShader;
};

typedef struct GLShader   GLShader;

struct GLSLProgramData
{
    BOOL       mbIsProgram;
    BOOL       mbIsValidated;
    GLShader   m_Fragment;
    GLShader   m_Vertex;
	GLuint	   mnProgram;
    NSBundle  *mpAppBundle;
};

typedef struct GLSLProgramData   GLSLProgramData;

#pragma mark -
#pragma mark Private - Utilities - Destructor

static void GLSLProgramDelete(GLSLProgramDataRef pProgram)
{
    if(pProgram != NULL)
    {
        if(pProgram->m_Fragment.mnShader)
        {
            glDeleteShader(pProgram->m_Fragment.mnShader);
        } // if
        
        if(pProgram->m_Vertex.mnShader)
        {
            glDeleteShader(pProgram->m_Vertex.mnShader);
        } // if
        
        if(pProgram->mnProgram)
        {
            glDeleteProgram(pProgram->mnProgram);
        } // if
        
        free(pProgram);
        
        pProgram = NULL;
    } // if
} // GLSLProgramDelete

#pragma mark -
#pragma mark Private - Utilities - Compilation

static GLuint GLSLProgramCompileShader(const GLenum nType,
                                       const GLchar **hSource,
                                       GLint *pIsCompiled)
{
	GLuint nShader = 0;
	
	if(*hSource != NULL)
	{
		GLint nLength = 0;
		
		nShader = glCreateShader(nType);
		
		glShaderSource(nShader, 1, hSource, NULL);
		glCompileShader(nShader);
		
		glGetShaderiv(nShader, GL_INFO_LOG_LENGTH, &nLength);
		
		if(nLength > 0)
		{
			GLchar *pLog = (GLchar *)malloc(nLength);
			
			if(pLog != NULL)
			{
				glGetShaderInfoLog(nShader, nLength, &nLength, pLog);
				
				NSLog(@">> [OpenGL Shader Kit] Shader compile log:\n%s\n", pLog);
				
				free(pLog);
			} // if
		} // if
        
		glGetShaderiv(nShader, GL_COMPILE_STATUS, pIsCompiled);
		
		if(*pIsCompiled == 0)
		{
			NSLog(@">> [OpenGL Shader Kit] WARNING: Failed to compile shader!\n%s\n", *hSource);
		} // if
	} // if
	else
	{
		*pIsCompiled = 0;
	} // else
	
	return nShader;
} // GLSLProgramCompileShader

#pragma mark -
#pragma mark Private - Utilities - Linking

static BOOL GLSLProgramLink(const GLuint nProgram)
{
	GLint  nLength  = 0;
	GLint  nLinked  = 0;
	BOOL   bSuccess = NO;
	
	glLinkProgram(nProgram);
	
	glGetProgramiv(nProgram , GL_INFO_LOG_LENGTH, &nLength);
	
	if(nLength)
	{
		GLchar *infoLog = (GLchar *)malloc(nLength);
		
		if(infoLog != NULL)
		{
			glGetProgramInfoLog(nProgram, nLength, &nLength, infoLog);
			
			NSLog(@">> [OpenGL Shader Kit] Program link log:\n%s\n", infoLog);
			
			free(infoLog);
		} // if
	} // if
	
	glGetProgramiv(nProgram, GL_LINK_STATUS, &nLinked);
	
    bSuccess = nLinked != 0;
    
	if(!bSuccess)
	{
		NSLog(@">> [OpenGL Shader Kit] WARNING: Failed to link program 0x%x\n", nProgram);
	} // if
	
	return  bSuccess;
} // GLSLProgramLink

static BOOL GLSLProgramAcquireShader(const GLenum nType,
                                     GLSLProgramDataRef pProgram)
{
	GLuint  nShader   = 0;
	GLint   nCompiled = GL_FALSE;
    
	switch(nType)
	{
		case GL_VERTEX_SHADER:
			
			pProgram->m_Vertex.mnShader = GLSLProgramCompileShader(nType,
                                                                   &pProgram->m_Vertex.mpSource,
                                                                   &nCompiled);
			break;
			
		case GL_FRAGMENT_SHADER:
			
			pProgram->m_Fragment.mnShader = GLSLProgramCompileShader(nType,
                                                                     &pProgram->m_Fragment.mpSource,
                                                                     &nCompiled);
			break;
            
		default:
			break;
	} // switch
    
	if(!nCompiled)
	{
        glDeleteShader(nShader);
	} // if
	
	return (bool)nCompiled;
} // GLSLProgramAcquireShader

#pragma mark -
#pragma mark Private - Utilities - Program Object

static BOOL GLSLProgramCreate(GLSLProgramDataRef pProgram)
{
	BOOL bSuccess = pProgram->m_Fragment.mnShader && pProgram->m_Vertex.mnShader;
	
	// Create a program object and link shaders
	
	if(bSuccess)
	{
		pProgram->mnProgram = glCreateProgram();
		
		if(pProgram->mnProgram)
		{
            glAttachShader(pProgram->mnProgram, pProgram->m_Vertex.mnShader);
            glAttachShader(pProgram->mnProgram, pProgram->m_Fragment.mnShader);
			
            bSuccess = GLSLProgramLink(pProgram->mnProgram);
            
            pProgram->mbIsProgram = glIsProgram(pProgram->mnProgram);
            
            if(!bSuccess)
            {
                glDeleteProgram(pProgram->mnProgram);
            } // if
		} // if
	} // if
	
	return bSuccess;
} // GLSLProgramCreate

static BOOL GLSLProgramAcquire(GLSLProgramDataRef pProgram)
{
	// Load and compile both shaders
	
	GLSLProgramAcquireShader(GL_VERTEX_SHADER, pProgram);
	GLSLProgramAcquireShader(GL_FRAGMENT_SHADER, pProgram);
	
	// Create a program object and link both shaders
    
	return  GLSLProgramCreate(pProgram);
} // GLSLProgramAcquire

static BOOL GLSLProgramValidate(GLSLProgramDataRef pProgram)
{
	GLint  nLength      = 0;
	GLint  nIsValidated = 0;
    
	glValidateProgram(pProgram->mnProgram);
    
	glGetProgramiv(pProgram->mnProgram,
                   GL_INFO_LOG_LENGTH,
                   &nLength);
	
	if(nLength)
	{
		GLchar *pLog = (GLchar *)malloc(nLength);
		
		if(pLog != NULL)
		{
			glGetProgramInfoLog(pProgram->mnProgram,
                                nLength,
                                &nLength,
                                pLog);
			
			NSLog(@">> INFO: OpenGL Shader Kit - Program validate log:\n%s\n", pLog);
			
			free(pLog);
		} // if
	} // if
	
	glGetProgramiv(pProgram->mnProgram,
                   GL_VALIDATE_STATUS,
                   &nIsValidated);
	
	if(nIsValidated == 0)
	{
		NSLog(@">> WARNING: OpenGL Shader Kit - Failed to validate program!");
	} // if
	
    pProgram->mbIsValidated = nIsValidated != 0;
    
	return  pProgram->mbIsValidated;
} // GLSLProgramValidate

static BOOL GLSLProgramBuild(NSString *pShadersName,
                             GLSLProgramDataRef pProgram)

{
    BOOL bSuccess = GLSLProgramAcquire(pProgram);
	
	if(!bSuccess)
	{
        if(pShadersName)
        {
            NSLog(@">> [OpenGL Shader Kit] WARNING: Failed to compile+link GLSL \"%@\" fragment and/or vertex shader(s)!", pShadersName);
        } // if
        else
        {
            NSLog(@">> [OpenGL Shader Kit] WARNING: Failed to compile+link GLSL fragment and/or vertex shader(s)!");
        } // else
	} // if
	else
    {
        GLSLProgramValidate(pProgram);
    } // else
    
	return bSuccess;
} // GLSLProgramBuild

static GLchar *GLSLProgramGetShaderSource(NSString *pName,
                                          NSString *pExtension,
                                          GLSLProgramDataRef pProgram)

{
    GLchar *pSource = NULL;
    
    if(pName && pExtension)
    {
        NSString  *pPathname = [pProgram->mpAppBundle pathForResource:pName
                                                               ofType:pExtension];
        
        if(pPathname)
        {
            NSError *pError = nil;
            
            NSString  *pResource = [NSString stringWithContentsOfFile:pPathname
                                                             encoding:NSASCIIStringEncoding
                                                                error:&pError];
            
            if(!pError)
            {
                pSource = (GLchar *)[pResource cStringUsingEncoding:NSASCIIStringEncoding];
            } // if
            else
            {
                NSLog(@">> [OpenGL Shader Kit] ERROR: {%@}" , [pError localizedDescription]);
                
                [pError release];
            } // else
        } // if
    } // if
	
	return  pSource;
} // GLSLProgramGetShaderSource

static GLSLProgramDataRef GLSLProgramCreateFromResource(NSString *pName)
{
	GLSLProgramDataRef pProgram = NULL;
    
    if(pName)
    {
        pProgram = (GLSLProgramDataRef)calloc(1, sizeof(GLSLProgramData));
        
        if(pProgram != NULL)
        {
            pProgram->mpAppBundle = [NSBundle mainBundle];
            
            if(pProgram->mpAppBundle)
            {
                pProgram->m_Fragment.mpSource = GLSLProgramGetShaderSource(pName, @"fs", pProgram);
                pProgram->m_Vertex.mpSource   = GLSLProgramGetShaderSource(pName, @"vs", pProgram);
                
                GLSLProgramBuild(pName, pProgram);
            } // if
        } // if
        else
        {
			NSLog(@">> [OpenGL Shader Kit] ERROR: Failure Allocating a backing store for the object!");
        } // else
    } // if
    else
    {
        NSLog(@">> [OpenGL Shader Kit] ERROR: Pathname for the resources is NULL!");
    } // else
    
    return  pProgram;
} // GLSLProgramCreateFromResource

static GLSLProgramDataRef GLSLProgramCreateFromSources(NSString * const pFragment,
                                                       NSString * const pVertex)
{
	GLSLProgramDataRef pProgram = NULL;
    
    if(pVertex && pFragment)
    {
        pProgram = (GLSLProgramDataRef)calloc(1, sizeof(GLSLProgramData));
        
        if(pProgram != NULL)
        {
            pProgram->m_Fragment.mpSource = (const GLchar *)[pFragment cStringUsingEncoding:NSASCIIStringEncoding];
            pProgram->m_Vertex.mpSource   = (const GLchar *)[pVertex   cStringUsingEncoding:NSASCIIStringEncoding];
            
            GLSLProgramBuild(nil, pProgram);
        } // if
        else
        {
			NSLog(@">> [OpenGL Shader Kit] ERROR: Failure Allocating a backing store for the object!");
        } // else
    } // if
    else
    {
        NSLog(@">> [OpenGL Shader Kit] ERROR: Shader sources are NULL!");
    } // else
    
    return  pProgram;
} // GLSLProgramCreateFromSources

static GLSLProgramDataRef GLSLProgramCreateFromDictionary(NSDictionary * const pDictionary)
{
	GLSLProgramDataRef pProgram = NULL;
    
    if(pDictionary)
    {
        pProgram = GLSLProgramCreateFromSources([pDictionary objectForKey:kGLShaderKeyFrag],
                                                [pDictionary objectForKey:kGLShaderKeyVert]);
    } // if
    else
    {
        NSLog(@">> [OpenGL Shader Kit] ERROR: Shader dictionary is NULL!");
    } // else
    
    return  pProgram;
} // GLSLProgramCreateFromDictionary

#pragma mark -
#pragma mark Private - Utilities - Uniforms

static inline GLint GLSLProgramGetUniformLocation(NSString *pName,
                                                  GLSLProgramDataRef pProgram)
{
    GLint nLocation = -1;
    
    if(pName)
    {
        const GLchar *pUniform = (GLchar *)[pName cStringUsingEncoding:NSASCIIStringEncoding];
        
        if(pUniform != NULL)
        {
            nLocation = glGetUniformLocation(pProgram->mnProgram, pUniform);
            
            if(nLocation == -1)
            {
                NSLog(@">> [OpenGL Shader Kit] WARNING: No such uniform named \"%s\"!", pUniform);
            } // if
        } // if
    } // if
    
	return nLocation;
} // GLSLProgramGetUniformLocation

@implementation GLSLProgram

#pragma mark -
#pragma mark Public - Designated initializer

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // init

- (id) initWithDictionary:(NSDictionary *)theDictionary
{
	self = [super init];
	
	if (self)
	{
        mpProgram = GLSLProgramCreateFromDictionary(theDictionary);
	} // if
	
	return self;
} // initWithVertex

- (id) initWithShadersInAppBundle:(NSString *)theName
{
	self = [super init];
	
	if (self)
	{
        mpProgram = GLSLProgramCreateFromResource(theName);
	} // if
	
	return self;
} // initWithShadersInAppBundle

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
	// Delete GLSL resources
    GLSLProgramDelete(mpProgram);
	
	// Dealloc the superclass
	[super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Utilties

- (void) enable
{
	glUseProgram(mpProgram->mnProgram);
} // enable

- (void) disable
{
	glUseProgram(0);
} // disable

- (GLint) location:(NSString *)theName
{
	return GLSLProgramGetUniformLocation(theName, mpProgram);
} // location

#pragma mark -
#pragma mark Public - Accessors

- (BOOL) isValidated
{
    return mpProgram->mbIsValidated;
} // isValidated

- (BOOL) isProgram
{
    return mpProgram->mbIsProgram;
} // isProgram

- (GLuint) program
{
    return mpProgram->mnProgram;
} // program

@end
