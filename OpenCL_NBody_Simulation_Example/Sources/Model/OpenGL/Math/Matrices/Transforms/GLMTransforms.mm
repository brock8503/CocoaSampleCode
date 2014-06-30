/*
     File: GLMTransforms.mm
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

#pragma mark -
#pragma mark Private - Headers

#import <cmath>
#import <iostream>

#import "GLMConstants.h"
#import "GLMTransforms.h"

#pragma mark -
#pragma mark Private - Utilities

static GLfloat GLMToRadians(const GLfloat &degrees)
{
    return degrees * GLM::kPiDiv180_f;
} // GLMToRadians

#pragma mark -
#pragma mark Public - Transformations - Scale

GLM::Matrix4 GLM::scale(const GLfloat& x,
                        const GLfloat& y,
                        const GLfloat& z)
{
    GLM::Matrix4 M;
    
    M.m[0] = x;
    M.m[1] = 0.0f;
    M.m[2] = 0.0f;
    M.m[3] = 0.0f;
    
    M.m[4] = 0.0f;
    M.m[5] = y;
    M.m[6] = 0.0f;
    M.m[7] = 0.0f;
    
    M.m[8]  = 0.0f;
    M.m[9]  = 0.0f;
    M.m[10] = z;
    M.m[11] = 0.0f;
    
    M.m[12] = 0.0f;
    M.m[13] = 0.0f;
    M.m[14] = 0.0f;
    M.m[15] = 1.0f;
    
    return M;
} // Scale

GLM::Matrix4 GLM::scale(const GLM::Vector3& s)
{
    return GLM::scale(s.x, s.y, s.z);
} // Scale

#pragma mark -
#pragma mark Public - Transformations - Translate

GLM::Matrix4 GLM::translate(const GLfloat& x,
                            const GLfloat& y,
                            const GLfloat& z)
{
    GLM::Matrix4 M;
    
    M.m[0] = 1.0f;
    M.m[1] = 0.0f;
    M.m[2] = 0.0f;
    M.m[3] = x;
    
    M.m[4] = 0.0f;
    M.m[5] = 1.0f;
    M.m[6] = 0.0f;
    M.m[7] = y;
    
    M.m[8]  = 0.0f;
    M.m[9]  = 0.0f;
    M.m[10] = 1.0f;
    M.m[11] = z;
    
    M.m[12] = 0.0f;
    M.m[13] = 0.0f;
    M.m[14] = 0.0f;
    M.m[15] = 1.0f;
    
    return M;
} // Translate

GLM::Matrix4 GLM::translate(const GLM::Vector3& t)
{
    return GLM::translate(t.x, t.y, t.z);
} // Translate

#pragma mark -
#pragma mark Public - Transformations - Rotate

GLM::Matrix4 GLM::rotate(const GLfloat& angle,
                         const GLM::Vector3& r)
{
    GLfloat a = GLMToRadians(angle);
    GLfloat c = std::cos(a);
    GLfloat s = std::sin(a);
    GLfloat k = 1.0f - c;
    
    GLM::Vector3 u = GLM::normalize(r);
    GLM::Vector3 v = GLM::scale(s, u);
    GLM::Vector3 w = GLM::scale(k, u);
    
    GLM::Matrix4 M;
    
    M.m[0] = w.x * u.x + c;
    M.m[1] = w.x * u.y - v.z;
    M.m[2] = w.x * u.z + v.y;
    M.m[3] = 0.0f;
    
    M.m[4] = w.y * u.x + v.z;
    M.m[5] = w.y * u.y + c;
    M.m[6] = w.y * u.z - v.x;
    M.m[7] = 0.0f;
    
    M.m[8]  = w.z * u.x - v.y;
    M.m[9]  = w.z * u.y + v.x;
    M.m[10] = w.z * u.z + c;
    M.m[11] = 0.0f;
    
    M.m[12] = 0.0f;
    M.m[13] = 0.0f;
    M.m[14] = 0.0f;
    M.m[15] = 1.0f;
    
    return M;
} // Rotate

GLM::Matrix4 GLM::rotate(const GLfloat& angle,
                         const GLfloat& x,
                         const GLfloat& y,
                         const GLfloat& z)
{
    GLM::Vector3 r(x, y, z);
    
    return GLM::rotate(angle, r);
} // Rotate

#pragma mark -
#pragma mark Public - Transformations - Perspective

GLM::Matrix4 GLM::perspective(const GLfloat& fovy,
                              const GLfloat& aspect,
                              const GLfloat& near,
                              const GLfloat& far)
{
    GLM::Matrix4 M;
    
    GLfloat dNear = 2.0f * near;
    
    GLfloat hFovy = fovy / 2.0f;
    GLfloat theta = GLMToRadians(hFovy);
    GLfloat range = near * std::tan(theta);
    
    GLfloat left   = -range * aspect;
    GLfloat right  =  range * aspect;
    GLfloat bottom = -range;
    GLfloat top    =  range;
    
    GLfloat sWidth  = 1.0f / (right - left);
    GLfloat sHeight = 1.0f / (top - bottom);
    GLfloat sDepth  = 1.0f / (far - near);
    
    M.m[0] = dNear * sWidth;
    M.m[1] = 0.0f;
    M.m[2] = 0.0f;
    M.m[3] = 0.0f;
    
    M.m[4] = 0.0f;
    M.m[5] = dNear * sHeight;
    M.m[6] = 0.0f;
    M.m[7] = 0.0f;
    
    M.m[8]  = 0.0f;
    M.m[9]  = 0.0f;
    M.m[10] = -sDepth * (far + near);
    M.m[11] = -1.0f;
    
    M.m[12] = 0.0f;
    M.m[13] = 0.0f;
    M.m[14] = -dNear * sDepth * far;
    M.m[15] = 0.0f;
    
    return M;
} // Perspective

GLM::Matrix4 GLM::perspective(const GLfloat& fovy,
                              const GLfloat& width,
                              const GLfloat& height,
                              const GLfloat& near,
                              const GLfloat& far)
{
    GLfloat aspect = width / height;
    
    return GLM::perspective(fovy, aspect, near, far);
} // Perspective

#pragma mark -
#pragma mark Public - Transformations - LookAt

GLM::Matrix4 GLM::lookAt(const GLM::Vector3& eye,
                         const GLM::Vector3& center,
                         const GLM::Vector3& up)
{
    GLM::Matrix4 M;
    
    GLM::Vector3 N = GLM::normalize(eye - center);
    GLM::Vector3 U = GLM::normalize(GLM::cross(up, N));
    GLM::Vector3 V = GLM::cross(N, U);
    
    M.m[0] = U.x;
    M.m[1] = V.x;
    M.m[2] = N.x;
    M.m[3] = 0.0f;
    
    M.m[4] = U.y;
    M.m[5] = V.y;
    M.m[6] = N.y;
    M.m[7] = 0.0f;
    
    M.m[8]  = U.z;
    M.m[9]  = V.z;
    M.m[10] = N.z;
    M.m[11] = 0.0f;
    
    M.m[12] = -GLM::dot(U, eye);
    M.m[13] = -GLM::dot(V, eye);
    M.m[14] = -GLM::dot(N, eye);
    M.m[15] =  1.0f;
    
    return M;
} // LookAt

GLM::Matrix4 GLM::lookAt(const GLfloat * const pEye,
                         const GLfloat * const pCenter,
                         const GLfloat * const pUp)
{
    GLM::Vector3 eye(pEye);
    GLM::Vector3 center(pCenter);
    GLM::Vector3 up(pUp);
    
    return GLM::lookAt(eye, center, up);
} // lookAt

#pragma mark -
#pragma mark Public - Transformations - Orthographic

GLM::Matrix4 GLM::ortho(const GLfloat& left,
                        const GLfloat& right,
                        const GLfloat& bottom,
                        const GLfloat& top,
                        const GLfloat& near,
                        const GLfloat& far)
{
    GLM::Matrix4 M;
    
    GLfloat sWidth  = 1.0f / (right - left);
    GLfloat sHeight = 1.0f / (top   - bottom);
    GLfloat sDepth  = 1.0f / (far   - near);
    
    M.m[0] = 2.0f * sWidth;
    M.m[1] = 0.0f;
    M.m[2] = 0.0f;
    M.m[3] = 0.0f;
    
    M.m[4] = 0.0f;
    M.m[5] = 2.0f * sHeight;
    M.m[6] = 0.0f;
    M.m[7] = 0.0f;
    
    M.m[8]  =  0.0f;
    M.m[9]  =  0.0f;
    M.m[10] = -2.0f * sDepth;
    M.m[11] =  0.0f;
    
    M.m[12] = -sWidth  * (right + left);
    M.m[13] = -sHeight * (top   + bottom);
    M.m[14] = -sDepth  * (far   + near);
    M.m[15] =  1.0f;
    
    return M;
} // Ortho

GLM::Matrix4 GLM::ortho(const GLM::Vector3& origin,
                        const GLM::Vector3& size)
{
    return GLM::ortho(origin.x, origin.y, origin.z, size.x, size.y, size.z);
} // Ortho

#pragma mark -
#pragma mark Public - Transformations - frustum

GLM::Matrix4 GLM::frustum(const GLfloat& left,
                          const GLfloat& right,
                          const GLfloat& bottom,
                          const GLfloat& top,
                          const GLfloat& near,
                          const GLfloat& far)
{
    GLfloat sWidth  = 1.0f / (right - left);
    GLfloat sHeight = 1.0f / (top   - bottom);
    GLfloat sDepth  = 1.0f / (far   - near);
    GLfloat dNear   = 2.0f * near;
    
    GLM::Matrix4 M;
    
    M.m[0] = dNear * sWidth;
    M.m[1] = 0.0f;
    M.m[2] = 0.0f;
    M.m[3] = 0.0f;
    
    M.m[4] = 0.0f;
    M.m[5] = dNear * sHeight;
    M.m[6] = 0.0f;
    M.m[7] = 0.0f;
    
    M.m[8]  =  sWidth  * (right + left);
    M.m[9]  =  sHeight * (top   + bottom);
    M.m[10] = -sDepth  * (far   + near);
    M.m[11] = -1.0f;
    
    M.m[12] = 0.0f;
    M.m[13] = 0.0f;
    M.m[14] = -sDepth * dNear * far;
    M.m[15] = 0.0f;
    
    return M;
} // frustum

GLM::Matrix4 GLM::frustum(const GLfloat& angle,
                          const GLfloat& aspect,
                          const GLfloat& near,
                          const GLfloat& far)
{
    const GLfloat theta = GLM::kPiDiv360_f * angle;
    const GLfloat diam  = near * std::tan(theta);
    
    GLfloat left;
    GLfloat right;
    GLfloat top;
    GLfloat bottom;
    
    if( aspect >= 1.0f )
    {
        right  =  aspect * diam;
        left   = -right;
        top    =  diam;
        bottom = -top;
    } // if
    else
    {
        right  =  diam;
        left   = -right;
        top    =  diam / aspect;
        bottom = -top;
    } // else
    
    return GLM::frustum(left, right, bottom, top, near, far);
} // frustum

GLM::Matrix4 GLM::frustum(const GLfloat& angle,
                          const GLfloat& width,
                          const GLfloat& heigth,
                          const GLfloat& near,
                          const GLfloat& far)
{
    const GLfloat aspect = width / heigth;
    
    return GLM::frustum(angle, aspect, near, far);
} // frustum

GLM::Matrix4 GLM::frustum(const GLM::Vector3& near,
                          const GLM::Vector3& far)
{
    GLM::Vector3 u = far - near;
    GLM::Vector3 v = far + near;
    GLM::Vector3 w;
    
    w.x = 1.0f / u.x;
	w.y = 1.0f / u.y;
	w.z = 1.0f / u.z;
    
    GLfloat z = 2.0f * near.z;
    
    GLM::Vector3 W;
    
    W.x = z * w.x;
    W.y = z * w.y;
    W.z = z * w.z;
    
    GLM::Matrix4 M;
    
    M.m[0] = W.x;
    M.m[1] = 0.0f;
    M.m[2] = 0.0f;
    M.m[3] = 0.0f;
    
    M.m[4] = 0.0f;
    M.m[5] = W.y;
    M.m[6] = 0.0f;
    M.m[7] = 0.0f;
    
    M.m[8]  =  w.x * v.x;
    M.m[9]  =  w.y * v.y;
    M.m[10] = -w.z * v.z;
    M.m[11] = -1.0f;
    
    M.m[12] = 0.0f;
    M.m[13] = 0.0f;
    M.m[14] = -W.z * far.z;
    M.m[15] = 0.0f;
    
    return M;
} // frustum
