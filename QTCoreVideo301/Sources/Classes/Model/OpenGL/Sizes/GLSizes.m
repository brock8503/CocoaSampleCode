/*
     File: GLSizes.m
 Abstract: 
 OpenGL size types.
 
  Version: 2.0
 
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

#define GLSizeChar           sizeof(GLchar)
#define GLSizeChrPtr         sizeof(GLchar *)
#define GLSizeFloat          sizeof(GLfloat)
#define GLSizeDouble         sizeof(GLdouble)
#define GLSizeSignedByte     sizeof(GLbyte)
#define GLSizeSignedShort    sizeof(GLshort)
#define GLSizeSignedInt      sizeof(GLint)
#define GLSizeUnsignedByte   sizeof(GLubyte)
#define GLSizeUnsignedShort  sizeof(GLushort)
#define GLSizeUnsignedInt    sizeof(GLuint)

GLuint kGLSizeByte = GLSizeChar;
GLuint kGLSizeChar = GLSizeChar;

GLuint kGLSizeBytePtr = GLSizeChrPtr;
GLuint kGLSizeCharPtr = GLSizeChrPtr;

GLuint kGLSizeFloat     = GLSizeFloat;
GLuint kGLSizeHalfFloat = GLSizeFloat / 2;
GLuint kGLSizeDouble    = GLSizeDouble;

GLuint kGLSizeSignedByte  = GLSizeSignedByte;
GLuint kGLSizeSignedShort = GLSizeSignedShort;
GLuint kGLSizeSignedInt   = GLSizeSignedInt;

GLuint kGLSizeUnsignedByte                = GLSizeUnsignedByte;
GLuint kGLSizeUnsignedByte_3_3_2          = GLSizeUnsignedByte;
GLuint kGLSizeUnsignedByte_2_3_3_REV      = GLSizeUnsignedByte;
GLuint kGLSizeUnsignedShort               = GLSizeUnsignedShort;
GLuint kGLSizeUnsignedShort_4_4_4_4       = GLSizeUnsignedShort;
GLuint kGLSizeUnsignedShort_5_5_5_1       = GLSizeUnsignedShort;
GLuint kGLSizeUnsignedShort_5_6_5         = GLSizeUnsignedShort;
GLuint kGLSizeUnsignedShort_5_6_5_REV     = GLSizeUnsignedShort;
GLuint kGLSizeUnsignedShort_4_4_4_4_REV   = GLSizeUnsignedShort;
GLuint kGLSizeUnsignedShort_1_5_5_5_REV   = GLSizeUnsignedShort;
GLuint kGLSizeUnsignedShort_8_8_APPLE     = GLSizeUnsignedShort;
GLuint kGLSizeUnsignedShort_8_8_REV_APPLE = GLSizeUnsignedShort;

GLuint kGLSizeUnsignedInt                = GLSizeUnsignedInt;
GLuint kGLSizeUnsignedInt_8_8_8_8        = GLSizeUnsignedInt;
GLuint kGLSizeUnsignedInt_10_10_10_2     = GLSizeUnsignedInt;
GLuint kGLSizeUnsignedInt_8_8_8_8_REV    = GLSizeUnsignedInt;
GLuint kGLSizeUnsignedInt_2_10_10_10_REV = GLSizeUnsignedInt;
