/*
     File: CMatrix.cpp
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

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#import <iostream>
#import <limits>

//------------------------------------------------------------------------------------

#import "CMatrix.h"

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructors

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type>::Matrix()
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
    
    matrix[9]  = kZero;
    matrix[10] = kZero;
    matrix[11] = kZero;
} // Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type>::Matrix(const Type * const pMatrix)
{
    if( pMatrix != NULL )
    {
        matrix[0]  = pMatrix[0];
        matrix[1]  = pMatrix[1];
        matrix[2]  = pMatrix[2];
        
        matrix[3]  = pMatrix[3];
        matrix[4]  = pMatrix[4];
        matrix[5]  = pMatrix[5];
        
        matrix[6]  = pMatrix[6];
        matrix[7]  = pMatrix[7];
        matrix[8]  = pMatrix[8];
        
        matrix[9]  = pMatrix[9];
        matrix[10] = pMatrix[10];
        matrix[11] = pMatrix[11];
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
        
        matrix[9]  = kZero;
        matrix[10] = kZero;
        matrix[11] = kZero;
    } // else
} // Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type>::Matrix(const Math::Matrix3<Type> &rMatrix,
							const Math::Vector3<Type> &rWhitePt)
{
    const Type *N = rMatrix.matrix;
    
    matrix[0]  = N[0];
    matrix[1]  = N[1];
    matrix[2]  = N[2];
    
    matrix[3]  = N[3];
    matrix[4]  = N[4];
    matrix[5]  = N[5];
    
    matrix[6]  = N[6];
    matrix[7]  = N[7];
    matrix[8]  = N[8];
    
    matrix[9]  = rWhitePt.x;
    matrix[10] = rWhitePt.y;
    matrix[11] = rWhitePt.z;
} // Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type>::Matrix(const Math::Vector3<Type> &rRed,
							const Math::Vector3<Type> &rGreen,
							const Math::Vector3<Type> &rBlue,
							const Math::Vector3<Type> &rWhitePt)
{
    matrix[0] = rRed.x;
    matrix[1] = rRed.y;
    matrix[2] = rRed.z;
    
    matrix[3] = rGreen.x;
    matrix[4] = rGreen.y;
    matrix[5] = rGreen.z;
    
    matrix[6] = rBlue.x;
    matrix[7] = rBlue.y;
    matrix[8] = rBlue.z;
    
    matrix[9]  = rWhitePt.x;
    matrix[10] = rWhitePt.y;
    matrix[11] = rWhitePt.z;
} // Constructor

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type>::Matrix(const Matrix<Type> &rMatrix)
{
    matrix[0]  = rMatrix.matrix[0];
    matrix[1]  = rMatrix.matrix[1];
    matrix[2]  = rMatrix.matrix[2];
    
    matrix[3]  = rMatrix.matrix[3];
    matrix[4]  = rMatrix.matrix[4];
    matrix[5]  = rMatrix.matrix[5];
    
    matrix[6]  = rMatrix.matrix[6];
    matrix[7]  = rMatrix.matrix[7];
    matrix[8]  = rMatrix.matrix[8];
    
    matrix[9]  = rMatrix.matrix[9];
    matrix[10] = rMatrix.matrix[10];
    matrix[11] = rMatrix.matrix[11];
} // Copy Constructor

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type>::Matrix(const Matrix<Type> * const pMatrix)
{
    if( pMatrix != NULL )
    {
        const Type *pElements = pMatrix->matrix;
        
        matrix[0]  = pElements[0];
        matrix[1]  = pElements[1];
        matrix[2]  = pElements[2];
        
        matrix[3]  = pElements[3];
        matrix[4]  = pElements[4];
        matrix[5]  = pElements[5];
        
        matrix[6]  = pElements[6];
        matrix[7]  = pElements[7];
        matrix[8]  = pElements[8];
        
        matrix[9]  = pElements[9];
        matrix[10] = pElements[10];
        matrix[11] = pElements[11];
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
        
        matrix[9]  = kZero;
        matrix[10] = kZero;
        matrix[11] = kZero;
    } // else
} // Copy Constructor

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type>::~Matrix()
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
    
    matrix[9]  = kZero;
    matrix[10] = kZero;
    matrix[11] = kZero;
} // Destructor

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Assignment Operator

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type> &Color::Matrix<Type>::operator=(const Matrix<Type> &rMatrix)
{
	if( this != &rMatrix )
	{
        matrix[0]  = rMatrix.matrix[0];
        matrix[1]  = rMatrix.matrix[1];
        matrix[2]  = rMatrix.matrix[2];
        
        matrix[3]  = rMatrix.matrix[3];
        matrix[4]  = rMatrix.matrix[4];
        matrix[5]  = rMatrix.matrix[5];
        
        matrix[6]  = rMatrix.matrix[6];
        matrix[7]  = rMatrix.matrix[7];
        matrix[8]  = rMatrix.matrix[8];
        
        matrix[9]  = rMatrix.matrix[9];
        matrix[10] = rMatrix.matrix[10];
        matrix[11] = rMatrix.matrix[11];
	} // if
	
	return *this;
} // Matrix::operator=

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Operators

//------------------------------------------------------------------------------------

template <typename Type>
const Color::Matrix<Type> Color::Matrix<Type>::operator+(const Matrix<Type> &rMatrix) const
{
	Matrix<Type> matrixC;
	
    matrixC.matrix[0]  = matrix[0]  + rMatrix.matrix[0];
    matrixC.matrix[1]  = matrix[1]  + rMatrix.matrix[1];
    matrixC.matrix[2]  = matrix[2]  + rMatrix.matrix[2];
    
    matrixC.matrix[3]  = matrix[3]  + rMatrix.matrix[3];
    matrixC.matrix[4]  = matrix[4]  + rMatrix.matrix[4];
    matrixC.matrix[5]  = matrix[5]  + rMatrix.matrix[5];
    
    matrixC.matrix[6]  = matrix[6]  + rMatrix.matrix[6];
    matrixC.matrix[7]  = matrix[7]  + rMatrix.matrix[7];
    matrixC.matrix[8]  = matrix[8]  + rMatrix.matrix[8];
    
    matrixC.matrix[9]  = matrix[9]  + rMatrix.matrix[9];
    matrixC.matrix[10] = matrix[10] + rMatrix.matrix[10];
    matrixC.matrix[11] = matrix[11] + rMatrix.matrix[11];
	
	return matrixC;
} // Matrix::operator+

//------------------------------------------------------------------------------------

template <typename Type>
const Color::Matrix<Type> Color::Matrix<Type>::operator+(const Type k) const
{
	Matrix<Type> matrixB;
	
    matrixB.matrix[0]  = matrix[0]  + k;
    matrixB.matrix[1]  = matrix[1]  + k;
    matrixB.matrix[2]  = matrix[2]  + k;
    
    matrixB.matrix[3]  = matrix[3]  + k;
    matrixB.matrix[4]  = matrix[4]  + k;
    matrixB.matrix[5]  = matrix[5]  + k;
    
    matrixB.matrix[6]  = matrix[6]  + k;
    matrixB.matrix[7]  = matrix[7]  + k;
    matrixB.matrix[8]  = matrix[8]  + k;
    
    matrixB.matrix[9]  = matrix[9]  + k;
    matrixB.matrix[10] = matrix[10] + k;
    matrixB.matrix[11] = matrix[11] + k;
	
	return matrixB;
} // Matrix::operator+

//------------------------------------------------------------------------------------

template <typename Type>
const Color::Matrix<Type> Color::Matrix<Type>::operator-(const Matrix<Type> &rMatrix) const
{
	Matrix<Type> matrixC;
	
    matrixC.matrix[0]  = rMatrix.matrix[0]  - matrix[0];
    matrixC.matrix[1]  = rMatrix.matrix[1]  - matrix[1];
    matrixC.matrix[2]  = rMatrix.matrix[2]  - matrix[2];
    
    matrixC.matrix[3]  = rMatrix.matrix[3]  - matrix[3];
    matrixC.matrix[4]  = rMatrix.matrix[4]  - matrix[4];
    matrixC.matrix[5]  = rMatrix.matrix[5]  - matrix[5];
    
    matrixC.matrix[6]  = rMatrix.matrix[6]  - matrix[6];
    matrixC.matrix[7]  = rMatrix.matrix[7]  - matrix[7];
    matrixC.matrix[8]  = rMatrix.matrix[8]  - matrix[8];
    
    matrixC.matrix[9]  = rMatrix.matrix[9]  - matrix[9];
    matrixC.matrix[10] = rMatrix.matrix[10] - matrix[10];
    matrixC.matrix[11] = rMatrix.matrix[11] - matrix[11];
	
	return matrixC;
} // Matrix::operator-

//------------------------------------------------------------------------------------

template <typename Type>
const Color::Matrix<Type> Color::Matrix<Type>::operator-(const Type k ) const
{
	Matrix<Type> matrixB;
	
    matrixB.matrix[0]  = matrix[0]  - k;
    matrixB.matrix[1]  = matrix[1]  - k;
    matrixB.matrix[2]  = matrix[2]  - k;
    
    matrixB.matrix[3]  = matrix[3]  - k;
    matrixB.matrix[4]  = matrix[4]  - k;
    matrixB.matrix[5]  = matrix[5]  - k;
    
    matrixB.matrix[6]  = matrix[6]  - k;
    matrixB.matrix[7]  = matrix[7]  - k;
    matrixB.matrix[8]  = matrix[8]  - k;
    
    matrixB.matrix[9]  = matrix[9]  - k;
    matrixB.matrix[10] = matrix[10] - k;
    matrixB.matrix[11] = matrix[11] - k;
	
	return matrixB;
} // Matrix::operator-

//------------------------------------------------------------------------------------

template <typename Type>
const Color::Matrix<Type> Color::Matrix<Type>::operator*(const Type k ) const
{
	Matrix<Type> matrixB;
	
    matrixB.matrix[0]  = matrix[0]  * k;
    matrixB.matrix[1]  = matrix[1]  * k;
    matrixB.matrix[2]  = matrix[2]  * k;
    
    matrixB.matrix[3]  = matrix[3]  * k;
    matrixB.matrix[4]  = matrix[4]  * k;
    matrixB.matrix[5]  = matrix[5]  * k;
    
    matrixB.matrix[6]  = matrix[6]  * k;
    matrixB.matrix[7]  = matrix[7]  * k;
    matrixB.matrix[8]  = matrix[8]  * k;
    
    matrixB.matrix[9]  = matrix[9]  * k;
    matrixB.matrix[10] = matrix[10] * k;
    matrixB.matrix[11] = matrix[11] * k;
	
	return matrixB;
} // Matrix::operator*

//------------------------------------------------------------------------------------

template <typename Type>
const Color::Matrix<Type> Color::Matrix<Type>::operator/(const Type k ) const
{
	Matrix<Type> matrixB;
	
    const Type K = Type(1) / k;
    
    matrixB.matrix[0]  = matrix[0]  * K;
    matrixB.matrix[1]  = matrix[1]  * K;
    matrixB.matrix[2]  = matrix[2]  * K;
    
    matrixB.matrix[3]  = matrix[3]  * K;
    matrixB.matrix[4]  = matrix[4]  * K;
    matrixB.matrix[5]  = matrix[5]  * K;
    
    matrixB.matrix[6]  = matrix[6]  * K;
    matrixB.matrix[7]  = matrix[7]  * K;
    matrixB.matrix[8]  = matrix[8]  * K;
    
    matrixB.matrix[9]  = matrix[9]  * K;
    matrixB.matrix[10] = matrix[10] * K;
    matrixB.matrix[11] = matrix[11] * K;
	
	return matrixB;
} // Matrix::operator/

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type> &Color::Matrix<Type>::operator+=(const Matrix<Type> &rMatrix)
{
    matrix[0]  += rMatrix.matrix[0];
    matrix[1]  += rMatrix.matrix[1];
    matrix[2]  += rMatrix.matrix[2];
    
    matrix[3]  += rMatrix.matrix[3];
    matrix[4]  += rMatrix.matrix[4];
    matrix[5]  += rMatrix.matrix[5];
    
    matrix[6]  += rMatrix.matrix[6];
    matrix[7]  += rMatrix.matrix[7];
    matrix[8]  += rMatrix.matrix[8];
    
    matrix[9]  += rMatrix.matrix[9];
    matrix[10] += rMatrix.matrix[10];
    matrix[11] += rMatrix.matrix[11];
	
	return *this;
} // Matrix::operator+=

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type> &Color::Matrix<Type>::operator-=(const Matrix<Type> &rMatrix)
{
    matrix[0]  -= rMatrix.matrix[0];
    matrix[1]  -= rMatrix.matrix[1];
    matrix[2]  -= rMatrix.matrix[2];
    
    matrix[3]  -= rMatrix.matrix[3];
    matrix[4]  -= rMatrix.matrix[4];
    matrix[5]  -= rMatrix.matrix[5];
    
    matrix[6]  -= rMatrix.matrix[6];
    matrix[7]  -= rMatrix.matrix[7];
    matrix[8]  -= rMatrix.matrix[8];
    
    matrix[9]  -= rMatrix.matrix[9];
    matrix[10] -= rMatrix.matrix[10];
    matrix[11] -= rMatrix.matrix[11];
	
	return *this;
} // Matrix::operator-=

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type> &Color::Matrix<Type>::operator+=(const Type k)
{
    matrix[0]  += k;
    matrix[1]  += k;
    matrix[2]  += k;
    
    matrix[3]  += k;
    matrix[4]  += k;
    matrix[5]  += k;
    
    matrix[6]  += k;
    matrix[7]  += k;
    matrix[8]  += k;
    
    matrix[9]  += k;
    matrix[10] += k;
    matrix[11] += k;
	
	return *this;
} // Matrix::operator+=

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type> &Color::Matrix<Type>::operator-=(const Type k)
{
    matrix[0]  -= k;
    matrix[1]  -= k;
    matrix[2]  -= k;
    
    matrix[3]  -= k;
    matrix[4]  -= k;
    matrix[5]  -= k;
    
    matrix[6]  -= k;
    matrix[7]  -= k;
    matrix[8]  -= k;
    
    matrix[9]  -= k;
    matrix[10] -= k;
    matrix[11] -= k;
	
	return *this;
} // Matrix::operator-=

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type> &Color::Matrix<Type>::operator*=(const Type k)
{
    matrix[0]  *= k;
    matrix[1]  *= k;
    matrix[2]  *= k;
    
    matrix[3]  *= k;
    matrix[4]  *= k;
    matrix[5]  *= k;
    
    matrix[6]  *= k;
    matrix[7]  *= k;
    matrix[8]  *= k;
    
    matrix[9]  *= k;
    matrix[10] *= k;
    matrix[11] *= k;
	
	return *this;
} // Matrix::operator*=

//------------------------------------------------------------------------------------

template <typename Type>
Color::Matrix<Type> &Color::Matrix<Type>::operator/=(const Type k)
{
    const Type K = Type(1) / k;
    
    matrix[0]  *= K;
    matrix[1]  *= K;
    matrix[2]  *= K;
    
    matrix[3]  *= K;
    matrix[4]  *= K;
    matrix[5]  *= K;
    
    matrix[6]  *= K;
    matrix[7]  *= K;
    matrix[8]  *= K;
    
    matrix[9]  *= K;
    matrix[10] *= K;
    matrix[11] *= K;
	
	return *this;
} // Matrix::operator*=

//------------------------------------------------------------------------------------

template <typename Type>
Type &Color::Matrix<Type>::operator()(const long nRow, const long nColumn)
{
    static Type nError = std::numeric_limits<Type>::has_quiet_NaN ? std::numeric_limits<Type>::quiet_NaN() : Type(0);
    
    if( ( nRow < 0 ) || ( nRow > 3 ) )
    {
        std::cerr
        << std::endl
        << ">> ERROR: Core Color -  Matrix - Row index "
        << nRow
        << " is outside the row bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    if( ( nColumn < 0 ) || ( nColumn > 2 ) )
    {
        std::cerr
        << std::endl
        << ">> ERROR: Core Color -  Matrix - Column index "
        << nColumn
        << " is outside the column bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    const long k = 3 * nRow + nColumn;
    
    return matrix[k];
} // Matrix::operator()

//------------------------------------------------------------------------------------

template <typename Type>
Type Color::Matrix<Type>::operator()(const long nRow, const long nColumn) const
{
    Type nError = std::numeric_limits<Type>::has_quiet_NaN ? std::numeric_limits<Type>::quiet_NaN() : Type(0);
    
    if( ( nRow < 0 ) || ( nRow > 3 ) )
    {
        std::cerr
        << std::endl
        << ">> ERROR: Core Color -  Matrix - Row index "
        << nRow
        << " is outside the row bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    if( ( nColumn < 0 ) || ( nColumn > 2 ) )
    {
        std::cerr
        << std::endl
        << ">> ERROR: Core Color -  Matrix - Column index "
        << nColumn
        << " is outside the column bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    const long k = 3 * nRow + nColumn;
    
    return matrix[k];
} // Matrix::operator()

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//------------------------------------------------------------------------------------

template <typename Type>
void  Color::Matrix<Type>::SetMatrix(const Type * const pArray2D)
{
	if( pArray2D != NULL )
	{
        matrix[0]  = pArray2D[0];
        matrix[1]  = pArray2D[1];
        matrix[2]  = pArray2D[2];
        
        matrix[3]  = pArray2D[3];
        matrix[4]  = pArray2D[4];
        matrix[5]  = pArray2D[5];
        
        matrix[6]  = pArray2D[6];
        matrix[7]  = pArray2D[7];
        matrix[8]  = pArray2D[8];
        
        matrix[9]  = pArray2D[9];
        matrix[10] = pArray2D[10];
        matrix[11] = pArray2D[11];
	} // if
} // Matrix::SetMatrix

//------------------------------------------------------------------------------------

template <typename Type>
void  Color::Matrix<Type>::SetMatrix(const Math::Matrix3<Type> &rMatrix,
									 const Math::Vector3<Type> &rWhitePt)
{
    const Type *N = rMatrix.matrix;
    
    matrix[0]  = N[0];
    matrix[1]  = N[1];
    matrix[2]  = N[2];
    
    matrix[3]  = N[3];
    matrix[4]  = N[4];
    matrix[5]  = N[5];
    
    matrix[6]  = N[6];
    matrix[7]  = N[7];
    matrix[8]  = N[8];
    
    matrix[9]  = rWhitePt.x;
    matrix[10] = rWhitePt.y;
    matrix[11] = rWhitePt.z;
} // Constructor

//------------------------------------------------------------------------------------

template <typename Type>
void  Color::Matrix<Type>::SetMatrix(const Math::Vector3<Type> &rRed,
									 const Math::Vector3<Type> &rGreen,
									 const Math::Vector3<Type> &rBlue,
									 const Math::Vector3<Type> &rWhitePt)
{
    matrix[0] = rRed.x;
    matrix[1] = rRed.y;
    matrix[2] = rRed.z;
    
    matrix[3] = rGreen.x;
    matrix[4] = rGreen.y;
    matrix[5] = rGreen.z;
    
    matrix[6] = rBlue.x;
    matrix[7] = rBlue.y;
    matrix[8] = rBlue.z;
    
    matrix[9]  = rWhitePt.x;
    matrix[10] = rWhitePt.y;
    matrix[11] = rWhitePt.z;
} // Constructor

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Template Implementations

//------------------------------------------------------------------------------------

template class Color::Matrix<float>;
template class Color::Matrix<double>;

//------------------------------------------------------------------------------------

//------------------------------------------------------------------------------------
