/*
     File: CWorkingSpace.cpp
 Abstract: 
 RGB working space specifications.
 
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

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#include <iostream>
#include <limits>

//---------------------------------------------------------------------------

#include "CEnums.h"

#include "CWorkingSpace.h"

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::WorkingSpace<Type>::WorkingSpace(const size_t nType)
{
    switch(nType)
    {
        case Color::Standard::kApple:
        {
            //---------------------------------------------------------------------------
            //
            // Generic Apple coordinates for red, green, and blue primaries, as well
            // D65 reference white point.
            //
            //---------------------------------------------------------------------------
            
            M[0] = Type(0.625);
            M[1] = Type(0.34);
            
            M[2] = Type(0.28);
            M[3] = Type(0.595);
            
            M[4] = Type(0.155);
            M[5] = Type(0.07);
            
            M[6] = Type(0.312713);
            M[7] = Type(0.329016);
            
            break;
        } // Apple
            
        case Color::Standard::kSMPTEC:
        {
            //---------------------------------------------------------------------------
            //
            // SMPTE-C is the current colour standard for broadcasting in America,
            // the old NTSC standard for primaries is no longer in wide use because
            // the primaries of the system have gradually shifted towards those of
            // the EBU (see section 6.2). In all other respects, SMPTE-C is the
            // same as NTSC.
            //
            // SMPTE-C coordinates for red, green, and blue primaries, as well D65
            // reference white point.
            //
            //---------------------------------------------------------------------------
            
            M[0] = Type(0.63);
            M[1] = Type(0.34);
            
            M[2] = Type(0.31);
            M[3] = Type(0.595);
            
            M[4] = Type(0.155);
            M[5] = Type(0.07);
            
            M[6] = Type(0.312713);
            M[7] = Type(0.329016);
            
            break;
        } // SMPTE-C
            
        case Color::Standard::ksRGB:
        {
            //---------------------------------------------------------------------------
            //
            // sRGB coordinates for red, green, and blue primaries, as well D65
            // reference white point.
            //
            //---------------------------------------------------------------------------
            
            M[0] = Type(0.64);
            M[1] = Type(0.33);
            
            M[2] = Type(0.30);
            M[3] = Type(0.60);
            
            M[4] = Type(0.15);
            M[5] = Type(0.06);
            
            M[6] = Type(0.312713);
            M[7] = Type(0.329016);
            
            break;
        } // sRGB
            
        case Color::Standard::kRec709:
        default:
        {
            //---------------------------------------------------------------------------
            //
            // CCIR/ITU-R BT/CIE Rec 709-5 (HDTV).
            //
            //---------------------------------------------------------------------------
            //
            // Rec 709 does not specify a gamma for the output device. Only the gamma
            // of the input device (0.45) is given. Typical CRTs have a gamma value
            // of 2.5, which yields an overall gamma of 1.125, within the 1.1 to 1.2
            // range usually used with the dim viewing environment assumed for
            // television.
            //
            //---------------------------------------------------------------------------
            
            //---------------------------------------------------------------------------
            //
            // Rec 709 coordinates for red, green, and blue primaries, as well D65
            // reference white point.
            //
            //---------------------------------------------------------------------------
            
            M[0] = Type(0.64);
            M[1] = Type(0.33);
            
            M[2] = Type(0.30);
            M[3] = Type(0.60);
            
            M[4] = Type(0.15);
            M[5] = Type(0.06);
            
            M[6] = Type(0.312713);
            M[7] = Type(0.329016);
            
            break;
        } // Rec 709
    } // switch
} // Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

template <typename Type>
Type &Color::WorkingSpace<Type>::operator()(const long nRow, const long nColumn)
{
    static Type nError = std::numeric_limits<Type>::has_quiet_NaN ? std::numeric_limits<Type>::quiet_NaN() : Type(0);
    
    if( ( nRow < 0 ) || ( nRow > 3 ) )
    {
        std::cerr
        << std::endl
        << ">> ERROR: Core Color - Working Space - WorkingSpace - Row index "
        << nRow
        << " is outside the row bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    if( ( nColumn < 0 ) || ( nColumn > 1 ) )
    {
        std::cerr
        << std::endl
        << ">> ERROR: Core Color - Working Space - WorkingSpace - Column index "
        << nColumn
        << " is outside the column bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    const long k = 2 * nRow + nColumn;
    
    return M[k];
} // WorkingSpace::operator()

//---------------------------------------------------------------------------

template <typename Type>
Type Color::WorkingSpace<Type>::operator()(const long nRow, const long nColumn) const
{
    Type nError = std::numeric_limits<Type>::has_quiet_NaN ? std::numeric_limits<Type>::quiet_NaN() : Type(0);
    
    if( ( nRow < 0 ) || ( nRow > 3 ) )
    {
        std::cerr
        << std::endl
        << ">> ERROR: Core Color - Working Space - WorkingSpace - Row index "
        << nRow
        << " is outside the row bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    if( ( nColumn < 0 ) || ( nColumn > 1 ) )
    {
        std::cerr
        << std::endl
        << ">> ERROR: Core Color - Working Space - WorkingSpace - Column index "
        << nColumn
        << " is outside the column bounds of this matrix!"
        << std::endl;
        
        return nError;
    } // if
    
    const long k = 2 * nRow + nColumn;
    
    return M[k];
} // WorkingSpace::operator()

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Destructor

//---------------------------------------------------------------------------

template <typename Type>
Color::WorkingSpace<Type>::~WorkingSpace()
{
    std::memset(M, 0x0, 8 * sizeof(Type));
} // Destructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Copy Constructors

//---------------------------------------------------------------------------

template <typename Type>
Color::WorkingSpace<Type>::WorkingSpace(const WorkingSpace<Type> &rWorkingSpace)
{
    std::memcpy(M, rWorkingSpace.M, 8 * sizeof(Type));
} // Copy Constructor

//---------------------------------------------------------------------------

template <typename Type>
Color::WorkingSpace<Type>::WorkingSpace( const WorkingSpace<Type> * const pWorkingSpace )
{
    if( pWorkingSpace != NULL )
    {
        std::memcpy(M, pWorkingSpace->M, 8 * sizeof(Type));
    } // if
} // Copy Constructor

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Assignment Operator

//---------------------------------------------------------------------------

template <typename Type>
Color::WorkingSpace<Type> &Color::WorkingSpace<Type>::operator=(const WorkingSpace<Type> &rWorkingSpace)
{
	if( this != &rWorkingSpace )
	{
        std::memcpy(M, rWorkingSpace.M, 8 * sizeof(Type));
	} // if
	
	return *this;
} // Assignment Operator

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Accessors

//---------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Color::WorkingSpace<Type>::GetWorkingSpaceRed() const
{
    return Math::Vector2<Type>(M[0], M[1]);
} // GetWorkingSpaceRed

//---------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Color::WorkingSpace<Type>::GetWorkingSpaceGreen() const
{
    return Math::Vector2<Type>(M[2], M[3]);
} // GetWorkingSpaceGreen

//---------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Color::WorkingSpace<Type>::GetWorkingSpaceBlue() const
{
    return Math::Vector2<Type>(M[4], M[5]);
} // GetWorkingSpaceBlue

//---------------------------------------------------------------------------

template <typename Type>
const Math::Vector2<Type> Color::WorkingSpace<Type>::GetWorkingSpaceWhitePoint() const
{
    return Math::Vector2<Type>(M[6], M[7]);
} // GetWorkingSpaceWhitePoint

//---------------------------------------------------------------------------

template <typename Type>
const Type *Color::WorkingSpace<Type>::GetWorkingSpace() const
{
	return( &M[0] );
} // GetWorkingSpace

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

#pragma mark -
#pragma mark Public - Implementations - Template

//---------------------------------------------------------------------------

template class Color::WorkingSpace<float>;
template class Color::WorkingSpace<double>;

//---------------------------------------------------------------------------

//---------------------------------------------------------------------------

