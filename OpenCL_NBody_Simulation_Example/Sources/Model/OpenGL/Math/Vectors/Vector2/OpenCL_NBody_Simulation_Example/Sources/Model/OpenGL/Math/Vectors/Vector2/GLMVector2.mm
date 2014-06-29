/*
     File: GLMVector2.mm
 Abstract: 
 Utility class for managing 2-vectors.
 
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

#import "GLMVector2.h"

#pragma mark -
#pragma mark Private - Constants

static const GLfloat kRandMax = GLfloat(RAND_MAX);

#pragma mark -
#pragma mark Public - Vector 2

GLM::Vector2::Vector2(const bool& bIsClamped)
{
    if(bIsClamped)
    {
        x = GLfloat(std::rand()) / kRandMax * 2.0f - 1.0f;
        y = GLfloat(std::rand()) / kRandMax * 2.0f - 1.0f;
    } // if
    else
    {
        x = GLfloat(std::rand()) / kRandMax;
        y = GLfloat(std::rand()) / kRandMax;
    } // else
} // Constructor

GLM::Vector2::Vector2(const GLfloat& k)
{
	x = k;
	y = k;
} // Constructor

GLM::Vector2::Vector2(const GLfloat& X,
                      const GLfloat& Y)
{
	x = X;
	y = Y;
}// Constructor

GLM::Vector2::Vector2(const GLfloat * const v)
{
	if(v != NULL)
	{
		x = v[1];
		y = v[2];
	} // if
	else
	{
		x = 0.0f;
		y = 0.0f;
	} // else
} // Constructor

GLM::Vector2::~Vector2()
{
    x = 0.0f;
    y = 0.0f;
} // Destructor

GLM::Vector2::Vector2(const Vector2& v)
{
	x = v.x;
	y = v.y;
}// Copy Constructor

GLM::Vector2& GLM::Vector2::operator=(const Vector2& v)
{
	if(this != &v)
	{
		x = v.x;
		y = v.y;
	} // if
    
    return *this;
}// Assignment operator

GLM::Vector2& GLM::Vector2::operator-=(const Vector2& v)
{
	x -= v.x;
	y -= v.y;
	
	return *this;
} // operator-

GLM::Vector2& GLM::Vector2::operator+=(const Vector2& v)
{
	x += v.x;
	y += v.y;
	
	return *this;
} // operator+=

GLM::Vector2& GLM::Vector2::operator*=(const Vector2& v)
{
	x *= v.x;
	y *= v.y;
	
	return *this;
} // operator*=

GLM::Vector2& GLM::Vector2::operator/=(const Vector2& v)
{
	x /= v.x;
	y /= v.y;
	
	return *this;
} // operator/=

const GLM::Vector2 GLM::Vector2::operator-(const Vector2& v) const
{
	Vector2 r;
	
	r.x = x - v.x;
	r.y = y - v.y;
	
	return r;
} // operator-

const GLM::Vector2 GLM::Vector2::operator+(const Vector2& v) const
{
	Vector2 r;
	
	r.x = x + v.x;
	r.y = y + v.y;
	
	return r;
} // operator+

const GLM::Vector2 GLM::Vector2::operator*(const Vector2& v) const
{
	Vector2 r;
	
	r.x = x * v.x;
	r.y = y * v.y;
	
	return r;
} // operator*

const GLM::Vector2 GLM::Vector2::operator/(const Vector2& v) const
{
	Vector2 r;
	
	r.x = x / v.x;
	r.y = y / v.y;
	
	return r;
} // operator/

GLfloat GLM::sqr(const GLM::Vector2& v)
{
	return v.x * v.x + v.y * v.y;
} // sqr

GLfloat GLM::dot(const GLM::Vector2& u,
                 const GLM::Vector2& v)
{
	return u.x * v.x + u.y * v.y;
} // dot

GLfloat GLM::norm(const GLM::Vector2 &v)
{
    return std::sqrt(v.x * v.x + v.y * v.y);
} // norm

GLM::Vector2 GLM::normalize(const GLM::Vector2 &v)
{
    GLM::Vector2 w;
    
	GLfloat d = std::sqrt(v.x * v.x + v.y * v.y);
    
	if(std::abs(d - 1.0f) > 1.0e-6)
	{
        GLfloat s = 1.0f / d;
        
        w.x = s * v.x;
        w.y = s * v.y;
	} // if
    else
    {
        w.x = v.x;
        w.y = v.y;
    } // else
    
	return w;
} // normalize

GLM::Vector2 GLM::scale(const GLfloat& s,
                        const GLM::Vector2 &v)
{
	GLM::Vector2 w;
	
	w.x = s * v.x;
	w.y = s * v.y;
	
	return w;
} // scale

GLM::Vector2 GLM::translate(const GLfloat& t,
                            const GLM::Vector2 &v)
{
	GLM::Vector2 w;
	
	w.x = t + v.x;
	w.y = t + v.y;
	
	return w;
} // translate
