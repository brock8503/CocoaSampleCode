/*
     File: GLMMatrix4.h
 Abstract: 
 Utility class for managing 4x4 matrices.
 
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

#ifndef _OPENGL_MATH_MATRIX_4_H_
#define _OPENGL_MATH_MATRIX_4_H_

#import <OpenGL/OpenGL.h>

#import "GLMVector3.h"
#import "GLMVector4.h"

#ifdef __cplusplus

namespace GLM
{
    class Matrix4
    {
    public:
        Matrix4(const GLfloat * const M = NULL);
        
        Matrix4(const Vector4& p,
                const Vector4& q,
                const Vector4& r,
                const Vector4& s);
        
        virtual ~Matrix4();
        
        Matrix4(const Matrix4& M);
        
        Matrix4& operator=(const Matrix4& M);
        
        const Matrix4 operator+(const Matrix4& M) const;
        const Matrix4 operator-(const Matrix4& M) const;
        const Matrix4 operator*(const Matrix4& M) const;
        
        Matrix4& operator+=(const Matrix4& M);
        Matrix4& operator-=(const Matrix4& M);
        Matrix4& operator*=(const Matrix4& M);
        
    public:
        union
        {
            GLfloat m[16];
            
            struct
            {
                GLfloat m_00, m_01, m_02, m_03;
                GLfloat m_10, m_11, m_12, m_13;
                GLfloat m_20, m_21, m_22, m_23;
                GLfloat m_30, m_31, m_32, m_33;
            }; // struct
        }; // union
    }; // Matrix4

    GLfloat det(const Matrix4& A);
    
    Matrix4 inv(const Matrix4& A);
    
    Matrix4 tr(const Matrix4& A);
    
    Vector4 solve(const Matrix4& A,
                  const Vector4& b);
} // GLM

#endif

#endif
