/*
     File: CMatrix.h
 Abstract: 
 Template class for 4x3 color matrix operations, where matrix elements are float or doubles numbers.
 
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

#ifndef _COLOR_MATRIX_H_
#define _COLOR_MATRIX_H_

#ifdef __cplusplus

#import "Vector3.h"
#import "Matrix3.h"

namespace Color
{
	template <typename Type>
	class Matrix
	{
	public:
		Matrix();
		
		Matrix(const Type * const pMatrix);
		
		Matrix(const Math::Matrix3<Type> &rMatrix,
			   const Math::Vector3<Type> &rWhitePt);
		
		Matrix(const Math::Vector3<Type> &rRed,
			   const Math::Vector3<Type> &rGreen,
			   const Math::Vector3<Type> &rBlue,
			   const Math::Vector3<Type> &rWhitePt);
		
		Matrix(const Matrix<Type> &rMatrix);
		Matrix(const Matrix<Type> * const pMatrix);
		
		virtual ~Matrix();
		
		Matrix<Type> &operator=(const Matrix<Type> &rMatrix);
		
		void SetMatrix(const Type * const pMatrix);
		
		void SetMatrix(const Math::Matrix3<Type> &rMatrix,
					   const Math::Vector3<Type> &rWhitePt);
		
		void SetMatrix(const Math::Vector3<Type> &rRed,
					   const Math::Vector3<Type> &rGreen,
					   const Math::Vector3<Type> &rBlue,
					   const Math::Vector3<Type> &rWhitePt);
		
		const Matrix<Type> operator+(const Matrix<Type> &rMatrix) const;
		const Matrix<Type> operator-(const Matrix<Type> &rMatrix) const;
		
		Matrix<Type> &operator+=(const Matrix<Type> &rMatrix);
		Matrix<Type> &operator-=(const Matrix<Type> &rMatrix);
		
		const Matrix<Type> operator+(const Type k) const;
		const Matrix<Type> operator-(const Type k) const;
		const Matrix<Type> operator*(const Type k) const;
		const Matrix<Type> operator/(const Type k) const;
		
		Matrix<Type> &operator+=(const Type k);
		Matrix<Type> &operator-=(const Type k);
		Matrix<Type> &operator*=(const Type k);
		Matrix<Type> &operator/=(const Type k);
		
		Type &operator()(const long nRow, const long nColumn);
		Type  operator()(const long nRow, const long nColumn) const;
		
	public:
		union
		{
			Type matrix[12];
			
			struct
			{
				Type red[3];
				Type green[3];
				Type blue[3];
				Type whitePt[3];
			}; // struct
		}; // union
	}; // Matrix
} // Color

#endif

#endif
