/*
     File: GLUGaussian.mm
 Abstract: 
 Utility methods for creating a Gaussian texture.
 
  Version: 3.1
 
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

#pragma mark -
#pragma mark Private - Headers

#import <cmath>
#import <iostream>

#import <OpenGL/gl.h>

#import "GLUGaussian.h"

#pragma mark -
#pragma mark Private - Utilities - Gaussian Map

static GLfloat GLUHermiteBasis(const GLfloat& pA,
                               const GLfloat& pB,
                               const GLfloat& vA,
                               const GLfloat& vB,
                               const GLfloat& u1)
{
    GLfloat u2 = u1 * u1;
    GLfloat u3 = u2 * u1;
    GLfloat B0 = 2.0f * u3 - 3.0f * u2 + 1.0f;
    GLfloat B1 = -2.0f * u3 + 3.0f * u2;
    GLfloat B2 = u3 - 2.0f * u2 + u1;
    GLfloat B3 = u3 - u1;
    
    return( B0 * pA + B1 * pB + B2 * vA + B3 * vB );
} // GLUHermiteBasis

static GLubyte* GLUGaussianCreateImage(const GLuint& nTexRes)
{
    GLubyte *pImage = NULL;

    if(nTexRes)
    {
        GLuint nCardinality = nTexRes * nTexRes;
        
        GLfloat *pMap = NULL;
        
        try
        {
            pMap = new GLfloat[2 * nCardinality];
        } // try
        catch(std::bad_alloc& ba)
        {
            NSLog(@">> ERROR: Failed allocating backing-store for Gaussian map: \"%s\"", ba.what());
            
            return NULL;
        } // catch
        
        try
        {
            pImage = new GLubyte[nCardinality];
        } // try
        catch(std::bad_alloc& ba)
        {
            NSLog(@">> ERROR: Failed allocating backing-store for Gaussian image: \"%s\"", ba.what());
            
            delete [] pMap;
            
            return NULL;
        } // catch
        
        GLfloat  X      = -1.0f;
        GLfloat  Y      = -1.0f;
        GLfloat  Y2     =  0.0f;
        GLfloat  nDist  =  0.0f;
        GLfloat  nDelta =  2.0f / GLfloat(nTexRes);
        
        GLint i = 0;
        GLint j = 0;
        GLint x;
        GLint y;

        for(y = 0; y < nTexRes; ++y, Y += nDelta)
        {
            Y2 = Y * Y;

            for(x = 0; x < nTexRes; ++x, X += nDelta, i += 2, ++j)
            {
                nDist = std::sqrtf(X * X + Y2);
                
                if(nDist > 1.0f)
                {
                    nDist = 1.0f;
                } // if
                
                pMap[i]   = GLUHermiteBasis(1.0f, 0.0f, 0.0f, 0.0f, nDist);
                pMap[i+1] = pMap[i];
                
                pImage[j] = GLubyte(pMap[i] * 255.0f);
            } // for
            
            X  = -1.0f;
        } // for

        delete [] pMap;
        
        pMap = NULL;
    } // if
    
    return pImage;
} // GLUGaussianCreateImage

#pragma mark -
#pragma mark Private - Utilities - Constructors

static GLuint GLUGaussianCreateTexture(const GLsizei& nTexRes)
{
    GLuint texture = 0;
    
    GLubyte *pImage = GLUGaussianCreateImage(nTexRes);

    if(pImage != NULL)
    {
        glGenTextures(1, &texture);
        
        if(texture)
        {
            glBindTexture(GL_TEXTURE_2D, texture);

            glTexParameteri(GL_TEXTURE_2D, GL_GENERATE_MIPMAP_SGIS, GL_TRUE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            
            glTexImage2D(GL_TEXTURE_2D,
                         0,
                         GL_LUMINANCE8,
                         nTexRes,
                         nTexRes,
                         0,
                         GL_LUMINANCE,
                         GL_UNSIGNED_BYTE,
                         pImage);
        } // if
        
        delete [] pImage;
        
        pImage = NULL;
    } // if
    
    return texture;
} // GLUGaussianCreateTexture

#pragma mark -
#pragma mark Public - Interfaces

GLU::Gaussian::Gaussian(const GLuint& nTexRes)
{
    mnTarget  = GL_TEXTURE_2D;
    mnTexRes  = nTexRes;
    mnTexture = GLUGaussianCreateTexture(mnTexRes);
} // Constructor

GLU::Gaussian::~Gaussian()
{
    if(mnTexture)
    {
        glDeleteTextures(1, &mnTexture);
        
        mnTexture = 0;
    } // if
} // Destructor

GLU::Gaussian::Gaussian(const GLU::Gaussian::Gaussian& rTexture)
{
    mnTarget  = rTexture.mnTarget;
    mnTexRes  = rTexture.mnTexRes;
    mnTexture = GLUGaussianCreateTexture(mnTexRes);
} // Copy Constructor

GLU::Gaussian& GLU::Gaussian::operator=(const GLU::Gaussian& rTexture)
{
    if(this != &rTexture)
    {
        if(mnTexture)
        {
            glDeleteTextures(1, &mnTexture);
            
            mnTexture = 0;
        } // if
        
        mnTarget  = rTexture.mnTarget;
        mnTexRes  = rTexture.mnTexRes;
        mnTexture = GLUGaussianCreateTexture(mnTexRes);
    } // if
    
    return *this;
} // Operator =

void GLU::Gaussian::enable()
{
    glBindTexture(mnTarget, mnTexture);
} // enable

void GLU::Gaussian::disable()
{
    glBindTexture(mnTarget, 0);
} // disable

const GLuint& GLU::Gaussian::texture() const
{
    return mnTexture;
} // texture

const GLenum& GLU::Gaussian::target()  const
{
    return mnTarget;
} // target
