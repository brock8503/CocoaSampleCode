/*
     File: GLUTexture.mm
 Abstract: 
 Utility methods for creating 2D OpenGL textures.
 
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

#import <OpenGL/gl.h>

#import "CFIFStream.h"

#import "GLUTexture.h"

#pragma mark -
#pragma mark Private - Utilities - Constructors

static GLuint GLUTextureCreate(const GLenum& target,
                               const GLsizei& width,
                               const GLsizei& height,
                               const bool&  mipmap,
                               const void * const pData)
{
    GLuint texture = 0;
    
    glEnable(target);
    {
        glGenTextures(1, &texture);
        
        if(texture)
        {
            glBindTexture(target, texture);
            
            if(mipmap)
            {
                glTexParameteri(target, GL_GENERATE_MIPMAP, GL_TRUE);
                glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            } // if
            else
            {
                glTexParameteri(target, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            } // else
            
            glTexParameteri(target, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameteri(target, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(target, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            
            glTexImage2D(target,
                         0,
                         GL_RGBA,
                         GLsizei(width),
                         GLsizei(height),
                         0,
                         GL_RGBA,
                         GL_UNSIGNED_BYTE,
                         pData);
        } // if
    }
    glDisable(target);
    
    return texture;
} // GLUTextureCreate

static void GLUTextureUpdate(const GLuint& texture,
                             const GLenum& target,
                             const GLsizei& width,
                             const GLsizei& height,
                             const void * const pData)
{
    glBindTexture(target, texture);
    
    glTexSubImage2D(target, 0, 0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, pData);
} // GLUTextureUpdate

#pragma mark -
#pragma mark Public - Interfaces

GLU::Texture::Texture(CFStringRef   pName,
                      CFStringRef   pExt,
                      const GLenum& nTarget,
                      const bool&   bMipmap)
try
{
    mpBitmap = new CG::Bitmap(pName, pExt);
    
    const void *pData = mpBitmap->data();
    
    mbMipmaps = bMipmap;
    mnTarget  = nTarget;
    mnWidth   = GLsizei(mpBitmap->width());
    mnHeight  = GLsizei(mpBitmap->height());
    mnTexture = GLUTextureCreate(mnTarget, mnWidth, mnHeight, mbMipmaps, pData);
} // Constructor
catch(std::bad_alloc& ba)
{
    NSLog(@">> ERROR: Failed allocating memory for the bitmap context: \"%s\"", ba.what());
} // catch

GLU::Texture::~Texture()
{
    if(mnTexture)
    {
        glDeleteTextures(1, &mnTexture);
        
        mnTexture = 0;
    } // if
    
    if(mpBitmap != NULL)
    {
        delete mpBitmap;
        
        mpBitmap = NULL;
    } // if
} // Destructor

GLU::Texture::Texture(const GLU::Texture::Texture& rTexture)
{
    mnTarget  = rTexture.mnTarget;
    mbMipmaps = rTexture.mbMipmaps;
    mnWidth   = rTexture.mnWidth;
    mnHeight  = rTexture.mnHeight;
    mpBitmap  = new CG::Bitmap(rTexture.mpBitmap);
    
    const void *pData = mpBitmap->data();
    
    mnTexture = GLUTextureCreate(mnTarget, mnWidth, mnHeight, mbMipmaps, pData);
} // Copy Constructor

GLU::Texture& GLU::Texture::operator=(const GLU::Texture& rTexture)
{
    if(this != &rTexture)
    {
        const void *pData = NULL;
        
        if(rTexture.mpBitmap != NULL)
        {
            bool bSuccess = (rTexture.mnWidth  == mnWidth) && (rTexture.mnHeight == mnHeight);
            
            if(bSuccess)
            {
                const CGContextRef pContext = rTexture.mpBitmap->context();
                
                bSuccess = mpBitmap->copy(pContext);
            } // if
            
            if(!bSuccess)
            {
                CG::Bitmap* pBitmap = NULL;
                
                try
                {
                    pBitmap = new CG::Bitmap(rTexture.mpBitmap);
                } // Constructor
                catch(std::bad_alloc& ba)
                {
                    NSLog(@">> ERROR: Failed allocating memory for a copy of bitmap context: \"%s\"", ba.what());
                    
                    return *this;
                } // catch

                if(mpBitmap != NULL)
                {
                    delete mpBitmap;
                    
                    mpBitmap = NULL;
                } // if
                
                mpBitmap = pBitmap;
            } // else
            
            pData = mpBitmap->data();
        } // if
        
        bool bTarget = mnTarget  == rTexture.mnTarget;
        bool bMipmap = mbMipmaps == rTexture.mbMipmaps;
        
        if(bTarget && bMipmap)
        {
            GLUTextureUpdate(mnTexture, mnTarget, mnWidth, mnHeight, pData);
        } // if
        else
        {
            glDeleteTextures(1, &mnTexture);
            
            mnTarget  = rTexture.mnTarget;
            mbMipmaps = rTexture.mbMipmaps;
            mnWidth   = rTexture.mnWidth;
            mnHeight  = rTexture.mnHeight;
            mnTexture = GLUTextureCreate(mnTarget, mnWidth, mnHeight, mbMipmaps, pData);
        } // else
    } // if
    
    return *this;
} // Operator =

void GLU::Texture::enable()
{
    glBindTexture(mnTarget, mnTexture);
} // enable

void GLU::Texture::disable()
{
    glBindTexture(mnTarget, 0);
} // disable

const GLuint& GLU::Texture::texture() const
{
    return mnTexture;
} // texture

const GLenum& GLU::Texture::target()  const
{
    return mnTarget;
} // target
