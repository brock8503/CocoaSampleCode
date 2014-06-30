/*
     File: GLMTransforms.h
 Abstract: 
 Utility methods for linear transformations of projective geometry.
 
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

#ifndef _OPENGL_MATH_TRANSFORMS_H_
#define _OPENGL_MATH_TRANSFORMS_H_

#import <OpenGL/OpenGL.h>

#import "GLMVector3.h"
#import "GLMVector4.h"
#import "GLMMatrix4.h"

#ifdef __cplusplus

namespace GLM
{
    Matrix4 scale(const GLfloat& x,
                  const GLfloat& y,
                  const GLfloat& z);
    
    Matrix4 scale(const Vector3& s);
    
    Matrix4 translate(const GLfloat& x,
                      const GLfloat& y,
                      const GLfloat& z);
    
    Matrix4 translate(const Vector3& t);
    
    Matrix4 rotate(const GLfloat& angle,
                   const GLfloat& x,
                   const GLfloat& y,
                   const GLfloat& z);
    
    Matrix4 rotate(const GLfloat& angle,
                   const Vector3& u);
    
    Matrix4 frustum(const GLfloat& left,
                    const GLfloat& right,
                    const GLfloat& bottom,
                    const GLfloat& top,
                    const GLfloat& near,
                    const GLfloat& far);
    
    Matrix4 frustum(const GLfloat& angle,
                    const GLfloat& width,
                    const GLfloat& heigth,
                    const GLfloat& near,
                    const GLfloat& far);
    
    Matrix4 frustum(const GLfloat& angle,
                    const GLfloat& aspect,
                    const GLfloat& near,
                    const GLfloat& far);
    
    Matrix4 frustum(const Vector3& near,
                    const Vector3& far);
    
    Matrix4 lookAt(const GLfloat * const pEye,
                   const GLfloat * const pCenter,
                   const GLfloat * const pUp);
    
    Matrix4 lookAt(const Vector3& eye,
                   const Vector3& center,
                   const Vector3& up);
    
    Matrix4 perspective(const GLfloat& fovy,
                        const GLfloat& aspect,
                        const GLfloat& near,
                        const GLfloat& far);
    
    Matrix4 perspective(const GLfloat& fovy,
                        const GLfloat& width,
                        const GLfloat& height,
                        const GLfloat& near,
                        const GLfloat& far);
    
    Matrix4 ortho(const GLfloat& left,
                  const GLfloat& right,
                  const GLfloat& bottom,
                  const GLfloat& top,
                  const GLfloat& near,
                  const GLfloat& far);
    
    Matrix4 ortho(const Vector3& origin,
                  const Vector3& size);
} // GLM

#endif

#endif
