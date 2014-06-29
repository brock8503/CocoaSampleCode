/*
     File: Vector3.cpp
 Abstract: 
 Template class for 3-Vector operators and methods.
 
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

#import "Vector3.h"

//------------------------------------------------------------------------

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type>::Vector3()
{
	x = Type(0);
	y = Type(0);
	z = Type(0);
} // Default Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type>::Vector3(const Type &k)
{
	x = k;
	y = k;
	z = k;
}// Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type>::Vector3(const Type &X,
							 const Type &Y)
{
	x = X;
	y = Y;
	z = Type(0);
}// Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type>::Vector3(const Type &X,
							 const Type &Y,
							 const Type &Z)
{
	x = X;
	y = Y;
	z = Z;
}// Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type>::Vector3(const Type * const v)
{
	if( v != NULL )
	{
		x = v[0];
		y = v[1];
		z = v[2];
	} // if
	else
	{
		x = Type(0);
		y = Type(0);
		z = Type(0);
	} // else
}// Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type>::Vector3(const Math::Vector2<Type> &v,
							 const Type &Z)
{
	x = v.x;
	y = v.y;
	z = Z;
} // Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type>::Vector3(const Math::Vector3<Type> &v)
{
	x = v.x;
	y = v.y;
	z = v.z;
}// Copy Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type>::Vector3(const Math::Vector3<Type> * const v)
{
    if( v != NULL )
    {
        x = v->x;
        y = v->y;
        z = v->z;
    } // if
    else
    {
        x = Type(0);
        y = Type(0);
        z = Type(0);
    } // else
}// Copy Constructor

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator=(const Math::Vector3<Type> &v)
{
	if( this != &v )
	{
		x = v.x;
		y = v.y;
		z = v.z;
	} // if
    
    return *this;
}// Assignment operator

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator=(const Type * const v)
{
	if( v != NULL )
	{
		x = v[0];
		y = v[1];
		z = v[2];
	} // if
    
    return *this;
}// Assignment operator

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator=(const Type &k)
{
    x = k;
    y = k;
    z = k;
    
    return *this;
}// Assignment operator

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Vector3<Type>::operator-(const Math::Vector3<Type> &v) const
{
	Vector3 w;
	
	w.x = x - v.x;
	w.y = y - v.y;
	w.z = z - v.z;
	
	return w;
} // operator-

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Vector3<Type>::operator+(const Math::Vector3<Type> &v) const
{
	Vector3 w;
	
	w.x = x + v.x;
	w.y = y + v.y;
	w.z = z + v.z;
	
	return w;
} // operator+

//------------------------------------------------------------------------

template <typename Type>
const Type Math::Vector3<Type>::operator*(const Math::Vector3<Type> &v) const
{
	Type m = x * v.x + y * v.y + z * v.z;
	
	return m;
} // operator*

//------------------------------------------------------------------------
//
// Here, using the operator "^" denoting a cross product, comes from
// diffferential forms.  In differential forms, cross product is an
// exterior product denoted by "^".
//
//------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Vector3<Type>::operator^(const Math::Vector3<Type> &v) const
{
	Vector3 w;
	
	w.x = y * v.z - z * v.y;
	w.y = z * v.x - x * v.z;
	w.z = x * v.y - y * v.x;
	
	return w;
} // operator^

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator-=(const Math::Vector3<Type> &v)
{
	x -= v.x;
	y -= v.y;
	z -= v.z;
	
	return *this;
} // operator-=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator+=(const Math::Vector3<Type> &v)
{
	x += v.x;
	y += v.y;
	z += v.z;
	
	return *this;
} // operator+=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator^=(const Math::Vector3<Type> &v)
{
	Math::Vector3<Type> u;
	
	u.x = x;
	u.y = y;
	u.z = z;
	
	x = u.y * v.z - u.z * v.y;
	y = u.z * v.x - u.x * v.z;
	z = u.x * v.y - u.y * v.x;
	
	return *this;
} // operator^=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> Math::Vector3<Type>::operator+() const
{
	return Math::Vector3<Type>(x,y,z);
} // Vector2::operator+()

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> Math::Vector3<Type>::operator-() const
{
	return Math::Vector3<Type>(-x,-y,-z);
} // Vector2::operator-()

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Vector3<Type>::operator-(const Type &t) const
{
	Vector3 w;
	
	w.x = x - t;
	w.y = y - t;
	w.z = z - t;
	
	return w;
} // operator-

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Vector3<Type>::operator+(const Type &t) const
{
	Vector3 w;
	
	w.x = x + t;
	w.y = y + t;
	w.z = z + t;
	
	return w;
} // operator+

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Vector3<Type>::operator*(const Type &s) const
{
	Vector3 w;
	
	w.x = x * s;
	w.y = y * s;
	w.z = z * s;
	
	return w;
} // operator*

//------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Vector3<Type>::operator/(const Type &s) const
{
	Vector3 w;
	
	w.x = x / s;
	w.y = y / s;
	w.z = z / s;
	
	return w;
} // operator/

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator-=(const Type &t)
{
	x -= t;
	y -= t;
	z -= t;
	
	return *this;
} // operator-=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator+=(const Type &t)
{
	x += t;
	y += t;
	z += t;
	
	return *this;
} // operator+=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator*=(const Type &s)
{
	x *= s;
	y *= s;
	z *= s;
	
	return *this;
} // operator*=

//------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> &Math::Vector3<Type>::operator/=(const Type &s)
{
	if(s != 0)
	{
		x /= s;
		y /= s;
		z /= s;
	} // if
	
	return *this;
} // operator/=

//------------------------------------------------------------------------

template <typename Type>
Type &Math::Vector3<Type>::operator[](const std::size_t &i)
{
    return array[i];
} // operator[]

//------------------------------------------------------------------------

template <typename Type>
const Type &Math::Vector3<Type>::operator[](const std::size_t &i) const
{
    return array[i];
} // operator[]

//------------------------------------------------------------------------

template <typename Type>
const Type Math::Vector3<Type>::bound( const Type &radius ) const
{
	Type L = Type(0);
	Type R = Type(0);
	Type Z = Type(0);
	
	L = x * x + y * y + z * z;
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

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Template Implementations

//------------------------------------------------------------------------

//------------------------------------------------------------------------

template class Math::Vector3<float>;
template class Math::Vector3<double>;

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Square

//------------------------------------------------------------------------

double Math::sqr(const Math::Vector3<double> &v)
{
	return v.x * v.x + v.y * v.y + v.z * v.z;
} // sqr

//------------------------------------------------------------------------

float  Math::sqr(const Math::Vector3<float>  &v)
{
	return v.x * v.x + v.y * v.y + v.z * v.z;
} // sqr

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Absolute Value or Norm

//------------------------------------------------------------------------

double Math::abs(const Math::Vector3<double> &v)
{
	return __builtin_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
} // abs

//------------------------------------------------------------------------

float  Math::abs(const Math::Vector3<float>  &v)
{
	return __builtin_sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
} // abs

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Absolute Value or Norm

//------------------------------------------------------------------------

double Math::norm(const Math::Vector3<double> &v)
{
	return __builtin_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
} // norm

//------------------------------------------------------------------------

float Math::norm(const Math::Vector3<float> &v)
{
	return __builtin_sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
} // norm

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Inverse Norm

//------------------------------------------------------------------------

double Math::inorm(const Math::Vector3<double> &v)
{
	return 1.0 / __builtin_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
} // inorm

//------------------------------------------------------------------------

float  Math::inorm(const Math::Vector3<float>  &v)
{
	return 1.0f / __builtin_sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
} // inorm

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Distance or Metric

//------------------------------------------------------------------------

template <typename Type>
static inline Type Vector3Dist(const Math::Vector3<Type> &u,
							   const Math::Vector3<Type> &v)
{
	Math::Vector3<Type> p;
	
	p.x = v.x - u.x;
	p.y = v.y - u.y;
	p.z = v.z - u.z;
    
    Type s = p.x * p.x + p.y * p.y + p.z * p.z;
    
	return std::sqrt(s);
} // cos

//------------------------------------------------------------------------

double Math::dist(const Math::Vector3<double> &u,
				  const Math::Vector3<double> &v)
{
    return Vector3Dist<double>(u, v);
} // Vector3Dist

//------------------------------------------------------------------------

float Math::dist(const Math::Vector3<float>  &u,
				 const Math::Vector3<float>  &v)
{
    return Vector3Dist<float>(u, v);
} // Vector3Dist

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Cosine

//------------------------------------------------------------------------

template <typename Type>
static inline Type Vector3Cos(const Math::Vector3<Type> &u,
							  const Math::Vector3<Type> &v)
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
} // cos

//------------------------------------------------------------------------

double Math::cos(const Math::Vector3<double> &u,
				 const Math::Vector3<double> &v)
{
    return Vector3Cos<double>(u, v);
} // cos

//------------------------------------------------------------------------

float Math::cos(const Math::Vector3<float>  &u,
				const Math::Vector3<float>  &v)
{
    return Vector3Cos<float>(u, v);
} // cos

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Sine

//------------------------------------------------------------------------

template <typename Type>
static inline Type Vector3Sin(const Math::Vector3<Type> &u,
							  const Math::Vector3<Type> &v)
{
    // lu = 1 / || u ||
    
	Type lu = Math::inorm(u);
    
    // lv = 1 / || v ||
    
    Type lv = Math::inorm(v);
	
	// exterior vector product w
	
	Math::Vector3<Type> w = u ^ v;
	
	// lw = || u ^ v ||
	
	Type lw = Math::inorm(w);
	
	// A = sin(a) = || u ^ v || / ( ||u|| ||v|| ) = lu * lv * lw
	
	Type A = lu * lv * lw;
	
	return A;
} // Vector3Sin

//------------------------------------------------------------------------

double Math::sin(const Math::Vector3<double> &u,
				 const Math::Vector3<double> &v)
{
    return Vector3Sin<double>(u, v);
} // sin

//------------------------------------------------------------------------

float Math::sin(const Math::Vector3<float>  &u,
				const Math::Vector3<float>  &v)
{
    return Vector3Sin<float>(u, v);
} // sin

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Normalize

//------------------------------------------------------------------------

static inline Math::Vector3<double> Vector3Normalize(const double &eps,
													 const Math::Vector3<double> &v)
{
    Math::Vector3<double> p(v);
    
	double L = __builtin_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    
	if( __builtin_fabs( L - 1.0 ) > eps )
	{
		L = 1.0/L;
		
		p.x *= L;
		p.y *= L;
		p.z *= L;
	} // if
    
	return p;
} // Vector3Normalize

//------------------------------------------------------------------------

Math::Vector3<double> Math::norml(const Math::Vector3<double> &v)
{
    return Vector3Normalize(1e-7, v);
} // norml

//------------------------------------------------------------------------

Math::Vector3<double> Math::norml(const double &e,
								  const Math::Vector3<double> &v)
{
    return Vector3Normalize(e, v);
} // norml

//------------------------------------------------------------------------

static inline Math::Vector3<float> Vector3Normalize(const float &eps,
													const Math::Vector3<float> &v)
{
    Math::Vector3<float> p(v);
    
	float L = __builtin_sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
    
	if( __builtin_fabsf( L - 1.0f ) > eps )
	{
		L = 1.0f/L;
		
		p.x *= L;
		p.y *= L;
		p.z *= L;
	} // if
    
	return p;
} // Vector3Normalize

//------------------------------------------------------------------------

Math::Vector3<float>  Math::norml(const Math::Vector3<float>  &v)
{
    return Vector3Normalize(1e-7, v);
} // norml

//------------------------------------------------------------------------

Math::Vector3<float>  Math::norml(const  float &e,
								  const Math::Vector3<float>  &v)
{
    return Vector3Normalize(e, v);
} // norml

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Manhattan metric

//------------------------------------------------------------------------

template <typename Type>
static inline Math::Vector3<Type> Vector3Diff(const Math::Vector3<Type> &u,
											  const Math::Vector3<Type> &v)
{
	Math::Vector3<Type> p;
	
	p.x = std::abs(v.x - u.x);
	p.y = std::abs(v.y - u.y);
	p.z = std::abs(v.z - u.z);
	
	return p;
} // Vector3Diff

//------------------------------------------------------------------------

Math::Vector3<double> Math::diff(const Math::Vector3<double> &u,
								 const Math::Vector3<double> &v)
{
    return Vector3Diff<double>(u, v);
} // diff

//------------------------------------------------------------------------

Math::Vector3<float> Math::diff(const Math::Vector3<float>  &u,
								const Math::Vector3<float>  &v)
{
    return Vector3Diff<float>(u, v);
} // diff

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Normal to vectors

//------------------------------------------------------------------------

template <typename Type>
static inline Math::Vector3<Type> Vector3Normalv(const Math::Vector3<Type> &u,
												 const Math::Vector3<Type> &v)
{
    Math::Vector3<Type> U = Vector3Normalize(1e-7, u);
    Math::Vector3<Type> V = Vector3Normalize(1e-7, v);
	Math::Vector3<Type> N = U ^ V;
	
	return Vector3Normalize(1e-7, N);
} // Vector3Normalv

//------------------------------------------------------------------------

Math::Vector3<double> Math::normalv(const Math::Vector3<double> &u,
									const Math::Vector3<double> &v)
{
    return Vector3Normalv<double>(u, v);
} // normalv

//------------------------------------------------------------------------

Math::Vector3<float> Math::normalv(const Math::Vector3<float>  &u,
								   const Math::Vector3<float>  &v)
{
    return Vector3Normalv<float>(u, v);
} // normalv

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Normal to vectors

//------------------------------------------------------------------------

template <typename Type>
static inline Math::Vector3<Type> Vector3Normalv(const Math::Vector3<Type> &u,
												 const Math::Vector3<Type> &v,
												 const Math::Vector3<Type> &w)
{
	Math::Vector3<Type> dv = v - u;
	Math::Vector3<Type> V  = Vector3Normalize(1e-7, dv);
	Math::Vector3<Type> dw = w - u;
	Math::Vector3<Type> W  = Vector3Normalize(1e-7, dw);
	Math::Vector3<Type> N  = V ^ W;
	
	return Vector3Normalize(1e-7, N);
} // Vector3Normal

//------------------------------------------------------------------------

Math::Vector3<double> Math::normalv(const Math::Vector3<double> &u,
									const Math::Vector3<double> &v,
									const Math::Vector3<double> &w)
{
    return Vector3Normalv<double>(u, v, w);
} // normalv

//------------------------------------------------------------------------

Math::Vector3<float> Math::normalv(const Math::Vector3<float>  &u,
								   const Math::Vector3<float>  &v,
								   const Math::Vector3<float>  &w)
{
    return Vector3Normalv<float>(u, v, w);
} // normalv

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Functions - Orthonormalize

//------------------------------------------------------------------------

static inline Math::Vector3<double> Vector3Orthonormalize(const double &eps,
														  const Math::Vector3<double> &u,
														  const Math::Vector3<double> &v)
{
    Math::Vector3<double> p;
    
    double D = __builtin_sqrt(v.x * v.x + v.y * v.y + v.z * v.z);
    
	if( __builtin_fabs( D - 1.0 ) > eps )
	{
        double N = u.x * v.x + u.y * v.y + u.z * v.z;
        double Q = N / D;
        
        p.x = u.x - Q * v.x;
        p.y = u.y - Q * v.y;
        p.z = u.z - Q * v.z;
        
        double L = 1.0 / __builtin_sqrt(p.x * p.x + p.y * p.y + p.z * p.z);
        
        p.x *= L;
        p.y *= L;
        p.z *= L;
    } // if
	
	return p;
} // Vector3Orthonormalize

//------------------------------------------------------------------------

Math::Vector3<double> Math::orthn(const Math::Vector3<double> &u,
								  const Math::Vector3<double> &v)
{
    return Vector3Orthonormalize(1e-7,u,v);
} // orthn

//------------------------------------------------------------------------

Math::Vector3<double> Math::orthn(const double &e,
								  const Math::Vector3<double> &u,
								  const Math::Vector3<double> &v)
{
    return Vector3Orthonormalize(e,u,v);
} // orthn

//------------------------------------------------------------------------

static inline Math::Vector3<float> Vector3Orthonormalize(const float &eps,
														 const Math::Vector3<float> &u,
														 const Math::Vector3<float> &v)
{
    Math::Vector3<float> p;
    
    float D = __builtin_sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
    
	if( __builtin_fabsf( D - 1.0 ) > eps )
	{
        double N = u.x * v.x + u.y * v.y + u.z * v.z;
        double Q = N / D;
        
        p.x = u.x - Q * v.x;
        p.y = u.y - Q * v.y;
        p.z = u.z - Q * v.z;
        
        double L = 1.0 / __builtin_sqrtf(p.x * p.x + p.y * p.y + p.z * p.z);
        
        p.x *= L;
        p.y *= L;
        p.z *= L;
    } // if
	
	return p;
} // Vector3Orthonormalize

//------------------------------------------------------------------------

Math::Vector3<float>  Math::orthn(const Math::Vector3<float>  &u,
								  const Math::Vector3<float>  &v)
{
    return Vector3Orthonormalize(1e-7,u,v);
} // orthn

//------------------------------------------------------------------------

Math::Vector3<float>  Math::orthn(const float  &eps,
								  const Math::Vector3<float>  &u,
								  const Math::Vector3<float>  &v)
{
    return Vector3Orthonormalize(eps,u,v);
} // orthn

//------------------------------------------------------------------------

//------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Functions - Projection

//------------------------------------------------------------------------

Math::Vector3<double> Math::proj(const Math::Vector3<double> &u,
								 const Math::Vector3<double> &v)
{
    return v * ((u * v) / __builtin_sqrt(v * v));
} // proj

//------------------------------------------------------------------------

Math::Vector3<float> Math::proj(const Math::Vector3<float> &u,
								const Math::Vector3<float> &v)
{
    return v * ((u * v) / __builtin_sqrtf(v * v));
} // proj

//------------------------------------------------------------------------

//------------------------------------------------------------------------

