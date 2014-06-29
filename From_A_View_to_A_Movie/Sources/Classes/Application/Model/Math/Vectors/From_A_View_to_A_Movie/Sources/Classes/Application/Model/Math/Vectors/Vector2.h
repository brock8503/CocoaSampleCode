/*
     File: Vector2.h
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

#ifndef _VECTOR2_H_
#define _VECTOR2_H_

#ifdef __cplusplus

#import <cstddef>

namespace Math
{
	template <typename Type>
	class Vector2
	{
	public:
		Vector2();
		Vector2(const Type &k);
		Vector2(const Type &X, const Type &Y);
		Vector2(const Type * const v);
		
		Vector2(const Vector2<Type> &v);
		Vector2(const Vector2<Type> * const v);
		
		Vector2<Type> &operator=(const Vector2<Type> &v);
		Vector2<Type> &operator=(const Type * const v);
		Vector2<Type> &operator=(const Type &k);
		
		const Vector2<Type> operator+(const Vector2<Type> &v) const;
		const Vector2<Type> operator-(const Vector2<Type> &v) const;
		const Type          operator*(const Vector2<Type> &v) const;  // Interior dot product
		
		Vector2<Type> &operator+=(const Vector2<Type> &v);
		Vector2<Type> &operator-=(const Vector2<Type> &v);
		
		const Vector2<Type> operator+(const Type &k) const;
		const Vector2<Type> operator-(const Type &k) const;
		const Vector2<Type> operator*(const Type &k) const;
		const Vector2<Type> operator/(const Type &k) const;
		
		Vector2<Type> &operator+=(const Type &k);
		Vector2<Type> &operator-=(const Type &k);
		Vector2<Type> &operator*=(const Type &k);
		Vector2<Type> &operator/=(const Type &k);
		
		Vector2<Type> operator+() const;
		Vector2<Type> operator-() const;
		
		Type &operator[](const std::size_t &i);
		
		const Type &operator[](const std::size_t &i) const;
		
		const Type bound(const Type &radius) const;
		
		void swap();
		
	public:
		union
		{
			Type array[2];
			
			union
			{
				struct{ Type x, y;};
				struct{ Type s, t; };
				struct{ Type u, v; };
			}; // struct
		}; // union
	}; // Vector2
	
	double arg(const Vector2<double> &v);
	float  arg(const Vector2<float>  &v);
	
	double atan2(const Vector2<double> &v);
	float  atan2(const Vector2<float>  &v);
	
	double sqr(const Vector2<double> &v);
	float  sqr(const Vector2<float>  &v);
	
	double abs(const Vector2<double> &v);
	float  abs(const Vector2<float>  &v);
	
	double norm(const Vector2<double> &v);
	float  norm(const Vector2<float>  &v);
	
	double inorm(const Vector2<double> &v);
	float  inorm(const Vector2<float>  &v);
	
	double dist(const Vector2<double> &u, const Vector2<double> &v);
	float  dist(const Vector2<float>  &u, const Vector2<float>  &v);
	
	double cos(const Vector2<double> &u, const Vector2<double> &v);
	float  cos(const Vector2<float>  &u, const Vector2<float>  &v);
	
	Vector2<double> norml(const Vector2<double> &v);
	Vector2<float>  norml(const Vector2<float>  &v);
	
	Vector2<double> norml(const double &e, const Vector2<double> &v);
	Vector2<float>  norml(const float  &e, const Vector2<float>  &v);
	
	Vector2<double> orthn(const Vector2<double> &u, const Vector2<double> &v);
	Vector2<float>  orthn(const Vector2<float>  &u, const Vector2<float>  &v);
	
	Vector2<double> proj(const Vector2<double> &u, const Vector2<double> &v);
	Vector2<float>  proj(const Vector2<float>  &u, const Vector2<float>  &v);
	
	Vector2<double> orthn(const double &e, const Vector2<double> &u, const Vector2<double> &v);
	Vector2<float>  orthn(const float  &e, const Vector2<float>  &u, const Vector2<float>  &v);
	
	Vector2<double> diff(const Vector2<double> &u, const Vector2<double> &v);
	Vector2<float>  diff(const Vector2<float>  &u, const Vector2<float>  &v);
} // Math

#endif

#endif
