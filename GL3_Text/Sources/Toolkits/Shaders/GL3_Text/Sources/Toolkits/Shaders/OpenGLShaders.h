/*
     File: OpenGLShaders.h
 Abstract: 
 GLSL shader utility toolkit.
 
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

#ifndef _OPENGL_SHADERS_H_
#define _OPENGL_SHADERS_H_

// Mac OS X frameworks
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

// OpenGL container types
#import "OpenGLContainers.h"

#ifdef __cplusplus

// Compile vertex and fragment shaders
GLobjects GLShadersCreate(const GLchar * const pVertex,
						  const GLchar * const pFragment);

// Compile vertex and fragment shaders, with/without optional
// geometry shader
GLobjects GLShadersCreate(const GLchar * const pVertex,
						  const GLchar * const pFragment,
						  const GLchar * const pGeometry);

// Compile vertex and fragment shaders
GLobjects GLShadersCreate(const GLsource &rVertex,
						  const GLsource &rFragment);

// Compile vertex and fragment shaders, with/without optional
// geometry shader
GLobjects GLShadersCreate(const GLsource &rVertex,
						  const GLsource &rFragment,
						  const GLsource &rGeometry);

// Compile vertex and fragment shaders
GLobjects GLShadersCreate(CFStringRef pVertex,
                          CFStringRef pFragment);

// Compile vertex and fragment shaders, with/without optional
// geometry shader
GLobjects GLShadersCreate(CFStringRef pVertex,
                          CFStringRef pFragment,
                          CFStringRef pGeometry);

// Compile vertex and fragment shaders at a pathname
GLobjects GLShadersCreateAtPath(const GLchar * const pVertex,
                                const GLchar * const pFragment);

// Compile vertex and fragment shaders, with/without optional geometry shader
// geometry shader at a pathname
GLobjects GLShadersCreateAtPath(const GLchar * const pVertex,
                                const GLchar * const pFragment,
                                const GLchar * const pGeometry);

// Compile vertex and fragment shaders at a pathname
GLobjects GLShadersCreateAtPath(const GLpathname &rVertex,
                                const GLpathname &rFragment);

// Compile vertex and fragment shaders, with/without optional geometry shader
// geometry shader at a pathname
GLobjects GLShadersCreateAtPath(const GLpathname &rVertex,
                                const GLpathname &rFragment,
                                const GLpathname &rGeometry);

// Compile vertex and fragment shaders at a pathname
GLobjects GLShadersCreateAtPath(CFStringRef pVertex,
                                CFStringRef pFragment);

// Compile vertex and fragment shaders, with/without optional geometry shader
// geometry shader at a pathname
GLobjects GLShadersCreateAtPath(CFStringRef pVertex,
                                CFStringRef pFragment,
                                CFStringRef pGeometry);

// Delete all the shaders
void GLShadersDelete(GLobjects &rObjects);

// Create an associative array (a.k.a. map) from key-value pairs
GLlocations GLLocationsCreate(const GLuint nCount,
							  const GLuint *pKeys,
							  const GLchar **hValues);

// Create an associative array (a.k.a. map) from key-value vectors
GLlocations GLLocationsCreate(const GLuints   &rKeys,
                              const GLstrings &rValues);

// Create an associative array (a.k.a. map) from CFArrays
GLlocations GLLocationsCreate(CFArrayRef pKeys,
                              CFArrayRef pValues);

// Create an associative array (a.k.a. map) from a dictionary
GLlocations GLLocationsCreate(CFDictionaryRef pLocations);

// Delete locations
void GLLocationsDelete(GLlocations &rLocations);

// Create a program object from shaders (that may include an optional geometry shader)
GLuint GLProgramCreate(const GLobjects &rShaders,
					   GLlocations  &rAttributes,
					   GLlocations  &rFragments);

#endif

#endif
