/*
     File: GLUText.mm
 Abstract: 
 Utility methods for generating OpenGL texture from a string.
 
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

#import <OpenGL/gl.h>

#import "CFText.h"

#import "GLUText.h"

#pragma mark -
#pragma mark Private - Constants

static const GLuint kGLUTextBPC = 8;
static const GLuint kGLUTextSPP = 4;

static const CGBitmapInfo kGLUTextBitmapInfo = kCGImageAlphaPremultipliedLast;

#pragma mark -
#pragma mark Private - Utilities - Constructors - Contexts

CGContextRef GLU::Text::create(const GLsizei& nWidth,
                               const GLsizei& nHeight)
{
    CGContextRef pContext = NULL;
    
    if(nWidth * nHeight)
    {
        CGColorSpaceRef pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
        
        if(pColorspace != NULL)
        {
            const size_t bpp = nWidth * kGLUTextSPP;
            
            pContext = CGBitmapContextCreate(NULL,
                                             nWidth,
                                             nHeight,
                                             kGLUTextBPC,
                                             bpp,
                                             pColorspace,
                                             kGLUTextBitmapInfo);
            
            if(pContext != NULL)
            {
                CGContextSetShouldAntialias(pContext, true);
            } // if
            
            CFRelease(pColorspace);
        } // if
    } // if
    
    return pContext;
} // create

CGContextRef GLU::Text::create(const CGSize& rSize)
{
    return create(GLsizei(rSize.width), GLsizei(rSize.height));
} // create

#pragma mark -
#pragma mark Private - Utilities - Constructors - Texturers

GLuint GLU::Text::create(CGContextRef pContext)
{
    GLuint texture = 0;
    
    glGenTextures(1, &texture);
    
    if(texture)
    {
        glBindTexture(GL_TEXTURE_2D, texture);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        const GLsizei  width  = GLsizei(CGBitmapContextGetWidth(pContext));
        const GLsizei  height = GLsizei(CGBitmapContextGetHeight(pContext));
        const void    *pData  = CGBitmapContextGetData(pContext);
        
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_RGBA,
                     width,
                     height,
                     0,
                     GL_RGBA,
                     GL_UNSIGNED_BYTE,
                     pData);
    } // if
    
    return texture;
} // create

GLuint GLU::Text::create(const GLstring& rText,
                         const GLstring& rFont,
                         const GLfloat& nFontSize,
                         const CGPoint& rOrigin,
                         const CTTextAlignment& nTextAlign)
{
    GLuint nTexture = 0;
    
    mpFrame = new CT::Frame(rText, rFont, nFontSize, rOrigin, nTextAlign);
    
    if(mpFrame != NULL)
    {
        const CGRect bounds = mpFrame->bounds();
        
        CGContextRef pContext = create(bounds.size);
        
        if(pContext != NULL)
        {
            mpFrame->draw(pContext);
            
            nTexture = create(pContext);
            
            CFRelease(pContext);
        } // if
    } // if
    
    return nTexture;
} // create

GLuint GLU::Text::create(const GLstring& rText,
                         const GLstring& rFont,
                         const GLfloat& nFontSize,
                         const GLsizei& nWidth,
                         const GLsizei& nHeight,
                         const CTTextAlignment& nTextAlign)
{
    GLuint nTexture = 0;
    
    mpFrame = new CT::Frame(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign);
    
    if(mpFrame != NULL)
    {
        CGContextRef pContext = create(nWidth, nHeight);
        
        if(pContext != NULL)
        {
            mpFrame->draw(pContext);
            
            nTexture = create(pContext);
            
            CFRelease(pContext);
        } // if
    } // if
    
    return nTexture;
} // create

#pragma mark -
#pragma mark Public - Constructors

// Create a texture with bounds derived from the text size.
GLU::Text::Text(const GLstring& rText,
                const GLstring& rFont,
                const GLfloat& nFontSize,
                const CGPoint& rOrigin,
                const CTTextAlignment& nTextAlign)
{
    mpFrame   = NULL;
    mnTexture = create(rText, rFont, nFontSize, rOrigin, nTextAlign);
} // Constructor

// Create a texture with bounds derived from the input width and height.
GLU::Text::Text(const GLstring& rText,
                const GLstring& rFont,
                const GLfloat& nFontSize,
                const GLsizei& nWidth,
                const GLsizei& nHeight,
                const CTTextAlignment& nTextAlign)
{
    mpFrame   = NULL;
    mnTexture = create(rText, rFont, nFontSize, nWidth, nHeight, nTextAlign);
} // Constructor

// Create a texture with bounds derived from the text size using
// helvetica bold or helvetica bold oblique font.
GLU::Text::Text(const GLstring& rText,
                const CGFloat& nFontSize,
                const bool& bIsItalic,
                const CGPoint& rOrigin,
                const CTTextAlignment& nTextAlign)
{
    GLstring font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold";
    
    mpFrame   = NULL;
    mnTexture = create(rText, font, nFontSize, rOrigin, nTextAlign);
} // Constructor

// Create a texture with bounds derived from input width and height,
// and using helvetica bold or helvetica bold oblique font.
GLU::Text::Text(const GLstring& rText,
                const CGFloat& nFontSize,
                const bool& bIsItalic,
                const GLsizei& nWidth,
                const GLsizei& nHeight,
                const CTTextAlignment& nTextAlign)
{
    GLstring font = bIsItalic ? "Helvetica-BoldOblique" : "Helvetica-Bold";
    
    mpFrame   = NULL;
    mnTexture = create(rText, font, nFontSize, nWidth, nHeight, nTextAlign);
} // Constructor

#pragma mark -
#pragma mark Public - Destructor

GLU::Text::~Text()
{
    if(mnTexture)
    {
        glDeleteTextures(1, &mnTexture);
        
        mnTexture = 0;
    } // if
    
    if(mpFrame != NULL)
    {
        delete mpFrame;
        
        mpFrame = NULL;
    } // if
} // Destructor

#pragma mark -
#pragma mark Public - Accessors

const GLuint& GLU::Text::texture() const
{
    return mnTexture;
} // texture

const CGRect& GLU::Text::bounds() const
{
    return mpFrame->bounds();
} // bounds

const CFRange& GLU::Text::range() const
{
    return mpFrame->range();
} // range
