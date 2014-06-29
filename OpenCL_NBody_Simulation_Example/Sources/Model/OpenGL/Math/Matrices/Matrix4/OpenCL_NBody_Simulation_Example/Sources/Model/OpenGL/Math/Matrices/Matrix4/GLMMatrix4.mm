/*
     File: GLMMatrix4.mm
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

#pragma mark -
#pragma mark Private - Headers

#import <cmath>
#import <iostream>

#import "GLMMatrix4.h"

#pragma mark -
#pragma mark Public - Matrix 4

GLM::Matrix4::Matrix4(const GLfloat * const M)
{
    if(M != NULL)
    {
        m[0] = M[0];
        m[1] = M[1];
        m[2] = M[2];
        m[3] = M[3];
        
        m[4] = M[4];
        m[5] = M[5];
        m[6] = M[6];
        m[7] = M[7];
        
        m[8]  = M[8];
        m[9]  = M[9];
        m[10] = M[10];
        m[11] = M[11];
        
        m[12] = M[12];
        m[13] = M[13];
        m[14] = M[14];
        m[15] = M[15];
    } // if
    else
    {
        m[0] = 0.0f;
        m[1] = 0.0f;
        m[2] = 0.0f;
        m[3] = 0.0f;
        
        m[4] = 0.0f;
        m[5] = 0.0f;
        m[6] = 0.0f;
        m[7] = 0.0f;
        
        m[8]  = 0.0f;
        m[9]  = 0.0f;
        m[10] = 0.0f;
        m[11] = 0.0f;
        
        m[12] = 0.0f;
        m[13] = 0.0f;
        m[14] = 0.0f;
        m[15] = 0.0f;
    } // else
} // Constructor

GLM::Matrix4::Matrix4(const GLM::Vector4& p,
                      const GLM::Vector4& q,
                      const GLM::Vector4& r,
                      const GLM::Vector4& s)
{
    m[0] = p.t;
    m[1] = p.x;
    m[2] = p.y;
    m[3] = p.z;
    
    m[4] = q.t;
    m[5] = q.x;
    m[6] = q.y;
    m[7] = q.z;
    
    m[8]  = r.t;
    m[9]  = r.x;
    m[10] = r.y;
    m[11] = r.z;
    
    m[12] = s.t;
    m[13] = s.x;
    m[14] = s.y;
    m[15] = s.z;
} // Matrix4Create

GLM::Matrix4::~Matrix4()
{
    m[0] = 0.0f;
    m[1] = 0.0f;
    m[2] = 0.0f;
    m[3] = 0.0f;
    
    m[4] = 0.0f;
    m[5] = 0.0f;
    m[6] = 0.0f;
    m[7] = 0.0f;
    
    m[8]  = 0.0f;
    m[9]  = 0.0f;
    m[10] = 0.0f;
    m[11] = 0.0f;
    
    m[12] = 0.0f;
    m[13] = 0.0f;
    m[14] = 0.0f;
    m[15] = 0.0f;
} // Destructor

GLM::Matrix4::Matrix4(const GLM::Matrix4& M)
{
    m[0] = M.m[0];
    m[1] = M.m[1];
    m[2] = M.m[2];
    m[3] = M.m[3];
    
    m[4] = M.m[4];
    m[5] = M.m[5];
    m[6] = M.m[6];
    m[7] = M.m[7];
    
    m[8]  = M.m[8];
    m[9]  = M.m[9];
    m[10] = M.m[10];
    m[11] = M.m[11];
    
    m[12] = M.m[12];
    m[13] = M.m[13];
    m[14] = M.m[14];
    m[15] = M.m[15];
} // Copy Constructor

GLM::Matrix4& GLM::Matrix4::operator=(const GLM::Matrix4& M)
{
 	if(this != &M)
    {
        m[0] = M.m[0];
        m[1] = M.m[1];
        m[2] = M.m[2];
        m[3] = M.m[3];
        
        m[4] = M.m[4];
        m[5] = M.m[5];
        m[6] = M.m[6];
        m[7] = M.m[7];
        
        m[8]  = M.m[8];
        m[9]  = M.m[9];
        m[10] = M.m[10];
        m[11] = M.m[11];
        
        m[12] = M.m[12];
        m[13] = M.m[13];
        m[14] = M.m[14];
        m[15] = M.m[15];
    } // if
    
    return *this;
} // operator=

const GLM::Matrix4 GLM::Matrix4::operator+(const GLM::Matrix4& M) const
{
	GLM::Matrix4 C;
	
    C.m[0]  = m[0]  + M.m[0];
    C.m[1]  = m[1]  + M.m[1];
    C.m[2]  = m[2]  + M.m[2];
    C.m[3]  = m[3]  + M.m[3];
    
    C.m[4]  = m[4]  + M.m[4];
    C.m[5]  = m[5]  + M.m[5];
    C.m[6]  = m[6]  + M.m[6];
    C.m[7]  = m[7]  + M.m[7];
    
    C.m[8]  = m[8]  + M.m[8];
    C.m[9]  = m[9]  + M.m[9];
    C.m[10] = m[10] + M.m[10];
    C.m[11] = m[11] + M.m[11];
    
    C.m[12] = m[12] + M.m[12];
    C.m[13] = m[13] + M.m[13];
    C.m[14] = m[14] + M.m[14];
    C.m[15] = m[15] + M.m[15];
	
	return C;
} // Operator+

const GLM::Matrix4 GLM::Matrix4::operator-(const GLM::Matrix4& M) const
{
	GLM::Matrix4 C;
	
    C.m[0]  = m[0]  - M.m[0];
    C.m[1]  = m[1]  - M.m[1];
    C.m[2]  = m[2]  - M.m[2];
    C.m[3]  = m[3]  - M.m[3];
    
    C.m[4]  = m[4]  - M.m[4];
    C.m[5]  = m[5]  - M.m[5];
    C.m[6]  = m[6]  - M.m[6];
    C.m[7]  = m[7]  - M.m[7];
    
    C.m[8]  = m[8]  - M.m[8];
    C.m[9]  = m[9]  - M.m[9];
    C.m[10] = m[10] - M.m[10];
    C.m[11] = m[11] - M.m[11];
    
    C.m[12] = m[12] - M.m[12];
    C.m[13] = m[13] - M.m[13];
    C.m[14] = m[14] - M.m[14];
    C.m[15] = m[15] - M.m[15];
	
	return C;
} // operator-

const GLM::Matrix4 GLM::Matrix4::operator*(const GLM::Matrix4& M) const
{
    GLM::Matrix4 C;
    
	GLM::Vector4 a_1(m[0], m[1], m[2], m[3]);
	GLM::Vector4 a_2(m[4], m[5], m[6], m[7]);
	GLM::Vector4 a_3(m[8], m[9], m[10], m[11]);
	GLM::Vector4 a_4(m[12], m[13], m[14], m[15]);
    
	GLM::Vector4 b_1(M.m[0], M.m[4], M.m[8], M.m[12]);
	GLM::Vector4 b_2(M.m[1], M.m[5], M.m[9], M.m[13]);
	GLM::Vector4 b_3(M.m[2], M.m[6], M.m[10], M.m[14]);
	GLM::Vector4 b_4(M.m[3], M.m[7], M.m[11], M.m[15]);
    
    C.m[0] = GLM::dot(a_1, b_1);
    C.m[1] = GLM::dot(a_1, b_2);
    C.m[2] = GLM::dot(a_1, b_3);
    C.m[3] = GLM::dot(a_1, b_4);
    
    C.m[4] = GLM::dot(a_2, b_1);
    C.m[5] = GLM::dot(a_2, b_2);
    C.m[6] = GLM::dot(a_2, b_3);
    C.m[7] = GLM::dot(a_2, b_4);
    
    C.m[8]  = GLM::dot(a_3, b_1);
    C.m[9]  = GLM::dot(a_3, b_2);
    C.m[10] = GLM::dot(a_3, b_3);
    C.m[11] = GLM::dot(a_3, b_4);
	
    C.m[12] = GLM::dot(a_4, b_1);
    C.m[13] = GLM::dot(a_4, b_2);
    C.m[14] = GLM::dot(a_4, b_3);
    C.m[15] = GLM::dot(a_4, b_4);
    
    return C;
} // operator*

GLM::Matrix4& GLM::Matrix4::operator+=(const GLM::Matrix4& M)
{
    m[0]  += M.m[0];
    m[1]  += M.m[1];
    m[2]  += M.m[2];
    m[3]  += M.m[3];
    
    m[4]  += M.m[4];
    m[5]  += M.m[5];
    m[6]  += M.m[6];
    m[7]  += M.m[7];
    
    m[8]  += M.m[8];
    m[9]  += M.m[9];
    m[10] += M.m[10];
    m[11] += M.m[11];
    
    m[12] += M.m[12];
    m[13] += M.m[13];
    m[14] += M.m[14];
    m[15] += M.m[15];
    
    return *this;
} // operator+=

GLM::Matrix4& GLM::Matrix4::operator-=(const GLM::Matrix4& M)
{
    m[0]  -= M.m[0];
    m[1]  -= M.m[1];
    m[2]  -= M.m[2];
    m[3]  -= M.m[3];
    
    m[4]  -= M.m[4];
    m[5]  -= M.m[5];
    m[6]  -= M.m[6];
    m[7]  -= M.m[7];
    
    m[8]  -= M.m[8];
    m[9]  -= M.m[9];
    m[10] -= M.m[10];
    m[11] -= M.m[11];
    
    m[12] -= M.m[12];
    m[13] -= M.m[13];
    m[14] -= M.m[14];
    m[15] -= M.m[15];
    
    return *this;
} // operator+=

GLM::Matrix4& GLM::Matrix4::operator*=(const GLM::Matrix4& M)
{
    GLM::Matrix4 C;
    
	GLM::Vector4 a_1(m[0], m[1], m[2], m[3]);
	GLM::Vector4 a_2(m[4], m[5], m[6], m[7]);
	GLM::Vector4 a_3(m[8], m[9], m[10], m[11]);
	GLM::Vector4 a_4(m[12], m[13], m[14], m[15]);
    
	GLM::Vector4 b_1(M.m[0], M.m[4], M.m[8], M.m[12]);
	GLM::Vector4 b_2(M.m[1], M.m[5], M.m[9], M.m[13]);
	GLM::Vector4 b_3(M.m[2], M.m[6], M.m[10], M.m[14]);
	GLM::Vector4 b_4(M.m[3], M.m[7], M.m[11], M.m[15]);
    
    m[0] = GLM::dot(a_1, b_1);
    m[1] = GLM::dot(a_1, b_2);
    m[2] = GLM::dot(a_1, b_3);
    m[3] = GLM::dot(a_1, b_4);
    
    m[4] = GLM::dot(a_2, b_1);
    m[5] = GLM::dot(a_2, b_2);
    m[6] = GLM::dot(a_2, b_3);
    m[7] = GLM::dot(a_2, b_4);
    
    m[8]  = GLM::dot(a_3, b_1);
    m[9]  = GLM::dot(a_3, b_2);
    m[10] = GLM::dot(a_3, b_3);
    m[11] = GLM::dot(a_3, b_4);
	
    m[12] = GLM::dot(a_4, b_1);
    m[13] = GLM::dot(a_4, b_2);
    m[14] = GLM::dot(a_4, b_3);
    m[15] = GLM::dot(a_4, b_4);
    
    return *this;
} // operator*

GLfloat GLM::det(const GLM::Matrix4& A)
{
	GLfloat Det_2x2[6];
    
    Det_2x2[0] = A.m[8]  * A.m[13] - A.m[9]  * A.m[12];
    Det_2x2[1] = A.m[8]  * A.m[14] - A.m[10] * A.m[12];
    Det_2x2[2] = A.m[8]  * A.m[15] - A.m[11] * A.m[12];
    Det_2x2[3] = A.m[9]  * A.m[14] - A.m[10] * A.m[13];
    Det_2x2[4] = A.m[9]  * A.m[15] - A.m[11] * A.m[13];
    Det_2x2[5] = A.m[10] * A.m[15] - A.m[11] * A.m[14];
    
    // Compute the 4 3x3 determinants
    
	GLfloat Det_3x3[4];
    
    Det_3x3[0] = A.m[4] * Det_2x2[3] - A.m[5] * Det_2x2[1] + A.m[6] * Det_2x2[0];
    Det_3x3[1] = A.m[4] * Det_2x2[4] - A.m[5] * Det_2x2[2] + A.m[7] * Det_2x2[0];
    Det_3x3[2] = A.m[4] * Det_2x2[5] - A.m[6] * Det_2x2[2] + A.m[7] * Det_2x2[1];
    Det_3x3[3] = A.m[5] * Det_2x2[5] - A.m[6] * Det_2x2[4] + A.m[7] * Det_2x2[3];
    
    // Find the 4x4 det:
    
    GLfloat det = A.m[0] * Det_3x3[3]
    - A.m[1] * Det_3x3[2]
    + A.m[2] * Det_3x3[1]
    - A.m[3] * Det_3x3[0];
    
	return det;
} // det

GLM::Matrix4 GLM::inv(const GLM::Matrix4& A)
{
    // Compute the last 6 of the 18 2x2 determinants
    
	GLfloat Det_2x2[18];
    
    Det_2x2[12] = A.m[8]  * A.m[13] - A.m[9]  * A.m[12];
    Det_2x2[13] = A.m[8]  * A.m[14] - A.m[10] * A.m[12];
    Det_2x2[14] = A.m[8]  * A.m[15] - A.m[11] * A.m[12];
    Det_2x2[15] = A.m[9]  * A.m[14] - A.m[10] * A.m[13];
    Det_2x2[16] = A.m[9]  * A.m[15] - A.m[11] * A.m[13];
    Det_2x2[17] = A.m[10] * A.m[15] - A.m[11] * A.m[14];
    
    // Compute the last 4 of the 16 3x3 determinants
    
	GLfloat Det_3x3[16];
    
    Det_3x3[12] = A.m[4] * Det_2x2[15] - A.m[5] * Det_2x2[13] + A.m[6] * Det_2x2[12];
    Det_3x3[13] = A.m[4] * Det_2x2[16] - A.m[5] * Det_2x2[14] + A.m[7] * Det_2x2[12];
    Det_3x3[14] = A.m[4] * Det_2x2[17] - A.m[6] * Det_2x2[14] + A.m[7] * Det_2x2[13];
    Det_3x3[15] = A.m[5] * Det_2x2[17] - A.m[6] * Det_2x2[16] + A.m[7] * Det_2x2[15];
    
    // Find the 4x4 det:
    
    const GLfloat det = A.m[0] * Det_3x3[15]
    - A.m[1] * Det_3x3[14]
    + A.m[2] * Det_3x3[13]
    - A.m[3] * Det_3x3[12];
    
	if(det < 1.0e-9)
	{
		std::cerr << ">> ERROR: OpenGL Math Matrix 4 -  4x4 matrix is singular!" << std::endl;
		
		return A;
	} // if
    
    // If not singular then compute the rest of the 18 2x2 determinants
    
    Det_2x2[0]  = A.m[4]  * A.m[9]  - A.m[5]  * A.m[8];
    Det_2x2[1]  = A.m[4]  * A.m[10] - A.m[6]  * A.m[8];
    Det_2x2[2]  = A.m[4]  * A.m[11] - A.m[7]  * A.m[8];
    Det_2x2[3]  = A.m[5]  * A.m[11] - A.m[7]  * A.m[9];
    Det_2x2[4]  = A.m[6]  * A.m[11] - A.m[7]  * A.m[10];
    Det_2x2[5]  = A.m[5]  * A.m[10] - A.m[6]  * A.m[9];
    Det_2x2[6]  = A.m[4]  * A.m[13] - A.m[5]  * A.m[12];
    Det_2x2[7]  = A.m[4]  * A.m[14] - A.m[6]  * A.m[12];
    Det_2x2[8]  = A.m[4]  * A.m[15] - A.m[7]  * A.m[12];
    Det_2x2[9]  = A.m[5]  * A.m[14] - A.m[6]  * A.m[13];
    Det_2x2[10] = A.m[5]  * A.m[15] - A.m[7]  * A.m[13];
    Det_2x2[11] = A.m[6]  * A.m[15] - A.m[7]  * A.m[14];
    
    // If not singular then compute the rest of the 16 3x3 determinants
    
    Det_3x3[0]  = A.m[0] * Det_2x2[5]  - A.m[1] * Det_2x2[1]  + A.m[2] * Det_2x2[0];
    Det_3x3[1]  = A.m[0] * Det_2x2[3]  - A.m[1] * Det_2x2[2]  + A.m[3] * Det_2x2[0];
    Det_3x3[2]  = A.m[0] * Det_2x2[4]  - A.m[2] * Det_2x2[2]  + A.m[3] * Det_2x2[1];
    Det_3x3[3]  = A.m[1] * Det_2x2[4]  - A.m[2] * Det_2x2[3]  + A.m[3] * Det_2x2[5];
    Det_3x3[4]  = A.m[0] * Det_2x2[9]  - A.m[1] * Det_2x2[7]  + A.m[2] * Det_2x2[6];
    Det_3x3[5]  = A.m[0] * Det_2x2[10] - A.m[1] * Det_2x2[8]  + A.m[3] * Det_2x2[6];
    Det_3x3[6]  = A.m[0] * Det_2x2[11] - A.m[2] * Det_2x2[8]  + A.m[3] * Det_2x2[7];
    Det_3x3[7]  = A.m[1] * Det_2x2[11] - A.m[2] * Det_2x2[10] + A.m[3] * Det_2x2[9];
    Det_3x3[8]  = A.m[0] * Det_2x2[15] - A.m[1] * Det_2x2[13] + A.m[2] * Det_2x2[12];
    Det_3x3[9]  = A.m[0] * Det_2x2[16] - A.m[1] * Det_2x2[14] + A.m[3] * Det_2x2[12];
    Det_3x3[10] = A.m[0] * Det_2x2[17] - A.m[2] * Det_2x2[14] + A.m[3] * Det_2x2[13];
    Det_3x3[11] = A.m[1] * Det_2x2[17] - A.m[2] * Det_2x2[16] + A.m[3] * Det_2x2[15];
    
    const GLfloat idet = 1.0f / det;
    
    GLM::Matrix4 B;
    
    B.m[0] =   Det_3x3[15] * idet;
    B.m[1] =  -Det_3x3[11] * idet;
    B.m[2] =   Det_3x3[7]  * idet;
    B.m[3] =  -Det_3x3[3]  * idet;
    
    B.m[4] =  -Det_3x3[14] * idet;
    B.m[5] =   Det_3x3[10] * idet;
    B.m[6] =  -Det_3x3[6]  * idet;
    B.m[7] =   Det_3x3[2]  * idet;
    
    B.m[8]  =   Det_3x3[13] * idet;
    B.m[9]  =  -Det_3x3[9]  * idet;
    B.m[10] =   Det_3x3[5]  * idet;
    B.m[11] =  -Det_3x3[1]  * idet;
    
    B.m[12] =  -Det_3x3[12] * idet;
    B.m[13] =   Det_3x3[8]  * idet;
    B.m[14] =  -Det_3x3[4]  * idet;
    B.m[15] =   Det_3x3[0]  * idet;
    
	return B;
} // inv

GLM::Matrix4 GLM::tr(const GLM::Matrix4& A)
{
    GLM::Matrix4 T;
    
    T.m[0]  = A.m[0];
    T.m[1]  = A.m[4];
    T.m[2]  = A.m[8];
    T.m[3]  = A.m[12];
    
    T.m[4]  = A.m[1];
    T.m[5]  = A.m[5];
    T.m[6]  = A.m[9];
    T.m[7]  = A.m[13];
    
    T.m[8]  = A.m[2];
    T.m[9]  = A.m[6];
    T.m[10] = A.m[10];
    T.m[11] = A.m[14];
    
    T.m[12] = A.m[3];
    T.m[13] = A.m[7];
    T.m[14] = A.m[11];
    T.m[15] = A.m[15];
    
    return T;
} // tr

GLM::Vector4 GLM::solve(const GLM::Matrix4& A,
                        const GLM::Vector4& b)
{
    GLM::Matrix4 M = GLM::inv(A);
    
	GLM::Vector4 p(M.m[0], M.m[1], M.m[2], M.m[3]);
	GLM::Vector4 q(M.m[4], M.m[5], M.m[6], M.m[7]);
	GLM::Vector4 r(M.m[8], M.m[9], M.m[10], M.m[11]);
	GLM::Vector4 s(M.m[12], M.m[13], M.m[14], M.m[15]);
    
    GLM::Vector4 u;
    
    u.t = GLM::dot(p, b);
    u.x = GLM::dot(q, b);
    u.y = GLM::dot(r, b);
    u.z = GLM::dot(s, b);
    
	return u;
} // Matrix4Solve
