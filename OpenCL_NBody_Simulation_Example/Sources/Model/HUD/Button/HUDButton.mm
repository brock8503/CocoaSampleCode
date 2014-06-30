/*
     File: HUDButton.mm
 Abstract: 
 Utility class for generating a button in an OpenGL view.
 
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
#pragma mark Private - Utilities

#import <cstdlib>
#import <cmath>

#import <unordered_map>

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

#import "CFText.h"

#import "GLUText.h"
#import "GLUTexture.h"

#import "HUDButton.h"

#pragma mark -
#pragma mark Private - Enumerated Types

enum HUDTextureTypes
{
    eHUDMeterBackground = 0,
    eHUDMeterNeedle,
    eHUDMeterLegend,
    eHUDMeterMax
};

#pragma mark -
#pragma mark Private - Constants

static const CGBitmapInfo kHUDBitmapInfo = kCGImageAlphaPremultipliedLast;

static const GLuint kHUDBitsPerComponent = 8;
static const GLuint kHUDSamplesPerPixel  = 4;

static const GLfloat kHUDCenterX = 0.5f;
static const GLfloat kHUDCenterY = 0.5f;

#pragma mark -
#pragma mark Private - Containers

static std::unordered_map<std::string, GLuint> HUDCreateTextureWithLabels;

#pragma mark -
#pragma mark Private - Utilities

static void HUDAddRoundedRectToPath(CGContextRef context,
                                    const CGRect& rect,
                                    const GLfloat& ovalWidth,
                                    const GLfloat& ovalHeight)
{
    if((ovalWidth == 0.0f) || (ovalHeight == 0.0f))
    {
        CGContextAddRect(context, rect);
        
        return;
    } // if
    
    CGContextSaveGState(context);
    {
        CGContextTranslateCTM(context,
                              CGRectGetMinX(rect),
                              CGRectGetMinY(rect));
        
        CGContextScaleCTM(context, ovalWidth, ovalHeight);
        
        GLfloat fw = CGRectGetWidth(rect) / ovalWidth;
        GLfloat fh = CGRectGetHeight(rect) / ovalHeight;
        
        CGContextMoveToPoint(context, fw, fh / 2.0f);
        {
            CGContextAddArcToPoint(context, fw, fh, fw / 2.0f, fh, 1.0f);
            CGContextAddArcToPoint(context, 0.0f, fh, 0.0f, fh / 2.0f, 1.0f);
            CGContextAddArcToPoint(context, 0.0f, 0.0f, fw / 2.0f, 0.0f, 1.0f);
            CGContextAddArcToPoint(context, fw, 0.0f, fw, fh / 2.0f, 1.0f);
        }
        CGContextClosePath(context);
    }
    CGContextRestoreGState(context);
} // HUDAddRoundedRectToPath

static GLuint HUDButtonCreateTexture(const CGSize& rSize)
{
    GLuint texture = 0;
    
    glGenTextures(1, &texture);
    
    if(texture)
    {
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture);
        {
            CGColorSpaceRef pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            
            if(pColorspace != NULL)
            {
                const GLsizei width  = GLsizei(rSize.width);
                const GLsizei height = GLsizei(rSize.height);
                const size_t bpp     = width * kHUDSamplesPerPixel;
                
                CGContextRef pContext = CGBitmapContextCreate(NULL,
                                                              width,
                                                              height,
                                                              kHUDBitsPerComponent,
                                                              bpp,
                                                              pColorspace,
                                                              kHUDBitmapInfo);
                
                if(pContext != NULL)
                {
                    GLfloat cx = kHUDCenterX * rSize.width;
                    GLfloat cy = kHUDCenterY * rSize.height;
                    GLfloat sx = 0.05f * rSize.width;
                    GLfloat sy = 0.5f  * rSize.height - 32.0f;
                    
                    CGRect bound = CGRectMake(sx, sy, 0.9f * rSize.width, 64.0f);
                    
                    // background
                    CGContextTranslateCTM(pContext, 0.0f, height);
                    CGContextScaleCTM(pContext, 1.0f, -1.0f);
                    CGContextClearRect(pContext, CGRectMake(0, 0.0f, width, height));
                    CGContextSetRGBFillColor(pContext, 0.0f, 0.0f, 0.0f, 0.8f);
                    
                    HUDAddRoundedRectToPath(pContext, bound, 32.0f, 32.0f);
                    
                    CGContextFillPath(pContext);
                    
                    // top bevel
                    CGContextSaveGState(pContext);
                    {
                        size_t count = 2;
                        
                        CGFloat locations[2] = { 0.0f, 1.0f };
                        
                        CGFloat components[8] =
                        {
                            1.0f, 1.0f, 1.0f, 0.5f,  // Start color
                            0.0f, 0.0f, 0.0f, 0.0f
                        }; // End color
                        
                        HUDAddRoundedRectToPath(pContext, bound, 32.0f, 32.0f);
                        
                        CGContextEOClip(pContext);
                        
                        CGGradientRef pGradient = CGGradientCreateWithColorComponents(pColorspace,
                                                                                      components,
                                                                                      locations,
                                                                                      count);
                        
                        
                        if(pGradient != NULL)
                        {
                            CGContextDrawLinearGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(cx, cy + 32.0f),
                                                        CGPointMake(cx, cy),
                                                        0.0f);
                            
                            CGContextDrawLinearGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(cx, cy - 32.0f),
                                                        CGPointMake(cx, cy - 16.0f),
                                                        0.0f);
                            
                            CFRelease(pGradient);
                        } // if
                    }
                    CGContextRestoreGState(pContext);
                    
                    const void *pData = CGBitmapContextGetData(pContext);
                    
                    glTexImage2D(GL_TEXTURE_RECTANGLE_ARB,
                                 0,
                                 GL_RGBA,
                                 width,
                                 height,
                                 0,
                                 GL_RGBA,
                                 GL_UNSIGNED_BYTE,
                                 pData);
                    
                    CFRelease(pContext);
                } // if
                
                CFRelease(pColorspace);
            } // if
        }
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
    } // if
    
    return texture;
} // HUDButtonCreateTexture

#pragma mark -
#pragma mark Public - Button - Utilities

HUD::Button::Image::Image(const CGRect& rBounds,
                          const CGFloat& size)
{
    if(!CGRectIsEmpty(rBounds))
    {
        m_Bounds     = rBounds;
        mbIsItalic   = false;
        mnSize       = (size > 12.0f) ? size : 24.0f;
        m_Label      = "";
        mnWidth      = GLsizei(rBounds.size.width  + 0.5f);
        mnHeight     = GLsizei(rBounds.size.height + 0.5f);
        m_Texture[0] = HUDButtonCreateTexture(rBounds.size);
        m_Texture[1] = 0;
        mpText       = NULL;
        mpQuad       = GLU::QuadCreate(GL_DYNAMIC_DRAW);
    } // if
} // Constructor

HUD::Button::Image::Image(const CGRect& rBounds,
                          const CGFloat& size,
                          const bool& italic,
                          const HUD::Button::Label& label)
{
    if(!CGRectIsEmpty(rBounds))
    {
        m_Bounds     = rBounds;
        mnWidth      = GLsizei(rBounds.size.width  + 0.5f);
        mnHeight     = GLsizei(rBounds.size.height + 0.5f);
        mbIsItalic   = italic;
        mnSize       = (size > 12.0f) ? size : 24.0f;
        m_Label      = label;
        mpQuad       = GLU::QuadCreate(GL_DYNAMIC_DRAW);
        mpText       = new GLU::Text(m_Label, mnSize, mbIsItalic, mnWidth, mnHeight);
        m_Texture[1] = mpText->texture();
        m_Texture[0] = HUDButtonCreateTexture(rBounds.size);
    } // if
} // Constructor

HUD::Button::Image::~Image()
{
    if(m_Texture[0])
    {
        glDeleteTextures(1, &m_Texture[0]);
        
        m_Texture[0] = 0;
    } // if
    
    if(mpText != NULL)
    {
        delete mpText;
        
        mpText = NULL;
    } // if
    
    GLU::QuadRelease(mpQuad);
    
    mpQuad = NULL;
} // Destructor

bool HUD::Button::Image::setLabel(const HUD::Button::Label& label)
{
    if(mpText != NULL)
    {
        GLU::Text *pText = new GLU::Text(m_Label, mnSize, mbIsItalic, mnWidth, mnHeight);
        
        if(pText != NULL)
        {
            delete mpText;
            
            m_Label      = label;
            mpText       = pText;
            m_Texture[1] = mpText->texture();
        } // if
    } // if
    
    return m_Texture[1] != 0;
} // NBodySetSimulatorDescription

void HUD::Button::Image::draw(const bool& selected,
                              const HUD::Button::Position& position,
                              const HUD::Button::Bounds& bounds)
{
    glPushMatrix();
    {
        glTranslatef(position.x, position.y, 0.0f);
        
        glColor3f(1.0f, 1.0f, 1.0f);
        
        glEnable(GL_TEXTURE_RECTANGLE_ARB);
        {
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB, m_Texture[0]);
            {
                glMatrixMode(GL_TEXTURE);
                
                glPushMatrix();
                {
                    glLoadIdentity();
                    glScalef(bounds.size.width, bounds.size.height, 1.0f);
                    
                    glMatrixMode(GL_MODELVIEW);
                    
                    if(selected)
                    {
                        glColor3f(0.5f, 0.5f, 0.5f);
                    } // if
                    else
                    {
                        glColor3f(0.3f, 0.3f, 0.3f);
                    } // else
                    
                    GLU::QuadSetIsInverted(false, mpQuad);
                    GLU::QuadSetBounds(bounds, mpQuad);
                    
                    if(!GLU::QuadIsFinalized(mpQuad))
                    {
                        GLU::QuadFinalize(mpQuad);
                    } // if
                    else
                    {
                        GLU::QuadUpdate(mpQuad);
                    } // else
                    
                    GLU::QuadDraw(mpQuad);
                    
                    glMatrixMode(GL_TEXTURE);
                }
                glPopMatrix();
                
                glMatrixMode(GL_MODELVIEW);
            }
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
        }
        glDisable(GL_TEXTURE_RECTANGLE_ARB);
        
        glEnable(GL_TEXTURE_2D);
        {
            glBindTexture(GL_TEXTURE_2D, m_Texture[1]);
            {
                if(selected)
                {
                    glColor3f(0.4f, 0.7f, 1.0f);
                } // if
                else
                {
                    glColor3f(0.85f, 0.2f, 0.2f);
                } // else
                
                glTranslatef(0.0f, -10.0f, 0.0f);
                
                GLU::QuadSetIsInverted(true, mpQuad);
                GLU::QuadSetBounds(bounds, mpQuad);
                
                GLU::QuadUpdate(mpQuad);
                GLU::QuadDraw(mpQuad);
                
                glTranslatef(0.0f, 10.0f, 0.0f);
                
                glColor3f(1.0f, 1.0f, 1.0f);
            }
            glBindTexture(GL_TEXTURE_2D, 0);
        }
        glDisable(GL_TEXTURE_2D);
    }
    glPopMatrix();
} // Draw
