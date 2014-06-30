/*
     File: Matrix3.h
 Abstract: 
 Template class for 3x3 matrix operations, where matrix elements are real numbers. 
 
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

#ifndef _MATRIX_3x3_H_
#define _MATRIX_3x3_H_

#ifdef __cplusplus

#import "Vector.h"

namespace Math
{
	template <typename Type>
	class Matrix3
	{
	public:
		Matrix3();
		
		Matrix3(const bool &bIsRowMajor,
				const Type * const pMatrix);
		
		Matrix3(const bool &bIsRowMajor,
				const Vector3<Type> &rVec1,
				const Vector3<Type> &rVec2,
				const Vector3<Type> &rVec3);
		
		Matrix3(const bool &bIsRowMajor,
				const Vector2<Type> &rVec1,
				const Vector2<Type> &rVec2,
				const Vector2<Type> &rVec3);
		
		Matrix3(const Matrix3<Type> &rMatrix);
		Matrix3(const Matrix3<Type> * const pMatrix);
		
		virtual ~Matrix3();
		
		Matrix3<Type> &operator=(const Matrix3<Type> &rMatrix);
		
		const Vector3<Type> GetColumn(const std::size_t &nCol) const;
		const Vector3<Type> GetRow(const std::size_t &nRow)    const;
		
		const Type  GetTolerance() const;
		
		void SetColumn(const std::size_t &nCol, const Vector3<Type> &rVec);
		void SetRow(const std::size_t &nRow, const Vector3<Type> &rVec);
		
		void SetMatrix(const bool &bIsRowMajor,
					   const Type * const pMatrix);
		
		void SetMatrix(const bool &bIsRowMajor,
					   const Vector3<Type> &rVec1,
					   const Vector3<Type> &rVec2,
					   const Vector3<Type> &rVec3);
		
		void SetTolerance(const Type &nTolerance);
		
		const Vector3<Type> operator[](const std::size_t &nRow) const;
		
		const Matrix3<Type> operator+(const Matrix3<Type> &rMatrix) const;
		const Matrix3<Type> operator-(const Matrix3<Type> &rMatrix) const;
		const Matrix3<Type> operator*(const Matrix3<Type> &rMatrix) const;
		
		Matrix3<Type> &operator+=(const Matrix3<Type> &rMatrix);
		Matrix3<Type> &operator-=(const Matrix3<Type> &rMatrix);
		Matrix3<Type> &operator*=(const Matrix3<Type> &rMatrix);
		
		const Matrix3<Type> operator+(const Type &k) const;
		const Matrix3<Type> operator-(const Type &k) const;
		const Matrix3<Type> operator*(const Type &k) const;
		const Matrix3<Type> operator/(const Type &k) const;
		
		Matrix3<Type> &operator+=(const Type &k);
		Matrix3<Type> &operator-=(const Type &k);
		Matrix3<Type> &operator*=(const Type &k);
		Matrix3<Type> &operator/=(const Type &k);
		
		Type &operator()(const std::size_t &nRow, const std::size_t &nColumn);
		Type  operator()(const std::size_t &nRow, const std::size_t &nColumn) const;
		
		friend Vector3<Type> operator*(const Matrix3<Type> &rMatrix, const Vector3<Type> &rVector);
		friend Vector3<Type> operator*(const Vector3<Type> &rVector, const Matrix3<Type> &rMatrix);
		
	public:
		union
		{
			Type matrix[10];
			
			struct
			{
				Type m_11, m_12, m_13;
				Type m_21, m_22, m_23;
				Type m_31, m_32, m_33;
				Type eps;
			}; // struct
		}; // union
	}; // Matrix3
	
	// Compute determinant of a 3x3 matrix.
	double det(const Matrix3<double> &rMatrix);
	float  det(const Matrix3<float>  &rMatrix);
	
	// Construct a diagonal 3x3 matrix.
	// Can be used to create identity and scalar matrices.
	Matrix3<double> diag(const Vector3<double> &rScalar);
	Matrix3<float>  diag(const Vector3<float>  &rScalar);
	
	// Compute matrix inverse of a 3x3 matrix.
	Matrix3<double> inv(const Matrix3<double> &rMatrix);
	Matrix3<float>  inv(const Matrix3<float>  &rMatrix);
	
	// Compute transpose of a 3x3 matrix.
	Matrix3<double> tr(const Matrix3<double> &rMatrix);
	Matrix3<float>  tr(const Matrix3<float>  &rMatrix);
	
	// Orthonormalize a 3x3 matrix.
	Matrix3<double> orthn(const Matrix3<double> &rMatrix);
	Matrix3<float>  orthn(const Matrix3<float>  &rMatrix);
	
	// Solve a 3x3 system of linear equations.
	Vector3<double> solve(const Vector3<double> &rColVecB, const Matrix3<double> &rMatrix);
	Vector3<float>  solve(const Vector3<float>  &rColVecB, const Matrix3<float>  &rMatrix);
} // Math

#endif

#endif
