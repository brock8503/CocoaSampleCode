//--------------------------------------------------------------------------------------
//
//	File: Vector3.h
//
//  Abstract: C++ templates for 3-Vector operators and methods
//
//  Disclaimer: IMPORTANT:  This Apple software is supplied to you by
//  Inc. ("Apple") in consideration of your agreement to the following terms,
//  and your use, installation, modification or redistribution of this Apple
//  software constitutes acceptance of these terms.  If you do not agree with
//  these terms, please do not use, install, modify or redistribute this
//  Apple software.
//
//  In consideration of your agreement to abide by the following terms, and
//  subject to these terms, Apple grants you a personal, non-exclusive
//  license, under Apple's copyrights in this original Apple software (the
//  "Apple Software"), to use, reproduce, modify and redistribute the Apple
//  Software, with or without modifications, in source and/or binary forms;
//  provided that if you redistribute the Apple Software in its entirety and
//  without modifications, you must retain this notice and the following
//  text and disclaimers in all such redistributions of the Apple Software.
//  Neither the name, trademarks, service marks or logos of Apple Inc. may
//  be used to endorse or promote products derived from the Apple Software
//  without specific prior written permission from Apple.  Except as
//  expressly stated in this notice, no other rights or licenses, express
//  or implied, are granted by Apple herein, including but not limited to
//  any patent rights that may be infringed by your derivative works or by
//  other works in which the Apple Software may be incorporated.
//
//  The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
//  MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
//  THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
//  FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
//  OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
//
//  IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
//  MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
//  AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
//  STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
//  Copyright (c) 2007-2012 Apple Inc., All rights reserved.
//
//------------------------------------------------------------------------------------

#ifndef _VECTOR3_H_
#define _VECTOR3_H_

#ifdef __cplusplus

#import "Vector2.h"

namespace Math
{
	template <typename Type>
	class Vector3
	{
	public:
		Vector3();
		Vector3(const Type &k);
		Vector3(const Type &X, const Type &Y);
		Vector3(const Type &X, const Type &Y, const Type &Z);
		Vector3(const Type * const v);
		
		Vector3(const Vector2<Type> &v, const Type &Z);
		
		Vector3(const Vector3<Type> &v);
		Vector3(const Vector3<Type> * const v);
		
		Vector3<Type> &operator=(const Vector3<Type> &v);
		Vector3<Type> &operator=(const Type * const v);
		Vector3<Type> &operator=(const Type &k);
		
		const Vector3<Type> operator-(const Vector3<Type> &v) const;
		const Vector3<Type> operator+(const Vector3<Type> &v) const;
		const Vector3<Type> operator^(const Vector3<Type> &v) const;  // Exterior cross product
		const Type          operator*(const Vector3<Type> &v) const;  // Interior dot product
		
		Vector3<Type> &operator+=(const Vector3<Type> &v);
		Vector3<Type> &operator-=(const Vector3<Type> &v);
		Vector3<Type> &operator^=(const Vector3<Type> &v);  // Exterior cross product
		
		const Vector3<Type> operator-(const Type &k) const;
		const Vector3<Type> operator+(const Type &k) const;
		const Vector3<Type> operator*(const Type &k) const;
		const Vector3<Type> operator/(const Type &k) const;
		
		Vector3<Type> &operator+=(const Type &k);
		Vector3<Type> &operator-=(const Type &k);
		Vector3<Type> &operator*=(const Type &k);
		Vector3<Type> &operator/=(const Type &k);
		
		Vector3<Type> operator+() const;
		Vector3<Type> operator-() const;
		
		Type &operator[](const std::size_t &i);
		
		const Type &operator[](const std::size_t &i) const;
		
		const Type bound(const Type &radius) const;
		
	public:
		union
		{
			Type array[3];
			
			union
			{
				struct{ Type x, y, z; };
				struct{ Type r, s, t; };
				struct{ Type u, v, w; };
			}; // struct
		}; // union
	}; // Vector3
	
	double sqr(const Vector3<double> &v);
	float  sqr(const Vector3<float>  &v);
	
	double abs(const Vector3<double> &v);
	float  abs(const Vector3<float>  &v);
	
	double norm(const Vector3<double> &v);
	float  norm(const Vector3<float>  &v);
	
	double inorm(const Vector3<double> &v);
	float  inorm(const Vector3<float>  &v);
	
	double dist(const Vector3<double> &u, const Vector3<double> &v);
	float  dist(const Vector3<float>  &u, const Vector3<float>  &v);
	
	double cos(const Vector3<double> &u, const Vector3<double> &v);
	float  cos(const Vector3<float>  &u, const Vector3<float>  &v);
	
	double sin(const Vector3<double> &u, const Vector3<double> &v);
	float  sin(const Vector3<float>  &u, const Vector3<float>  &v);
	
	Vector3<double> norml(const Vector3<double> &v);
	Vector3<float>  norml(const Vector3<float>  &v);
	
	Vector3<double> norml(const double &e, const Vector3<double> &v);
	Vector3<float>  norml(const float  &e, const Vector3<float>  &v);
	
	Vector3<double> orthn(const Vector3<double> &u, const Vector3<double> &v);
	Vector3<float>  orthn(const Vector3<float>  &u, const Vector3<float>  &v);
	
	Vector3<double> proj(const Vector3<double> &u, const Vector3<double> &v);
	Vector3<float>  proj(const Vector3<float>  &u, const Vector3<float>  &v);
	
	Vector3<double> orthn(const double &e, const Vector3<double> &u, const Vector3<double> &v);
	Vector3<float>  orthn(const float  &e, const Vector3<float>  &u, const Vector3<float>  &v);
	
	Vector3<double> diff(const Vector3<double> &u, const Vector3<double> &v);
	Vector3<float>  diff(const Vector3<float>  &u, const Vector3<float>  &v);
	
	Vector3<double> normalv(const Vector3<double> &u, const Vector3<double> &v);
	Vector3<float>  normalv(const Vector3<float>  &u, const Vector3<float>  &v);
	
	Vector3<double> normalv(const Vector3<double> &u, const Vector3<double> &v, const Vector3<double> &w);
	Vector3<float>  normalv(const Vector3<float>  &u, const Vector3<float>  &v, const Vector3<float>  &w);
} // Math

#endif

#endif
