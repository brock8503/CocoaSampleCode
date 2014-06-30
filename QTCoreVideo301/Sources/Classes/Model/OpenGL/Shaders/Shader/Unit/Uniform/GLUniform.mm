/*
     File: GLUniform.mm
 Abstract: 
 Accessors for uniforms.
 
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

#import <cstdarg>

#import "GLSLUnitDictKeys.h"
#import "GLSizes.h"
#import "GLUniform.h"

#pragma mark -
#pragma mark Private - Prototypes

typedef void (*GLUniformSetIntegerVectorFuncPtr)(GLint location, GLsizei count, const GLint *value);

typedef void (*GLUniformSetFloatVectorFuncPtr)(GLint location, GLsizei count, const GLfloat *value);
typedef void (*GLUniformSetFloatMatrixFuncPtr)(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

#pragma mark -
#pragma mark Private - Utilities - Locations

static inline GLint GLUniformGetLocation(NSDictionary *pUniform)
{
    GLint nLocation = -1;
    
    if(pUniform)
    {
        NSNumber *pLocation = [pUniform objectForKey:kGLSLUniformLocKey];
        
        if(pLocation)
        {
            nLocation = [pLocation intValue];
        } // if
    } // if
    
    return nLocation;
} // GLUniformGetLocation

#pragma mark -
#pragma mark Private - Utilities - Templates

template <typename TName>
static inline BOOL GLUniformGetVector(NSDictionary *pUniform,
                                      TName *pVector)
{
    BOOL bSuccess = pVector != NULL;
    
    if(bSuccess)
    {
        NSData *pData = [pUniform objectForKey:kGLSLUniformValueKey];
        
        bSuccess = pData != nil;
        
        if(bSuccess)
        {
            [pData getBytes:pVector];
        } // if
    } // if
    
    return bSuccess;
} // GLUniformGetVector

template <typename TName>
static inline TName *GLUniformCreateVectors(const GLuint nSize,
                                            NSDictionary *pUniform,
                                            GLuint &rCount)
{
    TName *pVector = NULL;
    
    if(nSize)
    {
        NSNumber *pNumber = [pUniform objectForKey:kGLSLUniformCountKey];
        
        if(pNumber)
        {
            rCount = nSize * [pNumber intValue];
            
            if(rCount)
            {
                pVector = new TName[rCount];
            } // if
        } // if
    } // if
    
    return pVector;
} // GLUniformCreateVectors

#pragma mark -
#pragma mark Private - Utilities - Vectors

// Template for GL uniform functor
template <typename TName>
class TGLUniformFunctor
{
private:
    // Pointer to the member function
    void (*mpFunc)(GLint location, GLsizei count, const TName *value);
    
public:
    
    // Construct a functor with a function pointer
    TGLUniformFunctor(void(*pFunc)(GLint location, GLsizei count, const TName *value))
    {
        mpFunc = pFunc;
    }; // Constructor
    
    // Override the "()" operator
    void operator()(const GLuint nSize, NSDictionary *pUniform)
    {
        // The uniform location
        GLint nLocation = GLUniformGetLocation(pUniform);

        if(nLocation > -1)
        {
            // Create a float or an integer vector
            GLuint   nCount  = 0;
            TName   *pVector = GLUniformCreateVectors<TName>(nSize, pUniform, nCount);
            
            // Fill a float or an integer vector
            if(GLUniformGetVector<TName>(pUniform, pVector))
            {
                // Excute the member function for setting a GL uniform
                (*mpFunc)(nLocation, nCount, pVector);
            } // if
            
            // Release a float or an integer vector
            if(pVector != NULL)
            {
                delete [] pVector;
            } // if
        } // if
    }; // Operator ()
}; // TGLUniformFunctor

static inline void GLUniformSetIntegerVectors(const GLuint nSize,
                                              NSDictionary *pUniform,
                                              GLUniformSetIntegerVectorFuncPtr glUniformSetIntegerVectors)
{
    TGLUniformFunctor<GLint> glUniformSetVectors(glUniformSetIntegerVectors);
    
    glUniformSetVectors(nSize, pUniform);
} // GLUniformSetIntegerVectors

static inline void GLUniformSetFloatVectors(const GLuint nSize,
                                            NSDictionary *pUniform,
                                            GLUniformSetFloatVectorFuncPtr glUniformSetFloatVectors)
{
    TGLUniformFunctor<GLfloat> glUniformSetVectors(glUniformSetFloatVectors);
    
    glUniformSetVectors(nSize, pUniform);
} // GLUniformSetFloatVectors

#pragma mark -
#pragma mark Private - Utilities - Matrices

static void GLUniformSetMatrix(const GLuint nSize,
                               NSDictionary *pUniform,
                               GLUniformSetFloatMatrixFuncPtr glUniformSetFloatMatrix)
{
    GLint nLocation = GLUniformGetLocation(pUniform);
    
    if(nLocation > -1)
    {
        GLboolean   bTranspose = GL_FALSE;
        NSNumber   *pTranspose = [pUniform objectForKey:kGLSLUniformTransposeKey];
        
        if(pTranspose)
        {
            bTranspose = [pTranspose intValue];
        } // if
        
        GLuint    nCount  = 0;
        GLfloat  *pVector = GLUniformCreateVectors<GLfloat>(nSize, pUniform, nCount);
        
        if(GLUniformGetVector<GLfloat>(pUniform, pVector))
        {
            glUniformSetFloatMatrix(nLocation, nCount, bTranspose, pVector);
        } // if
        
        if(pVector != NULL)
        {
            delete [] pVector;
        } // if
    } // if
} // GLUniformSetMatrix4fv

#pragma mark -
#pragma mark Public - Utilities - Accessors - Integer Scalars

void GLUniformSet1i(NSDictionary *pUniform)
{
    GLint nLocation = GLUniformGetLocation(pUniform);
    
    if(nLocation > -1)
    {
        NSNumber *pNumber = [pUniform objectForKey:kGLSLUniformValueKey];
        
        if(pNumber)
        {
            GLint  nValue = [pNumber intValue];
            
            glUniform1i(nLocation, nValue);
        } // if
    } // if
} // GLUniformSet1i

void GLUniformSet2i(NSDictionary *pUniform)
{
    GLint nLocation = GLUniformGetLocation(pUniform);
    
    if(nLocation > -1)
    {
        GLint vector[2] = { 0, 0 };
        
        if(GLUniformGetVector<GLint>(pUniform, vector))
        {
            glUniform2i(nLocation, vector[0], vector[1]);
        } // if
    } // if
} // GLUniformSet2i

void GLUniformSet3i(NSDictionary *pUniform)
{
    GLint nLocation = GLUniformGetLocation(pUniform);
    
    if(nLocation > -1)
    {
        GLint vector[3] = { 0, 0, 0 };
        
        if(GLUniformGetVector<GLint>(pUniform, vector))
        {
            glUniform3i(nLocation, vector[0], vector[1], vector[2]);
        } // if
    } // if
} // GLUniformSet3i

void GLUniformSet4i(NSDictionary *pUniform)
{
    GLint nLocation = GLUniformGetLocation(pUniform);
    
    if(nLocation > -1)
    {
        GLint vector[4] = { 0, 0, 0, 0 };
        
        if(GLUniformGetVector<GLint>(pUniform, vector))
        {
            glUniform4i(nLocation, vector[0], vector[1], vector[2], vector[3]);
        } // if
    } // if
} // GLUniformSet4i

#pragma mark -
#pragma mark Public - Utilities - Accessors - Integer Vectors

void GLUniformSet1iv(NSDictionary *pUniform)
{
    GLUniformSetIntegerVectors(1, pUniform, glUniform1iv);
} // GLUniformSet1iv

void GLUniformSet2iv(NSDictionary *pUniform)
{
    GLUniformSetIntegerVectors(2, pUniform, glUniform2iv);
} // GLUniformSet2iv

void GLUniformSet3iv(NSDictionary *pUniform)
{
    GLUniformSetIntegerVectors(3, pUniform, glUniform3iv);
} // GLUniformSet3iv

void GLUniformSet4iv(NSDictionary *pUniform)
{
    GLUniformSetIntegerVectors(4, pUniform, glUniform4iv);
} // GLUniformSet4iv

#pragma mark -
#pragma mark Public - Utilities - Accessors - Float Scalars

void GLUniformSet1f(NSDictionary *pUniform)
{    
    GLint nLocation = GLUniformGetLocation(pUniform);
    
    if(nLocation > -1)
    {
        NSNumber *pNumber = [pUniform objectForKey:kGLSLUniformValueKey];
        
        if(pNumber)
        {
            GLfloat nValue = [pNumber floatValue];
            
            glUniform1f(nLocation, nValue);
        } // if
    } // if
} // GLUniformSet1f

void GLUniformSet2f(NSDictionary *pUniform)
{
    GLint nLocation = GLUniformGetLocation(pUniform);
    
    if(nLocation > -1)
    {
        GLfloat vector[2] = { 0.0f, 0.0f };
        
        if(GLUniformGetVector<GLfloat>(pUniform, vector))
        {
            glUniform2f(nLocation, vector[0], vector[1]);
        } // if
    } // if
} // GLUniformSet2f

void GLUniformSet3f(NSDictionary *pUniform)
{
    GLint nLocation = GLUniformGetLocation(pUniform);
    
    if(nLocation > -1)
    {
        GLfloat vector[3] = { 0.0f, 0.0f, 0.0f };
        
        if(GLUniformGetVector<GLfloat>(pUniform, vector))
        {
            glUniform3f(nLocation, vector[0], vector[1], vector[2]);
        } // if
    } // if
} // GLUniformSet3f

void GLUniformSet4f(NSDictionary *pUniform)
{
    GLint nLocation = GLUniformGetLocation(pUniform);
    
    if(nLocation > -1)
    {
        GLfloat vector[4] = { 0.0f, 0.0f, 0.0f, 0.0f };
        
        if(GLUniformGetVector<GLfloat>(pUniform, vector))
        {
            glUniform4f(nLocation, vector[0],  vector[1], vector[2], vector[3]);
        } // if
    } // if
} // GLUniformSet4f

#pragma mark -
#pragma mark Public - Utilities - Accessors - Float Vectors

void GLUniformSet1fv(NSDictionary *pUniform)
{
    GLUniformSetFloatVectors(1, pUniform, glUniform4fv);
} // GLUniformSet1fv

void GLUniformSet2fv(NSDictionary *pUniform)
{
    GLUniformSetFloatVectors(2, pUniform, glUniform4fv);
} // GLUniformSet2fv

void GLUniformSet3fv(NSDictionary *pUniform)
{
    GLUniformSetFloatVectors(3, pUniform, glUniform4fv);
} // GLUniformSet3fv

void GLUniformSet4fv(NSDictionary *pUniform)
{
    GLUniformSetFloatVectors(4, pUniform, glUniform4fv);
} // GLUniformSet4fv

#pragma mark -
#pragma mark Public - Utilities - Accessors - Float Matrices

void GLUniformSet2x2fv(NSDictionary *pUniform)
{
    GLUniformSetMatrix(4, pUniform, glUniformMatrix2fv);
} // GLUniformSet2x2fv

void GLUniformSet3x3fv(NSDictionary *pUniform)
{
    GLUniformSetMatrix(9, pUniform, glUniformMatrix3fv);
} // GLUniformSet3x3fv

void GLUniformSet4x4fv(NSDictionary *pUniform)
{
    GLUniformSetMatrix(16, pUniform, glUniformMatrix4fv);
} // GLUniformSet4x4fv
