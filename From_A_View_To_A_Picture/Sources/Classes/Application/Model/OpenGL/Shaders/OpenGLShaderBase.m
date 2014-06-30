//------------------------------------------------------------------------------//
//	File: OpenGLShaderBase.m
//
//  Abstract: Utility toolkit for fragement and vertex shaders
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
//  Copyright (c) 2007-2009, 2012 Apple Inc., All rights reserved.
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#import "OpenGLShaderBase.h"

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structure

//------------------------------------------------------------------------------

struct OpenGLShaderBaseData
{
	NSString  *mpSourceFragment;        // the GLSL source for our fragment Shader
	NSString  *mpSourceVertex;          // the GLSL source for our vertex Shader
    GLuint     mnShaderVertex;          // Vertex shader id
    GLuint     mnShaderFragment;        // Fragment shader id
	GLuint     mnProgramObject;         // the program object id
};

typedef struct OpenGLShaderBaseData   OpenGLShaderBaseData;

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Loaders

//------------------------------------------------------------------------------

static NSString *OpenGLShaderBaseLoadShaderSourceFromResource(NSString *pShaderResourceName,
															  NSString *pExtension)
{
    NSString *pShaderSource = NULL;
    
	NSBundle  *pAppBundle = [NSBundle mainBundle];
    
    if( pAppBundle )
    {
        NSString  *pShaderPathname = [pAppBundle pathForResource:pShaderResourceName
                                                          ofType:pExtension];
        
        if( pShaderPathname )
        {
            pShaderSource = [[NSString alloc] initWithContentsOfFile:pShaderPathname
                                                            encoding:NSUTF8StringEncoding
                                                               error:NULL];
        } // if
    } // if
	
	return  pShaderSource;
} // OpenGLShaderBaseLoadShaderSourceFromResource

//------------------------------------------------------------------------------

static void OpenGLShaderBaseSetSource(const GLenum nShaderType,
									  NSString *pShaderPathname,
									  OpenGLShaderBaseDataRef pSShader)
{
    if( pShaderPathname != NULL )
    {
        switch( nShaderType )
        {
            case GL_VERTEX_SHADER:
                pSShader->mpSourceVertex
                = OpenGLShaderBaseLoadShaderSourceFromResource(pShaderPathname, @"vs");
                break;
                
            case GL_FRAGMENT_SHADER:
            default:
                pSShader->mpSourceFragment
                = OpenGLShaderBaseLoadShaderSourceFromResource(pShaderPathname, @"fs");
                break;
        } // switch
    } // if
    else
    {
        NSLog(@">> WARNING: OpenGL Shader Base - Pathname to shader is NULL!");
    } // if
} // OpenGLShaderBaseSetSource

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Accessors

//------------------------------------------------------------------------------

static const GLchar *OpenGLShaderBaseGetShaderSource(const GLenum nShaderType,
													 OpenGLShaderBaseDataRef pSShader)
{
    NSString *pShaderSource = nil;
    
    switch( nShaderType )
    {
        case GL_VERTEX_SHADER:
            pShaderSource = pSShader->mpSourceVertex;
            break;
            
        case GL_FRAGMENT_SHADER:
        default:
            pShaderSource = pSShader->mpSourceFragment;
            break;
    } // switch
    
    return [pShaderSource cStringUsingEncoding:NSUTF8StringEncoding];
} // OpenGLShaderBaseGetShaderSource

//------------------------------------------------------------------------------

static void OpenGLShaderBaseSetShader(const GLenum nShaderType,
									  const GLuint nShaderObject,
									  OpenGLShaderBaseDataRef pSShader)
{
    switch( nShaderType )
    {
        case GL_VERTEX_SHADER:
            pSShader->mnShaderVertex = nShaderObject;
            break;
            
        case GL_FRAGMENT_SHADER:
        default:
            pSShader->mnShaderFragment = nShaderObject;
            break;
    } // switch
} // OpenGLShaderBaseSetShader

//------------------------------------------------------------------------------

static GLint OpenGLShaderBaseGetUniformLocation(NSString *pUniformName,
												OpenGLShaderBaseDataRef pSShader)
{
    GLint nUniformLoacation = -1;
    
    if( pSShader->mnProgramObject && pUniformName )
    {
		const char *pUniformString = [pUniformName cStringUsingEncoding:NSASCIIStringEncoding];
        
        if( pUniformString != NULL )
        {
            nUniformLoacation = glGetUniformLocation(pSShader->mnProgramObject,
                                                     pUniformString);
            
            if( nUniformLoacation == -1 )
            {
                NSLog( @">> WARNING: OpenGL Shader Base - No such uniform named \"%s\"!", pUniformString );
            } // if
        } // if
        else
        {
            NSLog( @">> ERROR: OpenGL Shader Base - Null uniform name!" );
        } // if
    } // if
    else
    {
        NSLog( @">> ERROR: OpenGL Shader Base - Invalid parameters!" );
    } // if
    
	return nUniformLoacation;
} // OpenGLShaderBaseGetUniformLocation

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Destructors

//------------------------------------------------------------------------------

static void OpenGLShaderBaseDeleteProgram(OpenGLShaderBaseDataRef pSShader)
{
    if( pSShader->mnProgramObject )
    {
        if( pSShader->mnShaderVertex )
        {
            glDeleteShader(pSShader->mnShaderVertex);
        } // if
        
        if( pSShader->mnShaderFragment )
        {
            glDeleteShader(pSShader->mnShaderFragment);
        } // if
        
        // Delete the program
        
        glDeleteProgram(pSShader->mnProgramObject);
        
        glUseProgram(0);
    } // if
} // OpenGLShaderBaseDeleteProgram

//------------------------------------------------------------------------------

static void OpenGLShaderBaseDelete(OpenGLShaderBaseDataRef pSShader)
{
	if( pSShader != NULL )
	{
        OpenGLShaderBaseDeleteProgram(pSShader);
		
		free(pSShader);
		
		pSShader = NULL;
	} // if
} // OpenGLShaderBaseDelete

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Utilities - Constructors

//------------------------------------------------------------------------------

static void OpenGLShaderBaseCompileShader(const GLenum nShaderType,
										  GLuint nShaderObject,
										  OpenGLShaderBaseDataRef pSShader)
{
    GLint nInfoLogLength = 0;
    
    const GLchar *pShaderSource = OpenGLShaderBaseGetShaderSource(nShaderType,
																  pSShader);
    
    glShaderSource(nShaderObject, 1, &pShaderSource, NULL);
    glCompileShader(nShaderObject);
    
    glGetShaderiv(nShaderObject, GL_INFO_LOG_LENGTH, &nInfoLogLength);
    
    if( nInfoLogLength > 0 )
    {
        GLchar *pInfoLog = (GLchar *)malloc(nInfoLogLength);
        
        if( pInfoLog != NULL )
        {
            glGetShaderInfoLog(nShaderObject,
                               nInfoLogLength,
                               &nInfoLogLength,
                               pInfoLog);
            
            NSLog(@">> INFO: OpenGL Shader Base - Shader compile log:\n%s\n", pInfoLog);
            
            free(pInfoLog);
        } // if
    } // if
} // OpenGLShaderBaseCompileShader

//------------------------------------------------------------------------------

static BOOL OpenGLShaderBaseValidateShader(const GLenum nShaderType,
										   GLuint nShaderObject,
										   OpenGLShaderBaseDataRef pSShader)
{
    GLint nIsCompiled = 0;
    
    glGetShaderiv(nShaderObject, GL_COMPILE_STATUS, &nIsCompiled);
    
    if( nIsCompiled == 0 )
    {
        const GLchar *pShaderSource = OpenGLShaderBaseGetShaderSource(nShaderType,
																	  pSShader);
        
        NSLog(@">> WARNING: OpenGL Shader Base - Failed to compile shader!\n%s\n", pShaderSource);
        NSLog(@">> WARNING: OpenGL Shader Base - Deleted shader object!");
        
        glDeleteShader(nShaderObject);
    } // if
    else
    {
        OpenGLShaderBaseSetShader(nShaderType, nShaderObject, pSShader);
    } // else
    
	return nIsCompiled != 0;
} // OpenGLShaderBaseValidateShader

//------------------------------------------------------------------------------

static void OpenGLShaderBaseDeleteShaderSource(const GLenum nShaderType,
											   OpenGLShaderBaseDataRef pSShader)
{
    NSString *pShaderSource = nil;
    
    switch( nShaderType )
    {
        case GL_VERTEX_SHADER:
            pShaderSource = pSShader->mpSourceVertex;
            break;
            
        case GL_FRAGMENT_SHADER:
        default:
            pShaderSource = pSShader->mpSourceFragment;
            break;
    } // switch
    
    if(pShaderSource)
    {
        [pShaderSource release];
        
        pShaderSource = nil;
    } // if
} // OpenGLShaderBaseDeleteShaderSource

//------------------------------------------------------------------------------

static BOOL OpenGLShaderBaseCreateShader(const GLenum nShaderType,
										 OpenGLShaderBaseDataRef pSShader)
{
    BOOL bSuccess = NO;
    
    GLuint nShaderObject = glCreateShader(nShaderType);
    
    if( nShaderObject )
    {
        OpenGLShaderBaseCompileShader(nShaderType,
									  nShaderObject,
									  pSShader);
        
        OpenGLShaderBaseDeleteShaderSource(nShaderType,
										   pSShader);
        
        bSuccess = OpenGLShaderBaseValidateShader(nShaderType,
												  nShaderObject,
												  pSShader);
	} // if
    
	return bSuccess;
} // OpenGLShaderBaseCreateShader

//------------------------------------------------------------------------------

static BOOL OpenGLShaderBaseLinkProgram(OpenGLShaderBaseDataRef pSShader)
{
	GLint  nInfoLogLength = 0;
	GLint  nProgramLinked = 0;
	
	glLinkProgram(pSShader->mnProgramObject);
	
	glGetProgramiv(pSShader->mnProgramObject,
                   GL_INFO_LOG_LENGTH,
                   &nInfoLogLength);
	
	if( nInfoLogLength >  0 )
	{
		GLchar *pInfoLog = (GLchar *)malloc(nInfoLogLength);
		
		if( pInfoLog != NULL )
		{
			glGetProgramInfoLog(pSShader->mnProgramObject,
                                nInfoLogLength,
                                &nInfoLogLength,
                                pInfoLog);
			
			NSLog(@">> INFO: OpenGL Shader Base - Program link log:\n%s\n", pInfoLog);
			
			free(pInfoLog);
		} // if
	} // if
	
	glGetProgramiv(pSShader->mnProgramObject,
                   GL_LINK_STATUS,
                   &nProgramLinked);
	
	if( nProgramLinked == 0 )
	{
		NSLog(@">> WARNING: OpenGL Shader Base - Failed to link program!");
	} // if
	
	return  nProgramLinked != 0;
} // OpenGLShaderBaseLinkProgram

//------------------------------------------------------------------------------

static BOOL OpenGLShaderBaseAcquireProgram(OpenGLShaderBaseDataRef pSShader)
{
    BOOL bIsValidProgram = NO;
    
	// Create a program object and link shaders
	
    pSShader->mnProgramObject = glCreateProgram();
    
    if( pSShader->mnProgramObject )
    {
        if( pSShader->mnShaderVertex )
        {
            glAttachShader(pSShader->mnProgramObject,
                           pSShader->mnShaderVertex);
        } // if
        
        if( pSShader->mnShaderFragment )
        {
            glAttachShader(pSShader->mnProgramObject,
                           pSShader->mnShaderFragment);
        } // if
        
        bIsValidProgram = OpenGLShaderBaseLinkProgram(pSShader);
        
        if( !bIsValidProgram )
        {
            OpenGLShaderBaseDeleteProgram(pSShader);
        } // if
    } // if
	
	return bIsValidProgram;
} // OpenGLShaderBaseAcquireProgram

//------------------------------------------------------------------------------

static BOOL OpenGLShaderBaseNewProgram(OpenGLShaderBaseDataRef pSShader)
{
	// Load and compile both shaders
	
	OpenGLShaderBaseCreateShader(GL_VERTEX_SHADER, pSShader);
	OpenGLShaderBaseCreateShader(GL_FRAGMENT_SHADER, pSShader);
	
	// Create a program object and link both shaders
    
	BOOL bSuccess = OpenGLShaderBaseAcquireProgram(pSShader);
    
	return bSuccess;
} // OpenGLShaderBaseNewProgram

//------------------------------------------------------------------------------

static BOOL OpenGLShaderBaseValidateProgram(OpenGLShaderBaseDataRef pSShader)
{
	GLint  nInfoLogLength = 0;
	GLint  nIsValidated   = 0;
    
	glValidateProgram(pSShader->mnProgramObject);
    
	glGetProgramiv(pSShader->mnProgramObject,
                   GL_INFO_LOG_LENGTH,
                   &nInfoLogLength);
	
	if( nInfoLogLength >  0 )
	{
		GLchar *infoLog = (GLchar *)malloc(nInfoLogLength);
		
		if( infoLog != NULL )
		{
			glGetProgramInfoLog(pSShader->mnProgramObject,
                                nInfoLogLength,
                                &nInfoLogLength,
                                infoLog);
			
			NSLog(@">> INFO: OpenGL Shader Base - Program validate log:\n%s\n", infoLog);
			
			free(infoLog);
		} // if
	} // if
	
	glGetProgramiv(pSShader->mnProgramObject,
                   GL_VALIDATE_STATUS,
                   &nIsValidated);
	
	if( nIsValidated == 0 )
	{
		NSLog(@">> WARNING: OpenGL Shader Base - Failed to validate program!");
	} // if
	
	return  nIsValidated != 0;
} // OpenGLShaderBaseValidateProgram

//------------------------------------------------------------------------------

static BOOL OpenGLShaderBaseCreateProgram(const BOOL bValidate,
										  OpenGLShaderBaseDataRef pSShader)
{
	BOOL bSuccess = OpenGLShaderBaseNewProgram(pSShader);
	
	if( !bSuccess )
	{
		NSLog(@">> WARNING: OpenGL Shader Base - Failed to create the program object!");
	} // if
	else
	{
		if( bValidate )
		{
			bSuccess = OpenGLShaderBaseValidateProgram(pSShader);
			
			if( !bSuccess )
			{
				NSLog(@">> WARNING: OpenGL Shader Base - Failed to validate the program object!");
			} // if
		} // if
	} // else
	
	return bSuccess;
} // OpenGLShaderBaseCreateProgram

//------------------------------------------------------------------------------

static OpenGLShaderBaseDataRef OpenGLShaderBaseCreate(const BOOL bValidate,
													  NSString *pShadersName)
{
    OpenGLShaderBaseDataRef pSShader = (OpenGLShaderBaseDataRef)calloc(1, sizeof(OpenGLShaderBaseData));
    
    if( pSShader != NULL )
    {
        OpenGLShaderBaseSetSource(GL_VERTEX_SHADER, pShadersName, pSShader);
        OpenGLShaderBaseSetSource(GL_FRAGMENT_SHADER, pShadersName, pSShader);
        
        BOOL bSuccess = OpenGLShaderBaseCreateProgram(bValidate, pSShader);
        
        if( !bSuccess )
        {
            NSLog( @">> ERROR: OpenGL Shader Base - Failed to create & validate the program for the \"%@\" shader",pShadersName );
        } // if
    } // if
    else
    {
        NSLog( @">> ERROR: OpenGL Shader Base - Failure Allocating backing store for the data!" );
    } // else
    
	return pSShader;
} // OpenGLShaderBaseCreate

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Interfaces

//------------------------------------------------------------------------------

@implementation OpenGLShaderBase

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

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

//------------------------------------------------------------------------------

- (id) initWithShaderSourcesInAppBundle:(NSString *)theShadersName
							   validate:(const BOOL)theShaderNeedsValidation;
{
	self = [super init];
	
	if( self )
	{
		mpShaderBase = OpenGLShaderBaseCreate(theShaderNeedsValidation,
											  theShadersName);
	} // if
	
	return self;
} // initWithShaderSourcesInAppBundle

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//------------------------------------------------------------------------------

- (void) dealloc
{
    OpenGLShaderBaseDelete(mpShaderBase);
	
	[super dealloc];
} // dealloc

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//------------------------------------------------------------------------------

- (GLuint) programObject
{
	return( mpShaderBase->mnProgramObject );
} // programObject

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities

//------------------------------------------------------------------------------

- (void) enable
{
	glUseProgram(mpShaderBase->mnProgramObject);
} // enable

//------------------------------------------------------------------------------

- (void) disable
{
	glUseProgram(0);
} // disable

//------------------------------------------------------------------------------

- (GLint) uniformLocation:(NSString *)pUniformName
{
	return OpenGLShaderBaseGetUniformLocation(pUniformName, mpShaderBase);
} // uniformLocation

//------------------------------------------------------------------------------

@end

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------

