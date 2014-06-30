/*
     File: CFText.mm
 Abstract: 
 Utility toolkit for managing mutable attributed strings.
 
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
#pragma mark Headers

// CF mutable attributed string utilities
#import "CFText.h"

#pragma mark -
#pragma mark Private - Constants

// Size constants
static const uint32_t CFTextSizeCTTextAlignment = sizeof(CTTextAlignment);
static const uint32_t CFTextSizeCGFloat         = sizeof(CGFloat);

// Array counts
static const uint32_t CFTextAttribsCount = 3;
static const uint32_t CFTextStyleCount   = 2;

#pragma mark -
#pragma mark Private - utilities - CF Strings

static CFStringRef CFStringCreate(const std::string& rString)
{
    CFStringRef pString = NULL;
    
    if(!rString.empty())
    {
        pString = CFStringCreateWithCString(kCFAllocatorDefault,
                                            rString.data(),
                                            kCFStringEncodingUTF8);
    } // if
    
    return pString;
} // CFStringCreate

#pragma mark -
#pragma mark Private - utilities - Paragraph Styles

// Create alignment paragraph setting
static CTParagraphStyleSetting CFTextCreateParagraphSettingAlignment(const CTTextAlignment *pAlignment)
{
    CTParagraphStyleSetting setting =
    {
        kCTParagraphStyleSpecifierAlignment,
        CFTextSizeCTTextAlignment,
        pAlignment
    };
    
    // Create a paragraph style
    return setting;
} // CFTextCreateParagraphSettingAlignment

// Create line height paragraph setting
static CTParagraphStyleSetting CFTextCreateParagraphSettingLineHeight(const CGFloat *pLineHeight)
{
    CTParagraphStyleSetting setting =
    {
        kCTParagraphStyleSpecifierLineHeightMultiple,
        CFTextSizeCGFloat,
        pLineHeight
    };
    
    return setting;
} // CFTextCreateParagraphSettingLineHeight

// Create a paragraph style with line height and alignment
static CTParagraphStyleRef CFTextCreateParagraphStyle(const CGFloat& nLineHeight,
                                                      const CTTextAlignment& nAlignment)
{
    CTParagraphStyleSetting alignment  = CFTextCreateParagraphSettingAlignment(&nAlignment);
    CTParagraphStyleSetting lineHeight = CFTextCreateParagraphSettingLineHeight(&nLineHeight);
    
    // Paragraph settings with alignment and style
    CTParagraphStyleSetting settings[CFTextStyleCount] = {alignment, lineHeight};
    
    // Create a paragraph style
    return CTParagraphStyleCreate(settings, CFTextStyleCount);
} // CFTextCreateParagraphStyle

#pragma mark -
#pragma mark Private - utilities - Fonts

// Create a font with name and size
static CTFontRef CFTextCreateFont(CFStringRef pFontNameSrc,
                                  const CGFloat& nFontSizeSrc)
{
    // Minimum sizeis 4 pts.
    CGFloat nFontSizeDst = (nFontSizeSrc > 4.0) ? nFontSizeSrc : 4.0;
    
    // If the font name is null default to Helvetica
    CFStringRef pFontNameDst = (pFontNameSrc) ? pFontNameSrc : CFSTR("Helvetica");
    
    // Prepare font
    return CTFontCreateWithName(pFontNameDst, nFontSizeDst, NULL);
} // CFTextCreateFont

// Create a font with name and size
static CTFontRef CFTextCreateFont(const std::string& rFontNameSrc,
                                  const CGFloat& nFontSizeSrc)
{
    CTFontRef pFont = NULL;
    
    // If the font name is null default to Helvetica
    std::string rFontNameDst = (!rFontNameSrc.empty()) ? rFontNameSrc : "Helvetica";
    
    // Create a cf string representing a font name
    CFStringRef pFontName = CFStringCreate(rFontNameDst);
    
    if( pFontName != NULL )
    {
        // Create a font reference with name and size
        pFont = CFTextCreateFont(pFontName, nFontSizeSrc);
        
        // Release the font name
        CFRelease(pFontName);
    } // if
    
    return pFont;
} // CFTextCreateFont

#pragma mark -
#pragma mark Private - utilities - Colors

// Return a color reference if valid, else get the clear color
static CGColorRef CFTextGetColor(CGColorRef pColor)
{
    return (pColor) ? pColor : CGColorGetConstantColor(kCGColorClear);
} // CFTextGetColor

// Return a color reference if valid, else get the clear color
static CGColorRef CFTextCreateColor(const CGFloat * const pComponents)
{
    return (pComponents)
    ? CGColorCreateGenericRGB(pComponents[0], pComponents[1], pComponents[2], pComponents[3])
    : CGColorCreateGenericRGB(1.0, 1.0, 1.0, 1.0);
} // CFTextGetColor

#pragma mark -
#pragma mark Private - utilities - Attributes

// Create an attributes dictionary with paragraph style, font, and colors
static CFDictionaryRef CFTextCreateAttributes(CTParagraphStyleRef pStyle,
                                              CTFontRef pFont,
                                              const CGColorRef pColor)
{
    // Dictionary Keys
    CFStringRef keys[CFTextAttribsCount] =
    {
        kCTParagraphStyleAttributeName,
        kCTFontAttributeName,
        kCTForegroundColorAttributeName
    };
    
    // Dictionary Values
    CFTypeRef values[CFTextAttribsCount] =
    {
        pStyle,
        pFont,
        pColor
    };
    
    // Create a dictionary of attributes for our string
    return CFDictionaryCreate(NULL,
                              (const void **)&keys,
                              (const void **)&values,
                              CFTextAttribsCount,
                              &kCFTypeDictionaryKeyCallBacks,
                              &kCFTypeDictionaryValueCallBacks);
} // CFTextCreateAttributes

#pragma mark -
#pragma mark Private - utilities - Mutable Attributed Strings

// Creating a mutable attributed string from a cf string and
// an dictionary of attributes.
static CF::TextRef CFTextCreate(CFStringRef pString,
                                CFDictionaryRef pAttributes)
{
    // Creating a mutable attributed string
    CF::TextRef pText = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    
    if( pText != NULL )
    {
        // Set a mutable attributed string with the input string
        CFAttributedStringReplaceString(pText, CFRangeMake(0, 0), pString);
        
        // Compute the mutable attributed string range
        CFRange range = CFRangeMake(0, CFAttributedStringGetLength(pText));
        
        // Set the attributes
        CFAttributedStringSetAttributes(pText, range, pAttributes, NO);
    } // if
    
    return pText;
} // CFTextCreate

// Create an attributed string from a CF string, font, justification, and font size
static CF::TextRef CFTextCreate(CFStringRef pString,
                                CTFontRef pFont,
                                const CGFloat& nLineHeight,
                                const CTTextAlignment& nAlignment,
                                const CGColorRef pColor)
{
    CF::TextRef pText = NULL;
	
    // Create a paragraph style
    CTParagraphStyleRef pStyle = CFTextCreateParagraphStyle(nLineHeight, nAlignment);
    
    if( pStyle != NULL )
    {
        // Create a dictionary of attributes for our string
        CFDictionaryRef pAttributes = CFTextCreateAttributes(pStyle, pFont, pColor);
        
        if( pAttributes != NULL )
        {
            // Creating a mutable attributed string
            pText = CFTextCreate(pString, pAttributes);
            
            // Relase the attributes
            CFRelease(pAttributes);
        } // if
        
        // Release the paragraph style
        CFRelease(pStyle);
    } // if
    
    return pText;
} // CFTextCreate

#pragma mark -
#pragma mark Public - Constructors

// Create an attributed string from a CF string, font, justification, and font size
CF::TextRef CF::TextCreate(CFStringRef pString,
                           CFStringRef pFontName,
                           const CGFloat& nFontSize,
                           const CGFloat& nLineHeight,
                           const CTTextAlignment& nAlignment,
                           CGColorRef pComponents)
{
    CF::TextRef pText = NULL;
	
	if( pString != NULL )
	{
        // Create a font reference
        CTFontRef pFont = CFTextCreateFont(pFontName, nFontSize);
        
        if( pFont != NULL )
        {
            // If null color components then default to the constant clear color
            CGColorRef pColor = CFTextGetColor(pComponents);
            
            // Creating a mutable attributed string
            pText = CFTextCreate(pString,
                                 pFont,
                                 nLineHeight,
                                 nAlignment,
                                 pColor);
            
            // Release the font reference
            CFRelease(pFont);
        } // if
	} // if
    
    return pText;
} // CFTextCreate

// Create an attributed string from a CF string, font, justification, and font size
CF::TextRef CF::TextCreate(CFStringRef pString,
                           CFStringRef pFontName,
                           const CGFloat& nFontSize,
                           const CTTextAlignment& nAlignment)
{
    return CF::TextCreate(pString, pFontName, nFontSize, 1.0f, nAlignment, NULL);
} // CFTextCreate

// Create an attributed string from a stl string, font, justification, and font size
CF::TextRef CF::TextCreate(const std::string& rString,
                           const std::string& rFontName,
                           const CGFloat& nFontSize,
                           const CGFloat& nLineHeight,
                           const CTTextAlignment& nAlignment,
                           const CGFloat * const pComponents)
{
    CF::TextRef pText = NULL;
    
    // Create a string reference from a stl string
    CFStringRef pString = CFStringCreate(rString);
    
    if( pString != NULL )
    {
        // Create a font reference
        CTFontRef pFont = CFTextCreateFont(rFontName, nFontSize);
        
        if( pFont != NULL )
        {
            // Create a white color reference
            CGColorRef pColor = CFTextCreateColor(pComponents);
            
            if( pColor != NULL )
            {
                // Create a mutable attributed string
                pText = CFTextCreate(pString,
                                     pFont,
                                     nLineHeight,
                                     nAlignment,
                                     pColor);
                
                // Release the color reference
                CFRelease(pColor);
            } // if
            
            // Release the font reference
            CFRelease(pFont);
        } // if
        
        // Release the string reference
        CFRelease(pString);
    } // if
    
    return pText;
} // CFTextCreate

// Create an attributed string from a stl string, font, justification, and font size
CF::TextRef CF::TextCreate(const std::string& rString,
                           const std::string& rFontName,
                           const CGFloat& nFontSize,
                           const CTTextAlignment& nAlignment)
{
    return CF::TextCreate(rString, rFontName, nFontSize, 1.0f, nAlignment, NULL);
} // CFTextCreate

// If not NULL then make a deep-copy of mutable attributed string reference
CF::TextRef CF::TextCreateCopy(CFAttributedStringRef pAttrString)
{
    CF::TextRef pText = NULL;
    
    if(pAttrString != NULL)
    {
        CFIndex nMaxLength = CFAttributedStringGetLength(pAttrString);
        
        if(nMaxLength)
        {
            pText = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, nMaxLength, pAttrString);
        } // if
    } // if
    
    return pText;
} // CFTextCreateCopy

// If not NULL then make a deep-copy of mutable attributed string reference
CF::TextRef CF::TextCreateCopy(CF::TextRef pTextSrc)
{
    CF::TextRef pTextDst = NULL;
    
    if(pTextSrc != NULL)
    {
        CFIndex nMaxLength = CFAttributedStringGetLength(pTextSrc);
        
        if(nMaxLength)
        {
            pTextDst = CFAttributedStringCreateMutableCopy(kCFAllocatorDefault, nMaxLength, pTextSrc);
        } // if
    } // if
    
    return pTextDst;
} // if

// If not NULL then retain a copy of mutable attributed string reference
CF::TextRef CF::TextRetain(CF::TextRef pText)
{
    CF::TextRef pTextCopy = NULL;
    
    if(pText != NULL)
    {
        CFRetain(pText);
        
        pTextCopy = pText;
    } // if
    
    return pTextCopy;
} // CFTextRetain

// If not NULL then release the mutable attributed string reference
void CF::TextRelease(CF::TextRef pText)
{
    if(pText != NULL)
    {
        CFRelease(pText);
        
        pText = NULL;
    } // if
} // CFTextRelease