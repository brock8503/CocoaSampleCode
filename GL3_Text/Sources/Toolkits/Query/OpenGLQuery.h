/*
     File: OpenGLQuery.h
 Abstract: 
 Utility toolkit for constructing a query of OpenGL Core profile features.
 
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

#ifndef _OPENGL_QUERY_H_
#define _OPENGL_QUERY_H_

// Mac OS X frameworks
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>

// OpenGL container types
#import "OpenGLContainers.h"

#ifdef __cplusplus

// In a large scale system architecture, instead of exposing the data
// structure, one would hide all the instance variables and instead
// expose a single opaque data reference.  In this case our opaque data
// reference is represented by a pointer to GLQuery structure.  The
// details of this data structure are hidden and only exposed in the
// implementation file.  All subsequent methods then work with this
// opaque data reference.
typedef struct GLQuery  *GLQueryRef;

// Query OpenGL for features
GLQueryRef GLQueryCreate();

// Delete query
void GLQueryDelete(GLQueryRef pQuery);

// Is the feature available
const bool GLQueryFeatureIsAvailable(const GLfeature &rFeature, GLQueryRef pQuery);

// If the feature is found, the returned string will be GL_APPLE, GL_ARB, or GL_EXT
const GLstring GLQueryFeatureGetType(const GLfeature &rFeature, GLQueryRef pQuery);

// OpenGL Apple features
const GLfeatures GLQueryFeaturesGetApple(const GLQueryRef pQuery);

// OpenGL ARB features
const GLfeatures GLQueryFeaturesGetARB(const GLQueryRef pQuery);

// OpenGL EXT features
const GLfeatures GLQueryFeaturesGetEXT(const GLQueryRef pQuery);

// OpenGL vendor
const GLstring GLQueryStringGetVendor(const GLQueryRef pQuery);

// OpenGL version
const GLstring GLQueryStringGetVersion(const GLQueryRef pQuery);

// OpenGL renderer
const GLstring GLQueryStringGetRenderer(const GLQueryRef pQuery);

// OpenGL Apple features as a string, where each feature is separated using a seperator string
const GLstring GLQueryStringGetApple(const GLstring &rSeperator, const GLQueryRef pQuery);

// OpenGL Apple features as a string, where each feature is separated using a seperator string
const GLstring GLQueryStringGetARB(const GLstring &rSeperator, const GLQueryRef pQuery);

// OpenGL Apple features as a string, where each feature is separated using a seperator string
const GLstring GLQueryStringGetEXT(const GLstring &rSeperator, const GLQueryRef pQuery);

// Apple feature set as a CF array
CFArrayRef GLQueryArrayGetApple(GLQueryRef pQuery);

// ARB feature set as a CF array
CFArrayRef GLQueryArrayGetARB(GLQueryRef pQuery);

// EXT feature set as a CF array
CFArrayRef GLQueryArrayGetEXT(GLQueryRef pQuery);

#endif

#endif

