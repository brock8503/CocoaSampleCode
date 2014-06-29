/*
     File: CFText.h
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

// MacOS X

#ifndef _CORE_FOUNDATION_TEXT_H_
#define _CORE_FOUNDATION_TEXT_H_

// STL string
#import <string>

// Mac OS X frameworks
#import <Cocoa/Cocoa.h>

#ifdef __cplusplus

namespace CF
{
    // Text reference type definition representing a CF mutable attributed string
    // opaque data reference
    typedef CFMutableAttributedStringRef  TextRef;
    
    // Create an attributed string from a stl string, font, justification, and font size
    TextRef TextCreate(const std::string& rString,
                       const std::string& rFontName,
                       const CGFloat& nFontSize,
                       const CTTextAlignment& nAlignment);
    
    // Create an attributed string from a stl string, font, justification, and font size
    TextRef TextCreate(const std::string& rString,
                       const std::string& rFontName,
                       const CGFloat& nFontSize,
                       const CGFloat& nLineHeight,
                       const CTTextAlignment& nAlignment,
                       const CGFloat * const pComponents);
    
    // Create an attributed string from a CF string, font, justification, and font size
    TextRef TextCreate(CFStringRef pString,
                       CFStringRef pFontName,
                       const CGFloat& nFontSize,
                       const CTTextAlignment& nAlignment);
    
    // Create an attributed string from a CF string, font, justification, and font size
    TextRef TextCreate(CFStringRef pString,
                       CFStringRef pFontName,
                       const CGFloat& nFontSize,
                       const CGFloat& nLineHeight,
                       const CTTextAlignment& nAlignment,
                       CGColorRef pComponents);
    
    // If not NULL then make a deep-copy of an attributed string reference
    TextRef TextCreateCopy(CFAttributedStringRef pAttrString);
    
    // If not NULL then make a deep-copy of mutable attributed string reference
    TextRef TextCreateCopy(TextRef pText);
    
    // If not NULL then retain a copy of mutable attributed string reference
    TextRef TextRetain(TextRef pText);
    
    // If not NULL then release the mutable attributed string reference
    void TextRelease(TextRef pText);
} // CF

#endif

#endif
