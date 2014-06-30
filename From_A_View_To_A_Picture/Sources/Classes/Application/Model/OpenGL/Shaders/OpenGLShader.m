//------------------------------------------------------------------------
//
//	File: OpenGLShader.m
//
//  Abstract: A utility toolkit for managing shaders along with their
//            uniforms
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
//------------------------------------------------------------------------

//------------------------------------------------------------------------

#import "OpenGLTexture.h"

#import "OpenGLShaderDictKeys.h"
#import "OpenGLShader.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Enumerated Types

//------------------------------------------------------------------------

enum OpenGLUniformTypes
{
	kUniformDefault = 0,
	kUniform1i,
	kUniform1f,
	kUniform3fv,
	kUniformMatrix3fv,
    kUniformMax
};

typedef enum OpenGLUniformTypes OpenGLUniformTypes;

//------------------------------------------------------------------------

enum OpenGLUniformVectorTypes
{
	kVector = 1,
	k2Vector,
	k3Vector,
	k4Vector
};

typedef enum OpenGLUniformVectorTypes OpenGLUniformVectorTypes;

//------------------------------------------------------------------------

enum OpenGLUniformMatrixTypes
{
	k2x2Matrix = 2,
	k3x3Matrix,
	k4x4Matrix
};

typedef enum OpenGLUniformMatrixTypes OpenGLUniformMatrixTypes;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Constants

//------------------------------------------------------------------------

static const GLuint kSizeOfGLint   = sizeof(GLint);
static const GLuint kSizeOfGLfloat = sizeof(GLfloat);

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Function Pointers

//------------------------------------------------------------------------

typedef void (*OpenGLSetUniformFuncPtr)(NSDictionary *uniformDict);

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Data Structure

//------------------------------------------------------------------------

struct OpenGLShaderData
{
	NSMutableDictionary  *mpUniforms;
	NSMutableDictionary  *mpTextures;
	GLuint                mnProgram;
    
    OpenGLSetUniformFuncPtr glSetUniform[kUniformMax];
};

typedef struct OpenGLShaderData   OpenGLShaderData;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Private - Setting Uniforms

//------------------------------------------------------------------------

static void OpenGLSetUniform1i(NSDictionary *theUniformDict)
{
	NSNumber *uniformINum   = [theUniformDict objectForKey:kOpenGLUniformValueKey];
	GLint     uniformIValue = [uniformINum intValue];
	NSNumber *uniformLocNum = [theUniformDict objectForKey:kOpenGLUniformLocKey];
	GLint     uniformLoc    = [uniformLocNum intValue];
	
	glUniform1i( uniformLoc, uniformIValue );
} // OpenGLSetUniform1i

//------------------------------------------------------------------------

static void OpenGLSetUniform1f(NSDictionary *theUniformDict)
{
	NSNumber *uniformLocNum = [theUniformDict objectForKey:kOpenGLUniformLocKey];
	GLint     uniformLoc    = [uniformLocNum intValue];
	NSNumber *uniformFNum   = [theUniformDict objectForKey:kOpenGLUniformValueKey];
	GLfloat   uniformFValue = [uniformFNum floatValue];
	
	glUniform1f( uniformLoc, uniformFValue );
} // OpenGLSetUniform1f

//------------------------------------------------------------------------

static void OpenGLSetUniform3fv(NSDictionary *theUniformDict)
{
	NSNumber *uniformLocNum   = [theUniformDict objectForKey:kOpenGLUniformLocKey];
	GLint     uniformLoc      = [uniformLocNum intValue];
	NSData   *uniformFData    = [theUniformDict objectForKey:kOpenGLUniformValueKey];
	NSNumber *uniformCountNum = [theUniformDict objectForKey:kOpenGLUniformCountKey];
	GLuint    uniformCount    = [uniformCountNum intValue];
	GLuint    uniformCapacity = k3Vector * uniformCount * kSizeOfGLfloat;
	GLfloat  *uniformFVec     = (GLfloat *)malloc(uniformCapacity);
	
	if( uniformFVec != NULL )
	{
		[uniformFData getBytes:uniformFVec];
		
		glUniform3fv( uniformLoc, uniformCount, uniformFVec );
		
		free( uniformFVec );
	} // if
} // OpenGLSetUniform3fv

//------------------------------------------------------------------------

static void OpenGLSetUniformMatrix3fv(NSDictionary *theUniformDict)
{
	NSNumber   *uniformLocNum       = [theUniformDict objectForKey:kOpenGLUniformLocKey];
	GLint       uniformLoc          = [uniformLocNum intValue];
	NSData     *uniformFData        = [theUniformDict objectForKey:kOpenGLUniformValueKey];
	NSNumber   *uniformCountNum     = [theUniformDict objectForKey:kOpenGLUniformCountKey];
	GLuint      uniformCount        = [uniformCountNum intValue];
	GLuint      uniformCapacity     = k3x3Matrix * k3x3Matrix * uniformCount * kSizeOfGLfloat;
	NSNumber   *uniformTransposeNum = [theUniformDict objectForKey:kOpenGLUniformTransposeKey];
	GLboolean   uniformTranspose    = [uniformTransposeNum intValue];
	GLfloat    *uniformFMatrix      = (GLfloat *)malloc(uniformCapacity);
	
	if( uniformFMatrix != NULL )
	{
		[uniformFData getBytes:uniformFMatrix];
		
		glUniformMatrix3fv(uniformLoc,
						   uniformCount,
						   uniformTranspose,
						   uniformFMatrix );
		
		free( uniformFMatrix );
	} // if
} // OpenGLSetUniformMatrix3fv

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -

//------------------------------------------------------------------------

@implementation OpenGLShader

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Designated Initializers

//------------------------------------------------------------------------

- (void) initTexturesWithDictionary:(NSDictionary *)theTextures
{
	if( theTextures )
	{
		mpShader->mpTextures = [[NSMutableDictionary alloc] initWithDictionary:theTextures];
		
		if( mpShader->mpTextures )
		{
			glUseProgram(mpShader->mnProgram);
			{
				GLint                 samplerLoc      = 0;
				GLint                 samplerValue    = 0;
				GLenum                textureActive   = 0;
				NSNumber             *samplerLocNum   = nil;
				NSNumber             *samplerValueNum = nil;
				NSString             *textureName     = nil;
				NSMutableDictionary  *textureDesc     = nil;
				OpenGLTexture        *texture         = nil;
                
				for( textureName in theTextures )
				{
					textureDesc = [NSMutableDictionary dictionaryWithCapacity:3];
					
					texture       = [theTextures objectForKey:textureName];
					textureActive = [texture active];
					
					[textureDesc setObject:texture
									forKey:kOpenGLUniformTextureKey];
					
					samplerValue    = textureActive ^ GL_TEXTURE0;
					samplerValueNum = [NSNumber numberWithInt:samplerValue];
					
					[textureDesc setObject:samplerValueNum
									forKey:kOpenGLUniformValueKey];
					
					samplerLoc    = [self uniformLocation:textureName];
					samplerLocNum = [NSNumber numberWithInt:samplerLoc];
					
					[textureDesc setObject:samplerLocNum
									forKey:kOpenGLUniformLocKey];
					
					[mpShader->mpTextures setObject:textureDesc
                                             forKey:textureName];
					
					glUniform1i( samplerLoc, samplerValue );
				} // for
			}
			glUseProgram(0);
		} // if
	} // if
} // initSamplersWithDictionary

//------------------------------------------------------------------------

- (void) initUniformsWithDictionary:(NSDictionary *)theUniforms
{
	if( theUniforms )
	{
		mpShader->mpUniforms = [[NSMutableDictionary alloc] initWithDictionary:theUniforms];
		
		if( mpShader->mpUniforms )
		{
			glUseProgram(mpShader->mnProgram);
			{
				GLint                 uniformLoc     = 0;
				NSString             *uniformName    = nil;
				NSNumber             *uniformLocNum  = nil;
				NSNumber             *uniformTypeNum = nil;
				NSMutableDictionary  *uniform        = nil;
				
				for( uniformName in theUniforms )
				{
					uniform = [NSMutableDictionary dictionaryWithCapacity:2];
					
					uniformTypeNum = [theUniforms objectForKey:uniformName];
					
					[uniform setObject:uniformTypeNum
								forKey:kOpenGLUniformTypeKey];
					
					uniformLoc    = [self uniformLocation:uniformName];
					uniformLocNum = [NSNumber numberWithInt:uniformLoc];
					
					[uniform setObject:uniformLocNum
								forKey:kOpenGLUniformLocKey];
					
					[mpShader->mpUniforms setObject:uniform
                                             forKey:uniformName];
				} // for
			}
			glUseProgram(0);
		} // if
	} // if
} // initUniformsWithDictionary

//---------------------------------------------------------------------------

- (void) initUniformSetters
{
    mpShader->glSetUniform[kUniformDefault]   = &OpenGLSetUniform1f;
    mpShader->glSetUniform[kUniform1i]        = &OpenGLSetUniform1i;
    mpShader->glSetUniform[kUniform1f]        = &OpenGLSetUniform1f;
    mpShader->glSetUniform[kUniform3fv]       = &OpenGLSetUniform3fv;
    mpShader->glSetUniform[kUniformMatrix3fv] = &OpenGLSetUniformMatrix3fv;
} // initUniformSetters

//---------------------------------------------------------------------------
//
// Make sure client goes through designated initializer
//
//---------------------------------------------------------------------------

- (id) initWithShaderSourcesInAppBundle:(NSString *)theShadersName
							   validate:(const BOOL)theShaderNeedsValidation
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // initWithShaderSourcesInAppBundle

//------------------------------------------------------------------------

- (id) initShaderWithSourcesInAppBundle:(NSString *)theShadersName
							   validate:(const BOOL)theShaderNeedsValidation
							   textures:(NSDictionary *)theTexturesDescription
							   uniforms:(NSDictionary *)theUniformsDescription
{
	self = [super initWithShaderSourcesInAppBundle:theShadersName
										  validate:theShaderNeedsValidation];
	
	if( self )
	{
        mpShader = (OpenGLShaderDataRef)calloc(1, sizeof(OpenGLShaderData));
        
        if( mpShader != NULL )
        {
            // Cache the shader's program object
            
            mpShader->mnProgram = [self programObject];
            
            // Initialize setter function pointer array for uniforms
            
            [self initUniformSetters];
            
            // Initialize samplers & mpShader->mpUniforms dictionaries
            
            [self initTexturesWithDictionary:theTexturesDescription];
            [self initUniformsWithDictionary:theUniformsDescription];
        } // if
	} // if
	
	return self;
} // initShaderWithSourcesInAppBundle

//------------------------------------------------------------------------

- (id) initShaderWithSourcesInAppBundle:(NSString *)theShadersName
							   validate:(const BOOL)theShaderNeedsValidation
							   uniforms:(NSDictionary *)theUniformsDescription
{
	self = [super initWithShaderSourcesInAppBundle:theShadersName
										  validate:theShaderNeedsValidation];
	
	if( self )
	{
        mpShader = (OpenGLShaderDataRef)calloc(1, sizeof(OpenGLShaderData));
        
        if( mpShader != NULL )
        {
            // Cache the shader's program object
            
            mpShader->mnProgram = [self programObject];
            
            // Initialize setter function pointer array for uniforms
            
            [self initUniformSetters];
            
            // Initialize mpShader->mpUniforms dictionary
            
            [self initUniformsWithDictionary:theUniformsDescription];
        } // if
	} // if
	
	return self;
} // initShaderWithSourcesInAppBundle

//------------------------------------------------------------------------

- (id) initShaderWithSourcesInAppBundle:(NSString *)theShadersName
							   validate:(const BOOL)theShaderNeedsValidation
{
	self = [super initWithShaderSourcesInAppBundle:theShadersName
										  validate:theShaderNeedsValidation];
	
	if( self )
	{
        mpShader = (OpenGLShaderDataRef)calloc(1, sizeof(OpenGLShaderData));
        
        if( mpShader != NULL )
        {
            // Cache the shader's program object
            
            mpShader->mnProgram = [self programObject];
            
            // Initialize setter function pointer array for uniforms
            
            [self initUniformSetters];
        } // if
	} // if
	
	return self;
} // initShaderWithSourcesInAppBundle

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Deallocating Resources

//------------------------------------------------------------------------

- (void) cleanUpShader
{
    if( mpShader != NULL )
    {
        // Sampler dictionary is not needed
        
        if( mpShader->mpTextures )
        {
            [mpShader->mpTextures release];
            
            mpShader->mpTextures = nil;
        } // if
        
        // Uniform dictionary is not needed
        
        if( mpShader->mpUniforms )
        {
            [mpShader->mpUniforms release];
            
            mpShader->mpUniforms = nil;
        } // if
        
        free( mpShader );
        
        mpShader = NULL;
    } // if
} // cleanUpShader

//------------------------------------------------------------------------

- (void) dealloc
{
	[self cleanUpShader];
	
	[super dealloc];
} // dealloc

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//------------------------------------------------------------------------

- (void) setTexturesDictionary:(NSDictionary *)theTextures
{
	if( theTextures )
	{
		NSMutableDictionary *pTextures = [[NSMutableDictionary alloc] initWithDictionary:theTextures];
		
		if( pTextures )
		{
			[mpShader->mpTextures release];
			
			mpShader->mpTextures = pTextures;
		} // if
	} // if
} // setTexturesDictionary

//------------------------------------------------------------------------

- (NSMutableDictionary *) textures
{
	return( [[[NSMutableDictionary alloc] initWithDictionary:mpShader->mpTextures] autorelease] );
} // textures

//------------------------------------------------------------------------

- (void) setUniformsDictionary:(NSDictionary *)theUniforms
{
	if( theUniforms )
	{
		NSMutableDictionary *pUniforms = [[NSMutableDictionary alloc] initWithDictionary:theUniforms];
		
		if( pUniforms )
		{
			[mpShader->mpUniforms release];
			
			mpShader->mpUniforms = pUniforms;
		} // if
	} // if
} // setUniformsDictionary

//------------------------------------------------------------------------

- (NSMutableDictionary *) uniforms
{
	return( [[[NSMutableDictionary alloc] initWithDictionary:mpShader->mpUniforms] autorelease] );
} // uniforms

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Setting Uniforms

//---------------------------------------------------------------------------

- (void) setUniformWithIntegers:(NSString *)theUniformName
						 scalar:(const GLint)theUniformScalar
{
	NSMutableDictionary *uniformDict = [mpShader->mpUniforms objectForKey:theUniformName];
	
	[uniformDict setObject:[NSNumber numberWithInt:theUniformScalar]
					forKey:kOpenGLUniformValueKey];
} // setUniformWithIntegers

//---------------------------------------------------------------------------

- (void) setUniformWithFloats:(NSString *)theUniformName
					   scalar:(const GLfloat)theUniformScalar
{
	NSMutableDictionary *uniformDict = [mpShader->mpUniforms objectForKey:theUniformName];
	
	[uniformDict setObject:[NSNumber numberWithFloat:theUniformScalar]
					forKey:kOpenGLUniformValueKey];
} // setUniformWithFloats

//------------------------------------------------------------------------

- (void) setUniformWithFloatVectors3:(NSString *)theUniformName
							 vectors:(const GLfloat *)theUniformVectors
							   count:(const GLuint)theUniformCount
{
	NSMutableDictionary *uniformDict = [mpShader->mpUniforms objectForKey:theUniformName];
	
	if( theUniformCount > 0 )
	{
		NSUInteger   uniformLength = k3Vector * theUniformCount * kSizeOfGLfloat;
		NSData      *uniformValues = [NSData dataWithBytes:theUniformVectors
													length:uniformLength];
		
		[uniformDict setObject:uniformValues
						forKey:kOpenGLUniformValueKey];
		
		NSNumber *uniformCountNum = [NSNumber numberWithInt:theUniformCount];
		
		[uniformDict setObject:uniformCountNum
						forKey:kOpenGLUniformCountKey];
	} // if
} // setUniformWithFloatVectors3

//------------------------------------------------------------------------

- (void) setUniformWithFloatMatrices3x3:(NSString *)theUniformName
							   tanspose:(const GLboolean)theTransposeFlag
							   matrices:(const GLfloat *)theUniformMatrices
								  count:(const GLuint)theUniformCount
{
	NSMutableDictionary *uniformDict = [mpShader->mpUniforms objectForKey:theUniformName];
	
	if( theUniformCount > 0 )
	{
		NSUInteger   uniformLength = k3x3Matrix * k3x3Matrix * theUniformCount * kSizeOfGLfloat;
		NSData      *uniformValues = [NSData dataWithBytes:theUniformMatrices
													length:uniformLength];
		
		[uniformDict setObject:uniformValues
						forKey:kOpenGLUniformValueKey];
		
		NSNumber *uniformTranspose = [NSNumber numberWithBool:theTransposeFlag];
		
		[uniformDict setObject:uniformTranspose
						forKey:kOpenGLUniformTransposeKey];
		
		NSNumber *uniformCountNum = [NSNumber numberWithInt:theUniformCount];
		
		[uniformDict setObject:uniformCountNum
						forKey:kOpenGLUniformCountKey];
	} // if
} // setUniformWithFloatMatrices3x3

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Generic 2D/3D draw

//------------------------------------------------------------------------
//
// A generic method to draw a 2D/3D object. Once subclassed, one must
// override this method, so that a particular shader unit is bound to
// an actual 2D/3D object.
//
//------------------------------------------------------------------------

- (BOOL) draw
{
	return YES;
} // draw

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Shader Utilities

//------------------------------------------------------------------------

- (void) bindUniforms
{
	glUseProgram(mpShader->mnProgram);
	{
		OpenGLUniformTypes   uniformType    = 0;
		NSNumber            *uniformTypeNum = nil;
		NSDictionary        *uniform        = nil;
		NSString            *uniformKey     = nil;
		
		for( uniformKey in mpShader->mpUniforms )
		{
			uniform        = [mpShader->mpUniforms objectForKey:uniformKey];
			uniformTypeNum = [uniform objectForKey:kOpenGLUniformTypeKey];
			uniformType    = [uniformTypeNum intValue];
			
			mpShader->glSetUniform[uniformType](uniform);
		} // for
	}
	glUseProgram(0);
} // bindUniforms

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Shader Execution

//------------------------------------------------------------------------

- (void) execute
{
	glUseProgram(mpShader->mnProgram);
	{
		OpenGLUniformTypes   uniformType    = 0;
		OpenGLTexture       *texture        = nil;
		NSNumber            *uniformTypeNum = nil;
		NSDictionary        *uniformDesc    = nil;
		NSDictionary        *textureDesc    = nil;
		NSString            *uniformKey     = nil;
		NSString            *textureKey     = nil;
		
		for( uniformKey in mpShader->mpUniforms )
		{
			uniformDesc    = [mpShader->mpUniforms objectForKey:uniformKey];
			uniformTypeNum = [uniformDesc objectForKey:kOpenGLUniformTypeKey];
			uniformType    = [uniformTypeNum intValue];
			
			mpShader->glSetUniform[uniformType](uniformDesc);
		} // for
		
		for( textureKey in mpShader->mpTextures )
		{
			textureDesc = [mpShader->mpTextures objectForKey:textureKey];
			texture     = [textureDesc objectForKey:kOpenGLUniformTextureKey];
			
			[texture bind];
		} // for
		
		glActiveTexture( GL_TEXTURE0 );
		
		[self draw];
	}
	glUseProgram(0);
} // execute

//------------------------------------------------------------------------

@end

//------------------------------------------------------------------------

//------------------------------------------------------------------------

