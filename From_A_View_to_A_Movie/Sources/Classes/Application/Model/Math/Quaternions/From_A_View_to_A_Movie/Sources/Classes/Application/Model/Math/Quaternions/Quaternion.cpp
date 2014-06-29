/*
     File: Quaternion.cpp
 Abstract: 
 Template class for Quaternion operators and methods.
 
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

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#import <cmath>
#import <iostream>

//------------------------------------------------------------------------------------------------

#import "Quaternion.h"

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type>::Quaternion()
{
	t = Type(0);
	x = Type(0);
	y = Type(0);
	z = Type(0);
} // Default Constructor

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type>::Quaternion(const Type &k)
{
	t = k;
	x = k;
	y = k;
	z = k;
}// Constructor

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type>::Quaternion(const Type &X,
								   const Type &Y)
{
	t = Type(0);
	x = X;
	y = Y;
	z = Type(0);
}// Constructor

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type>::Quaternion(const Type &T,
								   const Type &X,
								   const Type &Y)
{
	t = T;
	x = X;
	y = Y;
	z = Type(0);
}// Constructor

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type>::Quaternion(const Type &T,
								   const Type &X,
								   const Type &Y,
								   const Type &Z)
{
	t = T;
	x = X;
	y = Y;
	z = Z;
}// Constructor

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors - Rotation or Quaternion

//------------------------------------------------------------------------------------------------
//
// Convert from degrees to radians, get the half-angle.
//
//------------------------------------------------------------------------------------------------
//
// Convert a GL-style rotation to a quaternion.  The GL rotation
// looks like this:
//
//		{angle, x, y, z},
//
// the corresponding quaternion looks like this:
//
//		{{v}, cos(angle/2)},
//
// where {v} is {x, y, z} / sin(angle/2).
//
//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type>::Quaternion(const Type * const r)
{
    if( r != NULL )
    {
        Type hAngle = (Type(M_PI) * r[0]) / Type(360); // The half-angle
        
        Type sin = std::sin( hAngle );
        
        x = sin * r[1];
        y = sin * r[2];
        z = sin * r[3];
        
        t = std::cos( hAngle );
    } // if
}// Constructor

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type>::Quaternion(const Type &theta,
								   const Vector3<Type> &r)
{
    Type hAngle = (Type(M_PI) * theta) / Type(360); // The half-angle
    
    Type sin = std::sin( hAngle );
    
    x = sin * r.x;
    y = sin * r.y;
    z = sin * r.z;
    
    t = std::cos( hAngle );
}// Constructor

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructor

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type>::Quaternion(const Math::Quaternion<Type> &v)
{
	x = v.x;
	y = v.y;
	z = v.z;
	t = v.t;
}// Copy Constructor

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type>::Quaternion(const Math::Quaternion<Type> * const v)
{
    if( v != NULL )
    {
        x = v->x;
        y = v->y;
        z = v->z;
        t = v->t;
    } // if
    else
    {
        x = Type(0);
        y = Type(0);
        z = Type(0);
        t = Type(0);
    } // else
}// Copy Constructor

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Assignment Operators

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type> &Math::Quaternion<Type>::operator=(const Math::Quaternion<Type> &v)
{
	if( this != &v )
	{
		x = v.x;
		y = v.y;
		z = v.z;
		t = v.t;
	} // if
    
    return *this;
}// Assignment operator

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type> &Math::Quaternion<Type>::operator=(const Type * const v)
{
	if( v != NULL )
	{
		t = v[0];
		x = v[1];
		y = v[2];
		z = v[3];
	} // if
    
    return *this;
}// Assignment operator

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type> &Math::Quaternion<Type>::operator=(const Type &k)
{
    t = k;
    x = k;
    y = k;
    z = k;
    
    return *this;
}// Assignment operator

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Operators

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type> Math::Quaternion<Type>::operator+() const
{
	return Math::Quaternion<Type>(t,x,y,z);
} // operator+()

//------------------------------------------------------------------------------------------------
//
// Quaternion conjugate
//
//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type> Math::Quaternion<Type>::operator-() const
{
	return Math::Quaternion<Type>(-t,-x,-y,-z);
} // Vector2::operator-()

//------------------------------------------------------------------------------------------------

template <typename Type>
const Math::Quaternion<Type> Math::Quaternion<Type>::operator-(Type &k) const
{
	Quaternion w;
	
	w.x = x - k;
	w.y = y - k;
	w.z = z - k;
	w.t = t - k;
	
	return w;
} // operator-

//------------------------------------------------------------------------------------------------

template <typename Type>
const Math::Quaternion<Type> Math::Quaternion<Type>::operator-(Math::Quaternion<Type> &v) const
{
	Quaternion w;
	
	w.x = x - v.x;
	w.y = y - v.y;
	w.z = z - v.z;
	w.t = t - v.t;
	
	return w;
} // operator-

//------------------------------------------------------------------------------------------------

template <typename Type>
const Math::Quaternion<Type> Math::Quaternion<Type>::operator+(Type &k) const
{
	Quaternion w;
	
	w.x = x + k;
	w.y = y + k;
	w.z = z + k;
	w.t = t + k;
	
	return w;
} // operator+

//------------------------------------------------------------------------------------------------

template <typename Type>
const Math::Quaternion<Type> Math::Quaternion<Type>::operator+(Math::Quaternion<Type> &v) const
{
	Quaternion w;
	
	w.x = x + v.x;
	w.y = y + v.y;
	w.z = z + v.z;
	w.t = t + v.t;
	
	return w;
} // operator+

//------------------------------------------------------------------------------------------------

template <typename Type>
const Math::Quaternion<Type> Math::Quaternion<Type>::operator*(Type &k) const
{
	Quaternion w;
	
	w.x = x * k;
	w.y = y * k;
	w.z = z * k;
	w.t = t * k;
	
	return w;
} // operator*

//------------------------------------------------------------------------------------------------

template <typename Type>
const Math::Quaternion<Type> Math::Quaternion<Type>::operator/(Type &k) const
{
	Quaternion w;
	
	Type S = Type(1) / k;
	
	w.x = S * x;
	w.y = S * y;
	w.z = S * z;
	w.t = S * t;
	
	return w;
} // operator/

//------------------------------------------------------------------------------------------------

template <typename Type>
const Type Math::Quaternion<Type>::operator*(Math::Quaternion<Type> &v) const
{
	Type m = t * v.t + x * v.x + y * v.y + z * v.z;
	
	return m;
} // operator*

//------------------------------------------------------------------------------------------------
//
// This is better known as the Hamilton product
//
//------------------------------------------------------------------------------------------------

template <typename Type>
const Math::Quaternion<Type> Math::Quaternion<Type>::operator^(Math::Quaternion<Type> &v) const
{
	Quaternion w;
	
	w.t = v.t * t - v.x * x - v.y * y - v.z * z;
	w.x = v.y * z - v.z * y + v.t * x + v.x * t;
	w.y = v.z * x - v.x * z + v.t * y + v.y * t;
	w.z = v.x * y - v.y * x + v.t * z + v.z * t;
	
	return w;
} // operator^

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type> &Math::Quaternion<Type>::operator-=(Type &k)
{
	x -= k;
	y -= k;
	z -= k;
	t -= k;
	
	return *this;
} // operator*=

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type> &Math::Quaternion<Type>::operator+=(Type &k)
{
	x += k;
	y += k;
	z += k;
	t += k;
	
	return *this;
} // operator*=

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type> &Math::Quaternion<Type>::operator*=(Type &k)
{
	x *= k;
	y *= k;
	z *= k;
	t *= k;
	
	return *this;
} // operator*=

//------------------------------------------------------------------------------------------------

template <typename Type>
Math::Quaternion<Type> &Math::Quaternion<Type>::operator/=(Type &k)
{
	if(k != Type(0))
	{
		x /= k;
		y /= k;
		z /= k;
		t /= k;
	} // if
	else
	{
		x = Type(0);
		y = Type(0);
		z = Type(0);
		t = Type(0);
	} // else
	
	return *this;
} // operator/=

//-------------------------------------------------------------------------------------------

template <typename Type>
Type &Math::Quaternion<Type>::operator[](const std::size_t &i)
{
    return array[i];
} // operator[]

//-------------------------------------------------------------------------------------------

template <typename Type>
const Type &Math::Quaternion<Type>::operator[](const std::size_t &i) const
{
    return array[i];
} // operator[]

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities

//------------------------------------------------------------------------------------------------
//
// Turn the quaternion back into an {angle, {axis}} rotation.
//
//------------------------------------------------------------------------------------------------

template <typename Type>
void Math::Quaternion<Type>::toRotation(Type *R)
{
    if( R != NULL )
    {
        Type theta = std::acos(t);
        
        Type csc = Type(1) / std::sin(theta);
        
        R[0] = (Type(360) * theta)/Type(M_PI);
        R[1] = csc * x;
        R[2] = csc * y;
        R[3] = csc * z;
    } // if
} // toRotation

//------------------------------------------------------------------------------------------------

template <typename Type>
void Math::Quaternion<Type>::toRotation(Type &theta, Vector3<Type> &R)
{
    Type angle = std::acos(t);
    
    Type csc = Type(1) / std::sin(theta);
    
    theta = (Type(360) * angle)/Type(M_PI);
    
    R.x = csc * x;
    R.y = csc * y;
    R.z = csc * z;
} // toRotation

//------------------------------------------------------------------------------------------------
//
// An identity rotation is expressed as rotation by 0 about any axis.  The "angle" term in a
// quaternion is really the cosine of the half-angle. So, if the cosine of the half-angle is
// one (or, 1.0 within our tolerance), then you have an identity rotation.
//
//------------------------------------------------------------------------------------------------

template <typename Type>
bool Math::Quaternion<Type>::isIdentity(const Type &eps)
{
    return std::abs( t - 1 ) < eps;
} // isIdentity

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Template Implementations

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

template class Math::Quaternion<float>;
template class Math::Quaternion<double>;

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Square

//------------------------------------------------------------------------------------------------

double Math::sqr(const Math::Quaternion<double> &v)
{
	return v.t * v.t + v.x * v.x + v.y * v.y + v.z * v.z;
} // sqr

//------------------------------------------------------------------------------------------------

float  Math::sqr(const Math::Quaternion<float>  &v)
{
	return v.t * v.t + v.x * v.x + v.y * v.y + v.z * v.z;
} // sqr

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Absolute Value or Norm

//------------------------------------------------------------------------------------------------

double Math::abs(const Math::Quaternion<double> &v)
{
	return __builtin_sqrt(v.t * v.t + v.x * v.x + v.y * v.y + v.z * v.z);
} // abs

//------------------------------------------------------------------------------------------------

float  Math::abs(const Math::Quaternion<float>  &v)
{
	return __builtin_sqrtf(v.t * v.t + v.x * v.x + v.y * v.y + v.z * v.z);
} // abs

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Absolute Value or Norm

//------------------------------------------------------------------------------------------------

double Math::norm(const Math::Quaternion<double> &v)
{
	return __builtin_sqrt(v.t * v.t + v.x * v.x + v.y * v.y + v.z * v.z);
} // norm

//------------------------------------------------------------------------------------------------

float Math::norm(const Math::Quaternion<float> &v)
{
	return __builtin_sqrtf(v.t * v.t + v.x * v.x + v.y * v.y + v.z * v.z);
} // norm

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Inverse Norm

//------------------------------------------------------------------------------------------------

double Math::inorm(const Math::Quaternion<double> &v)
{
	return 1.0 / __builtin_sqrt(v.t * v.t + v.x * v.x + v.y * v.y + v.z * v.z);
} // inorm

//------------------------------------------------------------------------------------------------

float  Math::inorm(const Math::Quaternion<float>  &v)
{
	return 1.0f / __builtin_sqrtf(v.t * v.t + v.x * v.x + v.y * v.y + v.z * v.z);
} // inorm

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Normalize

//------------------------------------------------------------------------------------------------

static inline Math::Quaternion<double> CMQuaternionNormalize(const double &eps,
															 const Math::Quaternion<double> &v)
{
    Math::Quaternion<double> p(v);
    
	double L = __builtin_sqrt(v.x * v.x + v.y * v.y + v.z * v.z + v.t* v.t);
    
	if( __builtin_fabs( L - 1.0 ) > eps )
	{
		L = 1.0/L;
		
		p.x *= L;
		p.y *= L;
		p.z *= L;
		p.t *= L;
	} // if
	
	return p;
} // CMQuaternionNormalize

//------------------------------------------------------------------------------------------------

Math::Quaternion<double> Math::norml(const Math::Quaternion<double> &v)
{
    return CMQuaternionNormalize(double(1e-7), v);
} // norml

//------------------------------------------------------------------------------------------------

Math::Quaternion<double> Math::norml(const double &eps,
									 const Math::Quaternion<double> &v)
{
    return CMQuaternionNormalize(eps, v);
} // norml

//------------------------------------------------------------------------------------------------

static inline Math::Quaternion<float> CMQuaternionNormalize(const float &eps,
															const Math::Quaternion<float> &v)
{
    Math::Quaternion<float> p(v);
    
	float L = __builtin_sqrtf(v.x * v.x + v.y * v.y + v.z * v.z + v.t* v.t);
    
	if( __builtin_fabsf( L - 1.0f ) > eps )
	{
		L = 1.0f/L;
		
		p.x *= L;
		p.y *= L;
		p.z *= L;
		p.t *= L;
	} // if
	
	return p;
} // CMQuaternionNormalize

//------------------------------------------------------------------------------------------------

Math::Quaternion<float>  Math::norml(const Math::Quaternion<float>  &v)
{
    return CMQuaternionNormalize(float(1e-7), v);
} // norml

//------------------------------------------------------------------------------------------------

Math::Quaternion<float>  Math::norml(const  float &e,
									 const Math::Quaternion<float>  &v)
{
    return CMQuaternionNormalize(e, v);
} // norml

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Conjugation

//------------------------------------------------------------------------------------------------

Math::Quaternion<double> Math::conj(const Math::Quaternion<double> &v)
{
    Math::Quaternion<double> w(v);
    
	w.x = -v.x;
	w.y = -v.y;
	w.z = -v.z;
    
	return w;
} // conj

//------------------------------------------------------------------------------------------------

Math::Quaternion<float> Math::conj(const Math::Quaternion<float> &v)
{
    Math::Quaternion<float> w(v);
    
	w.x = -v.x;
	w.y = -v.y;
	w.z = -v.z;
    
	return w;
} // conj

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Distance or Metric

//------------------------------------------------------------------------------------------------

double Math::dist(const Math::Quaternion<double> &u,
				  const Math::Quaternion<double> &v)
{
	Math::Quaternion<double> w;
	
	w.x = v.x - u.x;
	w.y = v.y - u.y;
	w.z = v.z - u.z;
	w.t = v.t - u.t;
    
    double s = w.x * w.x + w.y * w.y + w.z * w.z + w.t * w.t;
    
	return __builtin_sqrt(s);
} // dist

//------------------------------------------------------------------------------------------------

float Math::dist(const Math::Quaternion<float>  &u,
				 const Math::Quaternion<float>  &v)
{
	Math::Quaternion<float> w;
	
	w.x = v.x - u.x;
	w.y = v.y - u.y;
	w.z = v.z - u.z;
	w.t = v.t - u.t;
    
    float s = w.x * w.x + w.y * w.y + w.z * w.z + w.t * w.t;
    
	return __builtin_sqrtf(s);
} // dist

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Utilities - Manhattan metric

//------------------------------------------------------------------------------------------------

Math::Quaternion<double> Math::diff(const Math::Quaternion<double> &u,
									const Math::Quaternion<double> &v)
{
	Math::Quaternion<double> p;
	
	p.x = __builtin_fabs(v.x - u.x);
	p.y = __builtin_fabs(v.y - u.y);
	p.z = __builtin_fabs(v.z - u.z);
	p.t = __builtin_fabs(v.t - u.t);
	
	return p;
} // diff

//------------------------------------------------------------------------------------------------

Math::Quaternion<float> Math::diff(const Math::Quaternion<float>  &u,
								   const Math::Quaternion<float>  &v)
{
	Math::Quaternion<float> p;
	
	p.x = __builtin_fabsf(v.x - u.x);
	p.y = __builtin_fabsf(v.y - u.y);
	p.z = __builtin_fabsf(v.z - u.z);
	p.t = __builtin_fabsf(v.t - u.t);
	
	return p;
} // diff

//------------------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------------------

