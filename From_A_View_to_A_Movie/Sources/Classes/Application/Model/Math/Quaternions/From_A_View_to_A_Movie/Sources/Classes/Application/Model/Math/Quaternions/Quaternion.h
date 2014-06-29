/*
     File: Quaternion.h
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

#ifndef _QUATERNION_H_
#define _QUATERNION_H_

#ifdef __cplusplus

#import "Vector3.h"

namespace Math
{
	template <typename Type>
	class Quaternion
	{
	public:
		// Constructors
		Quaternion();
		Quaternion(const Type &k);
		Quaternion(const Type &X, const Type &Y);
		Quaternion(const Type &T, const Type &X, const Type &Y);
		Quaternion(const Type &T, const Type &X, const Type &Y, const Type &Z);
		
		// Constructors to convert from rotation
		Quaternion(const Type * const r);
		Quaternion(const Type &theta, const Vector3<Type> &r);
		
		// Copy constructors
		Quaternion(const Quaternion<Type> &v);
		Quaternion(const Quaternion<Type> * const v);
		
		// Assignment operators. No conversions.
		Quaternion<Type> &operator=(const Quaternion<Type> &v);
		Quaternion<Type> &operator=(const Type * const v);
		Quaternion<Type> &operator=(const Type &k);
		
		// Operators
		const Quaternion<Type> operator-(Quaternion<Type> &v) const;
		const Quaternion<Type> operator+(Quaternion<Type> &v) const;
		const Quaternion<Type> operator^(Quaternion<Type> &v) const;  // Exterior Hamilton product
		const Type             operator*(Quaternion<Type> &v) const;  // Interior dot product
		
		const Quaternion<Type> operator-(Type &k) const;
		const Quaternion<Type> operator+(Type &k) const;
		const Quaternion<Type> operator*(Type &k) const;
		const Quaternion<Type> operator/(Type &k) const;
		
		Quaternion<Type> &operator+=(Type &k);
		Quaternion<Type> &operator-=(Type &k);
		Quaternion<Type> &operator*=(Type &k);
		Quaternion<Type> &operator/=(Type &k);
		
		// Unary Operators
		Quaternion<Type> operator+() const;
		Quaternion<Type> operator-() const;
		
		// Index operator with {0,1,2,3} = {t,x,y,z}
		Type &operator[](const std::size_t &i);
		
		const Type &operator[](const std::size_t &i) const;
		
		// Conversion back to rotation
		void toRotation(Type *R);
		void toRotation(Type &theta, Vector3<Type> &R);
		
		// Check for identity within a tolerance
		bool isIdentity(const Type &eps);
		
	public:
		union
		{
			Type array[4];
			
			struct { Type t, x, y, z; };
		}; // union
	}; // Quaternion
	
	double sqr(const Quaternion<double> &v);
	float  sqr(const Quaternion<float>  &v);
	
	double abs(const Quaternion<double> &v);
	float  abs(const Quaternion<float>  &v);
	
	double norm(const Quaternion<double> &v);
	float  norm(const Quaternion<float>  &v);
	
	double inorm(const Quaternion<double> &v);
	float  inorm(const Quaternion<float>  &v);
	
	double dist(const Quaternion<double> &u, const Quaternion<double> &v);
	float  dist(const Quaternion<float>  &u, const Quaternion<float>  &v);
	
	Quaternion<double> norml(const Quaternion<double> &v);
	Quaternion<float>  norml(const Quaternion<float>  &v);
	
	Quaternion<double> norml(const double &e, const Quaternion<double> &v);
	Quaternion<float>  norml(const float  &e, const Quaternion<float>  &v);
	
	Quaternion<double> conj(const Quaternion<double> &v);
	Quaternion<float>  conj(const Quaternion<float>  &v);
	
	Quaternion<double> diff(const Quaternion<double> &u, const Quaternion<double> &v);
	Quaternion<float>  diff(const Quaternion<float>  &u, const Quaternion<float>  &v);
} // Math

#endif

#endif
