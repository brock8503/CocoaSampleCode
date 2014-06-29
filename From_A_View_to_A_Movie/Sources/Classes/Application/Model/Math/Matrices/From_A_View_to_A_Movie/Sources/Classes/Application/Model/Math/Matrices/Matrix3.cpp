/*
     File: Matrix3.cpp
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

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#import <iostream>
#import <limits>

//------------------------------------------------------------------------------------

#import "Matrix3.h"

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type>::Matrix3()
{
    const Type kZero = Type(0);
    
    matrix[0] = kZero;
    matrix[1] = kZero;
    matrix[2] = kZero;
    
    matrix[3] = kZero;
    matrix[4] = kZero;
    matrix[5] = kZero;
    
    matrix[6] = kZero;
    matrix[7] = kZero;
    matrix[8] = kZero;
    
    matrix[9] = Type(1E-9);
} // Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type>::Matrix3(const bool &bIsRowMajor,
							 const Type * const pMatrix)
{
    if( pMatrix != NULL )
    {
        if( bIsRowMajor )
        {
            matrix[0] = pMatrix[0];
            matrix[1] = pMatrix[1];
            matrix[2] = pMatrix[2];
            
            matrix[3] = pMatrix[3];
            matrix[4] = pMatrix[4];
            matrix[5] = pMatrix[5];
            
            matrix[6] = pMatrix[6];
            matrix[7] = pMatrix[7];
            matrix[8] = pMatrix[8];
        } // if
        else
        {
            matrix[0] = pMatrix[0];
            matrix[1] = pMatrix[3];
            matrix[2] = pMatrix[6];
            
            matrix[3] = pMatrix[1];
            matrix[4] = pMatrix[4];
            matrix[5] = pMatrix[7];
            
            matrix[6] = pMatrix[2];
            matrix[7] = pMatrix[5];
            matrix[8] = pMatrix[8];
        } // else
    } // if
    else
    {
        const Type kZero = Type(0);
        
        matrix[0] = kZero;
        matrix[1] = kZero;
        matrix[2] = kZero;
        
        matrix[3] = kZero;
        matrix[4] = kZero;
        matrix[5] = kZero;
        
        matrix[6] = kZero;
        matrix[7] = kZero;
        matrix[8] = kZero;
    } // else
    
    matrix[9] = Type(1E-9);
} // Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type>::Matrix3(const bool &bIsRowMajor,
							 const Math::Vector3<Type> &rVec1,
							 const Math::Vector3<Type> &rVec2,
							 const Math::Vector3<Type> &rVec3)
{
    if( bIsRowMajor )
    {
        matrix[0] = rVec1.x;
        matrix[1] = rVec1.y;
        matrix[2] = rVec1.z;
        
        matrix[3] = rVec1.x;
        matrix[4] = rVec1.y;
        matrix[5] = rVec1.z;
        
        matrix[6] = rVec1.x;
        matrix[7] = rVec1.y;
        matrix[8] = rVec1.z;
    } // if
    else
    {
        matrix[0] = rVec1.x;
        matrix[1] = rVec2.x;
        matrix[2] = rVec3.x;
        
        matrix[3] = rVec1.y;
        matrix[4] = rVec2.y;
        matrix[5] = rVec3.y;
        
        matrix[6] = rVec1.z;
        matrix[7] = rVec2.z;
        matrix[8] = rVec3.z;
    } // else
    
    matrix[9] = Type(1E-9);
} // Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type>::Matrix3(const bool &bIsRowMajor,
							 const Math::Vector2<Type> &rVec1,
							 const Math::Vector2<Type> &rVec2,
							 const Math::Vector2<Type> &rVec3)
{
    const Type kZero = Type(0);
	
    if( bIsRowMajor )
    {
        matrix[0] = rVec1.x;
        matrix[1] = rVec1.y;
        matrix[2] = kZero;
        
        matrix[3] = rVec1.x;
        matrix[4] = rVec1.y;
        matrix[5] = kZero;
        
        matrix[6] = rVec1.x;
        matrix[7] = rVec1.y;
        matrix[8] = kZero;
    } // if
    else
    {
        matrix[0] = rVec1.x;
        matrix[1] = rVec2.x;
        matrix[2] = rVec3.x;
        
        matrix[3] = rVec1.y;
        matrix[4] = rVec2.y;
        matrix[5] = rVec3.y;
        
        matrix[6] = kZero;
        matrix[7] = kZero;
        matrix[8] = kZero;
    } // else
    
    matrix[9] = Type(1E-9);
} // Constructor

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type>::Matrix3(const Math::Matrix3<Type> &rMatrix)
{
    matrix[0] = rMatrix.matrix[0];
    matrix[1] = rMatrix.matrix[1];
    matrix[2] = rMatrix.matrix[2];
    
    matrix[3] = rMatrix.matrix[3];
    matrix[4] = rMatrix.matrix[4];
    matrix[5] = rMatrix.matrix[5];
    
    matrix[6] = rMatrix.matrix[6];
    matrix[7] = rMatrix.matrix[7];
    matrix[8] = rMatrix.matrix[8];
    
    matrix[9] = rMatrix.matrix[9];
} // Copy Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type>::Matrix3(const Math::Matrix3<Type> * const pMatrix)
{
    if( pMatrix != NULL )
    {
        matrix[0]  = pMatrix->matrix[0];
        matrix[1]  = pMatrix->matrix[1];
        matrix[2]  = pMatrix->matrix[2];
        
        matrix[3]  = pMatrix->matrix[3];
        matrix[4]  = pMatrix->matrix[4];
        matrix[5]  = pMatrix->matrix[5];
        
        matrix[6]  = pMatrix->matrix[6];
        matrix[7]  = pMatrix->matrix[7];
        matrix[8]  = pMatrix->matrix[8];
        
        matrix[9] = pMatrix->matrix[9];
    } // if
    else
    {
        const Type kZero = Type(0);
        
        matrix[0]  = kZero;
        matrix[1]  = kZero;
        matrix[2]  = kZero;
        
        matrix[3]  = kZero;
        matrix[4]  = kZero;
        matrix[5]  = kZero;
        
        matrix[6]  = kZero;
        matrix[7]  = kZero;
        matrix[8]  = kZero;
        
        matrix[9] = Type(1E-9);
    } // else
} // Copy Constructor

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type>::~Matrix3()
{
    const Type kZero = Type(0);
    
    matrix[0] = kZero;
    matrix[1] = kZero;
    matrix[2] = kZero;
    
    matrix[3] = kZero;
    matrix[4] = kZero;
    matrix[5] = kZero;
    
    matrix[6] = kZero;
    matrix[7] = kZero;
    matrix[8] = kZero;
    
    matrix[9] = kZero;
} // Destructor

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Assignment Operator

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type> &Math::Matrix3<Type>::operator=(const Math::Matrix3<Type> &rMatrix)
{
	if( this != &rMatrix )
	{
        matrix[0] = rMatrix.matrix[0];
        matrix[1] = rMatrix.matrix[1];
        matrix[2] = rMatrix.matrix[2];
        
        matrix[3] = rMatrix.matrix[3];
        matrix[4] = rMatrix.matrix[4];
        matrix[5] = rMatrix.matrix[5];
        
        matrix[6] = rMatrix.matrix[6];
        matrix[7] = rMatrix.matrix[7];
        matrix[8] = rMatrix.matrix[8];
        
        matrix[9] = rMatrix.matrix[9];
	} // if
	
	return *this;
} // Operator=

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Operators

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Matrix3<Type>::operator[](const std::size_t &nRow) const
{
    Math::Vector3<Type> v(Type(0),Type(0),Type(0));
    
    if( nRow < 3 )
    {
        const std::size_t nIdx = 3*nRow;
        
        v.x = matrix[nIdx];
        v.y = matrix[nIdx+1];
        v.z = matrix[nIdx+2];
    } // if
    
    return v;
} // operator[]

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> Math::Matrix3<Type>::operator+(const Math::Matrix3<Type> &rMatrix) const
{
	Math::Matrix3<Type> matrixC;
	
    matrixC.matrix[0] = matrix[0] + rMatrix.matrix[0];
    matrixC.matrix[1] = matrix[1] + rMatrix.matrix[1];
    matrixC.matrix[2] = matrix[2] + rMatrix.matrix[2];
    
    matrixC.matrix[3] = matrix[3] + rMatrix.matrix[3];
    matrixC.matrix[4] = matrix[4] + rMatrix.matrix[4];
    matrixC.matrix[5] = matrix[5] + rMatrix.matrix[5];
    
    matrixC.matrix[6] = matrix[6] + rMatrix.matrix[6];
    matrixC.matrix[7] = matrix[7] + rMatrix.matrix[7];
    matrixC.matrix[8] = matrix[8] + rMatrix.matrix[8];
	
	return matrixC;
} // Matrix3::operator+

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> Math::Matrix3<Type>::operator+(const Type &k) const
{
	Math::Matrix3<Type> matrixB;
	
    matrixB.matrix[0] = matrix[0] + k;
    matrixB.matrix[1] = matrix[1] + k;
    matrixB.matrix[2] = matrix[2] + k;
    
    matrixB.matrix[3] = matrix[3] + k;
    matrixB.matrix[4] = matrix[4] + k;
    matrixB.matrix[5] = matrix[5] + k;
    
    matrixB.matrix[6] = matrix[6] + k;
    matrixB.matrix[7] = matrix[7] + k;
    matrixB.matrix[8] = matrix[8] + k;
	
	return matrixB;
} // Matrix3::operator+

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> Math::Matrix3<Type>::operator-(const Math::Matrix3<Type> &rMatrix) const
{
	Math::Matrix3<Type> matrixC;
	
    matrixC.matrix[0] = rMatrix.matrix[0] - matrix[0];
    matrixC.matrix[1] = rMatrix.matrix[1] - matrix[1];
    matrixC.matrix[2] = rMatrix.matrix[2] - matrix[2];
    
    matrixC.matrix[3] = rMatrix.matrix[3] - matrix[3];
    matrixC.matrix[4] = rMatrix.matrix[4] - matrix[4];
    matrixC.matrix[5] = rMatrix.matrix[5] - matrix[5];
    
    matrixC.matrix[6] = rMatrix.matrix[6] - matrix[6];
    matrixC.matrix[7] = rMatrix.matrix[7] - matrix[7];
    matrixC.matrix[8] = rMatrix.matrix[8] - matrix[8];
	
	return matrixC;
} // Matrix3::operator-

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> Math::Matrix3<Type>::operator-(const Type &k) const
{
	Math::Matrix3<Type> matrixB;
	
    matrixB.matrix[0] = matrix[0] - k;
    matrixB.matrix[1] = matrix[1] - k;
    matrixB.matrix[2] = matrix[2] - k;
    
    matrixB.matrix[3] = matrix[3] - k;
    matrixB.matrix[4] = matrix[4] - k;
    matrixB.matrix[5] = matrix[5] - k;
    
    matrixB.matrix[6] = matrix[6] - k;
    matrixB.matrix[7] = matrix[7] - k;
    matrixB.matrix[8] = matrix[8] - k;
	
	return matrixB;
} // Matrix3::operator-

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> Math::Matrix3<Type>::operator*(const Math::Matrix3<Type> &rMatrix) const
{
	Math::Matrix3<Type> C;
    
	Math::Vector3<Type> a_1(rMatrix.matrix[0],rMatrix.matrix[1],rMatrix.matrix[2]);
	Math::Vector3<Type> a_2(rMatrix.matrix[3],rMatrix.matrix[4],rMatrix.matrix[5]);
	Math::Vector3<Type> a_3(rMatrix.matrix[6],rMatrix.matrix[7],rMatrix.matrix[8]);
    
	Math::Vector3<Type> b_1(matrix[0],matrix[3],matrix[6]);
	Math::Vector3<Type> b_2(matrix[1],matrix[4],matrix[7]);
	Math::Vector3<Type> b_3(matrix[2],matrix[5],matrix[8]);
	
    C.matrix[0] = a_1 * b_1;
    C.matrix[1] = a_1 * b_2;
    C.matrix[2] = a_1 * b_3;
    
    C.matrix[3] = a_2 * b_1;
    C.matrix[4] = a_2 * b_2;
    C.matrix[5] = a_2 * b_3;
    
    C.matrix[6] = a_3 * b_1;
    C.matrix[7] = a_3 * b_2;
    C.matrix[8] = a_3 * b_3;
    
	return C;
} // Matrix3::operator*

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> Math::Matrix3<Type>::operator*(const Type &k) const
{
	Math::Matrix3<Type> matrixB;
	
    matrixB.matrix[0] = matrix[0] * k;
    matrixB.matrix[1] = matrix[1] * k;
    matrixB.matrix[2] = matrix[2] * k;
    
    matrixB.matrix[3] = matrix[3] * k;
    matrixB.matrix[4] = matrix[4] * k;
    matrixB.matrix[5] = matrix[5] * k;
    
    matrixB.matrix[6] = matrix[6] * k;
    matrixB.matrix[7] = matrix[7] * k;
    matrixB.matrix[8] = matrix[8] * k;
	
	return matrixB;
} // Matrix3::operator*

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Matrix3<Type> Math::Matrix3<Type>::operator/(const Type &k) const
{
	Math::Matrix3<Type> matrixB;
	
    if( k >=  matrix[9] )
    {
        const Type K = Type(1) / k;
        
        matrixB.matrix[0] = matrix[0] * K;
        matrixB.matrix[1] = matrix[1] * K;
        matrixB.matrix[2] = matrix[2] * K;
        
        matrixB.matrix[3] = matrix[3] * K;
        matrixB.matrix[4] = matrix[4] * K;
        matrixB.matrix[5] = matrix[5] * K;
        
        matrixB.matrix[6] = matrix[6] * K;
        matrixB.matrix[7] = matrix[7] * K;
        matrixB.matrix[8] = matrix[8] * K;
    } // if
	
	return matrixB;
} // Matrix3::operator/

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type> &Math::Matrix3<Type>::operator+=(const Math::Matrix3<Type> &rMatrix)
{
    matrix[0] += rMatrix.matrix[0];
    matrix[1] += rMatrix.matrix[1];
    matrix[2] += rMatrix.matrix[2];
    
    matrix[3] += rMatrix.matrix[3];
    matrix[4] += rMatrix.matrix[4];
    matrix[5] += rMatrix.matrix[5];
    
    matrix[6] += rMatrix.matrix[6];
    matrix[7] += rMatrix.matrix[7];
    matrix[8] += rMatrix.matrix[8];
	
	return *this;
} // Matrix3::operator+=

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type> &Math::Matrix3<Type>::operator-=(const Math::Matrix3<Type> &rMatrix)
{
    matrix[0] -= rMatrix.matrix[0];
    matrix[1] -= rMatrix.matrix[1];
    matrix[2] -= rMatrix.matrix[2];
    
    matrix[3] -= rMatrix.matrix[3];
    matrix[4] -= rMatrix.matrix[4];
    matrix[5] -= rMatrix.matrix[5];
    
    matrix[6] -= rMatrix.matrix[6];
    matrix[7] -= rMatrix.matrix[7];
    matrix[8] -= rMatrix.matrix[8];
	
	return *this;
} // Matrix3::operator-=

//------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type> &Math::Matrix3<Type>::operator*=(const Math::Matrix3<Type> &rMatrix)
{
	Math::Vector3<Type> a_1(rMatrix.matrix[0],rMatrix.matrix[1],rMatrix.matrix[2]);
	Math::Vector3<Type> a_2(rMatrix.matrix[3],rMatrix.matrix[4],rMatrix.matrix[5]);
	Math::Vector3<Type> a_3(rMatrix.matrix[6],rMatrix.matrix[7],rMatrix.matrix[8]);
    
	Math::Vector3<Type> b_1(matrix[0],matrix[3],matrix[6]);
	Math::Vector3<Type> b_2(matrix[1],matrix[4],matrix[7]);
	Math::Vector3<Type> b_3(matrix[2],matrix[5],matrix[8]);
    
    matrix[0] = a_1 * b_1;
    matrix[1] = a_1 * b_2;
    matrix[2] = a_1 * b_3;
    
    matrix[3] = a_2 * b_1;
    matrix[4] = a_2 * b_2;
    matrix[5] = a_2 * b_3;
    
    matrix[6] = a_3 * b_1;
    matrix[7] = a_3 * b_2;
    matrix[8] = a_3 * b_3;
	
	return *this;
} // Matrix3::operator*=

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type> &Math::Matrix3<Type>::operator+=(const Type &k)
{
    matrix[0] += k;
    matrix[1] += k;
    matrix[2] += k;
    
    matrix[3] += k;
    matrix[4] += k;
    matrix[5] += k;
    
    matrix[6] += k;
    matrix[7] += k;
    matrix[8] += k;
	
	return *this;
} // Matrix3::operator+=

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type> &Math::Matrix3<Type>::operator-=(const Type &k)
{
    matrix[0] -= k;
    matrix[1] -= k;
    matrix[2] -= k;
    
    matrix[3] -= k;
    matrix[4] -= k;
    matrix[5] -= k;
    
    matrix[6] -= k;
    matrix[7] -= k;
    matrix[8] -= k;
	
	return *this;
} // Matrix3::operator-=

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type> &Math::Matrix3<Type>::operator*=(const Type &k)
{
    matrix[0] *= k;
    matrix[1] *= k;
    matrix[2] *= k;
    
    matrix[3] *= k;
    matrix[4] *= k;
    matrix[5] *= k;
    
    matrix[6] *= k;
    matrix[7] *= k;
    matrix[8] *= k;
	
	return *this;
} // Matrix3::operator*=

//------------------------------------------------------------------------------------

template <typename Type>
Math::Matrix3<Type> &Math::Matrix3<Type>::operator/=(const Type &k)
{
    if( k >= matrix[9] )
    {
        const Type K = Type(1) / k;
        
        matrix[0] *= K;
        matrix[1] *= K;
        matrix[2] *= K;
        
        matrix[3] *= K;
        matrix[4] *= K;
        matrix[5] *= K;
        
        matrix[6] *= K;
        matrix[7] *= K;
        matrix[8] *= K;
    } // if
	
	return *this;
} // Matrix3::operator*=

//------------------------------------------------------------------------------------

template <typename Type>
Type &Math::Matrix3<Type>::operator()(const std::size_t &nRow,
									  const std::size_t &nColumn)
{
    static Type nError = std::numeric_limits<Type>::has_quiet_NaN ? std::numeric_limits<Type>::quiet_NaN() : Type(0);
    
    if( nRow > 2 )
    {
        std::cerr
        << std::endl
        << ">> ERROR:  Matrix 3 - Row index "
        << nRow
        << " is outside the row bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    if( nColumn > 2 )
    {
        std::cerr
        << std::endl
        << ">> ERROR:  Matrix 3 - Column index "
        << nColumn
        << " is outside the column bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    const std::size_t k = 3 * nRow + nColumn;
	
    return matrix[k];
} // Matrix3::operator()

//------------------------------------------------------------------------------------

template <typename Type>
Type Math::Matrix3<Type>::operator()(const std::size_t &nRow,
									 const std::size_t &nColumn) const
{
    Type nError = std::numeric_limits<Type>::has_quiet_NaN ? std::numeric_limits<Type>::quiet_NaN() : Type(0);
	
    if( nRow > 2 )
    {
        std::cerr
        << std::endl
        << ">> ERROR:  Matrix 3 - Row index "
        << nRow
        << " is outside the row bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    if( nColumn > 2 )
    {
        std::cerr
        << std::endl
        << ">> ERROR:  Matrix 3 - Column index "
        << nColumn
        << " is outside the column bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    const std::size_t k = 3 * nRow + nColumn;
    
    return matrix[k];
} // Matrix3::operator()

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//------------------------------------------------------------------------------------

template <typename Type>
void Math::Matrix3<Type>::SetColumn(const std::size_t &nCol,
									const Math::Vector3<Type> &rVec)
{
    if( nCol < 3 )
    {
        matrix[nCol]    = rVec.x;
        matrix[nCol+3]  = rVec.y;
        matrix[nCol+6]  = rVec.z;
    } // if
} // SetColumn

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Matrix3<Type>::GetColumn(const std::size_t &nCol) const
{
    Math::Vector3<Type> v(Type(0),Type(0),Type(0));
    
    if( nCol < 3 )
    {
        v.x = matrix[nCol];
        v.y = matrix[nCol+3];
        v.z = matrix[nCol+6];
    } // if
    
    return v;
} // GetColumn

//------------------------------------------------------------------------------------

template <typename Type>
void Math::Matrix3<Type>::SetRow(const std::size_t &nRow,
								 const Math::Vector3<Type> &rVec)
{
    if( nRow < 3 )
    {
        const std::size_t nIdx = 3*nRow;
        
        matrix[nIdx]   = rVec.x;
        matrix[nIdx+1] = rVec.y;
        matrix[nIdx+2] = rVec.z;
    } // if
} // SetRow

//------------------------------------------------------------------------------------

template <typename Type>
const Math::Vector3<Type> Math::Matrix3<Type>::GetRow(const std::size_t &nRow) const
{
    Math::Vector3<Type> v(Type(0),Type(0),Type(0));
    
    if( nRow < 3 )
    {
        const std::size_t nIdx = 3*nRow;
        
        v.x = matrix[nIdx];
        v.y = matrix[nIdx+1];
        v.z = matrix[nIdx+2];
    } // if
    
    return v;
} // GetRow

//------------------------------------------------------------------------------------

template <typename Type>
const Type Math::Matrix3<Type>::GetTolerance() const
{
	return( matrix[9] );
} // Matrix3::GetTolerance

//------------------------------------------------------------------------------------

template <typename Type>
void  Math::Matrix3<Type>::SetMatrix(const bool &bIsRowMajor,
									 const Type * const pArray2D)
{
	if( pArray2D != NULL )
	{
        if( bIsRowMajor )
        {
            matrix[0] = pArray2D[0];
            matrix[1] = pArray2D[1];
            matrix[2] = pArray2D[2];
            
            matrix[3] = pArray2D[3];
            matrix[4] = pArray2D[4];
            matrix[5] = pArray2D[5];
            
            matrix[6] = pArray2D[6];
            matrix[7] = pArray2D[7];
            matrix[8] = pArray2D[8];
        } // if
        else
        {
            matrix[0] = pArray2D[0];
            matrix[1] = pArray2D[3];
            matrix[2] = pArray2D[6];
            
            matrix[3] = pArray2D[1];
            matrix[4] = pArray2D[4];
            matrix[5] = pArray2D[7];
            
            matrix[6] = pArray2D[2];
            matrix[7] = pArray2D[5];
            matrix[8] = pArray2D[8];
        } // else
	} // if
} // Matrix3::SetMatrix3

//------------------------------------------------------------------------------------

template <typename Type>
void  Math::Matrix3<Type>::SetMatrix(const bool &bIsRowMajor,
									 const Math::Vector3<Type> &rVec1,
									 const Math::Vector3<Type> &rVec2,
									 const Math::Vector3<Type> &rVec3)
{
    if( bIsRowMajor )
    {
        matrix[0] = rVec1.x;
        matrix[1] = rVec1.y;
        matrix[2] = rVec1.z;
        
        matrix[3] = rVec1.x;
        matrix[4] = rVec1.y;
        matrix[5] = rVec1.z;
        
        matrix[6] = rVec1.z;
        matrix[7] = rVec1.y;
        matrix[8] = rVec1.z;
    } // if
    else
    {
        matrix[0] = rVec1.x;
        matrix[1] = rVec2.x;
        matrix[2] = rVec3.x;
        
        matrix[3] = rVec1.y;
        matrix[4] = rVec2.y;
        matrix[5] = rVec3.y;
        
        matrix[6] = rVec1.z;
        matrix[7] = rVec2.z;
        matrix[8] = rVec3.z;
    } // else
} // Matrix3::SetMatrix3

//------------------------------------------------------------------------------------

template <typename Type>
void  Math::Matrix3<Type>::SetTolerance(const Type &nTolerance)
{
	matrix[9] = (nTolerance > Type(0) ) ? nTolerance : Type(1E-9);
} // Matrix3::SetTolerance

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Template Implementations

//------------------------------------------------------------------------------------

template class Math::Matrix3<float>;
template class Math::Matrix3<double>;

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Friends - Vector Product

//------------------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> Matrix3Mult1(const Math::Matrix3<Type> &rMatrix,
								 const Math::Vector3<Type> &rVector)
{
    const Type *a = rMatrix.matrix;
    
    Math::Vector3<Type> x(a[0],a[1],a[2]);
    Math::Vector3<Type> y(a[3],a[4],a[5]);
    Math::Vector3<Type> z(a[6],a[7],a[8]);
    
    Math::Vector3<Type> r;
    
    r.x = rVector * x;
    r.y = rVector * y;
    r.z = rVector * z;
    
    return r;
} // Matrix3Mult1

//------------------------------------------------------------------------------------

Math::Vector3<double> Math::operator*(const Math::Matrix3<double> &rMatrix,
									  const Math::Vector3<double> &rVector)
{
    return Matrix3Mult1<double>(rMatrix,rVector);
} // operator *

//------------------------------------------------------------------------------------

Math::Vector3<float> Math::operator*(const Math::Matrix3<float> &rMatrix,
									 const Math::Vector3<float> &rVector)
{
    return Matrix3Mult1<float>(rMatrix,rVector);
} // operator *

//------------------------------------------------------------------------------------

template <typename Type>
Math::Vector3<Type> Matrix3Mult2(const Math::Vector3<Type> &rVector,
								 const Math::Matrix3<Type> &rMatrix)
{
    const Type *a = rMatrix.matrix;
    
    Math::Vector3<Type> x(a[0],a[3],a[6]);
    Math::Vector3<Type> y(a[1],a[4],a[7]);
    Math::Vector3<Type> z(a[2],a[5],a[8]);
    
    Math::Vector3<Type> r;
    
    r.x = rVector * x;
    r.y = rVector * y;
    r.z = rVector * z;
    
    return r;
} // operator *

//------------------------------------------------------------------------------------

Math::Vector3<double> Math::operator*(const Math::Vector3<double> &rVector,
									  const Math::Matrix3<double> &rMatrix)
{
    return Matrix3Mult2<double>(rVector,rMatrix);
} // operator *

//------------------------------------------------------------------------------------

Math::Vector3<float> Math::operator*(const Math::Vector3<float> &rVector,
									 const Math::Matrix3<float> &rMatrix)
{
    return Matrix3Mult2<float>(rVector,rMatrix);
} // operator *

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Methods - Diagonal Matrix

//------------------------------------------------------------------------------------

template <typename Type>
static Math::Matrix3<Type> Matrix3Diag(const Math::Vector3<Type> &rScalar)
{
    const Type kZero = Type(0);
    
    Type S[16];
    
    S[0]  = rScalar.x;
    S[1]  = kZero;
    S[2]  = kZero;
    
    S[3]  = kZero;
    S[4]  = rScalar.y;
    S[5]  = kZero;
    
    S[6]  = kZero;
    S[7]  = kZero;
    S[8]  = rScalar.z;
    
    return Math::Matrix3<Type>(true,S);
} // Matrix3Diag

//------------------------------------------------------------------------------------
//
// Construct a diagonal 3x3 matrix.
// Can be used to create identity and scalar matrices.
//
//------------------------------------------------------------------------------------

Math::Matrix3<double> Math::diag(const Math::Vector3<double> &rScalar)
{
    return Matrix3Diag<double>(rScalar);
} // diag

//------------------------------------------------------------------------------------

Math::Matrix3<float> Math::diag(const Math::Vector3<float>  &rScalar)
{
    return Matrix3Diag<float>(rScalar);
} // diag

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Methods - Determinants

//------------------------------------------------------------------------------------

template <typename Type>
static Type Matrix3Det(const Math::Matrix3<Type> &rMatrix)
{
    const Type *matrix = rMatrix.matrix;
    
	// Compute the minors to form a matrix of cofactors
	
	Type N[3];
	
	N[0] = matrix[4] * matrix[8] - matrix[5] * matrix[7];
	N[1] = matrix[5] * matrix[6] - matrix[3] * matrix[8];
	N[2] = matrix[3] * matrix[7] - matrix[4] * matrix[6];
	
	// Compute the determinant from the cofactors
	
	Type det = matrix[0] * N[0] + matrix[1] * N[1] + matrix[2] * N[2];
	
	return det;
} // Matrix3Det

//------------------------------------------------------------------------------------

double Math::det(const Math::Matrix3<double> &rMatrix)
{
    return Matrix3Det<double>(rMatrix);
} // det

//------------------------------------------------------------------------------------

float  Math::det(const Math::Matrix3<float>  &rMatrix)
{
    return Matrix3Det<float>(rMatrix);
} // det

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Methods - Inverse

//------------------------------------------------------------------------------------
//
// Calculate matrix inverse using the co-factor expansion.
//
//------------------------------------------------------------------------------------

template <typename Type>
static Math::Matrix3<Type> Matrix3Inv(const Math::Matrix3<Type> &rMatrix)
{
    const Type *matrix = rMatrix.matrix;
    
	// Compute the minors in order to compute the determinant
	
	Type N[9];
	
	N[0] = matrix[4] * matrix[8] - matrix[5] * matrix[7];
	N[1] = matrix[5] * matrix[6] - matrix[3] * matrix[8];
	N[2] = matrix[3] * matrix[7] - matrix[4] * matrix[6];
	
	// Compute the determinant using the minors
	
	Type det = matrix[0] * N[0] + matrix[1] * N[1] + matrix[2] * N[2];
	
	// If the matrix is singular do not continue
	
	if( det < rMatrix.GetTolerance() )
	{
		std::cerr << ">> ERROR:  Matrix 3 -  3x3 matrix is singular!" << std::endl;
		
		return rMatrix;
	} // if
	
	// Compute the rest of the minors to form a matrix of cofactors
	
	N[3] = matrix[7] * matrix[2] - matrix[8] * matrix[1];
	N[4] = matrix[8] * matrix[0] - matrix[6] * matrix[2];
	N[5] = matrix[6] * matrix[1] - matrix[7] * matrix[0];
	N[6] = matrix[1] * matrix[5] - matrix[2] * matrix[4];
	N[7] = matrix[2] * matrix[3] - matrix[0] * matrix[5];
	N[8] = matrix[0] * matrix[4] - matrix[1] * matrix[3];
	
	// The inverse of the matrix is the inverse of the determinant
	// times the transpose of the matrix of cofactors
	
	Type idet = Type(1) / det;
	
    Type R[9];
    
	R[0] = idet * N[0];
	R[1] = idet * N[3];
	R[2] = idet * N[6];
	R[3] = idet * N[1];
	R[4] = idet * N[4];
	R[5] = idet * N[7];
	R[6] = idet * N[2];
	R[7] = idet * N[5];
	R[8] = idet * N[8];
    
	return Math::Matrix3<Type>(true, R);
} // Matrix3Inv

//------------------------------------------------------------------------------------


Math::Matrix3<double> Math::inv(const Math::Matrix3<double> &rMatrix)
{
    return Matrix3Inv<double>(rMatrix);
} // inv

//------------------------------------------------------------------------------------

Math::Matrix3<float>  Math::inv(const Math::Matrix3<float>  &rMatrix)
{
    return Matrix3Inv<float>(rMatrix);
} // inv

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Methods - Transpose

//------------------------------------------------------------------------------------

template<typename Type>
static Math::Matrix3<Type> Matrix3Transpose(const Math::Matrix3<Type> &rMatrix)
{
    const Type *matrix = rMatrix.matrix;
    
    Type T[9];
    
    T[0] = matrix[0];
    T[1] = matrix[3];
    T[2] = matrix[6];
    
    T[3] = matrix[1];
    T[4] = matrix[4];
    T[5] = matrix[7];
    
    T[6] = matrix[2];
    T[7] = matrix[5];
    T[8] = matrix[8];
    
    return Math::Matrix3<Type>(true,T);
} // Matrix3Transpose

//------------------------------------------------------------------------------------

Math::Matrix3<double> Math::tr(const Math::Matrix3<double> &rMatrix)
{
    return Matrix3Transpose<double>(rMatrix);
} // tr

//------------------------------------------------------------------------------------

Math::Matrix3<float> Math::tr(const Math::Matrix3<float>  &rMatrix)
{
    return Matrix3Transpose<float>(rMatrix);
} // tr

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Methods - Solutions of 3x3 Linear System

//------------------------------------------------------------------------------------

template<typename Type>
static Math::Vector3<Type> Matrix3Solve(const Math::Vector3<Type> &rColVecB,
										const Math::Matrix3<Type> &rMatrix)
{
    Math::Matrix3<Type> A = Math::inv(rMatrix);
	
    const Type *a = A.matrix;
    
	Math::Vector3<Type> a_0(a[0],a[1],a[2]);
	Math::Vector3<Type> a_1(a[3],a[4],a[5]);
	Math::Vector3<Type> a_2(a[6],a[7],a[8]);
    
    Math::Vector3<Type> r;
    
    r.x = a_0 * rColVecB;
    r.y = a_1 * rColVecB;
    r.z = a_2 * rColVecB;
    
	return r;
} // Matrix3Solve

//------------------------------------------------------------------------------------

Math::Vector3<double> Math::solve(const Math::Vector3<double> &rColVecB,
								  const Math::Matrix3<double> &rMatrix)
{
    return Matrix3Solve<double>(rColVecB, rMatrix);
} // inv

//------------------------------------------------------------------------------------

Math::Vector3<float> Math::solve(const Math::Vector3<float> &rColVecB,
								 const Math::Matrix3<float> &rMatrix)
{
    return Matrix3Solve<float>(rColVecB, rMatrix);
} // inv

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Methods - Orthonormalize

//------------------------------------------------------------------------------------

template<typename Type>
static Math::Matrix3<Type> Matrix3Orthonormalize(const Math::Matrix3<Type> &matrix)
{
    Math::Vector3<Type> v[3];
    
    v[0] = norml(matrix[0]);
    
    v[1] = matrix[1];
    v[2] = matrix[2];
    
    v[1] = v[1] - proj(v[0], v[1]);
    v[1] = norml(v[1]);
	
    v[2] = v[2] - proj(v[0], v[2]) - proj(v[1], v[2]);
    v[2] = norml(v[2]);
	
    return Math::Matrix3<Type>(true, v[0], v[1], v[2]);
} // Matrix3Orthonormalize

//------------------------------------------------------------------------------------

Math::Matrix3<double> Math::orthn(const Math::Matrix3<double> &rMatrix)
{
    return Matrix3Orthonormalize<double>(rMatrix);
} // orthn

//------------------------------------------------------------------------------------

Math::Matrix3<float>  Math::orthn(const Math::Matrix3<float>  &rMatrix)
{
    return Matrix3Orthonormalize<float>(rMatrix);
} // orthn

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

