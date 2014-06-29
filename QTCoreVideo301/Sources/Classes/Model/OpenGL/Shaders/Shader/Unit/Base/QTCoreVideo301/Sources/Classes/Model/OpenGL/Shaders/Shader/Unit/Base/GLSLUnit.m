/*
     File: GLSLUnit.m
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

#pragma mark -
#pragma mark Private - Headers

#import "GLSizes.h"

#import "GLUniform.h"

#import "GLSLUnitDictTypes.h"
#import "GLSLUnit.h"

#pragma mark -
#pragma mark Private - Keys

NSString *kGLSLUniformLocKey       = @"location";
NSString *kGLSLUniformTypeKey      = @"type";
NSString *kGLSLUniformValueKey     = @"value";
NSString *kGLSLUniformCountKey     = @"count";
NSString *kGLSLUniformTransposeKey = @"transpose";

#pragma mark -
#pragma mark Private - Prototypes

typedef void (*GLSLUniformFuncptr)(NSDictionary *pUniform);

#pragma mark -
#pragma mark Private - Data Structure

struct GLSLUnitData
{
    GLuint              mnProgram;
    GLSLUniformFuncptr  m_Method[kGLSLUniformMax];
}; // GLSLUnitData

typedef struct GLSLUnitData GLSLUnitData;

#pragma mark -
#pragma mark Private - Utilities - Acquire

static inline GLint GLSLUnitAcquireLocation(const NSString * const pName,
                                            GLSLUnitDataRef pShaderUnit)
{
    GLint nLocation = -1;
    
    if(pName)
    {
        const GLchar *pUniform = (GLchar *)[pName cStringUsingEncoding:NSASCIIStringEncoding];
        
        if(pUniform != NULL)
        {
            nLocation = glGetUniformLocation(pShaderUnit->mnProgram, pUniform);
            
            if(nLocation == -1)
            {
                NSLog(@">> [OpenGL Shader Kit] WARNING: No such uniform named \"%s\"!", pUniform);
            } // if
        } // if
    } // if
    
	return nLocation;
} // GLSLUnitAcquireLocation

// Acquire sampler
static void GLSLUnitAcquireSampler(const NSString * const pSampler,
                                   const GLuint nValue,
                                   GLSLUnitDataRef pShaderUnit)
{
    if(pSampler)
    {
        glUseProgram(pShaderUnit->mnProgram);
        {
            GLint nLocation = GLSLUnitAcquireLocation(pSampler, pShaderUnit);
            
            if(nLocation > -1)
            {
                glUniform1i(nLocation, nValue);
            } // if
        }
        glUseProgram(0);
    } // if
} // GLSLUnitAcquireSampler

// Acquire samplers
static void GLSLUnitAcquireSamplers(NSDictionary *pSamplers,
                                    GLSLUnitDataRef pShaderUnit)
{
    if(pSamplers)
    {
        glUseProgram(pShaderUnit->mnProgram);
        {
            NSString *pSamplerKey;
            NSNumber *pSamplerNum;
            
            GLint  nSamplerLoc   = 0;
            GLint  nSamplerValue = 0;
            
            for(pSamplerKey in pSamplers)
            {
                pSamplerNum = [pSamplers objectForKey:pSamplerKey];
                
                if(pSamplerNum)
                {
                    nSamplerValue = [pSamplerNum integerValue];
                    nSamplerLoc   = GLSLUnitAcquireLocation(pSamplerKey, pShaderUnit);
                    
                    if(nSamplerLoc > -1)
                    {
                        glUniform1i(nSamplerLoc, nSamplerValue);
                    } // if
                } // if
            } // for
        }
        glUseProgram(0);
    } // if
} // GLSLUnitAcquireSamplers

static inline void GLSLUnitAcquireMethods(GLSLUnitDataRef pShaderUnit)
{
    pShaderUnit->m_Method[kGLSLUniformNone] = NULL;
    
    pShaderUnit->m_Method[kGLSLUniformSampler1D]     = GLUniformSet1i;
    pShaderUnit->m_Method[kGLSLUniformSampler2D]     = GLUniformSet1i;
    pShaderUnit->m_Method[kGLSLUniformSampler3D]     = GLUniformSet1i;
    pShaderUnit->m_Method[kGLSLUniformSampler2DRect] = GLUniformSet1i;
    
    pShaderUnit->m_Method[kGLSLUniform1i] = GLUniformSet1i;
    pShaderUnit->m_Method[kGLSLUniform2i] = GLUniformSet2i;
    pShaderUnit->m_Method[kGLSLUniform3i] = GLUniformSet3i;
    pShaderUnit->m_Method[kGLSLUniform4i] = GLUniformSet4i;
    
    pShaderUnit->m_Method[kGLSLUniform1iv] = GLUniformSet1iv;
    pShaderUnit->m_Method[kGLSLUniform2iv] = GLUniformSet2iv;
    pShaderUnit->m_Method[kGLSLUniform3iv] = GLUniformSet3iv;
    pShaderUnit->m_Method[kGLSLUniform4iv] = GLUniformSet4iv;
    
    pShaderUnit->m_Method[kGLSLUniform1f] = GLUniformSet1f;
    pShaderUnit->m_Method[kGLSLUniform2f] = GLUniformSet2f;
    pShaderUnit->m_Method[kGLSLUniform3f] = GLUniformSet3f;
    pShaderUnit->m_Method[kGLSLUniform4f] = GLUniformSet4f;
    
    pShaderUnit->m_Method[kGLSLUniform1fv] = GLUniformSet1fv;
    pShaderUnit->m_Method[kGLSLUniform2fv] = GLUniformSet2fv;
    pShaderUnit->m_Method[kGLSLUniform3fv] = GLUniformSet3fv;
    pShaderUnit->m_Method[kGLSLUniform4fv] = GLUniformSet4fv;
    
    pShaderUnit->m_Method[kGLSLUniform2x2fv] = GLUniformSet2x2fv;
    pShaderUnit->m_Method[kGLSLUniform3x3fv] = GLUniformSet3x3fv;
    pShaderUnit->m_Method[kGLSLUniform4x4fv] = GLUniformSet4x4fv;
} // GLSLUnitAcquireMethods

#pragma mark -
#pragma mark Private - Utilities - Constructor

static GLSLUnitDataRef GLSLUnitCreate(GLSLUnit *pUnit)
{
    GLSLUnitDataRef pShaderUnit = NULL;
    
    if(pUnit)
    {
        pShaderUnit = (GLSLUnitDataRef)calloc(1, sizeof(GLSLUnitData));
        
        if( pShaderUnit != NULL )
        {
            pShaderUnit->mnProgram = [pUnit program];
            
            GLSLUnitAcquireMethods(pShaderUnit);
        } // if
    } // if
    
    return pShaderUnit;
} // GLSLUnitCreate

#pragma mark -
#pragma mark Private - Utilities - Destructor

static inline void GLSLUnitDelete(GLSLUnitDataRef pShaderUnit)
{
    // Delete methods
    if( pShaderUnit != NULL )
    {
        free(pShaderUnit);
        
        pShaderUnit = NULL;
    } // if
} // GLSLUnitDelete

#pragma mark -
#pragma mark Private - Utilities - Accessors

static void GLSLUnitSetUniform(NSDictionary *pUniform,
                               GLSLUnitDataRef pShaderUnit)
{
    if(pUniform)
    {
        NSNumber *pType = [pUniform objectForKey:kGLSLUniformTypeKey];
        
        if(pType)
        {
            GLuint nType = [pType intValue];
            
            if((nType > kGLSLUniformNone) && (nType < kGLSLUniformMax))
            {
                pShaderUnit->m_Method[nType](pUniform);
            } // if
        } // if
    } // if
} // GLSLUnitSetUniform

static inline void GLSLUnitSetUniforms(NSDictionary *pUniforms,
                                       GLSLUnitDataRef pShaderUnit)
{
    if(pUniforms)
    {
        NSDictionary *pKey    = nil;
        NSDictionary *pObject = nil;
        
        for(pKey in pUniforms)
        {
            pObject = [pUniforms objectForKey:pKey];
            
            GLSLUnitSetUniform(pObject, pShaderUnit);
        } // for
    } // if
} // GLSLUnitSetUniforms

#pragma mark -
#pragma mark Private - Utilities - Uniforms - Integer Scalar

static inline void GLSLUnitSetUniform1i(const GLint nLocation,
                                        const GLint nValue,
                                        GLSLUnitDataRef pShaderUnit)
{
	glUseProgram(pShaderUnit->mnProgram);
	
    glUniform1i(nLocation, nValue);
    
	glUseProgram(0);
} // GLSLUnitSetUniform1i

static inline void GLSLUnitSetUniform2i(const GLint nLocation,
                                        const GLint *pValues,
                                        GLSLUnitDataRef pShaderUnit)

{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform2i(nLocation,
                    pValues[0],
                    pValues[1]);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform2i

static inline void GLSLUnitSetUniform3i(const GLint nLocation,
                                        const GLint *pValues,
                                        GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform3i(nLocation,
                    pValues[0],
                    pValues[1],
                    pValues[2]);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform3i

static inline void GLSLUnitSetUniform4i(const GLint nLocation,
                                        const GLint *pValues,
                                        GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform4i(nLocation,
                    pValues[0],
                    pValues[1],
                    pValues[2],
                    pValues[3]);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform4i

#pragma mark -
#pragma mark Private - Utilities - Uniforms - Scalar Float

static inline void GLSLUnitSetUniform1f(const GLint nLocation,
                                        const GLfloat nValue,
                                        GLSLUnitDataRef pShaderUnit)
{
	glUseProgram(pShaderUnit->mnProgram);
	
    glUniform1f(nLocation, nValue);
    
	glUseProgram(0);
} // GLSLUnitSetUniform1f

static inline void GLSLUnitSetUniform2f(const GLint nLocation,
                                        const GLfloat *pValues,
                                        GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform2f(nLocation,
                    pValues[0],
                    pValues[1]);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform2f

static inline void GLSLUnitSetUniform3f(const GLint nLocation,
                                        const GLfloat *pValues,
                                        GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform3f(nLocation,
                    pValues[0],
                    pValues[1],
                    pValues[2]);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform3f

static inline void GLSLUnitSetUniform4f(const GLint nLocation,
                                        const GLfloat *pValues,
                                        GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform4f(nLocation,
                    pValues[0],
                    pValues[1],
                    pValues[2],
                    pValues[3]);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform4f

#pragma mark -
#pragma mark Private - Utilities - Uniforms - Integer Vector

static inline void GLSLUnitSetUniform1iv(const GLint nLocation,
                                         const GLsizei nCount,
                                         const GLint *pValues,
                                         GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform1iv(nLocation, nCount, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform1iv

static inline void GLSLUnitSetUniform2iv(const GLint nLocation,
                                         const GLsizei nCount,
                                         const GLint *pValues,
                                         GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform2iv(nLocation, nCount, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform2iv

static inline void GLSLUnitSetUniform3iv(const GLint nLocation,
                                         const GLsizei nCount,
                                         const GLint *pValues,
                                         GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform3iv(nLocation, nCount, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform3iv

static inline void GLSLUnitSetUniform4iv(const GLint nLocation,
                                         const GLsizei nCount,
                                         const GLint *pValues,
                                         GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform4iv(nLocation, nCount, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform4iv

#pragma mark -
#pragma mark Private - Utilities - Uniforms - Float Vector

static inline void GLSLUnitSetUniform1fv(const GLint nLocation,
                                         const GLsizei nCount,
                                         const GLfloat *pValues,
                                         GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform1fv(nLocation, nCount, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform1fv

static inline void GLSLUnitSetUniform2fv(const GLint nLocation,
                                         const GLsizei nCount,
                                         const GLfloat *pValues,
                                         GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform2fv(nLocation, nCount, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform2fv

static inline void GLSLUnitSetUniform3fv(const GLint nLocation,
                                         const GLsizei nCount,
                                         const GLfloat *pValues,
                                         GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform3fv(nLocation, nCount, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform3fv

static inline void GLSLUnitSetUniform4fv(const GLint nLocation,
                                         const GLsizei nCount,
                                         const GLfloat *pValues,
                                         GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniform4fv(nLocation, nCount, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform4fv

#pragma mark -
#pragma mark Private - Utilities - Uniforms - Float Matrix

static inline void GLSLUnitSetUniform2x2fv(const GLint nLocation,
                                           const GLsizei nCount,
                                           const GLboolean bTranspose,
                                           const GLfloat *pValues,
                                           GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniformMatrix2fv(nLocation, nCount, bTranspose, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform2x2fv

static inline void GLSLUnitSetUniform3x3fv(const GLint nLocation,
                                           const GLsizei nCount,
                                           const GLboolean bTranspose,
                                           const GLfloat *pValues,
                                           GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniformMatrix3fv(nLocation, nCount, bTranspose, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform3x3fv

static inline void GLSLUnitSetUniform4x4fv(const GLint nLocation,
                                           const GLsizei nCount,
                                           const GLboolean bTranspose,
                                           const GLfloat *pValues,
                                           GLSLUnitDataRef pShaderUnit)
{
    if(pValues != NULL)
    {
        glUseProgram(pShaderUnit->mnProgram);
        
        glUniformMatrix4fv(nLocation, nCount, bTranspose, pValues);
        
        glUseProgram(0);
    } // if
} // GLSLUnitSetUniform4x4fv

#pragma mark -

@implementation GLSLUnit

#pragma mark -
#pragma mark Public - Designated Initializer

- (id) init
{
	[self doesNotRecognizeSelector:_cmd];
	
	return nil;
} // init

- (id) initWithDictionary:(NSDictionary *)theDicitionary
{
	self = [super initWithDictionary:theDicitionary];
	
	if(self)
	{
        mpShaderUnit = GLSLUnitCreate(self);
    } // if
	
	return self;
} // initWithVertex

- (id) initWithShadersInAppBundle:(NSString *)theName
{
	self = [super initWithShadersInAppBundle:theName];
	
	if(self)
	{
        mpShaderUnit = GLSLUnitCreate(self);
    } // if
	
	return self;
} // initWithShadersInAppBundle

#pragma mark -
#pragma mark Public - Destructor

- (void) dealloc
{
    // Delete methods
    GLSLUnitDelete(mpShaderUnit);
    
	// Dealloc the superclass
	[super dealloc];
} // dealloc

#pragma mark -
#pragma mark Public - Utilities - Samplers

- (void) sampler:(const NSString *)theSampler
           value:(const GLuint)theValue
{
    GLSLUnitAcquireSampler(theSampler, theValue, mpShaderUnit);
} // sampler

- (void) samplers:(NSDictionary *)theSamplers
{
    GLSLUnitAcquireSamplers(theSamplers, mpShaderUnit);
} // samplers

#pragma mark -
#pragma mark Public - Utilities - Uniforms - Integer Scalar

- (void) uniform1i:(const GLint)theLocation
             value:(const GLint)theValue
{
    GLSLUnitSetUniform1i(theLocation, theValue, mpShaderUnit);
} // uniform1i

- (void) uniform2i:(const GLint)theLocation
			values:(const GLint *)theValues
{
    GLSLUnitSetUniform2i(theLocation, theValues, mpShaderUnit);
} // uniform2i

- (void) uniform3i:(const GLint)theLocation
			values:(const GLint *)theValues
{
    GLSLUnitSetUniform3i(theLocation, theValues, mpShaderUnit);
} // uniform3i

- (void) uniform4i:(const GLint)theLocation
			values:(const GLint *)theValues
{
    GLSLUnitSetUniform4i(theLocation, theValues, mpShaderUnit);
} // uniform4i

#pragma mark -
#pragma mark Public - Utilities - Uniforms - Scalar Float

- (void) uniform1f:(const GLint)theLocation
             value:(const GLfloat)theValue
{
    GLSLUnitSetUniform1f(theLocation, theValue, mpShaderUnit);
} // uniform1f

- (void) uniform2f:(const GLint)theLocation
			values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform2f(theLocation, theValues, mpShaderUnit);
} // uniform2f

- (void) uniform3f:(const GLint)theLocation
			values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform3f(theLocation, theValues, mpShaderUnit);
} // uniform3f

- (void) uniform4f:(const GLint)theLocation
			values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform4f(theLocation, theValues, mpShaderUnit);
} // uniform4f

#pragma mark -
#pragma mark Public - Utilities - Uniforms - Integer Vector

- (void) uniform1iv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLint *)theValues
{
    GLSLUnitSetUniform1iv(theLocation, theCount, theValues, mpShaderUnit);
} // uniform1iv

- (void) uniform2iv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLint *)theValues
{
    GLSLUnitSetUniform2iv(theLocation, theCount, theValues, mpShaderUnit);
} // uniform2iv

- (void) uniform3iv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLint *)theValues
{
    GLSLUnitSetUniform3iv(theLocation, theCount, theValues, mpShaderUnit);
} // uniform3iv

- (void) uniform4iv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLint *)theValues
{
    GLSLUnitSetUniform4iv(theLocation, theCount, theValues, mpShaderUnit);
} // uniform4iv

#pragma mark -
#pragma mark Public - Utilities - Uniforms - Float Vector

- (void) uniform1fv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform1fv(theLocation, theCount, theValues, mpShaderUnit);
} // uniform1fv

- (void) uniform2fv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform2fv(theLocation, theCount, theValues, mpShaderUnit);
} // uniform2fv

- (void) uniform3fv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform3fv(theLocation, theCount, theValues, mpShaderUnit);
} // uniform3fv

- (void) uniform4fv:(const GLint)theLocation
              count:(const GLsizei)theCount
             values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform4fv(theLocation, theCount, theValues, mpShaderUnit);
} // uniform4fv

#pragma mark -
#pragma mark Public - Utilities - Uniforms - Float Matrix

- (void) uniform2x2fv:(const GLint)theLocation
                count:(const GLsizei)theCount
             tanspose:(const GLboolean)theFlag
               values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform2x2fv(theLocation, theCount, theFlag, theValues, mpShaderUnit);
} // uniform2x2fv

- (void) uniform3x3fv:(const GLint)theLocation
                count:(const GLsizei)theCount
             tanspose:(const GLboolean)theFlag
               values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform3x3fv(theLocation, theCount, theFlag, theValues, mpShaderUnit);
} // uniform3x3fv

- (void) uniform4x4fv:(const GLint)theLocation
                count:(const GLsizei)theCount
             tanspose:(const GLboolean)theFlag
               values:(const GLfloat *)theValues
{
    GLSLUnitSetUniform4x4fv(theLocation, theCount, theFlag, theValues, mpShaderUnit);
} // uniform4x4fv

#pragma mark -
#pragma mark Public - Utilities -

- (void) uniforms:(NSDictionary *)theUniforms
{
    GLSLUnitSetUniforms(theUniforms, mpShaderUnit);
} // uniforms

@end
