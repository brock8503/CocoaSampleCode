/*
     File: OpenGLIFStream.h
 Abstract: 
 A toolkit for managing input file streams (such as vertex, fragment, or geometry shader ascii text files).
 
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

#ifndef _OPENGL_INPUT_FILE_STREAM_H_
#define _OPENGL_INPUT_FILE_STREAM_H_

// Mac OS X
#import <Cocoa/Cocoa.h>

// OpenGL container types
#import "OpenGLContainers.h"

#ifdef __cplusplus

// Byte buffer
typedef GLchar *GLbuffer;

// In a large scale system architecture, instead of exposing the data
// structure, one would hide all the instance variables and instead
// expose a single opaque data reference.  In this case our opaque data
// reference is represented by a pointer to GLIFStream structure.  The
// details of this data structure are hidden and only exposed in the
// implementation file.  All subsequent methods then work with this
// opaque data reference.
typedef struct GLIFStream *GLIFStreamRef;

// Create a file object from a stl string pathname
GLIFStreamRef GLIFStreamCreate(const GLchar * const pPathname);

// Create a file object from a stl string pathname
GLIFStreamRef GLIFStreamCreate(const GLpathname &rPathname);

// Create a file object from a core foundation string pathname
GLIFStreamRef GLIFStreamCreate(CFStringRef pPathname);

// Delete the file object
void GLIFStreamDelete(GLIFStreamRef pFile);

// Get the pathname
const GLpathname GLIFStreamGetPathname(const GLIFStreamRef pFile);

// Get the buffer (or the contents of a file)
const GLbuffer GLIFStreamGetBuffer(const GLIFStreamRef pFile);

// Get the size of the buffer
const size_t GLIFStreamGetLength(const GLIFStreamRef pFile);

#endif

#endif

