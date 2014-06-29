/*
     File: HUDMeterImage.mm
 Abstract: 
 Utility class for generating and manging an OpenGl based 2D meter.
 
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

#import <Cocoa/Cocoa.h>
#import <OpenGL/gl.h>

#import "CTFrame.h"

#import "GLMConstants.h"

#import "GLUText.h"
#import "GLUTexture.h"

#import "HUDMeterImage.h"

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

static const CGFloat kHUDTicks_f    = 8.0f;
static const CGFloat kHUDSubTicks_f = 4.0f;

static const GLint kHUDTicks           = 8;
static const GLint kHUDSubTicks        = 4;
static const GLint kHUDNeedleThickness = 12;
static const GLint kHUDOffscreen       = 5000;

static const GLuint kHUDBitsPerComponent = 8;
static const GLuint kHUDSamplesPerPixel  = 4;

static const GLfloat kHUDCenterX      = 0.5f;
static const GLfloat kHUDCenterY      = 0.5f;
static const GLfloat kHUDLegendWidth  = 256.0f;
static const GLfloat kHUDLegendHeight = 64.0f;
static const GLfloat kHUDValueWidth   = 128.0f;
static const GLfloat kHUDValueHeight  = 64.0f;

#pragma mark -
#pragma mark Private - Utilities

static HUD::Meter::String HUDInteger2String(const GLuint& i)
{
    GLchar buffer[16];
    
    sprintf(buffer, "%u", i);
    
    return HUD::Meter::String(buffer);
} // HUDInteger2String

GLuint HUDEmplaceTextureWithLabel(const GLuint& nKey,
                                  HUD::Meter::Hash &rHash)
{
    GLuint nTexture = 0;
    
    HUD::Meter::String key = HUDInteger2String(nKey);
    
    GLU::Text *pValue = NULL;
    
    try
    {
        pValue = new GLU::Text(key, 52.0f, true, kHUDValueWidth, kHUDValueHeight);
    }
    catch(std::bad_alloc& ba)
    {
        NSLog(@">> ERROR: Failed acquiring an OpenGL text label: \"%s\"", ba.what());
        
        return 0;
    } // catch
    
    rHash.emplace(key, pValue);
    
    nTexture = pValue->texture();
    
    return nTexture;
} // HUDEmplaceTextureWithLabel

static void HUDDrawMark(CGContextRef pContext,
                        const CGPoint& rOrigin,
                        const std::string& rText,
                        const std::string& rFont,
                        const GLfloat& nFontSize,
                        const CTTextAlignment& nTextAlign)
{
    CT::Frame  *pFrame = NULL;
    
    try
    {
        pFrame = new CT::Frame(rText, rFont, nFontSize, rOrigin, nTextAlign);
    }
    catch(std::bad_alloc& ba)
    {
        NSLog(@">> ERROR: Failed acquiring a CoreText label: \"%s\"", ba.what());
        
        return;
    } // catch
    
    pFrame->draw(pContext);
    
    delete pFrame;
    
    pFrame = NULL;
} // HUDDrawMark

static void HUDDrawMarks(CGContextRef pContext,
                         const CGPoint& center,
                         const size_t& iMax,
                         const CGFloat& needle,
                         const CGFloat& fontSize,
                         const std::string& font,
                         const CTTextAlignment& textAlign)
{
    CGFloat radial = 0.82f * needle;
    CGFloat angle  = 0.0f;
    
    CGPoint delta;
    CGPoint origin;
    CGPoint coord;
    
    GLchar text[5]= {0x0, 0x0, 0x0, 0x0, '\0'};
    
    size_t i;
    
    const size_t iDelta = iMax / kHUDTicks;
    
    for(i = 0 ; i <= iMax ; i += iDelta)
    {
        sprintf(text, "%ld", i);
        
        // hardcoded text centering for this font size
        if(i > 199)
        {
            delta.x = -18.0f;
        } // if
        else if(i > 99)
        {
            delta.x = -17.0f;
        } // else if
        else if(i > 0)
        {
            delta.x = -14.0f;
        } // else if
        else
        {
            delta.x = -12.0f;
        } // else
        
        delta.y = -6.0f;
        
        angle = GLM::k4PiDiv3_f * i / iMax - GLM::kPiDiv6_f;
        
        coord.x = radial * std::cos(angle);
        coord.y = radial * std::sin(angle);
        
        origin.x = center.x - coord.x + delta.x;
        origin.y = center.y + coord.y + delta.y;
        
        HUDDrawMark(pContext, origin, text, font, fontSize, textAlign);
        
        text[0]= 0x0;
        text[1]= 0x0;
        text[2]= 0x0;
        text[3]= 0x0;
    } // for
} // HUDDrawMarks

static void HUDDrawMarks(CGContextRef pContext,
                         const GLsizei& width,
                         const GLsizei& height,
                         const size_t& max)
{
    CGFloat  angle, c, s, tick;
    CGFloat  r0, r1, r2, r3;
    GLint    i, start, end, section;
    
    CGPoint center = CGPointMake(kHUDCenterX * CGFloat(width),
                                 kHUDCenterY * CGFloat(height));
    
    CGFloat redline = kHUDTicks_f * kHUDSubTicks_f * 0.8f;
    CGFloat radius  = 0.5f * (width > height ? width : height);
    CGFloat needle  = radius * 0.85f;
    
    for(section = 0; section < 2; section++)
    {
        start = section ? redline + 1 : 0;
        end   = section ? kHUDTicks * kHUDSubTicks : redline;
        
        if (section)
        {
            CGContextSetRGBStrokeColor(pContext, 1.0f, 0.1f, 0.1f, 1.0f);
        } // if
        else
        {
            CGContextSetRGBStrokeColor(pContext, 0.9f, 0.9f, 1.0f, 1.0f);
        } // else
        
        // inner tick ring
        r0 = 0.97f * needle;
        r1 = 1.04f * needle;
        r2 = 1.00f * needle;
        r3 = 1.01f * needle;
        
        for(i = start; i <= end ; ++i)
        {
            tick  = i / (kHUDSubTicks_f * kHUDTicks_f);
            angle = GLM::k4PiDiv3_f * tick  -  GLM::kPiDiv6_f;
            
            c = std::cos(angle);
            s = std::sin(angle);
            
            if(i % kHUDSubTicks != 0)
            {
                CGContextMoveToPoint(pContext, center.x - r0 * c, center.y + r0 * s);
                CGContextAddLineToPoint(pContext, center.x - r1 * c, center.y + r1 * s);
            }
            else
            {
                CGContextMoveToPoint(pContext, center.x - r2 * c, center.y + r2 * s);
                CGContextAddLineToPoint(pContext, center.x - r3 * c, center.y + r3 * s);
            }
        } // for
        
        CGContextSetLineWidth(pContext, 2.0f);
        CGContextStrokePath(pContext);
        
        // outer tick ring
        start = (start / kHUDSubTicks) + section;
        end   = end / kHUDSubTicks;
        
        r0 = 1.05f * needle;
        r1 = 1.14f * needle;
        
        for(i = start; i <= end ; ++i)
        {
            tick  = i / kHUDTicks_f;
            angle = GLM::k4PiDiv3_f * tick - GLM::kPiDiv6_f;
            
            c = std::cos(angle);
            s = std::sin(angle);
            
            CGContextMoveToPoint(pContext, center.x - r0 * c, center.y + r0 * s);
            CGContextAddLineToPoint(pContext, center.x - r1 * c, center.y + r1 * s);
        } // for
        
        CGContextSetLineWidth(pContext, 3.0f);
        CGContextStrokePath(pContext);
    } // for
    
    HUDDrawMarks(pContext,
                 center,
                 max,
                 needle,
                 18.0f,
                 "Helvetica-Bold",
                 kCTTextAlignmentCenter);
} // HUDDrawMarks

static void HUDAcquireShadowWithColor(CGContextRef pContext,
                                      CGSize& offset,
                                      const CGFloat& blur,
                                      const CGFloat* pColors)
{
    CGColorRef pShadowColor = CGColorCreateGenericRGB(pColors[0],
                                                      pColors[1],
                                                      pColors[2],
                                                      pColors[3]);
    
    if(pShadowColor != NULL)
    {
        CGContextSetShadowWithColor(pContext,
                                    offset,
                                    blur,
                                    pShadowColor);
        
        CFRelease(pShadowColor);
    } // if
} // HUDAcquireShadowWithColor

static void HUDShadowAcquireWithColor(CGContextRef pContext)
{
    CGSize  offset    = CGSizeMake(0.0f, kHUDOffscreen);
    CGFloat colors[4] = {0.5f, 0.5f, 1.0f, 0.7f};
    
    HUDAcquireShadowWithColor(pContext, offset, 48.0f, colors);
} // HUDShadowAcquireWithColor

static void HUDBackgroundShadowAcquireWithColor(CGContextRef pContext)
{
    CGSize  offset    = CGSizeMake(0.0f, 1.0f);
    CGFloat colors[4] = {0.7f, 0.7f, 1.0f, 0.9f};
    
    HUDAcquireShadowWithColor(pContext, offset, 6.0f, colors);
} // HUDBackgroundShadowAcquireWithColor

static void HUDNeedleShadowAcquireWithColor(CGContextRef pContext)
{
    CGSize  offset    = CGSizeMake(0.0f, 1.0f);
    CGFloat colors[4] = {0.0f, 0.0f, 0.5f, 0.7f};
    
    HUDAcquireShadowWithColor(pContext, offset, 6.0f, colors);
} // HUDNeedleShadowAcquireWithColor

static GLuint HUDBackgroundCreateTexture(const GLsizei& width,
                                         const GLsizei& height,
                                         const size_t& max)
{
    GLuint  texture = 0;
    
    glEnable(GL_TEXTURE_RECTANGLE_ARB);
    {
        glGenTextures(1, &texture);
        
        if(texture)
        {
            CGColorSpaceRef pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            
            if(pColorspace != NULL)
            {
                const size_t bpp = width * kHUDSamplesPerPixel;
                
                CGContextRef pContext = CGBitmapContextCreate(NULL,
                                                              width,
                                                              height,
                                                              kHUDBitsPerComponent,
                                                              bpp,
                                                              pColorspace,
                                                              kHUDBitmapInfo);
                
                if(pContext != NULL)
                {
                    GLfloat cx = kHUDCenterX * width;
                    GLfloat cy = kHUDCenterY * height;
                    
                    GLfloat radius = 0.5f * (width > height ? width : height);
                    GLfloat needle = radius * 0.85f;
                    
                    // background
                    CGContextTranslateCTM(pContext, 0.0f, height);
                    CGContextScaleCTM(pContext, 1.0f, -1.0f);
                    CGContextClearRect(pContext, CGRectMake(0, 0, width, height));
                    CGContextSetRGBFillColor(pContext, 0.0f, 0.0f, 0.0f, 0.7f);
                    CGContextAddArc(pContext, cx, cy, radius, 0.0f, GLM::kTwoPi_f, false);
                    CGContextFillPath(pContext);
                    
                    size_t  count = 2;
                    CGFloat locations[2]  = { 0.0f, 1.0f };
                    CGFloat components[8] =
                    {
                        1.0f, 1.0f, 1.0f, 0.5f,  // Start color
                        0.0f, 0.0f, 0.0f, 0.0f
                    }; // End color
                    
                    CGGradientRef pGradient = CGGradientCreateWithColorComponents(pColorspace,
                                                                                  components,
                                                                                  locations,
                                                                                  count);
                    if(pGradient != NULL)
                    {
                        CGContextSaveGState(pContext);
                        {
                            CGContextAddArc(pContext, cx, cy, radius, 0.0f, GLM::kTwoPi_f, false);
                            CGContextAddArc(pContext, cx, cy, needle * 1.05, 0.0f, GLM::kTwoPi_f, false);
                            CGContextEOClip(pContext);
                            
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(cx, cy),
                                                        radius * 1.01f,
                                                        CGPointMake(cx, cy * 0.96f),
                                                        radius * 0.98f,
                                                        0);
                            // bottom rim light
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(cx, cy),
                                                        radius * 1.01f,
                                                        CGPointMake(cx, cy * 1.04f),
                                                        radius * 0.98f,
                                                        0);
                            // top bevel
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(cx, cy * 2.2f),
                                                        radius*0.2,
                                                        CGPointMake(cx, cy),
                                                        radius,
                                                        0);
                        }
                        CGContextRestoreGState(pContext);
                        
                        // bottom bevel
                        CGContextSaveGState(pContext);
                        {
                            CGContextAddArc(pContext, cx, cy, needle * 1.05f, 0.0f, GLM::kTwoPi_f, false);
                            CGContextAddArc(pContext, cx, cy, needle * 0.96f, 0.0f, GLM::kTwoPi_f, false);
                            CGContextEOClip(pContext);
                            
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(cx, -0.5f * cy),
                                                        radius * 0.2f,
                                                        CGPointMake(cx, cy),
                                                        radius,
                                                        0);
                        }
                        CGContextRestoreGState(pContext);
                        
                        CFRelease(pGradient);
                    } // if
                    
                    // top rim light
                    
                    CGContextSetRGBFillColor(pContext, 0.9f, 0.9f, 1.0f, 1.0f);
                    CGContextSetRGBStrokeColor(pContext, 0.9f, 0.9f, 1.0f, 1.0f);
                    CGContextSetLineCap(pContext, kCGLineCapRound);
                    
                    // draw several glow passes, with the content offscreen
                    CGContextTranslateCTM(pContext, 0.0f, kHUDOffscreen - 10.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    CGContextTranslateCTM(pContext, 0.0f, 20.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    CGContextTranslateCTM(pContext, -10.0f, -10.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    CGContextTranslateCTM(pContext, 20.0f, 0.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    CGContextTranslateCTM(pContext, -10.0f, -kHUDOffscreen);
                    
                    // draw real content
                    HUDBackgroundShadowAcquireWithColor(pContext);
                    
                    HUDDrawMarks(pContext, width, height, max);
                    
                    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture);
                    
                    const void *pData  = CGBitmapContextGetData(pContext);
                    
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
        } // if
    }
    glDisable(GL_TEXTURE_RECTANGLE_ARB);
    
    return texture;
} // HUDBackgroundCreateTexture

static GLdouble HUDAngleForValue(GLdouble& val,
                                 const size_t& max)
{
    if(val < 0.0f)
    {
        val = 0.0f;
    } // if
    
    GLdouble max_f = GLdouble(max);
    
    if(val > (max_f * 1.05f))
    {
        val = max_f + 1.05f;
    } // if
    
    return  GLM::kPiDiv6_f - GLM::k4PiDiv3_f * val / max_f;
} // HUDAngleForValue

static void HUDNeedleDraw(CGContextRef pContext,
                          const GLsizei& width,
                          const GLsizei& height,
                          const GLfloat& angle)
{
    GLfloat cx     = kHUDCenterX * width;
    GLfloat cy     = kHUDCenterY * height;
    GLfloat dx     = -std::cos(angle);
    GLfloat dy     = -std::sin(angle);
    GLfloat hdx    = 0.5f * dx;
    GLfloat hdy    = 0.5f * dy;
    GLfloat radius = 0.5f * (width > height ? width : height);
    GLfloat needle = radius * 0.85f;
    
    CGContextMoveToPoint(pContext,
                         cx + needle * dx - hdy,
                         cy + needle * dy + hdx);
    
    CGContextAddLineToPoint(pContext,
                            cx + needle * dx + hdy,
                            cy + needle * dy - hdx);
    
    CGContextAddLineToPoint(pContext,
                            cx - kHUDNeedleThickness * (dx + hdy),
                            cy - kHUDNeedleThickness * (dy - hdx));
    
    CGContextAddArc(pContext,
                    cx - kHUDNeedleThickness * dx,
                    cy - kHUDNeedleThickness * dy,
                    0.5f * kHUDNeedleThickness,
                    angle - GLM::kHalfPi_f,
                    angle + GLM::kHalfPi_f,
                    false);
    
    CGContextAddLineToPoint(pContext,
                            cx - kHUDNeedleThickness * (dx - hdy),
                            cy - kHUDNeedleThickness * (dy + hdx));
    
    CGContextFillPath(pContext);
} // HUDNeedleDraw

static GLuint HUDNeedleCreateTexture(const GLsizei& width,
                                     const GLsizei& height)
{
    GLuint texture = 0;
    
    glEnable(GL_TEXTURE_RECTANGLE_ARB);
    {
        glGenTextures(1, &texture);
        
        if(texture)
        {
            CGColorSpaceRef pColorspace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            
            if(pColorspace != NULL)
            {
                const size_t bpp = width * kHUDSamplesPerPixel;
                
                CGContextRef pContext = CGBitmapContextCreate(NULL,
                                                              width,
                                                              height,
                                                              kHUDBitsPerComponent,
                                                              bpp,
                                                              pColorspace,
                                                              kHUDBitmapInfo);
                
                if(pContext != NULL)
                {
                    GLfloat angle  = 0.0f;
                    GLfloat cx     = kHUDCenterX * width;
                    GLfloat cy     = kHUDCenterY * height;
                    
                    CGContextTranslateCTM(pContext, 0.0f, height);
                    CGContextScaleCTM(pContext, 1.0, -1.0);
                    CGContextClearRect(pContext, CGRectMake(0.0f, 0.0f, width, height));
                    
                    CGContextSaveGState(pContext);
                    {
                        GLfloat radius = 0.5f * (width > height ? width : height);
                        GLfloat needle = radius * 0.85f;
                        
                        size_t count = 2;
                        
                        CGFloat locations[2] = { 0.0f, 1.0f };
                        
                        CGFloat components[8] =
                        {
                            0.7f, 0.7f, 1.0f, 0.7f,  // Start color
                            0.0f, 0.0f, 0.0f, 0.0f
                        }; // End color
                        
                        CGContextAddArc(pContext, cx, cy, needle * 1.05, 0.0f, GLM::kTwoPi_f, false);
                        CGContextAddArc(pContext, cx, cy, needle * 0.96, 0.0f, GLM::kTwoPi_f, false);
                        
                        CGContextEOClip(pContext);
                        
                        CGGradientRef pGradient = CGGradientCreateWithColorComponents(pColorspace,
                                                                                      components,
                                                                                      locations,
                                                                                      count);
                        if(pGradient != NULL)
                        {
                            // draw glow reflecting on inner bevel
                            GLfloat dx = -cos(angle) + 1.0f;
                            GLfloat dy = -sin(angle) + 1.0f;
                            
                            CGContextDrawRadialGradient(pContext,
                                                        pGradient,
                                                        CGPointMake(cx * dx, cy * dy),
                                                        radius * 0.1f,
                                                        CGPointMake(cx, cy),
                                                        radius ,
                                                        0.0f);
                            
                            CFRelease(pGradient);
                        } // if
                    }
                    CGContextRestoreGState(pContext);
                    
                    CGContextSetRGBFillColor(pContext, 0.9f, 0.9f, 1.0f, 1.0f);
                    
                    // draw several glow passes, with the content offscreen
                    CGContextTranslateCTM(pContext, 0.0f, kHUDOffscreen - 10.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    CGContextTranslateCTM(pContext, 0.0f, 20.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    CGContextTranslateCTM(pContext, -10.0f, -10.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    CGContextTranslateCTM(pContext, 20.0f, 0.0f);
                    
                    HUDShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    CGContextTranslateCTM(pContext, -10.0f, -kHUDOffscreen);
                    
                    // draw real content
                    HUDNeedleShadowAcquireWithColor(pContext);
                    
                    HUDNeedleDraw(pContext, width, height, angle);
                    
                    glBindTexture(GL_TEXTURE_RECTANGLE_ARB, texture);
                    
                    const void *pData  = CGBitmapContextGetData(pContext);
                    
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
        } // if
    }
    glDisable(GL_TEXTURE_RECTANGLE_ARB);
    
    return texture;
} // HUDNeedleCreateTexture

#pragma mark -
#pragma mark Public - Meter - Image

HUD::Meter::Image::Image(const GLsizei& width,
                         const GLsizei& height,
                         const size_t& max,
                         const HUD::Meter::String& legend)
{
    mnWidth  = width;
    mnHeight = height;
    mnMax    = max;
    mnLimit  = GLdouble(mnMax);
    m_Legend = legend;
    
    mnValue  = 0.0f;
    mnSmooth = 0.0f;
    
    mpLegend = NULL;
    
    m_Texture[eHUDMeterBackground] = 0;
    m_Texture[eHUDMeterNeedle]     = 0;
    m_Texture[eHUDMeterLegend]     = 0;
    
    CGFloat fWidth  = CGFloat(mnWidth);
    CGFloat fHeight = CGFloat(mnHeight);
    
    CGFloat fx = -0.5f * fWidth;
    CGFloat fy = -0.5f * fHeight;
    
    m_Bounds[0] = CGRectMake(fx, fy, fWidth, fHeight);
    
    m_Bounds[1] = CGRectMake(-0.5f * kHUDLegendWidth,
                             -220.0f,
                             kHUDLegendWidth,
                             kHUDLegendHeight);
    
    m_Bounds[2] = CGRectMake(-0.5f * kHUDValueWidth,
                             -110.0f,
                             kHUDValueWidth,
                             kHUDValueHeight);
    
    mpQuad = GLU::QuadCreate(GL_DYNAMIC_DRAW);
} // Constructor

HUD::Meter::Image::~Image()
{
    if(m_Texture[eHUDMeterBackground])
    {
        glDeleteTextures(1, &m_Texture[eHUDMeterBackground]);
        
        m_Texture[eHUDMeterBackground] = 0;
    } // if
    
    if(m_Texture[eHUDMeterNeedle])
    {
        glDeleteTextures(1, &m_Texture[eHUDMeterNeedle]);
        
        m_Texture[eHUDMeterNeedle] = 0;
    } // if
    
    if(mpLegend != NULL)
    {
        delete mpLegend;
        
        mpLegend = NULL;
    } // if
    
    if(!m_Hash.empty())
    {
        GLU::Text *pText = NULL;
        
        for(auto& text:m_Hash)
        {
            pText = text.second;
            
            if(pText != NULL)
            {
                delete pText;
                
                pText = NULL;
            } // if
        } // for
        
        m_Hash.clear();
    } // if
    
    GLU::QuadRelease(mpQuad);
    
    mpQuad = NULL;
} // Destructor

void HUD::Meter::Image::setTarget(const GLdouble& target)
{
    mnValue = target;
} // setTarget

void HUD::Meter::Image::reset()
{
    mnValue  = 0.0f;
    mnSmooth = 0.0f;
} // reset

void HUD::Meter::Image::update()
{
    // TODO: Move to time-based
    GLdouble step = mnLimit / 60.0f;
    
    if(std::fabs(mnSmooth - mnValue) < step)
    {
        mnSmooth = mnValue;
    } // if
    else if(mnValue > mnSmooth)
    {
        mnSmooth += step;
    } // else if
    else if(mnValue < mnSmooth)
    {
        mnSmooth -= step;
    } // else if
} // update

void HUD::Meter::Image::render()
try
{
    if(m_Texture[eHUDMeterBackground] == 0)
    {
        m_Texture[eHUDMeterBackground] = HUDBackgroundCreateTexture(mnWidth, mnHeight, mnMax);
    } // if
    
    if(m_Texture[eHUDMeterNeedle] == 0)
    {
        m_Texture[eHUDMeterNeedle] = HUDNeedleCreateTexture(mnWidth, mnHeight);
    } // if
    
    if(mpLegend == NULL)
    {
        mpLegend = new GLU::Text(m_Legend,
                                 36.0f,
                                 false,
                                 GLsizei(kHUDLegendWidth),
                                 GLsizei(kHUDLegendHeight));
        
        m_Texture[eHUDMeterLegend] = mpLegend->texture();
    } // if
    
    glEnable(GL_TEXTURE_RECTANGLE_ARB);
    {
        glMatrixMode(GL_TEXTURE);
        
        glPushMatrix();
        {
            glLoadIdentity();
            glScalef(mnWidth, mnHeight, 1.0f);
            
            GLU::QuadSetIsInverted(false, mpQuad);
            GLU::QuadSetBounds(m_Bounds[0], mpQuad);
            
            if(!GLU::QuadIsFinalized(mpQuad))
            {
                GLU::QuadFinalize(mpQuad);
            } // if
            else
            {
                GLU::QuadUpdate(mpQuad);
            } // else
            
            glMatrixMode(GL_MODELVIEW);
            
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB, m_Texture[eHUDMeterBackground]);
            {
                GLU::QuadDraw(mpQuad);
                
                glBindTexture(GL_TEXTURE_RECTANGLE_ARB, m_Texture[eHUDMeterNeedle]);
                
                glPushMatrix();
                {
                    GLfloat angle = GLM::k180DivPi_f * HUDAngleForValue(mnSmooth, mnMax);
                    
                    glRotatef(angle, 0.0f, 0.0f, 1.0f);
                    
                    GLU::QuadDraw(mpQuad);
                }
                glPopMatrix();
                
                glMatrixMode(GL_TEXTURE);
            }
            glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
        }
        glPopMatrix();
        
        glMatrixMode(GL_MODELVIEW);
    }
    glDisable(GL_TEXTURE_RECTANGLE_ARB);
    
    glEnable(GL_TEXTURE_2D);
    {
        glBindTexture(GL_TEXTURE_2D, m_Texture[eHUDMeterLegend]);
        {
            GLU::QuadSetIsInverted(true, mpQuad);
            GLU::QuadSetBounds(m_Bounds[1], mpQuad);
            
            GLU::QuadUpdate(mpQuad);
            GLU::QuadDraw(mpQuad);
        }
        glBindTexture(GL_TEXTURE_2D, 0);
        
        GLuint nValue = GLuint(std::lrint(mnSmooth));
        GLuint nTex   = HUDEmplaceTextureWithLabel(nValue, m_Hash);
        
        if(nTex)
        {
            glBindTexture(GL_TEXTURE_2D, nTex);
            {
                GLU::QuadSetIsInverted(true, mpQuad);
                GLU::QuadSetBounds(m_Bounds[2], mpQuad);
                
                GLU::QuadUpdate(mpQuad);
                GLU::QuadDraw(mpQuad);
            }
            glBindTexture(GL_TEXTURE_2D, 0);
        } // if
    }
    glDisable(GL_TEXTURE_2D);
} // render
catch(std::bad_alloc& ba)
{
    NSLog(@">> ERROR: Failed an OpenGL text label for meter's legend: \"%s\"", ba.what());
} // catch

void HUD::Meter::Image::draw(const GLfloat& x,
                             const GLfloat& y)
{
    glPushMatrix();
    {
        glTranslatef(x, y, 0.0f);
        glColor3f(1.0f, 1.0f, 1.0f);
        
        render();
    }
    glPopMatrix();
} // Draw
