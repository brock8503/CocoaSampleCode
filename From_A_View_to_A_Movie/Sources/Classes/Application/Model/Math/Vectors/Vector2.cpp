/*
     File: Vector2.cpp
 Abstract: 
  Template class for 2-Vector operators and methods.
 
  Version: 1.2
 
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

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#import <cmath>
#import <iostream>

//------------------------------------------------------------------------

#import "Vector2.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type>::Vector2()
{
	x = Type(0);
	y = Type(0);
} // Default Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type>::Vector2(const Type &k)
{
	x = k;
	y = k;
}// Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type>::Vector2(const Type &X,
							 const Type &Y)
{
	x = X;
	y = Y;
}// Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type>::Vector2(const Type * const v)
{
	if( v != NULL )
	{
		x = v[0];
		y = v[1];
	} // if
	else
	{
		x = Type(0);
		y = Type(0);
	} // else
}// Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type>::Vector2(const Math::Vector2<Type> &v)
{
	x = v.x;
	y = v.y;
}// Copy Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type>::Vector2(const Math::Vector2<Type> * const v)
{
    if( v != NULL )
    {
        x = v->x;
        y = v->y;
    } // if
    else
    {
        x = Type(0);
        y = Type(0);
    } // else
}// Copy Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> &Math::Vector2<Type>::operator=(const Math::Vector2<Type> &v)
{
	if( this != &v )
	{
		x = v.x;
		y = v.y;
	} // if
    
    return *this;
}// Assignment operator

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> &Math::Vector2<Type>::operator=(const Type * const v)
{
	if( v != NULL )
	{
		x = v[0];
		y = v[1];
	} // if
    
    return *this;
}// Assignment operator

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> &Math::Vector2<Type>::operator=(const Type &k)
{
    x = k;
    y = k;
    
    return *this;
}// Assignment operator

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Math::Vector2<Type>::operator-(const Math::Vector2<Type> &v) const
{
	Vector2 w;
	
	w.x = x - v.x;
	w.y = y - v.y;
	
	return w;
} // operator-

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Math::Vector2<Type>::operator+(const Math::Vector2<Type> &v) const
{
	Vector2 w;
	
	w.x = x + v.x;
	w.y = y + v.y;
	
	return w;
} // operator+

//------------------------------------------------------------------------

template <typename Type>
const Type Math::Vector2<Type>::operator*(const Math::Vector2<Type> &v) const
{
	Type m;
	
	m = x * v.x + y * v.y;
	
	return m;
} // operator*

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> &Math::Vector2<Type>::operator-=(const Math::Vector2<Type> &v)
{
	x -= v.x;
	y -= v.y;
	
	return *this;
} // operator-=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> &Math::Vector2<Type>::operator+=(const Math::Vector2<Type> &v)
{
	x += v.x;
	y += v.y;
	
	return *this;
} // operator+=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> Math::Vector2<Type>::operator+() const
{
	return Math::Vector2<Type>(x,y);
} // operator+()

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> Math::Vector2<Type>::operator-() const
{
	return Math::Vector2<Type>(-x,-y);
} // operator-()

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Math::Vector2<Type>::operator-(const Type &k) const
{
	Vector2 p;
	
	p.x = x - k;
	p.y = y - k;
	
	return p;
} // operator-

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Math::Vector2<Type>::operator+(const Type &k) const
{
	Vector2 p;
	
	p.x = x + k;
	p.y = y + k;
	
	return p;
} // operator+

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Math::Vector2<Type>::operator*(const Type &k) const
{
	Vector2 p;
	
	p.x = x * k;
	p.y = y * k;
	
	return p;
} // operator*

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Math::Vector2<Type>::operator/(const Type &k) const
{
	Vector2 p;
	
	p.x = x / k;
	p.y = y / k;
	
	return p;
} // operator/

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> &Math::Vector2<Type>::operator-=(const Type &k)
{
	x -= k;
	y -= k;
	
	return *this;
} // operator-=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> &Math::Vector2<Type>::operator+=(const Type &k)
{
	x += k;
	y += k;
	
	return *this;
} // operator+=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> &Math::Vector2<Type>::operator*=(const Type &k)
{
	x *= k;
	y *= k;
	
	return *this;
} // operator*=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector2<Type> &Math::Vector2<Type>::operator/=(const Type &k)
{
	if(s != 0)
	{
		x /= k;
		y /= k;
	} // if
	
	return *this;
} // operator/=

//------------------------------------------------------------------------

template <typename Type>
Type &Math::Vector2<Type>::operator[](const std::size_t &i)
{
    return array[i];
} // operator[]

//------------------------------------------------------------------------

template <typename Type>
const Type &Math::Vector2<Type>::operator[](const std::size_t &i) const
{
    return array[i];
} // operator[]

//------------------------------------------------------------------------

template <typename Type>
const Type Math::Vector2<Type>::bound( const Type &radius ) const
{
	Type L = Type(0);
	Type R = Type(0);
	Type Z = Type(0);
	
	L = x * x + y * y;
	R = radius * radius;
	
	if( L > R )
	{
		// On or outside the sphere.
		
		Z = Type(0);
	}
	else
	{
		// Inside the sphere.
		
		Z = std::sqrt( R - L );
	} // else
	
	return Z;
} // bound

//------------------------------------------------------------------------

template <typename Type>
void Math::Vector2<Type>::swap()
{
	Type temp = x;
	
	x = y;
	y = temp;
} // swap

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Template Implementations

//------------------------------------------------------------------------

//------------------------------------------------------------------------

template class Math::Vector2<float>;
template class Math::Vector2<double>;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Square

//------------------------------------------------------------------------

double Math::sqr(const Math::Vector2<double> &v)
{
	return v.x * v.x + v.y * v.y;
} // sqr

//------------------------------------------------------------------------

float  Math::sqr(const Math::Vector2<float>  &v)
{
	return v.x * v.x + v.y * v.y;
} // sqr

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - atan2 or arg

//------------------------------------------------------------------------

double Math::arg(const Math::Vector2<double>  &v)
{
	return __builtin_atan2(v.x, v.y);
} // arg

//------------------------------------------------------------------------

float Math::arg(const Math::Vector2<float>  &v)
{
	return __builtin_atan2f(v.x, v.y);
} // arg

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - atan2 or arg

//------------------------------------------------------------------------

double Math::atan2(const Math::Vector2<double>  &v)
{
	return __builtin_atan2(v.y, v.x);
} // atan2

//------------------------------------------------------------------------

float Math::atan2(const Math::Vector2<float>  &v)
{
	return __builtin_atan2f(v.y, v.x);
} // atan2

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Absolute Value or Norm

//------------------------------------------------------------------------

double Math::abs(const Math::Vector2<double> &v)
{
	return __builtin_sqrt(v.x * v.x + v.y * v.y);
} // abs

//------------------------------------------------------------------------

float  Math::abs(const Math::Vector2<float>  &v)
{
	return __builtin_sqrtf(v.x * v.x + v.y * v.y);
} // abs

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Absolute Value or Norm

//------------------------------------------------------------------------

double Math::norm(const Math::Vector2<double> &v)
{
	return __builtin_sqrt(v.x * v.x + v.y * v.y);
} // norm

//------------------------------------------------------------------------

float Math::norm(const Math::Vector2<float> &v)
{
	return __builtin_sqrtf(v.x * v.x + v.y * v.y);
} // norm

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Inverse Norm

//------------------------------------------------------------------------

double Math::inorm(const Math::Vector2<double> &v)
{
	return 1.0 / __builtin_sqrt(v.x * v.x + v.y * v.y);
} // inorm

//------------------------------------------------------------------------

float  Math::inorm(const Math::Vector2<float>  &v)
{
	return 1.0f / __builtin_sqrtf(v.x * v.x + v.y * v.y);
} // inorm

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Normalize

//------------------------------------------------------------------------

static inline Math::Vector2<double> Vector2Normalize(const double eps,
													 const Math::Vector2<double> &v)
{
    Math::Vector2<double> p(v);
    
	double L = __builtin_sqrt(v.x * v.x + v.y * v.y);
    
	if( __builtin_fabs( L - 1.0 ) > eps )
	{
		L = 1.0/L;
		
		p.x *= L;
		p.y *= L;
	} // if
	
	return p;
} // Vector2Normalize

//------------------------------------------------------------------------

Math::Vector2<double> Math::norml(const double &e,
								  const Math::Vector2<double> &v)
{
    return Vector2Normalize(e, v);
} // norml

//------------------------------------------------------------------------

Math::Vector2<double> Math::norml(const Math::Vector2<double> &v)
{
    return Vector2Normalize(1e-7, v);
} // norml

//------------------------------------------------------------------------

static inline Math::Vector2<float> Vector2Normalize(const float eps,
													const Math::Vector2<float> &v)
{
    Math::Vector2<float> p(v);
    
	float L = __builtin_sqrtf(v.x * v.x + v.y * v.y);
    
	if( __builtin_fabsf( L - 1.0 ) > eps )
	{
		L = 1.0/L;
		
		p.x *= L;
		p.y *= L;
	} // if
	
	return p;
} // Vector2Normalize

//------------------------------------------------------------------------

Math::Vector2<float>  Math::norml(const Math::Vector2<float>  &v)
{
    return Vector2Normalize(float(1e-7), v);
} // Vector2Normalize

//------------------------------------------------------------------------

Math::Vector2<float>  Math::norml(const  float &e,
								  const Math::Vector2<float>  &v)
{
    return Vector2Normalize(e, v);
} // norml

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Distance or Metric

//------------------------------------------------------------------------

template <typename Type>
static inline Type Vector2Dist(const Math::Vector2<Type> &u,
							   const Math::Vector2<Type> &v)
{
	Math::Vector2<Type> w;
	
	w.x = v.x - u.x;
	w.y = v.y - u.y;
    
    Type s = w.x * w.x + w.y * w.y;
    
	return std::sqrt(s);
} // cos

//------------------------------------------------------------------------

double Math::dist(const Math::Vector2<double> &u,
				  const Math::Vector2<double> &v)
{
    return Vector2Dist<double>(u, v);
} // Vector2Dist

//------------------------------------------------------------------------

float Math::dist(const Math::Vector2<float>  &u,
				 const Math::Vector2<float>  &v)
{
    return Vector2Dist<float>(u, v);
} // Vector2Dist

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Cosine

//------------------------------------------------------------------------

template <typename Type>
static inline Type Vector2Cos(const Math::Vector2<Type> &u,
							  const Math::Vector2<Type> &v)
{
	// interior scalar product c = u * v
	
	Type c = u * v;
	
    // lu = 1 / || u ||
    
	Type lu = Math::inorm(u);
    
    // lv = 1 / || v ||
    
    Type lv = Math::inorm(v);
    
	// A = cos(a) = ( u * v ) / ( ||u|| ||v|| ) = c / ( lu * lv )
	
	Type A = lu * lv * c;
	
	return A;
} // Vector2Cos

//------------------------------------------------------------------------

double Math::cos(const Math::Vector2<double> &u,
				 const Math::Vector2<double> &v)
{
    return Vector2Cos<double>(u, v);
} // cos

//------------------------------------------------------------------------

float Math::cos(const Math::Vector2<float>  &u,
				const Math::Vector2<float>  &v)
{
    return Vector2Cos<float>(u, v);
} // cos

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Manhattan metric

//------------------------------------------------------------------------

template <typename Type>
static inline Math::Vector2<Type> Vector2Diff(const Math::Vector2<Type> &u,
											  const Math::Vector2<Type> &v)
{
	Math::Vector2<Type> p;
	
	p.x = std::abs(v.x - u.x);
	p.y = std::abs(v.y - u.y);
	
	return p;
} // Vector2Diff

//------------------------------------------------------------------------

Math::Vector2<double> Math::diff(const Math::Vector2<double> &u,
								 const Math::Vector2<double> &v)
{
    return Vector2Diff<double>(u, v);
} // diff

//------------------------------------------------------------------------

Math::Vector2<float> Math::diff(const Math::Vector2<float>  &u,
								const Math::Vector2<float>  &v)
{
    return Vector2Diff<float>(u, v);
} // diff

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Functions - Orthonormalize

//------------------------------------------------------------------------

static inline Math::Vector2<double> Vector2Orthonormalize(const double &eps,
														  const Math::Vector2<double> &u,
														  const Math::Vector2<double> &v)
{
    Math::Vector2<double> p;
    
    double D = __builtin_sqrt(v.x * v.x + v.y * v.y);
    
	if( __builtin_fabs( D - 1.0 ) > eps )
	{
        double N = u.x * v.x + u.y * v.y;
        double Q = N / D;
        
        p.x = u.x - Q * v.x;
        p.y = u.y - Q * v.y;
        
        double L = 1.0 / __builtin_sqrt(p.x * p.x + p.y * p.y);
        
        p.x *= L;
        p.y *= L;
    } // if
	
	return p;
} // Vector2Orthonormalize

//------------------------------------------------------------------------

Math::Vector2<double> Math::orthn(const Math::Vector2<double> &u,
								  const Math::Vector2<double> &v)
{
    return Vector2Orthonormalize(1e-7,u,v);
} // orthn

//------------------------------------------------------------------------

Math::Vector2<double> Math::orthn(const double &e,
								  const Math::Vector2<double> &u,
								  const Math::Vector2<double> &v)
{
    return Vector2Orthonormalize(e,u,v);
} // orthn

//------------------------------------------------------------------------

static inline Math::Vector2<float> Vector2Orthonormalize(const float &eps,
														 const Math::Vector2<float> &u,
														 const Math::Vector2<float> &v)
{
    Math::Vector2<float> p;
    
    float D = __builtin_sqrtf(v.x * v.x + v.y * v.y);
    
	if( __builtin_fabsf( D - 1.0f ) > eps )
	{
        double N = u.x * v.x + u.y * v.y;
        double Q = N / D;
        
        p.x = u.x - Q * v.x;
        p.y = u.y - Q * v.y;
        
        float L = 1.0f / __builtin_sqrtf(p.x * p.x + p.y * p.y);
        
        p.x *= L;
        p.y *= L;
    } // if
	
	return p;
} // Vector2Orthonormalize

//------------------------------------------------------------------------

Math::Vector2<float>  Math::orthn(const Math::Vector2<float>  &u,
								  const Math::Vector2<float>  &v)
{
    return Vector2Orthonormalize(1e-7,u,v);
} // orthn

//------------------------------------------------------------------------

Math::Vector2<float>  Math::orthn(const float  &eps,
								  const Math::Vector2<float>  &u,
								  const Math::Vector2<float>  &v)
{
    return Vector2Orthonormalize(eps,u,v);
} // orthn

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Functions - Projection

//------------------------------------------------------------------------

Math::Vector2<double> Math::proj(const Math::Vector2<double> &u,
								 const Math::Vector2<double> &v)
{
    return v * ((u * v) / __builtin_sqrt(v * v));
} // proj

//------------------------------------------------------------------------

Math::Vector2<float> Math::proj(const Math::Vector2<float> &u,
								const Math::Vector2<float> &v)
{
    return v * ((u * v) / __builtin_sqrtf(v * v));
} // proj

//------------------------------------------------------------------------

//------------------------------------------------------------------------


