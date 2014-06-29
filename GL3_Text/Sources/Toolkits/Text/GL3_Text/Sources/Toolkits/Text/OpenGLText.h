/*
     File: OpenGLText.h
 Abstract: 
 Utility toolkit for generating an OpenGL text from a string reference.
 
  Version: 1.0
 
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

// MacOS X

#ifndef _OPENGL_TEXT_H_
#define _OPENGL_TEXT_H_

// MacOS X Frameworks
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <GLKit/GLKMath.h>

// OpenGL container types
#import "OpenGLContainers.h"

#ifdef __cplusplus

// In a large scale system architecture, instead of exposing the data
// structure, one would hide all the instance variables and instead
// expose a single opaque data reference.  In this case our opaque data
// reference is represented by a pointer to GLText structure.  The
// details of this data structure are hidden and only exposed in the
// implementation file.  All subsequent methods then work with this
// opaque data reference.
typedef struct GLText *GLTextRef;

// Color array for the gradient text should be organized in this
// fashion:
//
// colors = { color 1 = { Red 1, Green 1, Blue 1,  Alpha 1 },
//            color 2 = { Red 2, Green 2, Blue 2,  Alpha 2 },
//            color 3 = { Red 3, Green 3, Blue 3,  Alpha 3 },
//            color 4 = { Red 4, Green 4, Blue 4,  Alpha 4 } }
//
// where the color quad is,
//
//       color 4 <--------------------- Color 3
//         |                              ^
//         |                              |
//         |                              |
//         |                              |
//         |                              |
//         v                              |
//       color 1 ---------------------> Color 2

// Create a perspective correct OpenGL text object
GLTextRef GLTextCreatePerspective(const GLchar * const pString,
								  const GLchar * const pFontName,
								  const CGFloat nFontSize,
								  const CTTextAlignment nAlignment,
								  const NSRect &rBounds,
								  const GLfloat * const pColors);

// Create a non-perspective OpenGL text object
GLTextRef GLTextCreateNonPerspective(const GLchar * const pString,
									 const GLchar * const pFontName,
									 const CGFloat nFontSize,
									 const CTTextAlignment nAlignment,
									 const NSRect &rBounds,
									 const NSPoint &rPosition,
									 const GLfloat * const pColors);

// Create a perspective correct OpenGL text object
GLTextRef GLTextCreatePerspective(const GLstring &rString,
								  const GLstring &rFontName,
								  const CGFloat nFontSize,
								  const CTTextAlignment nAlignment,
								  const NSRect &rBounds,
								  const GLfloat * const pColors);

// Create a non-perspective OpenGL text object
GLTextRef GLTextCreateNonPerspective(const GLstring &rString,
									 const GLstring &rFontName,
									 const CGFloat nFontSize,
									 const CTTextAlignment nAlignment,
									 const NSRect &rBounds,
									 const NSPoint &rPosition,
									 const GLfloat * const pColors);

// Create a perspective correct OpenGL text object
GLTextRef GLTextCreatePerspective(CFStringRef pString,
								  CFStringRef pFontName,
								  const CGFloat nFontSize,
								  const CTTextAlignment nAlignment,
								  const NSRect &rBounds,
								  const GLfloat * const pColors);

// Create a non-perspective OpenGL text object
GLTextRef GLTextCreateNonPerspective(CFStringRef pString,
									 CFStringRef pFontName,
									 const CGFloat nFontSize,
									 const CTTextAlignment nAlignment,
									 const NSRect &rBounds,
									 const NSPoint &rPosition,
									 const GLfloat * const pColors);

// Create a perspective correct OpenGL text object
GLTextRef GLTextCreatePerspective(CFAttributedStringRef pAttrString,
								  const NSRect &rBounds,
								  const GLfloat * const pColors);

// Create a non-perspective OpenGL text object
GLTextRef GLTextCreateNonPerspective(CFAttributedStringRef pAttrString,
									 const NSRect &rBounds,
									 const NSPoint &rPosition,
									 const GLfloat * const pColors);

// Delete OpenGL text Object
void GLTextDelete(GLTextRef pText);

// Update field-of-view for prespective correct text
void GLTextSetFieldOfView(const GLfloat nFovy,
						  GLTextRef pText);

// Specify how the red, green, blue, and alpha source and
// destination blending factors are computed
void GLTextSetBlending(const GLenum nSrc,
                       const GLenum nDst,
                       GLTextRef pText);

// Update the zoom value for perspective correct text
void GLTextSetZoom(const GLfloat nDeltaY,
				   GLTextRef pText);

// Set the model-view-projection linear transformation for a
// perspective-correct text
void GLTextSetMVP(const NSRect &rBounds,
				  const GLKVector4 &rRotate,
				  const GLKVector3 &rTranslate,
				  GLTextRef pText);

// Update the perspective transformation for a perspective-correct text
void GLTexSetPrespective(const NSRect &rBounds,
						 GLTextRef pText);

// Update the orthographic 2d transformation for a non-perspective text
void GLTextSetOrthographic(const NSRect &rBounds,
						   GLTextRef pText);

// Render a text into an OpenGL view
void GLTextDisplay(const GLTextRef pText);

#endif

#endif